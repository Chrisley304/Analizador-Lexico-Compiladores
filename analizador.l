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
// Para obtener la posicion del catalogo de operadores aritmeticos 
int buscaOperador(char* busqueda){
  for(int i = 0; i< 6; i++){
    if(strcmp(busqueda, operadoresRelacionales[i]) == 0){
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
{CerosInicio} {
  printf("Soy un error (0 antes de numero): %s\n", yytext);
}
{ConstantesNum} {
  contTokens++;
  contEnteros++;
  // Se añade a la tabla de identificadores
  struct Nodo *tempTabla = crearNuevoNodo(contEnteros,2,yytext);
  agregarALista(enterosList,tempTabla);
  // Se añade a la tabla de tokens
  char* posStr = parseInttoString(contEnteros);
  struct Nodo *tempToken = crearNuevoNodo(contTokens,2,posStr);
  agregarALista(tokensList,tempToken);
}
{ConstantesReal} {
  contTokens++;
  contReales++;
  // Se añade a la tabla de identificadores
  struct Nodo *tempTabla = crearNuevoNodo(contReales,3,yytext);
  agregarALista(realesList,tempTabla);
  // Se añade a la tabla de tokens
  char* posStr = parseInttoString(contReales);
  struct Nodo *tempToken = crearNuevoNodo(contTokens,3,posStr);
  agregarALista(tokensList,tempToken);
}
{ConstantesCad} {
  contTokens++;
  contCadenas++;
  // Se añade a la tabla de identificadores
  struct Nodo *tempTabla = crearNuevoNodo(contCadenas,4,yytext);
  agregarALista(cadenasList,tempTabla);
  // Se añade a la tabla de tokens
  char* posStr = parseInttoString(contCadenas);
  struct Nodo *tempToken = crearNuevoNodo(contTokens,4,posStr);
  agregarALista(tokensList,tempToken);
}
{SimbolosEsp} {
  contTokens++;
  struct Nodo *tempToken = crearNuevoNodo(contTokens,5,yytext);
  agregarALista(tokensList,tempToken);
}
{OperadoresArit} {
  contTokens++;
  struct Nodo *tempToken = crearNuevoNodo(contTokens,6,yytext);
  agregarALista(tokensList,tempToken);
}
{OperadoresRela1} {
  int pos = buscaOperador(yytext);
  contTokens++;
  // Parse de int a str para la struct
  char* posStr = parseInttoString(pos);
  struct Nodo *temp = crearNuevoNodo(contTokens,7,posStr);
  agregarALista(tokensList,temp);
}
{OperadoresRela2} {
  int pos = buscaOperador(yytext);
  contTokens++;
  // Parse de int a str para la struct
  char* posStr = parseInttoString(pos);
  struct Nodo *temp = crearNuevoNodo(contTokens,7,posStr);
  agregarALista(tokensList,temp);
}
{OperadoresAsig} {
  contTokens++;
  struct Nodo *tempToken = crearNuevoNodo(contTokens,8,yytext);
  agregarALista(tokensList,tempToken);
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
