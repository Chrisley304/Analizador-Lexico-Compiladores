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
const int LONGITUD_MAXIMA_CADENAS = 50;

// Estructuras necesarias para las tablas:

// Para las linked lists
typedef struct{
  int clase;
  char valor[LONGITUD_MAXIMA_CADENAS];
  Nodo *sig;
}Nodo;

typedef struct{
  struct Nodo *head,*tail;
}Lista;

Lista* crearLista(){
  Lista *lista;
  lista=(Lista*)malloc(sizeof(Lista));
  if(lista==NULL)
  {
    printf("No se pudo reservar lista\n");
  }
  lista->h=NULL;
  lista->t=NULL;
  return lista;
}

void agregarALista(Lista *lista, Nodo *nuevo){
  // Si la lista esta vacia:
  if(*lista.h == NULL){
    lista->h = nuevo;
  }else{
    lista->t->sig = nuevo;
  }
  lista->t=nuevo;
}

Nodo *crearNuevoNodo(int clase, char* valor){
  Nodo *nuevoNodo = NULL;
  nuevoNodo = malloc(sizeof(Nodo));
  nuevoNodo->sig = NULL;
  nuevoNodo.clase = clase;
  nuevoNodo.valor = valor;
  return nuevoNodo;
}

// Tablas & Catalogos
// 0 -> Palabras reservadas
char palabrasReservadas[][LONGITUD_MAXIMA_CADENAS] = {"alternative","big","evaluate","instead","large","loop","make","number","other","real","repeat","select","small","step","stop","symbol","throw"};
// 1 -> Identificadores.
Lista *identificadoresList = crearLista();
// 2 -> Constantes numéricas enteras. 
Lista *enterosList = crearLista();
// 3 -> Constantes numéricas reales. 
Lista *realesList = crearLista();
// 4 -> Constantes cadenas.
Lista *cadenasList = crearLista();
// 7 Operadores relacionales.
char operadoresRelacionales[][LONGITUD_MAXIMA_CADENAS] = {"<",">","<=",">=","==","!="};
// Tabla de tokens
Lista *tokensList = crearLista();

%}

reserv1 alternative|big|evaluate|instead|large|loop
reserv2 make|number|other|real|repeat|select|small
reserv3 step|stop|symbol|throw
PalabraReservada {reserv1}|{reserv2}|{reserv3}
Identif \$([a-z]|[A-Z])+
MuchosCero 0(0)+
digCero [0-9]
digUno [1-9]
digSieteCero [0-7]
digSieteUno [1-7]
ConstantesNumEnt 0|({digUno}({digCero})*)
ConstantesNumOct (o|O)0|(o|O)({digSieteUno}({digSieteCero})*)
ConstantesNum {ConstantesNumEnt}|{ConstantesNumOct}
ConstantesRealDec 0|{digCero}*{digUno}
ConstantesReal {ConstantesNumEnt}\.{ConstantesRealDec}
ConstantesCad (\"[^(\"|'|^.)]([^(\"|'|^.)])+\")|('([^('|^.)])')|(\"'\")
SimbolosEsp \[|\]|\(|\)|\{|\}|,|:|;
OperadoresArit \+|\-|\*|\/|%|\\|\^
OperadoresRela1 <=|>=|==|!=
OperadoresRela2 <|>
OperadoresAsig =
FinDeLinea " "+|^.

%%
{PalabraReservada}	{
  printf("Soy una palabra reservada: %s\n", yytext);
}
{Identif}	{
  printf("Soy un identificador: %s\n", yytext);
}
{MuchosCero} {
  printf("Soy un error (Más de un 0 al inicio): %s\n", yytext);
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
  printf("");
}
%%
int yywrap(){return(1);}

int main(){
	yylex();
	return 0;
}
