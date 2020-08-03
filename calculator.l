/* Autor: Oliver Schäfer, verändert durch J. Hättig, M. Stark, J. Weiß, 
	  weiter verändert durch M. Kluge und S. Rösch
   Datum: Mittwoch 8. Juli 2020
   Zweck: Lex-Datei zur Analyse der Token eines Taschen-
          rechners für Grundrechenoperationen, Potenzieren, Quadrat-
	  wurzelziehen und Modulorechnung auf (ir-)rationalen Zahlen
	  als Teil eines Parsers. Zusätzlich Beträge verarbeitet werden. 
	  Aus- und Eingabe können auch als Dual-, Oktal- oder Hexa-
	  dezimalzahl erfolgen, sofern es sich um natürliche Zahlen
	  handelt (außer Dual, da sind auch positive rationale Zahlen
	  möglich. */
	 
nat		(0|([1-9][0-9]*))
rat		{nat}"."[0-9]*|"."[0-9]*|{nat}"."
num		"(-"{nat}")"|{nat}|"(-"{rat}")"|{rat}
bin		("0b"[01]*)
hex		("0x")(0|([1-9a-f][0-9a-f]*))
okt		("0k")(0|([1-7][0-7]*))
error		"+-"|"-+"|"++"|"--"	    

%%

"BIN"		{ return BIN ; }//BIN wird eingegeben, die Ausgabe des Ergebnisses erfolgt als Binärzahl. //Verschlankung: BIN führt direkt zu rationaler Binärzahl
"HEX"		{ return HEX ; } // Eingabe von HEX -> Ausgabe als Hexadezimalzahl
"OKT"		{ return OKT ; } //OKT wird eingegeben, die Ausgabe des Ergebnisses, erfolgt als Oktalalzahl.
		
{num}		{ if (yytext[0]=='(') {
			yylval = atof (yytext+1) ; //"(" gehört zum Suchmuster von num und würde mit übergeben werden, was zu Fehlern führt.
						   //mit yytext+1 werden nur die Ziffern ohne die öffnende Klammer übergeben.
		  }else{
			yylval = atof (yytext) ;
		  }
		  return NUM; }

{bin}		{ yylval = (double) bin2int (yytext+2); //Übergibt den BIN an den Parser und startet beim 3. Zeichen in der Zeichenkette.
		  return NUM; }
{hex}		{ yylval = (double) hex2int (yytext+2); //Übergibt den NUM an den Parser und startet beim 3. Zeichen in der Zeichenkette.
	          return NUM; }	
{okt}		{ yylval = (double) okt2int (yytext+2); //Übergibt den NUM an den Parser und startet beim 3. Zeichen in der Zeichenkette.
	          return NUM; }

"+"		{ return ADD; }
"-"		{ return SUB; }
"*"		{ return MUL; }
"/"		{ return DIV; }
"**"		{ return POW; }
"sqrt"		{ return SQRT; }
"%"		{ return MOD; }
"("		{ return OP;  }
")"		{ return CP;  }
"|"		{ return ABS; }
\n		{ return EOL; }
[ \t]		{ }
{error}		{ printf ("\n> mathematischer Fehler: %s\n", yytext);
		  yyterminate (); }
.		{ printf ("\nunerwartetes Zeichen >%c<!\n", *yytext);
		  yyterminate (); }


%%

int bin2int (char *zahl) {
	int i,z;
	z=0.0;
	for ( i=0;  i < strlen(zahl);  i++) {
	z=2*z+ (zahl[i])-48; //atoi nicht möglich da volle Zeichenkette erwartet
                                    //und nicht nur ein Zeichen. Daher nehme ich nur den 
				    //Int-Wert ((int) ("0") = 48, (int) ("1") = 49, weil 
 				    //das die AscII-Codes der beiden Zeichen sind) und 
				    //subtrahiere 48 um 0 bzw. 1 zu erhalten
	}
	return z;
}

int hex2int (char *zahl) {
	int i,z;
	z=0;
	for (i=0; i < strlen(zahl); i++) {
	if (zahl[i] < 58) z=16*z+ (int)  (zahl[i])-48; //atoi nicht möglich da volle Zeichenkette erwartet und nicht nur ein Zeichen. Daher nehme ich nur den Int wert und subtrahiere 48 (bzw. 87 bei a-f) um den AsccII code zu erhalten
	else z = 16*z + (int) (zahl[i]-87);
	}
	return z;
}

int okt2int (char *zahl) {
	int i,z;
	z=0;
	for (i=0; i < strlen(zahl); i++) {
	z=8*z+ (int)  (zahl[i])-48; //atoi nicht möglich da volle Zeichenkette erwartet und nicht nur ein Zeichen. Daher nehme ich nur den Int wert und subtrahiere 48 um den AsccII code zu erhalten
	}
	return z;
}

