parser grammar OxideParser;

options {
    tokenVocab=OxideLexer;
}

entry
    : namespaceOrType* EOF
    ;
    
 namespaceOrType
    : namespaceDefinition
    ;
 
 namespaceDefinition
    : NAMESPACE qualifiedName '{' '}'
    ;
 
 qualifiedName
    : identifier ('.' identifier)*
    ;
    
identifier
	: IDENTIFIER
	;