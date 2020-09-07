/* define type of yylval */
%define api.value.type {double}


/* token definition */
%token NUM
%token ADD SUB MUL DIV MOD OP CP ABS BIN HEX OCT EOL 


%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

extern int yylex();

void yyerror(const char* s);
char * rat2bin(double r); 
double myfabs (double x);
double mypow (double x, double y);
double mysqrt (double x);
%}


/* Priority setting: upper operations bind weaker */
%left MOD
%left ADD SUB
%left MUL DIV POW SQRT


%start calclist


%%
calclist:
  | calclist exp EOL {printf("= %.10g\n", $2); } 
							  //%.10g displays up to 10 decimal places
  | calclist BIN exp EOL {printf("= 0b%s\n", rat2bin($3)); } 
  | calclist HEX exp EOL {printf("= 0x%x\n", (int) $3);} 
  | calclist OCT exp EOL {printf("= 0k%o\n", (int) $3);} 
  ;

exp:
    NUM		{ $$ = $1; }
  | OP  exp CP  { $$ = $2; }
  | ABS exp ABS { $$ = myfabs($2); } 
				     // myfabs takes double and returns double (abs func
				     // from <math.h> works on int)
  | exp ADD exp { $$ = $1 + $3; }
  | exp SUB exp { $$ = $1 - $3; }
  | SUB exp	{ $$ = -$2;	}
  | exp MUL exp { $$ = $1 * $3; }
  | exp DIV exp { $$ = $1 / $3; }
  | exp POW exp { $$ = mypow($1, $3); }
  				    // mypow takes double and returns double (pow func
				    // from <math.h> works on int)
  | SQRT exp	{ $$ = mysqrt($2); }
  				    // mypow takes double and returns double (sqrt func
				    // from <math.h> works on int)
  | exp MOD exp { $$ = (((int) $1 % (int) $3) + (int) $3) % (int) $3; } 
  ;							   // % works only on positive numbers
							   // for correct results on negative 
							   // numbers as well the modulo operand  
							   // first has to be added to the 
							   // calculation and second the result
							   // used as first operand to another
							   // modulo operation
							   // source: https://manderc.com/operators/
							   //         modoperator/index.php
							   


%%

void main() {
	printf(
	"************binary, hexadecimal and octal calculator************\n"
	"*********************for (rational) numbers*********************\n"
	"* Operations:                                                  *\n"
	"* +, -, *, /, ** (power), sqrt (square root), % (infix modulo),*\n" 
	"* (,), |...| (absolute value)                                  *\n"
	"* Input examples: 42, 0b101010, 0x2a, 0k52                     *\n"
	"*                 BIN 3*14, HEX 0b11*0k16, OCT 0k3*0b101010    *\n"
	"****************************************************************\n");
	yyparse ();
}


void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
}


char * rat2bin (double r) { 
    int n, c, i, j, k, l, x, point ;
    static  char  result[33]; 
    char r_as_string[65], decimal_places[65], decimal_places_doubled[65];
    char decimal_placesRest[65], tmp[65];
    c = 0;
    i = 0;
    j = 0;
    k = 0;
    l = 0;
    x = 0;
    n = (int) r;
    point = atoi(".");
    for (l = 0; l < 33; l++) { 
		result[l] = '\0';
    }
    for (l = 0; l < 65; l++) { 
		r_as_string[l] = '\0';
		decimal_places[l] = '\0';
		decimal_places_doubled[l] = '\0';
		decimal_placesRest[l] = '\0';
		tmp[l] = '\0';
    }
    snprintf(r_as_string,64, "%f", r); 
    if (n==0){
	result[0]='0';	
    }
    while (n>=1) {	
	if (n%2==1) {
	    strcat(tmp,"1");
	    strcat(tmp,result);
		for (i=0;i<31;i++) {
		    result[i]=tmp[i];
		    tmp[i]=0;
		}
		n = n/2;
	}else if (n%2==0) {
	    strcat(tmp,"0");
		strcat(tmp,result);
		for (i=0;i<31;i++) {
		    result[i]=tmp[i];
		    tmp[i]=0;
		}
			n = n/2;
		}
	}
	for (i=0;i<strlen(r_as_string);i++) { // finding the point where the
										  // decimal places start
		if (46==r_as_string[i]) {
	       		 c = i+1;
	   		 }
		}
		for (j=c; j<strlen(r_as_string); j++) {	  // calculating decimal
										 // places for the binary result
	   	 decimal_places[j-c] = r_as_string[j];
		}
	x = atoi(decimal_places);	// x is the the decimal places of r but
								// in form of a natural number
        if (x==0) {
		return result;		
	}else{
		strcat(result,".");	// puts the dot in front of the decimal 
							// places
		for (k = 31 - strlen(result); k>=0; k--) { // start of 
					// conversion of decimal places to binary fraction
		    sprintf(decimal_places_doubled,"%d",x*2);	
		    sprintf(decimal_places,"%d",x);
		    x=x*2;
	    
		    if (strlen(decimal_places_doubled)>strlen(decimal_places)) {	
		 // if x*2 > 1
		        strcat(result,"1");					
		     // append 1 to result
	        	for (i = 1; i<strlen(decimal_places_doubled); i++) {	
	         // x = x - 1
		           decimal_placesRest[i-1] = decimal_places_doubled[i];
		        }
	        	x = atoi(decimal_placesRest);
		        if (x==0) {					//terminating case: x == 0
		            break;
		        }
		    }else{
	        	strcat(result,"0");
		    }
		}
	}
  	return result;
}


double myfabs(double x) { 
	return fabs(x);
}


double mypow (double x, double y) {
	return pow(x,y);
}


double mysqrt (double x) {
	return sqrt(x);
}
