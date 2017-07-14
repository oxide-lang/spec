parser grammar OxideParser;

options {
    tokenVocab=OxideLexer;
}

entry
    : bodyElement* EOF
    ;
    
bodyElement
    : namespace
    | function
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
    : type 
    ;
 
functionBody
    : ';' #emptyFunctionBody
    ;

type
    : primitiveType
    ;
    
primitiveType
    : VOID
    | INT
    ;

qualifiedName
    : identifier ('.' identifier)*
    ;
    
identifier
	: IDENTIFIER
	;