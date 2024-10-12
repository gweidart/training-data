# main.py

import os
import argparse
from typing import Dict
from logging_config import setup_logging, get_logger, console
from reentrancy_detector import detect_reentrancy_in_contract
from utils import write_jsonl_line
from rich.progress import Progress  # type: ignore

# Parse command-line arguments
parser = argparse.ArgumentParser(description="Reentrancy Vulnerability Detector")
parser.add_argument(
    "-i", "--input", required=True, help="Input directory containing Solidity files"
)
parser.add_argument(
    "-o", "--output", default="labeled_contracts.json", help="Output JSON file"
)
parser.add_argument("--ast-output-dir", help="Directory to save the AST files.")
parser.add_argument(
    "-l",
    "--loglevel",
    default="INFO",
    help="Logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL)",
)
parser.add_argument("--logfile", action="store_true", help="Enable logging to a file")
parser.add_argument("--logfilepath", default="app.log", help="Path to the log file")
parser.add_argument(
    "--rich-tracebacks",
    action="store_true",
    help="Enable rich tracebacks for exceptions",
)
args = parser.parse_args()

# Set up logging
import logging

log_level = getattr(logging, args.loglevel.upper(), logging.INFO)
setup_logging(
    level=log_level,
    log_to_file=args.logfile,
    log_file_path=args.logfilepath,
    rich_tracebacks=args.rich_tracebacks,
    show_time=True,
    show_level=True,
    show_path=False,
    enable_markup=True,
)
logger = get_logger(__name__)

if __name__ == "__main__":
    input_directory = args.input
    output_file = args.output

    if not os.path.isdir(input_directory):
        logger.error(f"The input directory '{input_directory}' does not exist.")
        exit(1)

    try:
        results = []

        # Set up a progress bar using the same console
        with Progress(console=console) as progress:
            task_id = progress.add_task("[green]Analyzing contracts...", total=0)

            # Collect all Solidity files
            solidity_files = []
            for dirpath, _, filenames in os.walk(input_directory):
                for filename in filenames:
                    if filename.endswith(".sol"):
                        solidity_files.append(os.path.join(dirpath, filename))

            total_files = len(solidity_files)
            progress.update(task_id, total=total_files)

            if total_files == 0:
                logger.warning(
                    f"No Solidity files found in directory {input_directory}."
                )
            else:
                # Process each Solidity file
                for file_path in solidity_files:
                    contract_name = os.path.basename(file_path)
                    progress.console.log(
                        f"Processing [bold cyan]{contract_name}[/bold cyan]"
                    )
                    reentrancy_detected = detect_reentrancy_in_contract(file_path)
                    results.append(
                        {
                            "contract_name": contract_name,
                            "reentrancy": reentrancy_detected,
                        }
                    )
                    progress.update(task_id, advance=1)

        # Save the results
        write_jsonl_line(output_file, results)
    except Exception as e:
        logger.error(f"An unexpected error occurred: {e}", exc_info=True)
