%{
#include <iostream>
#include <vector>
#include <map>

#include "parser.hpp"

extern int yylex();
void yyerror(YYLTYPE* loc, const char* err);
std::string* translate_boolean_str(std::string* boolean_str);

/*
 * Here, target_program is a string that will hold the target program being
 * generated, and symbols is a simple symbol table.
 */
//std::string* target_program;
bool _error = false;
std::map<std::string, float> symbols; 

    /*
    the symbols variable was initalized as a set, but I changed to map
    because we worked with those in the last few assignments and don't
    want to interefere with my tried and trued methods.
    */

struct AST {
	int ID;
  bool isBox;
	std::string* value;
	std::vector<struct AST*> child;
};
int currentNID = 0; //the Node ID that is being assigned
struct AST* root = new AST;

AST* addNode(std::string* value, int ID, bool isBox){
  AST* temp = new AST;
  temp->isBox = isBox;
  temp->value = value;
  temp->ID = ID;
  return temp;
}

void addChild(struct AST *parent, struct AST *Child){
  parent->child.push_back(Child);
}

%}

%union {
  float value;
  std::string* str;
  int category;
  struct AST* block;
}

/* Enable location tracking. */
%locations

/*
 * All program constructs will be represented as strings, specifically as
 * their corresponding C/C++ translation.
 */
//%define api.value.type { std::string* }

/*
 * Because the lexer can generate more than one token at a time (i.e. DEDENT
 * tokens), we'll use a push parser.
 */
%define api.pure full
%define api.push-pull push

/*
 * These are all of the terminals in our grammar, i.e. the syntactic
 * categories that can be recognized by the lexer.
 */
%token <str> IDENTIFIER FLOAT INT
%token <category> INTEGER BOOLEAN
%token <category> INDENT DEDENT NEWLINE
%token <category> AND BREAK DEF ELIF ELSE FOR IF NOT OR RETURN WHILE
%token <category> ASSIGN PLUS MINUS TIMES DIVIDEDBY
%token <category> EQ NEQ GT GTE LT LTE
%token <category> LPAREN RPAREN COMMA COLON
%token <category> FALSE TRUE

%type <block> expression statement statements program else condition
/*
 * Here, we're defining the precedence of the operators.  The ones that appear
 * later have higher precedence.  All of the operators are left-associative
 * except the "not" operator, which is right-associative.
 */
%left OR
%left AND
%right NOT
%left EQ NEQ GT GTE LT LTE
%left PLUS MINUS
%left TIMES DIVIDEDBY

/* This is our goal/start symbol. */
%start program

%%

/*
 * Each of the CFG rules below recognizes a particular program construct in
 * Python and creates a new string containing the corresponding C/C++
 * translation.  Since we're allocating strings as we go, we also free them
 * as we no longer need them.  Specifically, each string is freed after it is
 * combined into a larger string.
 */

/*
 * This is the goal/start symbol.  Once all of the statements in the entire
 * source program are translated, this symbol receives the string containing
 * all of the translations and assigns it to the global target_program, so it
 * can be used outside the parser.
 */
program
  : statements { root = $1; }
  ;

/*
 * The `statements` symbol represents a set of contiguous statements.  It is
 * used to represent the entire program in the rule above and to represent a
 * block of statements in the `block` rule below.  The second production here
 * simply concatenates each new statement's translation into a running
 * translation for the current set of statements.
 */
statements
  : statements statement { addChild($1, $2); $$ = $1; }
  | statement {$$ = addNode(new std::string("Block"),currentNID, 0); addChild($$, $1); currentNID++;}
  ;

/*
 * This is a high-level symbol used to represent an individual statement.
 */
statement
: IDENTIFIER ASSIGN condition NEWLINE { symbols[*$1] = 1.0; $$ = addNode(new std::string("Assignment"), currentNID, 0); addChild($$, addNode(new std::string("Identifier: " + *$1),currentNID+1, 1)); addChild($$, $3); currentNID = currentNID+2;}
| IF expression COLON NEWLINE INDENT statements DEDENT else{ $$ = addNode(new std::string("IF"), currentNID, 0); addChild($$, $2); addChild($$, $6); addChild($$, $8); currentNID++;}
| WHILE expression COLON NEWLINE INDENT statements DEDENT{$$ = addNode(new std::string("While"), currentNID, 0); addChild($$, $2); addChild($$, $6); currentNID++;}
| BREAK NEWLINE {$$ = addNode(new std::string("Break"), currentNID, 0); currentNID++;}
  ;

/*
 * Symbol representing algebraic expressions.  For most forms of algebraic
 * expression, we generate a translated string that simply concatenates the
 * C++ translations of the operands with the C++ translation of the operator.
 */
expression
: LPAREN expression RPAREN {$$ = addNode(new std::string(""), currentNID, 0); addChild($$, $2);currentNID++;}
| expression EQ expression {$$ = addNode(new std::string("EQ"),currentNID, 0); addChild($$, $1); addChild($$, $3);currentNID++;}
| expression NEQ expression {$$ = addNode(new std::string("NEQ"),currentNID, 0); addChild($$, $1); addChild($$, $3);currentNID++;}
| expression GT expression {$$ = addNode(new std::string("GT"),currentNID, 0); addChild($$, $1); addChild($$, $3);currentNID++;}
| expression GTE expression {$$ = addNode(new std::string("GTE"),currentNID, 0); addChild($$, $1); addChild($$, $3);currentNID++;}
| expression LT expression {$$ = addNode(new std::string("LT"),currentNID, 0); addChild($$, $1); addChild($$, $3);currentNID++;}
| expression LTE expression {$$ = addNode(new std::string("LTE"),currentNID, 0); addChild($$, $1); addChild($$, $3);currentNID++;}
| expression AND expression {$$ = addNode(new std::string("AND"),currentNID, 0); addChild($$, $1); addChild($$, $3);currentNID++;}
| expression OR expression {$$ = addNode(new std::string("OR"),currentNID, 0); addChild($$, $1); addChild($$, $3);currentNID++;}
| NOT expression {$$ = addNode(new std::string("NOT"),currentNID, 1); addChild($$, $2);currentNID++;}
| FLOAT {$$ = addNode(new std::string("float: " + *$1),currentNID, 1);currentNID++;}
| INT { $$ = addNode(new std::string("Integer: " + *$1),currentNID, 1);currentNID++; }
| IDENTIFIER {$$ = addNode(new std::string("identifier: " + *$1),currentNID, 1);currentNID++;}
| TRUE {$$ = addNode(new std::string("true"),currentNID, 1);currentNID++;}
| FALSE {$$ = addNode(new std::string("false"),currentNID, 1);currentNID++;}
  ;

else
: ELSE COLON NEWLINE INDENT statements DEDENT {$$ = $5;}
| ELIF expression COLON NEWLINE INDENT statements DEDENT else {addNode(new std::string("ELIF"), currentNID, 1); addChild($$, $2); addChild($$, $6); addChild($$, $8); currentNID++;}
| %empty {$$ = addNode(NULL, currentNID, 1); currentNID++;}
;


condition
: LPAREN condition RPAREN { $$ = $2; }
| condition PLUS condition { $$ = addNode(new std::string("PLUS"),currentNID, 0); addChild($$, $1); addChild($$, $3);currentNID++; }
| condition MINUS condition { $$ = addNode(new std::string("MINUS"),currentNID, 0); addChild($$, $1); addChild($$, $3);currentNID++; }
| condition TIMES condition { $$ = addNode(new std::string("TIMES"),currentNID, 0); addChild($$, $1); addChild($$, $3);currentNID++; }
| condition DIVIDEDBY condition { $$ = addNode(new std::string("Divided BY"),currentNID, 0); addChild($$, $1); addChild($$, $3);currentNID++; }
| INT { $$ = addNode(new std::string("Integer: " + *$1),currentNID, 1);currentNID++; }
| IDENTIFIER { $$ = addNode(new std::string("Identifier: " + *$1),currentNID, 1);currentNID++; }
| FLOAT {$$ = addNode(new std::string("float: " + *$1),currentNID, 1);currentNID++;}
| TRUE{$$ = addNode(new std::string("Boolean: 1"),currentNID, 1);currentNID++;}
| FALSE{$$ = addNode(new std::string("Boolean: 0"),currentNID, 1);currentNID++;}
  ;
%%

/*
 * This is our simple error reporting function.  It prints the line number
 * and text of each error.
 */
void yyerror(YYLTYPE* loc, const char* err) {
  std::cerr << "Error (line " << loc->first_line << "): " << err << std::endl;
}

/*
 * This function translates a Python boolean value into the corresponding
 * C++ boolean value.
 */
std::string* translate_boolean_str(std::string* boolean_str) {
  if (*boolean_str == "True") {
    return new std::string("true");
  } else {
    return new std::string("false");
  }
}
