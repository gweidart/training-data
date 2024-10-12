# utils.py

import json
import os
import threading
from typing import Any
from logging_config import get_logger

logger = get_logger(__name__)
file_lock = threading.Lock()


def write_jsonl_line(file_path: str, data: Any):
    """
    Writes a single JSON object as a line to a JSON Lines file.

    Args:
        file_path (str): The path to the JSON Lines file.
        data (Any): The data to write (must be JSON serializable).
    """
    try:
        # Ensure the output directory exists
        os.makedirs(os.path.dirname(file_path), exist_ok=True)

        with file_lock:
            with open(file_path, "a", encoding="utf-8") as f:
                json_line = json.dumps(data)
                f.write(
                    json_line + "\n"
                )  # Open the file in append mode and write the JSON line
    except Exception as e:
        logger.error(f"Error writing writing to {file_path}: {e}", exc_info=True)


def read_jsonl_file(file_path: str) -> list:
    """
    Reads a JSON Lines file and returns a list of JSON objects.

    Args:
        file_path (str): The path to the JSON Lines file.

    Returns:
        list: A list of JSON objects read from the file.
    """
    results = []
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue  # Skip empty lines
                try:
                    result = json.loads(line)
                    results.append(result)
                except json.JSONDecodeError as e:
                    logger.error(f"Error decoding JSON line: {e}")
    except FileNotFoundError:
        logger.warning(f"File not found: {file_path}")
    except Exception as e:
        logger.error(f"Error reading {file_path}: {e}", exc_info=True)
    return results
