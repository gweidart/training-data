# logging_config.py

import logging
from rich.logging import RichHandler
from rich.console import Console
from rich.theme import Theme
from rich.traceback import install as install_rich_traceback
from typing import Optional

# Custom theme for log levels
custom_theme = Theme({
    "logging.level.debug": "dim cyan",
    "logging.level.info": "green",
    "logging.level.warning": "yellow",
    "logging.level.error": "bold red",
    "logging.level.critical": "bold red reverse",
})

# Initialize the Rich console with the custom theme
console = Console(theme=custom_theme)

def setup_logging(
    level: int = logging.INFO,
    log_to_file: bool = False,
    log_file_path: str = "app.log",
    file_log_level: int = logging.DEBUG,
    rich_tracebacks: bool = True,
    show_time: bool = True,
    show_level: bool = True,
    show_path: bool = False,
    enable_markup: bool = True,
):
    """
    Sets up the logging configuration for the application using Rich.

    Args:
        level (int): The logging level for the console handler.
        log_to_file (bool): Whether to log messages to a file.
        log_file_path (str): The file path for the log file.
        file_log_level (int): The logging level for the file handler.
        rich_tracebacks (bool): Whether to use Rich tracebacks for exceptions.
        show_time (bool): Whether to display time in the console logs.
        show_level (bool): Whether to display the log level in the console logs.
        show_path (bool): Whether to display the file path in the console logs.
        enable_markup (bool): Whether to enable Rich markup in logs.
    """
    # Install Rich traceback handler if enabled
    if rich_tracebacks:
        install_rich_traceback(show_locals=True, console=console)

    # Define the format for the log messages
    FORMAT = "%(message)s"

    # Create the console handler with Rich
    console_handler = RichHandler(
        console=console,
        show_time=show_time,
        show_level=show_level,
        show_path=show_path,
        markup=enable_markup,
        rich_tracebacks=rich_tracebacks,
    )

    # List of handlers
    handlers = [console_handler]

    # Optionally add file handler
    if log_to_file:
        file_handler = logging.FileHandler(log_file_path)
        file_handler.setLevel(file_log_level)
        # Define file log format
        formatter = logging.Formatter(
            fmt="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
            datefmt="%Y-%m-%d %H:%M:%S",
        )
        file_handler.setFormatter(formatter)
        handlers.append(file_handler)

    # Basic configuration for logging
    logging.basicConfig(
        level=level,
        format=FORMAT,
        datefmt="[%X]",
        handlers=handlers,
    )

def get_logger(name: Optional[str] = None) -> logging.Logger:
    """
    Gets a logger with the specified name.

    Args:
        name (str): The name of the logger (usually __name__). If None, returns the root logger.

    Returns:
        logging.Logger: The configured logger instance.
    """
    return logging.getLogger(name)
