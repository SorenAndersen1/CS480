#include <iostream>
#include <map>

extern int yylex();

/* VARIABLES FROM PARSER.Y */
extern std::map<std::string, float> symbols;
extern bool errorDetection;
extern std::string* overflowPrograms;

/* Your parser should generate a working C/C++ program, so it will need to contain boilerplate things like #include statements and a main() function. 
it will probably be easiest if you don't worry about adding things like #include <iostream> or wrapping your target program wihin a main() function 
until the parse is complete. If your parse simply translates a sequence of Python statements into a corresponding sequence of 
C/C++ statements, you can wrap this translated sequence in a main() function at the very end.*/

int main() {
  if (!yylex() && !errorDetection) {
  	/* CHECK TO SEE IF DONE AND NO ERRORS */
	  std::cout << "#include <iostream>\nint main(){\n";
	  /* CLASSIC C++ SETUP*/
	  std::map<std::string, float>::iterator i; /* Set Iterator to allow to print symbols*/
	  /* Then Print numbers*/

  for (i = symbols.begin(); i != symbols.end(); i++) {
	std::cout << "double " << i->first << ";\n";
  	}
    /* Fomatting per example_output/ */
	std::cout << "\n" << "/* Begin program */" << "\n\n";
    /* Actually print programs */
	std::cout << *overflowPrograms << std::endl;

	std::cout << "\n" << "/* End program */" << "\n\n";

	    /* Print Print statements */
  for (i = symbols.begin(); i != symbols.end(); i++) {
	std::cout << "std::cout << \"" << i->first << ": \" << " << i->first << " << std::endl;\n";
	}

	std::cout << "}\n"; /* Finish Print out*/
    
    return 0;

  } else {

    return 1; /* Hope you dont get this*/

  }
}