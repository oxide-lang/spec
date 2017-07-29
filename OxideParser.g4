parser grammar OxideParser;

options {
    tokenVocab=OxideLexer;
}

entry
    : bodyElement* EOF
    ;
    
bodyElement
    : using
    | namespace
    | function
    ;

using
    : USING qualifiedName ';'
    ;

namespace
    : NAMESPACE qualifiedName '{' bodyElement* '}'
    ;
 
function
    : access=(PUBLIC | PRIVATE) type identifier '(' parameterList? ')' functionBody
    ;

parameterList
    : parameter (',' parameter)*
    ;
 
parameter
    : type identifier
    ;
 
functionBody
    : ';' #emptyFunctionBody
    | block #blockFunctionBody
    ;

block
    : '{' statement* '}'
    ;

statement
    : ';' #emptyStatement
    | expression ';' #expressionStatement
    | IF '(' expression ')' statementBody #ifStatement
    | RETURN expression? ';' #returnStatement
    ;

statementBody
    : block
    | statement
    ;

expression
    : conditionalExpression
    ;

conditionalExpression
    : conditionalOrExpression '?' expression ':' expression #realConditionalExpression
    | conditionalOrExpression #passthroughConditionalExpression
    ;

conditionalOrExpression
    : conditionalOrExpression OP_OR conditionalAndExpression #realConditionalOrExpression
    | conditionalAndExpression #passthroughConditionalOrExpression
    ;

conditionalAndExpression
    : conditionalAndExpression OP_AND inclusiveOrExpression #realConditionalAndExpression
    | inclusiveOrExpression #passthroughConditionalAndExpression
    ;

inclusiveOrExpression
    : inclusiveOrExpression '|' exclusiveOrExpression #realInclusiveOrExpression
    | exclusiveOrExpression #passthroughInclusiveOrExpression
    ;

exclusiveOrExpression
    : exclusiveOrExpression '^' andExpression #realExclusiveOrExpression
    | andExpression #passthroughExclusiveOrExpression
    ;

andExpression
    : andExpression '&' equalityExpression #realAndExpression
    | equalityExpression #passthroughAndExpression
    ;

equalityExpression
    : equalityExpression op=(OP_EQ | OP_NE) relationalExpression #realEqualityExpression
    | relationalExpression #passthroughEqualityExpression
    ;

relationalExpression
    : relationalExpression op=('<' | '>' | '<=' | '>=') shiftExpression #realRelationalExpression
    | shiftExpression #passthroughRelationalExpression
    ;

shiftExpression
    : shiftExpression ('<<' | rightShift) additiveExpression #realShiftExpression
    | additiveExpression #passthroughShiftExpression
    ;

additiveExpression
    : additiveExpression op=('+' | '-') multiplicativeExpression #realAdditiveExpression
    | multiplicativeExpression #passthroughAdditiveExpression
    ;

multiplicativeExpression
    : multiplicativeExpression op=('*' | '/' | '%')  unaryExpression #realMultiplicativeExpression
    | unaryExpression #passthroughMultiplicativeExpression
    ;

unaryExpression
    : primaryExpression #primaryUnaryExpression
    | '+' unaryExpression #posUnaryExpression
    | '-' unaryExpression #negUnaryExpression
    | '!' unaryExpression #notUnaryExpression
    | '~' unaryExpression #compUnaryExpression
    | '++' unaryExpression #incUnaryExpression
    | '--' unaryExpression #decUnaryExpression
    | '(' type ')' unaryExpression #castUnaryExpression
    | '&' unaryExpression #addressUnaryExpression
    | '*' unaryExpression #derefUnaryExpression
    ;

primaryExpression
    : primaryExpressionStart #startPrimaryExpression
    | primaryExpression bracketExpression #bracketPrimaryExpression
    | primaryExpression memberAccess #accessPrimaryExpression
    | primaryExpression methodInvocation #methodPrimaryExpression
    | primaryExpression '++' #incPrimaryExpression
    | primaryExpression '--' #decPrimaryExpression
    ;

primaryExpressionStart
    : literal #literalPrimaryExpressionStart
    | identifier #identifierPrimaryExpressionStart
    | OPEN_PARENS expression CLOSE_PARENS #bracketPrimaryExpressionStart
    | primitiveType #primitivePrimaryExpressionStart
    | LITERAL_ACCESS #literalAccessPrimaryExpressionStart
    | THIS #thisPrimaryExpressionStart
    | SUPER #superPrimaryExpressionStart
    | NEW baseType OPEN_PARENS argumentList? CLOSE_PARENS #newObjectPrimaryExpressionStart
    ;

bracketExpression
    : '[' indexerArgument ( ',' indexerArgument)* ']'
    ;

memberAccess
    : '.' identifier
    ;

indexerArgument
    : expression
    ;

methodInvocation
    : OPEN_PARENS argumentList? CLOSE_PARENS
    ;

argumentList 
    : argument ( ',' argument)*
    ;

argument
    : expression
    ;

type
    : type '~' #mutableType
    | type '*' #rawPointerType
    | type '&' #referenceType
    | baseType #ownerType
    ;

baseType
    : primitiveType
    ;
    
primitiveType
    : VOID #voidPrimitiveType
    | BOOL #boolPrimitiveType
    | BYTE #bytePrimitiveType
    | SBYTE #sbytePrimitiveType
    | CHAR #charPrimitiveType
    | USHORT #ushortPrimitiveType
    | SHORT #shortPrimitiveType
    | INT #intPrimitiveType
    | UINT #uintPrimitiveType
    | LONG #longPrimitiveType
    | ULONG #ulongPrimitiveType
    | SIZE #sizePrimitiveType
    | USIZE #usizePrimitiveType
    | FLOAT #floatPrimitiveType
    | DOUBLE #doublePrimitiveType
    | DECIMAL #decimalPrimitiveType
    | STRING #stringPrimitiveType
    ;

qualifiedName
    : identifier ('.' identifier)*
    ;

rightArrow
    : first='=' second='>' {$first.index + 1 == $second.index}?
    ;

rightShift
    : first='>' second='>' {$first.index + 1 == $second.index}?
    ;

rightShiftAssignment
    : first='>' second='>=' {$first.index + 1 == $second.index}? 
    ;

literal
    : booleanLiteral
    | stringLiteral
    | integerLiteral
    | hexIntegerLiteral
    | realLiteral
    | characterLiteral
    | nullLiteral
    ;

booleanLiteral
    : TRUE #trueBooleanLiteral
    | FALSE #falseBooleanLiteral
    ;

integerLiteral
    : INTEGER_LITERAL
    ;

hexIntegerLiteral
    : HEX_INTEGER_LITERAL
    ;

realLiteral
    : REAL_LITERAL
    ;

characterLiteral
    : CHARACTER_LITERAL
    ;

nullLiteral
    : NULL
    ;

stringLiteral
    : interpolatedRegularString
    | interpolated_verbatium_string
    | REGULAR_STRING
    | VERBATIUM_STRING
    ;

interpolatedRegularString
    : INTERPOLATED_REGULAR_STRING_START interpolatedRegularStringPart* DOUBLE_QUOTE_INSIDE
    ;

interpolatedRegularStringPart
    : interpolatedStringExpression
    | DOUBLE_CURLY_INSIDE
    | REGULAR_CHAR_INSIDE
    | REGULAR_STRING_INSIDE
    ;

interpolated_verbatium_string
    : INTERPOLATED_VERBATIUM_STRING_START interpolatedVerbatiumString* DOUBLE_QUOTE_INSIDE
    ;

interpolatedVerbatiumString
    : INTERPOLATED_VERBATIUM_STRING_START interpolatedVerbatiumStringPart* DOUBLE_QUOTE_INSIDE
    ;

interpolatedVerbatiumStringPart
    : interpolatedStringExpression
    | DOUBLE_CURLY_INSIDE
    | VERBATIUM_DOUBLE_QUOTE_INSIDE
    | VERBATIUM_INSIDE_STRING
    ;

interpolatedStringExpression
    : expression (',' expression)* (':' FORMAT_STRING+)?
    ;


identifier
    : IDENTIFIER
    ;