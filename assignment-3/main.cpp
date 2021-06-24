#include <iostream>
#include <map>
#include <vector>
#include <queue>
#include <string>
#include <sstream>
#include "parser.hpp"

extern int yylex();

/*
 * These values are globals defined in the parsing function.
 */
extern std::map<std::string, float> symbols;
extern bool _error;

struct AST {
	int ID;
  bool isBox;
	std::string* value;
	std::vector<struct AST*> child;
};

extern struct AST* root;


void print(struct AST *node, struct AST *root, int preLevel){
	for(int i = 0; i< node->child.size(); ++i){
		if(node->child[i]->value != 0 && node->value != 0){
      if(node->child[i]->isBox){
			  std::cout << "n0_"<< node->ID <<" -> " << "n0_"<< node->child[i]->ID<<";\n"<< "n0_" << node->child[i]->ID << " [shape=box," <<"label=\""<< *node->child[i]->value <<"\"];\n" ;
      }
      else{
        std::cout << "n0_"<< node->ID <<" -> " << "n0_"<< node->child[i]->ID<<";\n"<< "n0_" << node->child[i]->ID << " [shape=oval," <<"label=\""<< *node->child[i]->value <<"\"];\n" ;

      }
		}	
		print(node->child[i], root, preLevel + 1);
	}
	
}


int main(int argc, char const *argv[]) {
	if (!yylex() && _error == false) {
		std::cout<<"digraph G {\nn0_3[label=\"Block\"]" <<";\n";
		print(root, root,0);
		std::cout<<"}" << "\n";
		return 0;
	} else {
		return 1;
	}
}
