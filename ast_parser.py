# ast_parser.py

from antlr4 import *
from solidity_parser.SolidityLexer import SolidityLexer
from solidity_parser.SolidityParser import SolidityParser
from typing import Optional, Tuple
from logging_config import get_logger

logger = get_logger(__name__)


def parse_solidity_file(file_path: str) -> Optional[ParserRuleContext]:
    """
    Parses a Solidity source file and returns the AST.

    Args:
        file_path (str): The path to the Solidity (.sol) file.

    Returns:
        ParserRuleContext: The root of the parse tree (AST) or None if parsing fails.
    """
    try:
        # Read the Solidity source code
        with open(file_path, "r", encoding="utf-8") as file:
            input_stream = InputStream(file.read())

        # Create a lexer and parser
        lexer = SolidityLexer(input_stream)
        stream = CommonTokenStream(lexer)
        parser = SolidityParser(stream)

        # Parse the source code to get the parse tree (AST)
        tree = parser.sourceUnit()

        return tree, parser
    except FileNotFoundError:
        logger.error(f"File not found: {file_path}")
        return None
    except Exception as e:
        logger.error(f"Error parsing {file_path}: {e}", exc_info=True)
        return None
