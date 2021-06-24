%{
  #include <iostream>
  #include <vector>
  #include <set>
  using namespace std;



  //Data Struc to hold Words
  struct word {
    string category;
    string lexeme;
  };

  //Array To hold words
  vector<struct word> words;



  set<string> identifiers;

  bool error = false;

  //Save Word Function
  void save_word(string lexeme, string category) {
    struct word word = { 
      lexeme, 
      category 
      };
    words.push_back(word); 
  }


int inStack[128];
int inStackPoint = 0;

void indent_detect(int currIndent) {
    while(currIndent != inStack[inStackPoint]) {
        if(currIndent > inStack[inStackPoint]) {
          inStackPoint += 1;
          inStack[inStackPoint] = currIndent;
          save_word("INDENT", "");
        } 
        else {
          inStackPoint -= 1;
            save_word("DEDENT", "");
        }
    }
}
%}

NUMB   [0-9]
LETT   [a-zA-Z_]

%option yylineno
%option noyywrap

%%

%{
  // Goes at the top of yylex()
  /* words.push_back(); */
%}


^[ \t]* {
  indent_detect(yyleng);
}
^(#[^\n]*)?\n {
 //comments allowed

}
and {
  save_word("AND         ", yytext);
}

break {
  save_word("BREAK        ", yytext);
}

def {
  save_word("DEF         ", yytext);
}

elif {
  save_word("ELIF        ", yytext);
}

"else" {
  save_word("ELSE        ", yytext);
}

"for" {
  save_word("FOR          ", yytext);
}

"if" {
  save_word("IF          ", yytext);
}

"not" {
  save_word("NOT         ", yytext);
}

"or" {
  save_word("OR         ", yytext);
}

"return" {
  save_word("RETURN      ", yytext);
}

"while" {
  save_word("WHILE       ", yytext);
}


"=" {
  save_word("ASSIGN      ", yytext);
}

"+" {
  save_word("PLUS        ", yytext);
}

"-" {
  save_word("MINUS        ", yytext);
}

"*" {
  save_word("TIMES       ", yytext);
}

"/" {
  save_word("DIVIDEDBY   ", yytext);
}

"==" {
  save_word("EQ          ", yytext);
} 

"!=" {
  save_word("NEQ           ", yytext);
}

">" {
  save_word("GT          ", yytext);
}

">=" {
  save_word("GTE           ", yytext);
} 

"<" {
  save_word("LT          ", yytext);
}

"<=" {
  save_word("LTE           ", yytext);
}


"(" {
  save_word("LPAREN      ", yytext);
}

")" {
  save_word("RPAREN      ", yytext);
}

":" {
  save_word("COLON       ", yytext);
}

"," {
  save_word("COMMA       ", yytext);
}

"\n" {
  save_word("NEWLINE       ", "");
}

-?{NUMB}+\.{NUMB}* {
    save_word("FLOAT       ", yytext);
}

-?{NUMB}+ {
    save_word("INTEGER     ", yytext);
}

True {
    save_word("BOOLEAN     ", "1");
}
False {
    save_word("BOOLEAN     ", "0");
}
({LETT}|{NUMB})* {
    save_word("IDENTIFIER  ", yytext);
}

[ ]+ {

}
<<EOF>> {
  if (error) {
    return 1;
  }
 indent_detect(0); //The <<EOF>> pattern can be used in a Flex rule to detect when your scanner has reached the end of the source code file.
 // This can be helpful for inserting any final DEDENT tokens that are needed at the end of the source code.
  return 0;
}
%%

int main() {
  inStack[0] = 0; 
  if (!yylex()) {
    for (int i = 0; i < words.size(); i++) {
      cout << words[i].category <<  words[i].lexeme << endl;

  }
  }
}
