from antlr4 import FileStream, CommonTokenStream
from SolidityLexer import SolidityLexer
import logging

log = logging.getLogger("rich")

def tokenize_solidity_file(file_path):
    try:
        input_stream = FileStream(file_path, encoding='utf-8')
        lexer = SolidityLexer(input_stream)
        for token in lexer.getAllTokens():
            yield str(token)
    except Exception as e:
        log.exception(f"Error tokenizing file {file_path}")
        raise
