import os
import json
import concurrent.futures
from threading import Lock
from rich.console import Console
from rich.progress import Progress
from rich.traceback import install
from rich.logging import RichHandler
import logging
from patterns import patterns  # Patterns from patterns.py
from labeler import label_vulnerabilities  # Vulnerability labeling logic from labeler.py

# Set up rich console and traceback handling
console = Console()
install(show_locals=True)
logging.basicConfig(
    level="DEBUG", 
    format="%(message)s",
    handlers=[RichHandler(show_path=False, markup=True, rich_tracebacks=True)]
)
log = logging.getLogger("rich")

# Initialize locks
io_lock = Lock()     # For file I/O operations
log_lock = Lock()    # For logging output
data_lock = Lock()   # For accessing shared data structures (like tokenized_data or labeled_data)

def write_json_entry(output_file, data_entry, first_entry=False):
    """
    Appends a single entry to a JSON file.

    Args:
        output_file (str): The file to append to.
        data_entry (dict): The labeled data entry to append.
        first_entry (bool): Whether this is the first entry (to handle starting the JSON array).
    """
    try:
        with io_lock:
            with open(output_file, 'a') as json_file:
                if first_entry:
                    json_file.write("[\n")  # Start the JSON array
                else:
                    json_file.write(",\n")  # Comma to separate entries
                json.dump(data_entry, json_file, indent=4)  # Write the entry
    except Exception as e:
        with log_lock:
            console.print_exception(show_locals=True)
            log.error(f"Error saving labeled data entry: {e}")

def close_json_file(output_file):
    """
    Closes the JSON array structure by writing the closing bracket.

    Args:
        output_file (str): The file to close.
    """
    try:
        with io_lock:
            with open(output_file, 'a') as json_file:
                json_file.write("\n]")  # Close the JSON array
    except Exception as e:
        with log_lock:
            console.print_exception(show_locals=True)
            log.error(f"Error closing JSON file: {e}")

def load_token_file(file_path):
    """
    Loads a single token file with thread safety using an I/O lock.
    
    Args:
        file_path (str): The path to the .tokens file.

    Returns:
        dict: A dictionary containing the file path and tokenized content.
    """
    try:
        with io_lock:  # Ensure only one thread is reading a file at a time
            with open(file_path, 'r') as token_file:
                token_content = token_file.read()
        return {
            "file_path": file_path,
            "token_content": token_content
        }
    except Exception as e:
        with log_lock:
            console.print_exception(show_locals=True)
            log.error(f"Error processing file {file_path}: {e}")
        return None


def load_tokenized_data_in_parallel(directory, batch_size=100):
    """
    Loads tokenized data from the output_tokens directory using parallel processing.

    Args:
        directory (str): The root directory containing tokenized Solidity files.
        batch_size (int): Number of files to process in each batch.

    Returns:
        list: A list of dictionaries, where each dictionary contains the file path and its tokenized content.
    """
    tokenized_data = []
    try:
        if not os.path.exists(directory):
            console.print(f"[red]Error:[/red] The directory '{directory}' does not exist.")
            return []

        # Get all .tokens file paths
        file_paths = []
        for folder_name in sorted(os.listdir(directory)):
            folder_path = os.path.join(directory, folder_name)
            if os.path.isdir(folder_path):
                for file_name in os.listdir(folder_path):
                    if file_name.endswith(".tokens"):
                        file_paths.append(os.path.join(folder_path, file_name))

        total_files = len(file_paths)
        console.print(f"[green]Found {total_files} .tokens files to process.[/green]")

        with Progress(console=console) as progress:
            task = progress.add_task("[cyan]Processing token files...", total=total_files)

            # Process in parallel using a ThreadPoolExecutor
            with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
                for batch_start in range(0, total_files, batch_size):
                    batch_files = file_paths[batch_start:batch_start + batch_size]

                    futures = {executor.submit(load_token_file, file): file for file in batch_files}

                    for future in concurrent.futures.as_completed(futures):
                        result = future.result()
                        if result:
                            with data_lock:
                                tokenized_data.append(result)
                        progress.update(task, advance=1)

        console.print(f"[green]Successfully processed {total_files} .tokens files.[/green]")

    except Exception as e:
        with log_lock:
            console.print_exception(show_locals=True)
            log.error(f"An error occurred: {e}")

    return tokenized_data


def apply_patterns_and_label_data_in_parallel(tokenized_data, output_file):
    """
    Applies vulnerability patterns and labels the tokenized data using parallel processing.
    Saves each labeled entry to a JSON file immediately after labeling.

    Args:
        tokenized_data (list): A list of dictionaries with 'file_path' and 'token_content' keys.
        output_file (str): The file to save labeled data entries to.
    """
    first_entry = True

    def label_data(data):
        file_path = data['file_path']
        token_content = data['token_content']
        try:
            labels = label_vulnerabilities(token_content, patterns)
            return {
                "file_path": file_path,
                "labels": labels
            }
        except Exception as e:
            with log_lock:
                console.print_exception(show_locals=True)
                log.error(f"Error labeling file {file_path}: {e}")
            return None

    total_files = len(tokenized_data)
    with Progress(console=console) as progress:
        task = progress.add_task("[cyan]Labeling vulnerabilities...", total=total_files)

        # Process in parallel using a ThreadPoolExecutor
        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
            futures = {executor.submit(label_data, data): data for data in tokenized_data}

            for future in concurrent.futures.as_completed(futures):
                result = future.result()
                if result:
                    with data_lock:
                        write_json_entry(output_file, result, first_entry=first_entry)
                        first_entry = False  # Only the first entry should start with `[`
                progress.update(task, advance=1)

    # Close the JSON array after all files are processed
    close_json_file(output_file)
    console.print("[green]Vulnerability labeling completed.[/green]")


# Example usage:
token_directory_path = "./output_tokens"
output_json_path = "labeled_data.json"

# Step 1: Load the tokenized data in parallel
tokenized_data = load_tokenized_data_in_parallel(token_directory_path, batch_size=50)

# Step 2: Apply patterns and label the data in parallel and save each entry after labeling
apply_patterns_and_label_data_in_parallel(tokenized_data, output_json_path)

log.debug(tokenized_data[:5])  # Debug output for verification
