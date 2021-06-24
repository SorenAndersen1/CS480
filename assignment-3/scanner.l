/*
 * Lexer definition for simplified Python syntax.
 */

%{
#include <iostream>
#include <stack>
#include <cstdlib>

#include "parser.hpp"

/*
 * We'll use this stack to keep track of indentation level, as described in
 * the Python docs:
 *
 * https://docs.python.org/3/reference/lexical_analysis.html#indentation
 */
std::stack<int> _indent_stack;
%}

%option noyywrap
%option yylineno

%%

%{
  /*
   * These lines go at the top of the lexing function.  We only want to
   * initialize the indentation level stack once by pushing a 0 onto it (the
   * indentation stack should never be empty, except immediately after it is
   * created).
   */
  if (_indent_stack.empty()) {
    _indent_stack.push(0);
  }

  /*
   * We also want to initialize a parser state to be sent to the parser on
   * each push parse call.
   */
  yypstate* pstate = yypstate_new();

  YYSTYPE yylval;
  YYLTYPE loc;

  /*
   * This macro invokes the push parser for a new token.
   */
#define PUSH_TOKEN(category) do {                       \
  loc.first_line = loc.last_line = yylineno;              \
  int s = yypush_parse(pstate, category, &yylval, &loc);  \
  if (s != YYPUSH_MORE) {                                 \
    yypstate_delete(pstate);                              \
    return s;                                             \
  }                                                       \
} while (0)
%}
^[ \t]*\r?\n  /* Skip blank lines */

^[ \t]*#.*\r?\n  /* Skip whole-line comments. */

#.*$  /* Skip comments on the same line as a statement. */

^[ \t]+ {
  /*
   * Handle indentation as described in Python docs linked above. Note that
   * this rule's pattern treats leading spaces and leading tabs equivalently,
   * which could cause some unexpected behavior (compared to normal Python
   * indentation behavior) if they're combined in a single line.  For the
   * purposes of this project, that's OK.
   */
  if (_indent_stack.top() < yyleng) {
    /*
     * If the current indentation level is greater than the previous indentation
     * level (stored at the top of the stack), then emit an INDENT and push the
     * new indentation level onto the stack.
     */
     PUSH_TOKEN(yylval.category = INDENT);
    _indent_stack.push(yyleng);
  } else {
    /*
     * If the current indentation level is less than or equal to the previous
     * indentation level, pop indentation levels off the stack until the top is
     * equal to the current indentation level.  Emit a DEDENT for each element
     * popped from the stack.
     */
     while (!_indent_stack.empty() && _indent_stack.top() != yyleng) {
       _indent_stack.pop();
       PUSH_TOKEN(yylval.category = DEDENT);
    }

    /*
     * If we popped everything off the stack, that means the current
     * indentation level didn't match any on the stack, which is an indentation
     * error.
     */
    if (_indent_stack.empty()) {
      std::cerr << "Error: Incorrect indentation on line " << yylineno
        << std::endl;
      return 1;
    }
  }
}

^[^ \t\r\n]+ {
  /*
   * If we find a line that's not indented, pop all indentation levels off the
   * stack, and emit a DEDENT for each one.  Then, call REJECT, so the next
   * rule matching this token is also applied.
   */
  while (_indent_stack.top() != 0) {
    _indent_stack.pop();
    PUSH_TOKEN((yylval.category = DEDENT));
      }
  REJECT;
}

\r?\n {
  /*
   * This rule will apply only to endlines that come after a statement.
   * Endlines assocuated with empty lines and comments are handled above.
   * This rule handles both Unix-style and Windows-style line endings.
   */
              PUSH_TOKEN ((yylval.category = NEWLINE));
}

<<EOF>> {
  /*
   * If we reach the end of the file, pop all indentation levels off the stack
   * and emit a DEDENT for each one.
   */
  while(_indent_stack.top() != 0) {
    _indent_stack.pop();
         PUSH_TOKEN((yylval.category = DEDENT));
           }
    int endNum = yypush_parse(pstate, 0, NULL, &loc);
    yypstate_delete(pstate);
    return endNum;
}

[ \t]  /* Ignore spaces that haven't been handled above. */


"=" {
  yylval.category = ASSIGN;
  PUSH_TOKEN(yylval.category);
}

"+" {
  yylval.category = PLUS;
  PUSH_TOKEN(yylval.category);
}

"-" {
  yylval.category = MINUS;
  PUSH_TOKEN(yylval.category);
}

"*" {
  yylval.category = TIMES;
  PUSH_TOKEN(yylval.category);
}

"/" {
  yylval.category = DIVIDEDBY;
  PUSH_TOKEN(yylval.category);
}

":" {
  yylval.category = COLON;
  PUSH_TOKEN(yylval.category);
}

"(" {
  yylval.category = LPAREN;
  PUSH_TOKEN(yylval.category);
}

")" {
  yylval.category = RPAREN;
  PUSH_TOKEN(yylval.category);
}

"==" {
  yylval.category = EQ;
  PUSH_TOKEN(yylval.category);
}


"!=" {
  yylval.category = NEQ;
  PUSH_TOKEN(yylval.category);
}


">" {
  yylval.category = GT;
  PUSH_TOKEN(yylval.category);
}


">=" {
  yylval.category = GTE;
  PUSH_TOKEN(yylval.category);
}


"<" {
  yylval.category = LT;
  PUSH_TOKEN(yylval.category);
}


"<=" {
  yylval.category = LTE;
  PUSH_TOKEN(yylval.category);
}


"," {
  yylval.category = COMMA;
  PUSH_TOKEN(yylval.category);
}


":" {
  yylval.category = COLON;
  PUSH_TOKEN(yylval.category);
}


"and" {
    yylval.category = AND;
  PUSH_TOKEN(yylval.category);
}

"break" {
  yylval.category = BREAK;
PUSH_TOKEN(yylval.category);
}


"def" {
yylval.category = DEF;
PUSH_TOKEN(yylval.category);
}


"elif" {
yylval.category = ELIF;
PUSH_TOKEN(yylval.category);
}

"else" {
yylval.category = ELSE;
PUSH_TOKEN(yylval.category);
}

"for" {
yylval.category = FOR;
PUSH_TOKEN(yylval.category);
}

"if" {
yylval.category = IF;
PUSH_TOKEN(yylval.category);
}

"not" {
yylval.category = NOT;
PUSH_TOKEN(yylval.category);
}

"or" {
yylval.category = OR;
PUSH_TOKEN(yylval.category);
}

"return" {
yylval.category = RETURN;
PUSH_TOKEN(yylval.category);
}

"while" {
yylval.category = WHILE;
PUSH_TOKEN(yylval.category);
}

"True" {
yylval.category = TRUE;
PUSH_TOKEN(yylval.category);
}

"False" {
yylval.category = FALSE;
PUSH_TOKEN(yylval.category);
}

[a-zA-Z_][a-zA-Z0-9_]* {
  yylval.str = new std::string(yytext, yyleng);
  /* return IDENTIFIER; */
  PUSH_TOKEN(IDENTIFIER);
}


[0-9]*"."[0-9]+     {
yylval.str = new std::string(yytext, yyleng);
PUSH_TOKEN(FLOAT);
}

[0-9]+ {
  yylval.str = new std::string(yytext, yyleng);
  PUSH_TOKEN(INT);
}

. {
  std::cerr << "Unrecognized token on line " << yylineno << ": " << yytext
    << std::endl;
  return 1;
}

%%