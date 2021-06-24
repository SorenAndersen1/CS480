%{
#include <iostream>
#include <map>

std::map<std::string, float> symbols; /* Hold symbols with float to act as key */
bool errorDetection = false; /* Set it to False at Beginning */
std::string* overflowPrograms; /* Multiple programs in case of program loop */

void yyerror(const char* err);
extern int yylex();
%}

%define api.push-pull push
%define api.pure full

/* Def of Union, lecture defined*/
%union {
  std::string* str;
  float num;
  int category;
}

/* NAMES */
%token <str> IDENTIFIER FLOAT INT
/* NUMBERS */
%token <num> NUMBER
/* MATH AND FORMATTING*/
%token <category> EQUALS PLUS MINUS TIMES DIVIDEDBY NEWLINE
%token <category> LPAREN RPAREN COMMA COLON SEMICOLON
/* LOGIC */
%token <category> EQ NEQ GT GTE LT LTE
/* IF LOGIC */
%token <category> AND BREAK DEF ELIF ELSE FOR IF
%token <category> NOT OR RETURN WHILE 
/* INDENTS */
%token <category> INDENT DEDENT
/* BOOLS */
%token <category> TRUE FALSE

/* STATEMENTS */
%type <str> else program statement mathematic bool expression


/* Left set */
%left PLUS MINUS
%left TIMES DIVIDEDBY






/* START */
%start program

%%

program
  : program statement{$$ = new std::string(*$1 + *$2); overflowPrograms = $$;}
  | statement {$$ = new std::string(*$1); overflowPrograms = $$;}
  ;

statement
  : IDENTIFIER EQUALS mathematic NEWLINE { symbols[*$1] = 1; $$ = new std::string(*$1 + " = " + *$3 + ";" + "\n");}
  | BREAK NEWLINE {$$ = new std::string("break;\n");}
  | IF expression COLON NEWLINE INDENT program DEDENT else { $$ = new std::string("if (" + *$2 + ") {\n" + *$6 + " }\n" + *$8);}
  | WHILE expression COLON NEWLINE INDENT program DEDENT{$$ = new std::string("while (" + *$2 + ") {\n" + *$6 + "}\n");}
  | error NEWLINE { std::cerr << "Error Found" << std::endl; errorDetection = true; }
  ;

expression
  : LPAREN expression RPAREN {$$ = new std::string( " (" + *$2 + ") " );}
  | expression AND expression {$$ = new std::string(*$1 + " && " + *$3);}
  | expression OR expression {$$ = new std::string(*$1 + " || " + *$3);}
  | expression EQ expression {$$ = new std::string(*$1 + " == " + *$3);}
  | expression NEQ expression {$$ = new std::string(*$1 + " != " + *$3);}
  | expression GT expression {$$ = new std::string(*$1 + " > " + *$3);}
  | expression GTE expression {$$ = new std::string(*$1 + " >= " + *$3);}
  | expression LT expression {$$ = new std::string(*$1 + " < " + *$3);}
  | expression LTE expression {$$ = new std::string(*$1 + " <= " + *$3);}
  | NOT expression {$$ = new std::string("! " + *$2);}
  | FLOAT {$$ = new std::string(*$1);}
  | INT {$$ = new std::string(*$1);}
  | IDENTIFIER {$$ = new std::string(*$1);}
  | bool{$$ = new std::string(*$1);}
  ;

else
  : ELSE COLON NEWLINE INDENT program DEDENT {$$ = new std::string("else {\n" + *$5 + "} \n");}
  | ELIF expression COLON NEWLINE INDENT program DEDENT else {$$ = new std::string("else if ( " + *$2 + " ) {\n" + *$6 + "} \n");}
  | %empty {$$ = new std::string("");}
  ;

mathematic
  : LPAREN mathematic RPAREN { $$ = new std::string( "(" + *$2 + ")" ); }
  | mathematic PLUS mathematic { $$ = new std::string(*$1 + " + " + *$3); }
  | mathematic MINUS mathematic { $$ = new std::string(*$1 + " - " + *$3); }
  | mathematic TIMES mathematic { $$ = new std::string(*$1 + " * " + *$3); }
  | mathematic DIVIDEDBY mathematic { $$ = new std::string(*$1 + " / " + *$3); }
  | IDENTIFIER { $$ = new std::string(*$1); } 
  | FLOAT { $$ = new std::string(*$1); }
  | INT {$$ = new std::string(*$1);}
  | bool
  ;

  bool
  : TRUE {$$ = new std::string("true");}
  | FALSE {$$ = new std::string("false");}


%%

void yyerror(const char* err) {
  std::cerr << "Error: " << err << std::endl;
}


