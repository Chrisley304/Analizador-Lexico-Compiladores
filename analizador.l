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
const int LONGITUD_MAXIMA_CADENAS = 20;

// Estructuras necesarias para las tablas:

// Para las linked lists
struct Nodo{
  int posicion;
  int clase;
  char *valor;
  struct Nodo *sig;
};

struct Lista{
  struct Nodo *head, *tail;
};

struct Lista *crearLista()
{
  struct Lista *lista;
  lista = (struct Lista *)malloc(sizeof(struct Lista));
  if (lista == NULL)
  {
      printf("No se pudo reservar lista\n");
  }
  lista->head = NULL;
  lista->tail = NULL;
  return lista;
}

void agregarALista(struct Lista *lista, struct Nodo *nuevo)
{
  // Si la lista esta vacia:
  if (lista->head == NULL)
  {
    lista->head = nuevo;
  }
  else
  {
    lista->tail->sig = nuevo;
  }
  lista->tail = nuevo;
}

struct Nodo *crearNuevoNodo(int posicion,int clase, char *valor)
{
  struct Nodo *nuevoNodo = NULL;
  nuevoNodo = malloc(sizeof(struct Nodo));
  nuevoNodo->sig = NULL;
  nuevoNodo->posicion = posicion;
  nuevoNodo->clase = clase;
  nuevoNodo->valor = valor;
  return nuevoNodo;
}

// Catalogos
// 0 -> Palabras reservadas
char palabrasReservadas[][LONGITUD_MAXIMA_CADENAS] = {"alternative","big","evaluate","instead","large","loop","make","number","other","real","repeat","select","small","step","stop","symbol","throw"};
// 7 Operadores relacionales.
char operadoresRelacionales[][LONGITUD_MAXIMA_CADENAS] = {"<",">","<=",">=","==","!="};

// Tablas:
struct Lista *identificadoresList;
// 2 -> Constantes numéricas enteras. 
struct Lista *enterosList;
// 3 -> Constantes numéricas reales. 
struct Lista *realesList;
// 4 -> Constantes cadenas.
struct Lista *cadenasList;
// Tabla de tokens
struct Lista *tokensList;

// Contadores para llevar la 'cuenta' de la posicion en la tabla
int contTokens = -1;
int contIdent = -1;
int contEnteros = -1;
int contReales = -1;
int contCadenas = -1;

// Para obtener la posicion del catalogo de palabras reservadas 
int buscaReservada(char* busqueda){
  for(int i = 0; i< 17; i++){
    if(strcmp(busqueda, palabrasReservadas[i]) == 0){
      return i;
    }
  }
  return -1;
}
// Parser de int a string
char* parseInttoString(int numero){
  int length = snprintf( NULL, 0, "%d", numero );
  char* numStr = malloc( length + 1 );
  snprintf( numStr, length + 1, "%d", numero );
  return numStr; 
}


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
ConstantesCad \"[^"'\n]([^"'\n])+\"|'[^'\n]'|\"'\"
SimbolosEsp [(){},:;]|\[|\]
OperadoresArit \+|\-|\*|\/|%|\\|\^
OperadoresRela1 <=|>=|==|!=
OperadoresRela2 <|>
OperadoresAsig =
FinDeLinea " "+|^.

%%
{PalabraReservada}	{
  int pos = buscaReservada(yytext);
  contTokens++;
  // Parse de int a str para la struct
  char* posStr = parseInttoString(pos);
  struct Nodo *temp = crearNuevoNodo(contTokens,0,posStr);
  agregarALista(tokensList,temp);
}
{Identif}	{
  contTokens++;
  contIdent++;
  // Se añade a la tabla de identificadores
  struct Nodo *tempTabla = crearNuevoNodo(contIdent,1,yytext);
  agregarALista(identificadoresList,tempTabla);
  // Se añade a la tabla de tokens
  char* posStr = parseInttoString(contIdent);
  struct Nodo *tempToken = crearNuevoNodo(contTokens,1,posStr);
  agregarALista(tokensList,tempToken);
  // printf("El ultimo de la linked list de Tokens es %d: %d | %s",tokensList->tail->posicion,tokensList->tail->clase,tokensList->tail->valor);
}
{MuchosCero} {
  printf("Soy un error (Más de un 0 al inicio): %s\n", yytext);
}
{ConstantesNum} {
  contTokens++;
  contEnteros++;
  // Se añade a la tabla de identificadores
  struct Nodo *tempTabla = crearNuevoNodo(contEnteros,2,yytext);
  agregarALista(identificadoresList,tempTabla);
  // Se añade a la tabla de tokens
  char* posStr = parseInttoString(contEnteros);
  struct Nodo *tempToken = crearNuevoNodo(contTokens,2,posStr);
  agregarALista(tokensList,tempToken);
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
  // Se inicializan las variables de las tablas
  identificadoresList = crearLista();
  enterosList = crearLista(); 
  realesList = crearLista();
  cadenasList = crearLista();
  tokensList = crearLista();
  // Se comienza a ejecutar lex
	yylex();
	return 0;
}
