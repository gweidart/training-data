# reentrancy_detector.py

import os
from antlr4 import *  # type: ignore
from solidity_parser.SolidityVisitor import SolidityVisitor
from solidity_parser.SolidityParser import SolidityParser
from typing import Optional, Tuple
from ast_parser import parse_solidity_file
from logging_config import get_logger

logger = get_logger(__name__)


class ReentrancyDetectorVisitor(SolidityVisitor):
    def __init__(self):
        super().__init__()
        self.state_variables = set()
        self.modifiers = {}
        self.contracts = {}
        self.current_contract_name = ""
        self.current_function_name = ""
        self.reentrancy_detected = False
        self.in_function = False
        self.external_call_made_stack = [False]
        self.state_variable_modified_stack = [False]
        self.visited_contracts = set()

    # Visit contract definitions to collect state variables and handle inheritance
    def visitContractDefinition(self, ctx: SolidityParser.ContractDefinitionContext):
        contract_name = ctx.identifier().getText()
        if contract_name in self.visited_contracts:
            return None  # Prevent infinite recursion
        self.visited_contracts.add(contract_name)
        self.current_contract_name = contract_name
        self.contracts[contract_name] = ctx
        logger.debug(f"Visiting contract '{contract_name}'")

        # Handle inheritance
        if ctx.inheritanceSpecifier():
            for inheritance in ctx.inheritanceSpecifier():
                base_contract_name = inheritance.userDefinedTypeName().getText()
                if base_contract_name in self.contracts:
                    base_contract_ctx = self.contracts[base_contract_name]
                    # Visit base contract to collect its state variables and modifiers
                    self.visit(base_contract_ctx)
                else:
                    logger.warning(f"Base contract '{base_contract_name}' not found.")
                    # Optionally, parse and visit the base contract if available

        # Collect state variables and modifiers
        for part in ctx.contractPart():
            if isinstance(part, SolidityParser.StateVariableDeclarationContext):
                var_name = part.identifier().getText()
                self.state_variables.add(var_name)
                logger.debug(
                    f"Collected state variable '{var_name}' in contract '{contract_name}'"
                )
            elif isinstance(part, SolidityParser.ModifierDefinitionContext):
                modifier_name = part.identifier().getText()
                self.modifiers[modifier_name] = part.block()
                logger.debug(
                    f"Collected modifier '{modifier_name}' in contract '{contract_name}'"
                )
            elif isinstance(part, SolidityParser.FunctionDefinitionContext):
                self.visit(part)  # Visit function definitions
        return None  # Do not visit children again

    # Visit function definitions and analyze for reentrancy
    def visitFunctionDefinition(self, ctx: SolidityParser.FunctionDefinitionContext):
        self.in_function = True
        self.external_call_made_stack = [False]
        self.state_variable_modified_stack = [False]

        # Get the function name
        self.current_function_name = (
            ctx.identifier().getText() if ctx.identifier() else "<anonymous>"
        )
        logger.debug(f"Analyzing function '{self.current_function_name}'")

        # Visit modifiers
        if ctx.functionModifiers():
            for modifier in ctx.functionModifiers():
                invocation = (
                    modifier.modifierInvocation()
                )  # This is a single ModifierInvocationContext
                if invocation:  # Ensure the invocation is not None
                    modifier_name = (
                        invocation.identifier().getText()
                    )  # Use identifier() to access the modifier's name
                    if modifier_name in self.modifiers:
                        logger.debug(
                            f"Applying modifier '{modifier_name}' in function '{self.current_function_name}'"
                        )
                        self.visit(self.modifiers[modifier_name])

        # Visit the function body
        if ctx.block():
            self.visit(ctx.block())

        # Check if reentrancy detected in this function
        if self.external_call_made_stack[-1] and self.state_variable_modified_stack[-1]:
            self.reentrancy_detected = True
            logger.info(
                f"Reentrancy detected in function '{self.current_function_name}'"
            )

        self.in_function = False
        return None  # Do not visit children again

    # Helper methods to manage the context stack for control flow
    def push_context(self):
        self.external_call_made_stack.append(self.external_call_made_stack[-1])
        self.state_variable_modified_stack.append(
            self.state_variable_modified_stack[-1]
        )

    def pop_context(self):
        self.external_call_made_stack.pop()
        self.state_variable_modified_stack.pop()

    # Visit statements to handle control flow
    def visitIfStatement(self, ctx: SolidityParser.IfStatementContext):
        logger.debug("Entering IfStatement")
        self.push_context()
        # Visit the 'true' branch
        self.visit(ctx.statement(0))
        true_external_call_made = self.external_call_made_stack[-1]
        true_state_var_modified = self.state_variable_modified_stack[-1]
        self.pop_context()

        else_external_call_made = False
        else_state_var_modified = False

        if ctx.ELSE():
            self.push_context()
            self.visit(ctx.statement(1))
            else_external_call_made = self.external_call_made_stack[-1]
            else_state_var_modified = self.state_variable_modified_stack[-1]
            self.pop_context()

        # Combine the results from both branches
        self.external_call_made_stack[-1] = (
            true_external_call_made or else_external_call_made
        )
        self.state_variable_modified_stack[-1] = (
            true_state_var_modified or else_state_var_modified
        )
        logger.debug("Exiting IfStatement")
        return None

    def visitWhileStatement(self, ctx: SolidityParser.WhileStatementContext):
        logger.debug("Entering WhileStatement")
        self.push_context()
        self.visit(ctx.statement())
        loop_external_call_made = self.external_call_made_stack[-1]
        loop_state_var_modified = self.state_variable_modified_stack[-1]
        self.pop_context()

        # Since loops can execute multiple times, we assume the worst-case scenario
        self.external_call_made_stack[-1] = (
            self.external_call_made_stack[-1] or loop_external_call_made
        )
        self.state_variable_modified_stack[-1] = (
            self.state_variable_modified_stack[-1] or loop_state_var_modified
        )
        logger.debug("Exiting WhileStatement")
        return None

    def visitForStatement(self, ctx: SolidityParser.ForStatementContext):
        logger.debug("Entering ForStatement")
        self.push_context()
        self.visit(ctx.statement())
        loop_external_call_made = self.external_call_made_stack[-1]
        loop_state_var_modified = self.state_variable_modified_stack[-1]
        self.pop_context()

        # Same assumption as in while loops
        self.external_call_made_stack[-1] = (
            self.external_call_made_stack[-1] or loop_external_call_made
        )
        self.state_variable_modified_stack[-1] = (
            self.state_variable_modified_stack[-1] or loop_state_var_modified
        )
        logger.debug("Exiting ForStatement")
        return None

    # Visit expressions to detect external calls and state variable modifications
    def visitExpression(self, ctx: SolidityParser.ExpressionContext):
        if not self.in_function:
            return None

        # Detect external calls and state variable modifications
        external_call_detected = False
        state_variable_modified = False

        # Check for external calls
        if ctx.getChildCount() >= 3:
            # Check for function calls like expression '(' expressionList? ')'
            if (
                ctx.getChild(1).getText() == "("
                and ctx.getChild(ctx.getChildCount() - 1).getText() == ")"
            ):
                function_name = ctx.getChild(0).getText()
                # Logic to determine if the function call is external
                if (
                    function_name
                    in {"call", "delegatecall", "transfer", "send", "callcode"}
                    or function_name.startswith("address(")
                    or function_name.startswith("this.")
                ):
                    external_call_detected = True
                    logger.debug(
                        f"External call '{function_name}' detected in function '{self.current_function_name}'"
                    )

        # Detect state variable modifications
        if ctx.getChildCount() >= 3 and ctx.getChild(1).getText() in {
            "=",
            "+=",
            "-=",
            "*=",
            "/=",
            "%=",
        }:
            # Assignment operation
            var_name = ctx.getChild(0).getText()
            if var_name in self.state_variables:
                state_variable_modified = True
                if self.external_call_made_stack[-1]:
                    self.state_variable_modified_stack[-1] = True
                    logger.debug(
                        f"State variable '{var_name}' modified after external call in function '{self.current_function_name}'"
                    )

        # Detect unary operations (e.g., ++, --) on state variables
        if ctx.getChildCount() == 2 and ctx.getChild(0).getText() in {"++", "--"}:
            var_name = ctx.getChild(1).getText()
            if var_name in self.state_variables:
                state_variable_modified = True
                if self.external_call_made_stack[-1]:
                    self.state_variable_modified_stack[-1] = True
                    logger.debug(
                        f"State variable '{var_name}' modified by unary operation after external call in function '{self.current_function_name}'"
                    )
        elif ctx.getChildCount() == 2 and ctx.getChild(1).getText() in {"++", "--"}:
            var_name = ctx.getChild(0).getText()
            if var_name in self.state_variables:
                state_variable_modified = True
                if self.external_call_made_stack[-1]:
                    self.state_variable_modified_stack[-1] = True
                    logger.debug(
                        f"State variable '{var_name}' modified by unary operation after external call in function '{self.current_function_name}'"
                    )

        # Update the stack based on detections
        if external_call_detected:
            self.external_call_made_stack[-1] = True

        if state_variable_modified and self.external_call_made_stack[-1]:
            self.state_variable_modified_stack[-1] = True

        return self.visitChildren(ctx)

    # Visit primary expressions to detect function calls
    def visitPrimaryExpression(self, ctx: SolidityParser.PrimaryExpressionContext):
        if not self.in_function:
            return None

        # Check if the primary expression is a function call
        if ctx.getChildCount() >= 3:
            if (
                ctx.getChild(1).getText() == "("
                and ctx.getChild(ctx.getChildCount() - 1).getText() == ")"
            ):
                function_name = ctx.getChild(0).getText()
                # Logic to determine if the function call is external
                if function_name.startswith("this.") or function_name in self.contracts:
                    self.external_call_made_stack[-1] = True
                    logger.debug(
                        f"External function call '{function_name}' detected in function '{self.current_function_name}'"
                    )

        return self.visitChildren(ctx)

    # Visit variable declarations to detect state variable modifications
    def visitVariableDeclarationStatement(
        self, ctx: SolidityParser.VariableDeclarationStatementContext
    ):
        # Variable declarations inside functions are local variables; no action needed
        return self.visitChildren(ctx)

    # Visit return statements
    def visitReturnStatement(self, ctx: SolidityParser.ReturnStatementContext):
        if not self.in_function:
            return None

        logger.debug(
            f"Return statement encountered in function '{self.current_function_name}'"
        )

        return self.visitChildren(ctx)

    # Other visitor methods as needed
    # You can implement additional methods if your analysis requires them


def detect_reentrancy_in_contract(
    file_path: str, ast_output_dir: Optional[str] = None
) -> bool:
    """
    Detects reentrancy vulnerabilities in a Solidity contract.

    Args:
        file_path (str): The path to the Solidity (.sol) file.
        ast_output_dir (Optional[str]): Directory to save the AST files. If None, ASTs are not saved.

    Returns:
        bool: True if a reentrancy vulnerability is detected, False otherwise.
    """
    result = parse_solidity_file(file_path)
    if result is None:
        return False

    tree, parser = result

    # Save the AST if an output directory is provided
    if ast_output_dir is not None:
        try:
            from antlr4.tree.Trees import Trees

            ast_str = Trees.toStringTree(tree, None, parser)
            # Create the output directory if it doesn't exist
            os.makedirs(ast_output_dir, exist_ok=True)
            # Create a file name based on the Solidity file name
            base_name = os.path.basename(file_path)
            ast_file_name = os.path.splitext(base_name)[0] + "_AST.txt"
            ast_file_path = os.path.join(ast_output_dir, ast_file_name)
            # Write the AST to the file
            with open(ast_file_path, "w", encoding="utf-8") as ast_file:
                ast_file.write(ast_str)
            logger.info(f"AST saved to {ast_file_path}")
        except Exception as e:
            logger.error(f"Error saving AST for {file_path}: {e}", exc_info=True)

    try:
        visitor = ReentrancyDetectorVisitor()
        visitor.visit(tree)
        return visitor.reentrancy_detected
    except Exception as e:
        logger.error(f"Error analyzing {file_path}: {e}", exc_info=True)
        return False
