/* yywrap() makes it possible to scan several files e.g. to compile them */
%option noyywrap 

%{
#include <stdio.h>
#include "calc.tab.h"

int bin2int (char *num);
int hex2int (char *num);
int oct2int (char *num);
%}

nat		(0|([1-9][0-9]*))
rat		{nat}"."[0-9]*|"."[0-9]*|{nat}"."
num		"(-"{nat}")"|{nat}|"(-"{rat}")"|{rat}
bin		("0b"[01]*)
hex		("0x")(0|([1-9a-f][0-9a-f]*))
oct		("0k")(0|([1-7][0-7]*))
error		"+-"|"-+"|"++"|"--"	    


%%
"BIN"		{ return BIN ; } // "BIN" -> output of result as binary num
"HEX"		{ return HEX ; } // "HEX" -> output of result as hex number
"OCT"		{ return OCT ; } // "OCT" -> output of result as octal num


{num}		{ if (yytext[0]=='(') {
				yylval = atof (yytext+1) ; // "(" is part of the 
												// search pattern but 
												// shall not be passed
			}else{
				yylval = atof (yytext) ;
			}
			return NUM; }
			
{bin}		{ yylval = (double) bin2int (yytext+2); // passes NUM 
				// and sets yylval with the number following "0b"
			  return NUM; }
{hex}		{ yylval = (double) hex2int (yytext+2); // passes NUM 
				// and sets yylval with the number following "0x"
	          return NUM; }				
{oct}		{ yylval = (double) oct2int (yytext+2); // passes NUM 
				// and sets yylval with the number following "0k"
	          return NUM; }
	          
"+"			{ return ADD; }
"-"			{ return SUB; }
"*"			{ return MUL; }
"/"			{ return DIV; }
"**"		{ return POW; }
"sqrt"		{ return SQRT; }
"%"			{ return MOD; }
"("			{ return OP;  }
")"			{ return CP;  }
"|"			{ return ABS; }
\n			{ return EOL; }
[ \t]		{ }
{error}		{ printf ("\n> mathematical error: %s\n", yytext);
			  yyterminate (); }
.			{ printf ("\n unexpected symbol >%c<!\n", *yytext);
			  yyterminate (); }


%%



int bin2int (char *num) {
	int i,n;
	n=0;
	for ( i=0;  i < strlen(num);  i++) {
	n=2*n+ (num[i])-48; 
				    // value of ((int) ("0") = 48, (int) ("1") = 49  
 				    // (ASCII code of 0 and 1) to obtain 0 or 1
				    //subtract 48 
	}
	return n;
}



int hex2int (char *num) {
	int i,n;
	n=0;
	for (i=0; i < strlen(num); i++) {
	if (num[i] < 58) n=16*n+ (int)  (num[i])-48; 
							   // atoi won't work with one symbol, 
							   // it expects full string as num[i] yields
							   // to the ASCII code, -48 yields to the
							   // corresponding number 
	else n = 16*n + (int) (num[i]-87);
	}
	return n;
}



int oct2int (char *num) {
	int i,n;
	n=0;
	for (i=0; i < strlen(num); i++) {
	n=8*n+ (int)  (num[i])-48; // atoi won't work with one symbol, 
							   // it expects full string as num[i] yields
							   // to the ASCII code, -48 yields to the
							   // corresponding number 
	}
	return n;
}
