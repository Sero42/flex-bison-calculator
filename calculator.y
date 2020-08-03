/* Autor: Oliver Schäfer, verändert durch J. Hättig, M. Stark, J. Weiß, weiter verändert 
	  durch M. Kluge und S. Rösch
   Datum: Mittwoch 8. Juli 2020
   Zweck: Parser-Datei zur Implementierung eines Taschenrechners mit Grundrechenarten,
	  Potenzieren, Quadratwurzelziehen und Modulorechnung auf (ir-)rationalen Zahlen 
	  plus Klammern und Beträge, sowie mit Auswertung der Lexem-Werte. 
	  Auch Ein- und Ausgabe von Oktal- und Hexadezimalzahlen sind möglich,
	  sofern es sich um natürliche Zahlen handelt. Positive rationale Zahlen können
	  auch als Dualzahl ausgegeben werden. */

/*definiert den Typ von yylval neu, der sonst auf int festgelegt ist. */
%define api.value.type {double}

/* TOKEN-Definition */
%token NUM ADD SUB MUL DIV MOD OP CP ABS BIN HEX OKT EOL 

/* Priorisierung: zuerst aufgeführte Operationen haben niedrigste
   Bindungskraft. Alle Operatoren sind linksassoziativ. */
%left MOD
%left ADD SUB
%left MUL DIV POW SQRT


%{
char * rat2bin(double r); //hier wird das unten im Kopf der Funktion rat2bin angesprochene Problem gelöst,
			  //dass als Rückgabewert "int" verlangt wird.
char * int2bin(double r);

double myfabs (double x);

double mypow (double x, double y);

double mysqrt (double x);
%}

%%

calclist:
  | calclist EOL 	{printf(
	"****************Taschenrechner für rationale Zahlen****************\n"
	"Funktionsweise: Werte eingeben, Entertaste drücken\n"
	"Dualzahlen: 0b, Oktalzahlen: 0k, Hexadezimalzahlen: 0x voranstellen\n"
	"Verfügbare Rechenoperationen: +, -, *, /, ** (Potenzieren), \n"
	"sqrt (Quadratwurzel), % (Infix-Modulo-Rechnung),\n"
	"(,), |...| (Absolutbetrag)\n"
	"Mögliche Darstellungsweisen: dezimal (Standard), binär (positive\n"
	"rationale Zahlen), hexadezimal (natürliche Zahlen),\n"
	"oktal (natürliche Zahlen). Dazu muss BIN, HEX bzw. OKT voran-\n"
	"gestellt werden.\n"
	"*******************************************************************\n"); }

  | calclist exp EOL {printf("= %.10g\n", $2); } //%.10g gibt eine Dezimalzahl mit mindestens 0 und maximal 10 Nachkommastellen aus.
  //| calclist BIN exp EOL {printf("=0b%s\n", int2bin((int) $3)); } //Alternative 1: Ausgabe natürlicher Zahlen im Dualsystem (wie HEX und OKT)
  | calclist BIN exp EOL {printf("= 0b%s\n", rat2bin($3)); } //Alternative 2: Ausgabe von rationalen Zahlen im Dualsystem
  | calclist HEX exp EOL {printf("= 0x%x\n", (int) $3);} 
  | calclist OKT exp EOL {printf("= 0k%o\n", (int) $3);} 

  ;

exp:
    NUM		{ $$ = $1; }
  | OP  exp CP  { $$ = $2; }
  | ABS exp ABS { $$ = myfabs($2); } //myfabs nimmt als Argument ein double und gibt ein double zurück (abs arbeitet nur auf int)
  | exp ADD exp { $$ = $1 + $3; }
  | exp SUB exp { $$ = $1 - $3; }
  | SUB exp	{ $$ = -$2;	}
  | exp MUL exp { $$ = $1 * $3; }
  | exp DIV exp { $$ = $1 / $3; }
  | exp POW exp { $$ = mypow($1, $3); }
  | SQRT exp	{ $$ = mysqrt($2); }
  | exp MOD exp { $$ = (((int) $1 % (int) $3) + (int) $3) % (int) $3; } // % arbeitet grundsätzlich nur auf positiven Zahlen. 
  ;									// Um auch mit negativen Werten korrekte Resultate zu 
									// erhalten, ist eine Addition des Modulo-Operanden 
									// mit anschliessender erneuter Modulo-Operation 
									// notwendig. Dies funktioniert auch mit positiven Werten.
									// Quelle: https://manderc.com/operators/modoperator/index.php

%%

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

char * int2bin (double r) {
static char erg[33] = ""; //statische Speicherbelegung für konsekutive Berechnung suboptimal, Speicher muss für jeden Funktionsaufruf genullt werden.
int i,c,d,k; 
   for (i=0; i<33; i++) { //Nullen des Speichers
	erg[i]='\0'; 
   }
   for (c=31; c>=0; c --) {
        k = (int)  r >> c; 
        if (k & 1 | c==0) {
            for (d=c; d>=0; d --) {
                k = (int) r >> d; 
                if (k & 1){ 
			erg[abs(d-c)] = '1';
                }else{ 
			erg[abs(d-c)] = '0';
		}
            }
            break;
	}
    } 
    return erg;
}


char * rat2bin (double r) { //aus irgendeinem Grund verlangt makeparser hier als Rückgabewert "int"
 			  //auch wenn nichts zurückgegeben wird. void oder float oder char führen
			  //zu Fehlern. atof gibt offenbar ein double zurück, denn wenn rat2bin ein float
 			  //erwartet, führt das auch zum Fehler. 
    int n, c, i, j, k, l, x, punkt ;
    static  char  erg[33]; //erg muss "static char" sein, damit es an fester Speicheradresse gespeichert
			    //wird. Sonst wird mit return erg nur ein Zeiger zurückgegeben (oder?).
    char r_als_string[65], nachkomma[65], nachkommaVerdoppelt[65], nachkommaRest[65], tmp[65];
    c = 0;
    i = 0;
    j = 0;
    k = 0;
    l = 0;
    x = 0;
    n = (int) r;
    punkt = atoi(".");
    for (l = 0; l < 33; l++) { //Versuch, den Ergebnisstring zurückzusetzen
 	erg[l] = '\0';
    }
    for (l = 0; l < 65; l++) { //Versuch die anderen beteiligten Strings zurückzusetzen
 	r_als_string[l] = '\0';
	nachkomma[l] = '\0';
	nachkommaVerdoppelt[l] = '\0';
	nachkommaRest[l] = '\0';
	tmp[l] = '\0';
    }
    snprintf(r_als_string,64, "%f", r); //Umwandlung des Ergebniswerts (rationale Zahl) in einen String
    if (n==0){
	erg[0]='0';	//Darstellung der Vorkommanull für einen Wert ohne Vorkommaanteil
    }
    while (n>=1) {	//Darstellung des Vorkommaanteils (ginge vllt eleganter mit erg[i] = '1' bzw '0'
			//Problem: Umkehrung der Reihenfolge
	if (n%2==1) {
	    strcat(tmp,"1");
	    strcat(tmp,erg);
		for (i=0;i<31;i++) {
		    erg[i]=tmp[i];
		    tmp[i]=0;
		}
		n = n/2;
	}else if (n%2==0) {
	    strcat(tmp,"0");
		strcat(tmp,erg);
		for (i=0;i<31;i++) {
		    erg[i]=tmp[i];
		    tmp[i]=0;
		}
			n = n/2;
		}
	}
	for (i=0;i<strlen(r_als_string);i++) {	//sucht die Position des Punkts in der Stringdarstellung von r
		if (46==r_als_string[i]) {
	       		 c = i+1;
	   		 }
		}
		for (j=c; j<strlen(r_als_string); j++) {	//hier beginnt die Darstellung des Nachkommaanteils
	   	 nachkomma[j-c] = r_als_string[j];
		}
	x = atoi(nachkomma);	//x ist der Nachkommanteil von r in Form einer ganzen Zahl
        if (x==0) {
		return erg;		
	}else{
		strcat(erg,".");	//schreibt den Punkt hinter den Vorkommaanteil
		for (k = 31 - strlen(erg); k>=0; k--) {
		    sprintf(nachkommaVerdoppelt,"%d",x*2);	//Beginn des Algorithmus zur Berechnung der Binärdarstellung 
								//von Bruchteilen von 1 : x = x*2
		    sprintf(nachkomma,"%d",x);
		    x=x*2;
	    
		    if (strlen(nachkommaVerdoppelt)>strlen(nachkomma)) {	//wenn x*2 > 1
		        strcat(erg,"1");					//1 an erg dranhängen
	        	for (i = 1; i<strlen(nachkommaVerdoppelt); i++) {	//x = x - 1
		           nachkommaRest[i-1] = nachkommaVerdoppelt[i];
		        }
	        	x = atoi(nachkommaRest);
		        if (x==0) {						//terminierender Fall: x == 0
		            break;
		        }
		    }else{
	        	strcat(erg,"0");
		    }
		}
	}
  	return erg;
}

double myfabs(double x) { //vermutlich gibt es eine Lösung, die eingebaute fabs() Funktion direkt zu verwenden, aber die kenne ich nicht
	return fabs(x);
}

double mypow (double x, double y) {
	return pow(x,y);
}

double mysqrt (double x) {
	return sqrt(x);
}

