# Generated from Solidity.g4 by ANTLR 4.13.2
from antlr4 import *
if "." in __name__:
    from .SolidityParser import SolidityParser
else:
    from SolidityParser import SolidityParser

# This class defines a complete generic visitor for a parse tree produced by SolidityParser.

class SolidityVisitor(ParseTreeVisitor):

    # Visit a parse tree produced by SolidityParser#sourceUnit.
    def visitSourceUnit(self, ctx:SolidityParser.SourceUnitContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#pragmaDirective.
    def visitPragmaDirective(self, ctx:SolidityParser.PragmaDirectiveContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#importDirective.
    def visitImportDirective(self, ctx:SolidityParser.ImportDirectiveContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#importDeclaration.
    def visitImportDeclaration(self, ctx:SolidityParser.ImportDeclarationContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#importAlias.
    def visitImportAlias(self, ctx:SolidityParser.ImportAliasContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#identifierPath.
    def visitIdentifierPath(self, ctx:SolidityParser.IdentifierPathContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#contractDefinition.
    def visitContractDefinition(self, ctx:SolidityParser.ContractDefinitionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#interfaceDefinition.
    def visitInterfaceDefinition(self, ctx:SolidityParser.InterfaceDefinitionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#libraryDefinition.
    def visitLibraryDefinition(self, ctx:SolidityParser.LibraryDefinitionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#libraryPart.
    def visitLibraryPart(self, ctx:SolidityParser.LibraryPartContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#contractPart.
    def visitContractPart(self, ctx:SolidityParser.ContractPartContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#interfacePart.
    def visitInterfacePart(self, ctx:SolidityParser.InterfacePartContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#stateVariableDeclaration.
    def visitStateVariableDeclaration(self, ctx:SolidityParser.StateVariableDeclarationContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#constantVariableDeclaration.
    def visitConstantVariableDeclaration(self, ctx:SolidityParser.ConstantVariableDeclarationContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#immutableVariableDeclaration.
    def visitImmutableVariableDeclaration(self, ctx:SolidityParser.ImmutableVariableDeclarationContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#structDefinition.
    def visitStructDefinition(self, ctx:SolidityParser.StructDefinitionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#structMember.
    def visitStructMember(self, ctx:SolidityParser.StructMemberContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#enumDefinition.
    def visitEnumDefinition(self, ctx:SolidityParser.EnumDefinitionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#enumValueList.
    def visitEnumValueList(self, ctx:SolidityParser.EnumValueListContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#usingForDeclaration.
    def visitUsingForDeclaration(self, ctx:SolidityParser.UsingForDeclarationContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#userDefinedValueTypeDefinition.
    def visitUserDefinedValueTypeDefinition(self, ctx:SolidityParser.UserDefinedValueTypeDefinitionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#userDefinedOperatorDefinition.
    def visitUserDefinedOperatorDefinition(self, ctx:SolidityParser.UserDefinedOperatorDefinitionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#errorDeclaration.
    def visitErrorDeclaration(self, ctx:SolidityParser.ErrorDeclarationContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#inheritanceSpecifier.
    def visitInheritanceSpecifier(self, ctx:SolidityParser.InheritanceSpecifierContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#functionDefinition.
    def visitFunctionDefinition(self, ctx:SolidityParser.FunctionDefinitionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#constructorDefinition.
    def visitConstructorDefinition(self, ctx:SolidityParser.ConstructorDefinitionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#fallbackFunction.
    def visitFallbackFunction(self, ctx:SolidityParser.FallbackFunctionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#receiveFunction.
    def visitReceiveFunction(self, ctx:SolidityParser.ReceiveFunctionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#functionModifiers.
    def visitFunctionModifiers(self, ctx:SolidityParser.FunctionModifiersContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#constructorModifiers.
    def visitConstructorModifiers(self, ctx:SolidityParser.ConstructorModifiersContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#modifierInvocation.
    def visitModifierInvocation(self, ctx:SolidityParser.ModifierInvocationContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#visibility.
    def visitVisibility(self, ctx:SolidityParser.VisibilityContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#stateMutability.
    def visitStateMutability(self, ctx:SolidityParser.StateMutabilityContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#overrideSpecifier.
    def visitOverrideSpecifier(self, ctx:SolidityParser.OverrideSpecifierContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#functionTypeName.
    def visitFunctionTypeName(self, ctx:SolidityParser.FunctionTypeNameContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#functionTypeParameterList.
    def visitFunctionTypeParameterList(self, ctx:SolidityParser.FunctionTypeParameterListContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#returnsParameters.
    def visitReturnsParameters(self, ctx:SolidityParser.ReturnsParametersContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#eventDefinition.
    def visitEventDefinition(self, ctx:SolidityParser.EventDefinitionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#modifierDefinition.
    def visitModifierDefinition(self, ctx:SolidityParser.ModifierDefinitionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#eventParameterList.
    def visitEventParameterList(self, ctx:SolidityParser.EventParameterListContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#eventParameter.
    def visitEventParameter(self, ctx:SolidityParser.EventParameterContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#parameterList.
    def visitParameterList(self, ctx:SolidityParser.ParameterListContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#parameter.
    def visitParameter(self, ctx:SolidityParser.ParameterContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#typeName.
    def visitTypeName(self, ctx:SolidityParser.TypeNameContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#userDefinedTypeName.
    def visitUserDefinedTypeName(self, ctx:SolidityParser.UserDefinedTypeNameContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#mapping.
    def visitMapping(self, ctx:SolidityParser.MappingContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#elementaryTypeName.
    def visitElementaryTypeName(self, ctx:SolidityParser.ElementaryTypeNameContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#block.
    def visitBlock(self, ctx:SolidityParser.BlockContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#statement.
    def visitStatement(self, ctx:SolidityParser.StatementContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#ifStatement.
    def visitIfStatement(self, ctx:SolidityParser.IfStatementContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#forStatement.
    def visitForStatement(self, ctx:SolidityParser.ForStatementContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#whileStatement.
    def visitWhileStatement(self, ctx:SolidityParser.WhileStatementContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#doWhileStatement.
    def visitDoWhileStatement(self, ctx:SolidityParser.DoWhileStatementContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#simpleStatement.
    def visitSimpleStatement(self, ctx:SolidityParser.SimpleStatementContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#variableDeclarationStatement.
    def visitVariableDeclarationStatement(self, ctx:SolidityParser.VariableDeclarationStatementContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#variableDeclarationList.
    def visitVariableDeclarationList(self, ctx:SolidityParser.VariableDeclarationListContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#variableDeclaration.
    def visitVariableDeclaration(self, ctx:SolidityParser.VariableDeclarationContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#expressionStatement.
    def visitExpressionStatement(self, ctx:SolidityParser.ExpressionStatementContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#tryCatchStatement.
    def visitTryCatchStatement(self, ctx:SolidityParser.TryCatchStatementContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#catchClause.
    def visitCatchClause(self, ctx:SolidityParser.CatchClauseContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#uncheckedStatement.
    def visitUncheckedStatement(self, ctx:SolidityParser.UncheckedStatementContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#assemblyStatement.
    def visitAssemblyStatement(self, ctx:SolidityParser.AssemblyStatementContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#assemblyDefinition.
    def visitAssemblyDefinition(self, ctx:SolidityParser.AssemblyDefinitionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#yulTopLevelStatement.
    def visitYulTopLevelStatement(self, ctx:SolidityParser.YulTopLevelStatementContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#yulFunctionDefinition.
    def visitYulFunctionDefinition(self, ctx:SolidityParser.YulFunctionDefinitionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#yulDirective.
    def visitYulDirective(self, ctx:SolidityParser.YulDirectiveContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#yulStatement.
    def visitYulStatement(self, ctx:SolidityParser.YulStatementContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#yulBlock.
    def visitYulBlock(self, ctx:SolidityParser.YulBlockContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#yulVariableDeclaration.
    def visitYulVariableDeclaration(self, ctx:SolidityParser.YulVariableDeclarationContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#yulTypedName.
    def visitYulTypedName(self, ctx:SolidityParser.YulTypedNameContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#yulAssignment.
    def visitYulAssignment(self, ctx:SolidityParser.YulAssignmentContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#yulFunctionCall.
    def visitYulFunctionCall(self, ctx:SolidityParser.YulFunctionCallContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#yulIfStatement.
    def visitYulIfStatement(self, ctx:SolidityParser.YulIfStatementContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#yulForStatement.
    def visitYulForStatement(self, ctx:SolidityParser.YulForStatementContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#yulSwitchStatement.
    def visitYulSwitchStatement(self, ctx:SolidityParser.YulSwitchStatementContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#yulLeave.
    def visitYulLeave(self, ctx:SolidityParser.YulLeaveContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#yulBreak.
    def visitYulBreak(self, ctx:SolidityParser.YulBreakContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#yulContinue.
    def visitYulContinue(self, ctx:SolidityParser.YulContinueContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#yulLabel.
    def visitYulLabel(self, ctx:SolidityParser.YulLabelContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#yulExpression.
    def visitYulExpression(self, ctx:SolidityParser.YulExpressionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#yulLiteral.
    def visitYulLiteral(self, ctx:SolidityParser.YulLiteralContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#yulIdentifier.
    def visitYulIdentifier(self, ctx:SolidityParser.YulIdentifierContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#yulPath.
    def visitYulPath(self, ctx:SolidityParser.YulPathContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#expression.
    def visitExpression(self, ctx:SolidityParser.ExpressionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#functionCallArguments.
    def visitFunctionCallArguments(self, ctx:SolidityParser.FunctionCallArgumentsContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#namedArgument.
    def visitNamedArgument(self, ctx:SolidityParser.NamedArgumentContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#primaryExpression.
    def visitPrimaryExpression(self, ctx:SolidityParser.PrimaryExpressionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#tupleExpression.
    def visitTupleExpression(self, ctx:SolidityParser.TupleExpressionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#typeNameExpression.
    def visitTypeNameExpression(self, ctx:SolidityParser.TypeNameExpressionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by SolidityParser#expressionList.
    def visitExpressionList(self, ctx:SolidityParser.ExpressionListContext):
        return self.visitChildren(ctx)



del SolidityParser