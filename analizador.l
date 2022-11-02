%{
/*
  Analizador sintáctico en lex para
  el lenguaje descrito en clase.
  
  Integrantes:
    - Núñez Quintana Luis Axel 
	    Hecho por Axel -> Ax
	- Leyva Mercado Christian Alejandro
	    Hecho por Christian -> 
*/

// Bibliotecas/Headers
#include <stdio.h>
#include <stdlib.h>

// Variables Globales/ Constantes
FILE *archSal; // Archivo de salida
%}

PalabraReservada alternative|big|evaluate|instead|large|loop|make|number|other|real|repeat|select|small|step|stop|symbol|throw
Identif \$([a-z]|[A-Z])+
digCero [0-9]
CerosInicio 0{digCero}+
digUno [1-9]
digSieteCero [0-7]
digSieteUno [1-7]
constantesNumEnt 0|({digUno}({digCero})*)
constantesNumOct (o|O)0|(o|O)({digSieteUno}({digSieteCero})*)
ConstantesNum {constantesNumEnt}|{constantesNumOct}
constantesRealDec 0|{digCero}*{digUno}
ConstantesReal {constantesNumEnt}\.{constantesRealDec}
ConstantesCad \"[^"'\n]([^"'\n])+\"|'[^'\n]'|\"'\"
SimbolosEsp [(){},:;]|\[|\]
OperadoresArit \+|\-|\*|\/|%|\\|\^
OperadoresRela1 <=|>=|==|!=
OperadoresRela2 <|>
OperadoresAsig =
FinDeLinea " "+|\n

%%
{PalabraReservada}	{
  printf("Soy una palabra reservada: %s\n", yytext);
}
{Identif}	{
  printf("Soy un identificador: %s\n", yytext);
}
{CerosInicio} {
  printf("Soy un error (0 antes de numero): %s\n", yytext);
}
{ConstantesNum} {
  printf("Soy un numero entero: %s\n", yytext);
}
{ConstantesReal} {
  printf("Soy un numero real: %s\n", yytext);
}
{ConstantesCad} {
  printf("Soy una cadena: %s\n", yytext);
}
{SimbolosEsp} {
  printf("Soy un simbolo especial: %s\n", yytext);
}
{OperadoresArit} {
  printf("Soy un operador aritmetico: %s\n", yytext);
}
{OperadoresRela1} {
  printf("Soy un operador relacional de dos caracteres: %s\n", yytext);
}
{OperadoresRela2} {
  printf("Soy un operador relacional de un caracter: %s\n", yytext);
}
{OperadoresAsig} {
  printf("Soy un operador de asignacion: %s\n", yytext);
}
{FinDeLinea} {
  printf("");
}
. {
  printf("Soy un error: %s\n", yytext);
}
%%
int yywrap(){return(1);}

int main(){
	yylex();
	return 0;
}
