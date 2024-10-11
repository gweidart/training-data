grammar Solidity;

// Lexer Rules
PRAGMA : 'pragma' ;
SOLIDITY : 'solidity' ;
EXPERIMENTAL : 'experimental' ;
ABICODER : 'abicoder' ;
VERSION : [0-9]+ '.' [0-9]+ '.' [0-9]+ ('-' [a-zA-Z0-9]+)? ;
IMPORT : 'import' ;
AS : 'as' ;
FROM : 'from' ;
SEMICOLON : ';' ;
LPAREN : '(' ;
RPAREN : ')' ;
LBRACE : '{' ;
RBRACE : '}' ;
LBRACK : '[' ;
RBRACK : ']' ;
ASSIGN : '=' ;
PLUS : '+' ;
MINUS : '-' ;
MULT : '*' ;
DIV : '/' ;
MOD : '%' ;
AND : '&&' ;
OR : '||' ;
NOT : '!' ;
LT : '<' ;
GT : '>' ;
LTE : '<=' ;
GTE : '>=' ;
EQ : '==' ;
NEQ : '!=' ;
BIT_AND : '&' ;
BIT_OR : '|' ;
BIT_XOR : '^' ;
BIT_NOT : '~' ;
LSHIFT : '<<' ;
RSHIFT : '>>' ;
QUESTION : '?' ;
COLON : ':' ;
COMMA : ',' ;
DOT : '.' ;
ABSTRACT : 'abstract' ;
CONTRACT : 'contract' ;
INTERFACE : 'interface' ;
LIBRARY : 'library' ;
FUNCTION : 'function' ;
RETURNS : 'returns' ;
EVENT : 'event' ;
MODIFIER : 'modifier' ;
STRUCT : 'struct' ;
ENUM : 'enum' ;
IF : 'if' ;
ELSE : 'else' ;
FOR : 'for' ;
WHILE : 'while' ;
DO : 'do' ;
TRY : 'try' ;
CATCH : 'catch' ;
REVERT : 'revert' ;
ASSEMBLY : 'assembly' ;
LET : 'let' ;
LEAVE : 'leave' ;
BREAK : 'break' ;
CONTINUE : 'continue' ;
RETURN : 'return' ;
NEW : 'new' ;
DELETE : 'delete' ;
MAPPING : 'mapping' ;
MEMORY : 'memory' ;
STORAGE : 'storage' ;
CALLDATA : 'calldata' ;
PUBLIC : 'public' ;
PRIVATE : 'private' ;
INTERNAL : 'internal' ;
EXTERNAL : 'external' ;
PURE : 'pure' ;
VIEW : 'view' ;
PAYABLE : 'payable' ;
CONSTANT : 'constant' ;
IMMUTABLE : 'immutable' ;
ANONYMOUS : 'anonymous' ;
INDEXED : 'indexed' ;
OVERRIDE : 'override' ;
VIRTUAL : 'virtual' ;
USING : 'using' ;
TYPE : 'type' ;
ERROR : 'error' ;
UNCHECKED : 'unchecked' ;
PLUSPLUS : '++' ;
MINUSMINUS : '--' ;
ASSIGN_GT : '=>' ;
FALLBACK : 'fallback' ;
RECEIVE : 'receive' ;
IS : 'is' ;
CONSTRUCTOR : 'constructor' ;

// Define tokens for 'bytes' types
BYTES_NUMBER
    : 'bytes' (
        '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' |
        '1' [0-9] | '2' [0-9] | '3' [0-2]
      )
    ;
BYTES: 'bytes' ;

// Define tokens for 'int' types
INT_NUMBER: 'int' [0-9]+ ;
INT: 'int' ;

// Define tokens for 'uint' types
UINT_NUMBER: 'uint' [0-9]+ ;
UINT: 'uint' ;

// Define tokens for 'fixed' types
FIXED_NUMBER: 'fixed' [0-9]+ 'x' [0-9]+ ;
FIXED: 'fixed' ;

// Define tokens for 'ufixed' types
UFIXED_NUMBER: 'ufixed' [0-9]+ 'x' [0-9]+ ;
UFIXED: 'ufixed' ;

IDENTIFIER : Letter (Letter | Digit)* ;
STRING_LITERAL
    : '"' (ESC_SEQ | ~["\\])* '"'
    | '\'' (ESC_SEQ | ~['\\])* '\''
    ;
DECIMAL_LITERAL : [0-9]+ ;
HEX_LITERAL : '0' [xX] [0-9a-fA-F]+ ;
BOOL_LITERAL : 'true' | 'false' ;
WS : [ \t\r\n]+ -> skip ;
COMMENT : '//' ~[\r\n]* -> skip ;
MULTI_LINE_COMMENT : '/*' .*? '*/' -> skip ;
DOC_COMMENT : '///' ~[\r\n]* -> skip ;
NAT_SPEC : '/**' .*? '*/' -> skip ;

// Fragments
fragment Letter : [a-zA-Z_] | [\u0080-\uFFFF] ;
fragment Digit : [0-9] ;
fragment ESC_SEQ
    : '\\' [btnfr"'\\]
    | '\\x' HEX_DIGIT HEX_DIGIT
    ;
fragment HEX_DIGIT : [0-9a-fA-F] ;

// Parser Rules
sourceUnit
    : (pragmaDirective
    | importDirective
    | contractDefinition
    | interfaceDefinition
    | libraryDefinition
    | functionDefinition
    | constantVariableDeclaration
    | immutableVariableDeclaration
    | structDefinition
    | enumDefinition
    | userDefinedValueTypeDefinition
    | errorDeclaration
    | userDefinedOperatorDefinition
    )* EOF
    ;

pragmaDirective
    : PRAGMA (SOLIDITY | EXPERIMENTAL) (VERSION | ABICODER DECIMAL_LITERAL)? SEMICOLON
    ;

importDirective
    : IMPORT (importDeclaration | importAlias)
    ;

importDeclaration
    : STRING_LITERAL
    | ('*' | IDENTIFIER) AS IDENTIFIER FROM STRING_LITERAL
    | LBRACE identifierPath (AS IDENTIFIER)? (COMMA identifierPath (AS IDENTIFIER)?)* RBRACE FROM STRING_LITERAL
    ;

importAlias
    : IDENTIFIER ASSIGN importDeclaration
    ;

identifierPath
    : IDENTIFIER (DOT IDENTIFIER)*
    ;

contractDefinition
    : ABSTRACT? CONTRACT IDENTIFIER (IS inheritanceSpecifier (COMMA inheritanceSpecifier)*)? LBRACE contractPart* RBRACE
    ;

interfaceDefinition
    : INTERFACE IDENTIFIER (IS inheritanceSpecifier (COMMA inheritanceSpecifier)*)? LBRACE interfacePart* RBRACE
    ;

libraryDefinition
    : LIBRARY IDENTIFIER LBRACE libraryPart* RBRACE
    ;

libraryPart
    : stateVariableDeclaration
    | functionDefinition
    | structDefinition
    | enumDefinition
    | usingForDeclaration
    ;

contractPart
    : stateVariableDeclaration
    | functionDefinition
    | constructorDefinition
    | modifierDefinition
    | eventDefinition
    | enumDefinition
    | structDefinition
    | usingForDeclaration
    ;

interfacePart
    : functionDefinition
    | eventDefinition
    | enumDefinition
    | structDefinition
    ;

stateVariableDeclaration
    : typeName (PUBLIC | PRIVATE | INTERNAL | CONSTANT | IMMUTABLE)* IDENTIFIER (ASSIGN expression)? SEMICOLON
    ;

constantVariableDeclaration
    : typeName (PUBLIC | PRIVATE | INTERNAL)* CONSTANT IDENTIFIER ASSIGN expression SEMICOLON
    ;

immutableVariableDeclaration
    : typeName (PUBLIC | PRIVATE | INTERNAL)* IMMUTABLE IDENTIFIER (ASSIGN expression)? SEMICOLON
    ;

structDefinition
    : STRUCT IDENTIFIER LBRACE structMember* RBRACE
    ;

structMember
    : typeName (MEMORY | STORAGE | CALLDATA)? IDENTIFIER SEMICOLON
    ;

enumDefinition
    : ENUM IDENTIFIER LBRACE enumValueList RBRACE
    ;

enumValueList
    : IDENTIFIER (COMMA IDENTIFIER)* (COMMA)?
    ;

usingForDeclaration
    : USING IDENTIFIER FOR typeName SEMICOLON
    ;

userDefinedValueTypeDefinition
    : TYPE IDENTIFIER IS typeName SEMICOLON
    ;

userDefinedOperatorDefinition
    : USING IDENTIFIER FOR typeName SEMICOLON
    ;

errorDeclaration
    : ERROR IDENTIFIER LPAREN parameterList? RPAREN SEMICOLON
    ;

inheritanceSpecifier
    : userDefinedTypeName (LPAREN expressionList? RPAREN)?
    ;

functionDefinition
    : (functionModifiers)* FUNCTION IDENTIFIER? LPAREN parameterList? RPAREN (returnsParameters)? (LBRACE block RBRACE | SEMICOLON)
    ;

constructorDefinition
    : CONSTRUCTOR LPAREN parameterList? RPAREN (constructorModifiers)* (LBRACE block RBRACE | SEMICOLON)
    ;

fallbackFunction
    : FALLBACK (LPAREN parameterList? RPAREN)? (functionModifiers)* (LBRACE block RBRACE | SEMICOLON)
    ;

receiveFunction
    : RECEIVE LPAREN RPAREN (functionModifiers)* (LBRACE block RBRACE | SEMICOLON)
    ;

functionModifiers
    : visibility
    | stateMutability
    | VIRTUAL
    | overrideSpecifier
    | modifierInvocation
    ;

constructorModifiers
    : visibility
    | stateMutability
    | modifierInvocation
    ;

modifierInvocation
    : IDENTIFIER
    ;

visibility
    : PUBLIC
    | PRIVATE
    | INTERNAL
    | EXTERNAL
    ;

stateMutability
    : PURE
    | VIEW
    | PAYABLE
    ;

overrideSpecifier
    : OVERRIDE (LPAREN userDefinedTypeName (COMMA userDefinedTypeName)* RPAREN)?
    ;

functionTypeName
    : FUNCTION (functionTypeParameterList)? (visibility | stateMutability)* (RETURNS functionTypeParameterList)?
    ;

functionTypeParameterList
    : LPAREN parameterList? RPAREN
    ;

returnsParameters
    : RETURNS LPAREN parameterList? RPAREN
    ;

eventDefinition
    : EVENT IDENTIFIER LPAREN eventParameterList? RPAREN (ANONYMOUS)? SEMICOLON
    ;

modifierDefinition
    : MODIFIER IDENTIFIER (LPAREN parameterList? RPAREN)? (LBRACE block RBRACE | SEMICOLON)
    ;

eventParameterList
    : eventParameter (COMMA eventParameter)*
    ;

eventParameter
    : typeName (INDEXED)? IDENTIFIER?
    ;

parameterList
    : parameter (COMMA parameter)*
    ;

parameter
    : typeName (MEMORY | STORAGE | CALLDATA)? IDENTIFIER?
    ;

typeName
    : (
        elementaryTypeName
      | userDefinedTypeName
      | mapping
      | functionTypeName
      ) (LBRACK expression? RBRACK)*
    ;

userDefinedTypeName
    : IDENTIFIER (DOT IDENTIFIER)*
    ;

mapping
    : MAPPING LPAREN elementaryTypeName ASSIGN_GT typeName RPAREN
    ;

elementaryTypeName
    : 'address'
    | 'bool'
    | 'string'
    | 'var'
    | 'byte'
    | BYTES_NUMBER
    | BYTES
    | INT_NUMBER
    | INT
    | UINT_NUMBER
    | UINT
    | FIXED_NUMBER
    | FIXED
    | UFIXED_NUMBER
    | UFIXED
    ;

block
    : LBRACE statement* RBRACE
    ;

statement
    : ifStatement
    | forStatement
    | whileStatement
    | doWhileStatement
    | simpleStatement
    | tryCatchStatement
    | assemblyStatement
    | uncheckedStatement
    ;

ifStatement
    : IF LPAREN expression RPAREN statement (ELSE statement)?
    ;

forStatement
    : FOR LPAREN (simpleStatement | SEMICOLON) expression? SEMICOLON expression? RPAREN statement
    ;

whileStatement
    : WHILE LPAREN expression RPAREN statement
    ;

doWhileStatement
    : DO statement WHILE LPAREN expression RPAREN SEMICOLON
    ;

simpleStatement
    : variableDeclarationStatement
    | expressionStatement
    ;

variableDeclarationStatement
    : variableDeclarationList (ASSIGN expressionList)? SEMICOLON
    ;

variableDeclarationList
    : variableDeclaration (COMMA variableDeclaration)*
    ;

variableDeclaration
    : typeName (MEMORY | STORAGE | CALLDATA)? IDENTIFIER
    ;

expressionStatement
    : expression SEMICOLON
    ;

tryCatchStatement
    : TRY expression (returnsParameters)? (catchClause)* LBRACE block RBRACE
    ;

catchClause
    : CATCH (IDENTIFIER)? (LPAREN parameterList? RPAREN)? LBRACE block RBRACE
    ;

uncheckedStatement
    : UNCHECKED block
    ;

assemblyStatement
    : ASSEMBLY STRING_LITERAL? LBRACE yulStatement* RBRACE
    ;

assemblyDefinition
    : ASSEMBLY STRING_LITERAL? LBRACE yulTopLevelStatement* RBRACE
    ;

yulTopLevelStatement
    : yulFunctionDefinition
    | yulDirective
    | yulStatement
    ;

yulFunctionDefinition
    : 'function' yulIdentifier LPAREN (yulTypedName (COMMA yulTypedName)*)? RPAREN yulBlock
    ;

yulDirective
    : 'object' yulIdentifier yulBlock
    | 'code' yulBlock
    ;

yulStatement
    : yulBlock
    | yulVariableDeclaration
    | yulAssignment
    | yulFunctionCall
    | yulIfStatement
    | yulForStatement
    | yulSwitchStatement
    | yulLeave
    | yulBreak
    | yulContinue
    | yulLabel
    ;

yulBlock
    : LBRACE yulStatement* RBRACE
    ;

yulVariableDeclaration
    : LET yulIdentifier (COLON yulTypedName)? (ASSIGN yulExpression)?
    ;

yulTypedName
    : yulIdentifier
    ;

yulAssignment
    : yulPath ASSIGN yulExpression
    ;

yulFunctionCall
    : yulIdentifier LPAREN (yulExpression (COMMA yulExpression)*)? RPAREN
    ;

yulIfStatement
    : IF yulExpression yulBlock
    ;

yulForStatement
    : FOR yulBlock yulExpression yulBlock yulBlock
    ;

yulSwitchStatement
    : 'switch' yulExpression ( 'case' yulLiteral yulBlock )* ( 'default' yulBlock )?
    ;

yulLeave
    : LEAVE
    ;

yulBreak
    : BREAK
    ;

yulContinue
    : CONTINUE
    ;

yulLabel
    : IDENTIFIER COLON
    ;

yulExpression
    : yulLiteral
    | yulIdentifier
    | yulFunctionCall
    | yulPath
    ;

yulLiteral
    : DECIMAL_LITERAL
    | HEX_LITERAL
    | STRING_LITERAL
    | BOOL_LITERAL
    ;

yulIdentifier
    : IDENTIFIER
    ;

yulPath
    : yulIdentifier (DOT yulIdentifier)*
    ;

expression
    : primaryExpression
    | expression op=('*' | '/' | '%') expression
    | expression op=('+' | '-') expression
    | expression op=('<<' | '>>') expression
    | expression op=('&' | '|' | '^') expression
    | expression op=('<' | '>' | '<=' | '>=') expression
    | expression op=('==' | '!=') expression
    | expression AND expression
    | expression OR expression
    | expression QUESTION expression COLON expression
    | expression op=('=' | '|=' | '^=' | '&=' | '<<=' | '>>=' | '+=' | '-=' | '*=' | '/=' | '%=') expression
    | NEW typeName
    | DELETE expression
    | PLUSPLUS expression
    | MINUSMINUS expression
    | PLUS expression
    | MINUS expression
    | BIT_NOT expression
    | NOT expression
    | expression LBRACK expression? RBRACK
    | expression DOT IDENTIFIER
    | expression LPAREN functionCallArguments? RPAREN
    ;

functionCallArguments
    : LBRACE namedArgument (COMMA namedArgument)* RBRACE
    | expressionList
    ;

namedArgument
    : IDENTIFIER COLON expression
    ;

primaryExpression
    : IDENTIFIER
    | DECIMAL_LITERAL
    | HEX_LITERAL
    | BOOL_LITERAL
    | STRING_LITERAL
    | tupleExpression
    | typeNameExpression
    ;

tupleExpression
    : LPAREN expressionList? RPAREN
    ;

typeNameExpression
    : typeName
    ;

expressionList
    : expression (COMMA expression)*
    ;
