import os
import re
import json
import logging
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import List, Dict
from rich.progress import Progress, BarColumn, TimeRemainingColumn
from rich.console import Console
from rich.logging import RichHandler

# Set up logging with Rich
console = Console()
logging.basicConfig(
    level="DEBUG",
    format="%(message)s",
    datefmt="[%X]",
    handlers=[RichHandler(show_path=False, markup=True, rich_tracebacks=True)]
)
logger = logging.getLogger("rich")

# Define the SolidityTokenMap class
class SolidityTokenMap:
    def __init__(self, token_file_path: str):
        self.token_type_map = self._load_token_types(token_file_path)
    
    def _load_token_types(self, token_file_path: str) -> Dict[str, int]:
        """
        Load the Solidity.tokens file into a dictionary mapping token names to their IDs.
        """
        token_type_map = {}
        try:
            with open(token_file_path, "r") as f:
                for line in f:
                    line = line.strip()

                    if not line or line.startswith('//'):
                        continue

                    if line.startswith("'"):
                        name, value = line.rsplit('=', 1)
                        name = name.strip()
                        value = value.strip()
                        try:
                            token_type_map[name] = int(value)
                        except ValueError:
                            logger.error(f"Invalid token value for {name}: {value}")
                    else:
                        parts = line.split('=', 1)
                        if len(parts) == 2:
                            name, value = parts
                            name = name.strip()
                            value = value.strip()
                            try:
                                token_type_map[name] = int(value)
                            except ValueError:
                                logger.error(f"Invalid token value for {name}: {value}")
                        else:
                            logger.error(f"Unexpected format in Solidity.tokens line: {line}")
            logger.info("Loaded Solidity token types successfully.")
        except FileNotFoundError:
            logger.error(f"Solidity.tokens file not found at: {token_file_path}")
            raise
        except Exception as e:
            logger.error(f"Error loading Solidity.tokens file: {e}")
            raise
        return token_type_map

# Define the Token class
class Token:
    def __init__(self, token_id: int, token_value: str, token_type: int, line: int, col: int):
        self.token_id = token_id
        self.token_value = token_value
        self.token_type = token_type
        self.line = line
        self.col = col

    def __repr__(self):
        return f"Token(id={self.token_id}, value={self.token_value}, type={self.token_type}, line={self.line}, col={self.col})"

# Define the TokenParser class
class TokenParser:
    TOKEN_REGEX = re.compile(
        r"\[@(?P<id>-?\d+),(?P<start>\d+):(?P<end>\d+)='(?P<value>[^']*)',<(?P<type>\d+)>,(?P<line>\d+):(?P<col>\d+)]"
    )

    def __init__(self, token_type_map: Dict[str, int]):
        self.token_type_map = token_type_map

    def parse_tokens(self, token_data: str) -> List[Token]:
        tokens = []
        for match in self.TOKEN_REGEX.finditer(token_data):
            token = Token(
                token_id=int(match.group("id")),
                token_value=match.group("value"),
                token_type=int(match.group("type")),
                line=int(match.group("line")),
                col=int(match.group("col")),
            )
            tokens.append(token)
        return tokens

# Define the AbstractState class
class AbstractState:
    def __init__(self):
        self._send_eth: Dict[int, set] = defaultdict(set)
        self._calls: Dict[int, set] = defaultdict(set)
        self._written: Dict[int, set] = defaultdict(set)

    def merge_states(self, other: 'AbstractState'):
        self._send_eth.update(other._send_eth)
        self._calls.update(other._calls)
        self._written.update(other._written)

    def analyze_node(self, token: Token, token_type_map: Dict[str, int]):
        if token.token_type in {
            token_type_map.get('CALL'),
            token_type_map.get('DELEGATECALL'),
            token_type_map.get('STATICCALL')
        }:
            self._calls[token.token_id].add(token.token_id)

        if token.token_type in {
            token_type_map.get('SEND'),
            token_type_map.get('TRANSFER'),
            token_type_map.get('CALL')
        }:
            self._send_eth[token.token_id].add(token.token_id)

        if token.token_type in {
            token_type_map.get('ASSIGN'),
            token_type_map.get('PLUS'),
            token_type_map.get('MINUS')
        }:
            self._written[token.token_id].add(token.token_id)

# Define the ReentrancyDetector class
class ReentrancyDetector:
    def __init__(self, token_type_map: Dict[str, int]):
        self.token_type_map = token_type_map

    def detect_reentrancy(self, tokens: List[Token]) -> bool:
        state = AbstractState()
        for token in tokens:
            state.analyze_node(token, self.token_type_map)
        return self._is_reentrancy_detected(state)
    
    def _is_reentrancy_detected(self, state: AbstractState) -> bool:
        for call in state._calls:
            if call in state._written:
                logger.debug(f"Reentrancy detected: Call ID {call} leads to state modification.")
                return True
        
        for send in state._send_eth:
            if send in state._written:
                logger.debug(f"Reentrancy detected: Ether send ID {send} leads to state modification.")
                return True

        return False

# Function to process a chunk of contracts
def process_contract_chunk(
    contract_chunk: List[Dict],
    token_type_map: Dict[str, int],
    progress: Progress,
    task_id: int
) -> List[Dict]:
    detector = ReentrancyDetector(token_type_map)
    labeled_contracts = []
    
    for contract in contract_chunk:
        label = {'contract_name': contract['contract_name'], 'reentrancy': False}
        
        if detector.detect_reentrancy(contract['tokens']):
            label['reentrancy'] = True
            
        labeled_contracts.append(label)
        
        # Update progress by 1
        if progress:
            progress.update(task_id, advance=1)
        
    return labeled_contracts

# Function to chunk data
def chunk_data(data: List[Dict], chunk_size: int) -> List[List[Dict]]:
    return [data[i:i + chunk_size] for i in range(0, len(data), chunk_size)]

# Function to load tokenized data with progress
def load_tokenized_data(
    root_directory: str,
    token_parser: TokenParser,
    progress: Progress,
    task_id: int
) -> List[Dict]:
    data = []
    try:
        # Get all .tokens files
        tokens_files = []
        for dirpath, _, filenames in os.walk(root_directory):
            for filename in filenames:
                if filename.endswith(".tokens"):
                    tokens_files.append(os.path.join(dirpath, filename))
        
        total_files = len(tokens_files)
        progress.update(task_id, total=total_files)
        
        for file_path in tokens_files:
            contract_name = os.path.basename(file_path).replace('.tokens', '')
            with open(file_path, 'r') as file:
                raw_data = file.read()
                tokens = token_parser.parse_tokens(raw_data)
                data.append({
                    'contract_name': contract_name,
                    'tokens': tokens
                })
            progress.update(task_id, advance=1)
    except Exception as e:
        logger.error(f"Unexpected error loading .tokens data: {e}")
        raise
    return data

# Function to save labeled data
def save_labeled_data(output_file: str, labeled_contracts: List[Dict]) -> None:
    try:
        with open(output_file, "w") as outfile:
            json.dump(labeled_contracts, outfile, indent=4)
        logger.info(f"Labeled data successfully saved to {output_file}.")
    except IOError as e:
        logger.error(f"IO error while saving labeled data: {e}")
        raise
    except Exception as e:
        logger.error(f"Unexpected error saving labeled data: {e}")
        raise

# Function to run threaded reentrancy detection
def run_threaded_reentrancy_detection(
    data: List[Dict],
    token_type_map: Dict[str, int],
    output_file: str,
    num_workers: int = 2
):
    chunk_size = max(1, len(data) // num_workers)
    data_chunks = chunk_data(data, chunk_size)
    results = []

    logger.debug(f"Starting reentrancy detection with {num_workers} threads and chunk size {chunk_size}.")

    with Progress(console=console) as progress:
        task_id = progress.add_task("[green]Processing contracts...", total=len(data))

        # Pass the progress object to the worker functions
        with ThreadPoolExecutor(max_workers=num_workers) as executor:
            futures = []
            for chunk in data_chunks:
                # Submit the task with progress and task_id
                futures.append(
                    executor.submit(process_contract_chunk, chunk, token_type_map, progress, task_id)
                )

            for future in as_completed(futures):
                result = future.result()
                results.extend(result)

    logger.debug(f"Detection complete. Saving results to {output_file}.")

    save_labeled_data(output_file, results)

    logger.info(f"Results successfully saved to {output_file}.")

# Main execution block
if __name__ == "__main__":
    input_directory = 'datast'
    output_file = 'labeled_tokens.json'
    solidity_token_file = 'Solidity.tokens'

    try:
        with Progress(console=console) as progress:
            # Token map loading task
            token_loading_task = progress.add_task("[cyan]Loading token map...", total=1)
            token_map = SolidityTokenMap(solidity_token_file).token_type_map
            progress.update(token_loading_task, advance=1)

            # File loading task
            loading_task_id = progress.add_task("[cyan]Loading tokenized data...", total=0)
            # The total will be set inside the function
            token_parser = TokenParser(token_map)
            tokenized_data = load_tokenized_data(input_directory, token_parser, progress, loading_task_id)
            logger.info(f"Successfully loaded tokenized data from {input_directory} and its subfolders.")

        # Run the detection with progress tracking
        run_threaded_reentrancy_detection(tokenized_data, token_map, output_file, num_workers=2)

    except Exception as e:
        logger.error(f"An unexpected error occurred during the process: {e}")
