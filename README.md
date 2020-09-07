# flex-bison-calculator
Calculator 

The calculator is capable of calculatin decimal, hexadecimal, octal and binary numbers. Decimals can be real numbers, binaries positive real numbers, hexadecimal and octal only natural numbers including zero.
It contains the ability of calculating sums, differences, products and quotients as well as absolute value and modulo-calculation.
It also can extract a squareroot and exponentiate.

Use the makefile script to compile and ./calc to start
or use this commands:

bison -d calc.y

flex calc.l

gcc calc.tab.c lex.yy.c -o calc -lm
