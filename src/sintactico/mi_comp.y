/**************		DEFINICIONES Y INCLUDS 		**************/
%{ 
// Librerias utilizadas
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<ctype.h>
// Variables y funciones externas
extern int yyparse();
extern "C" int yylex();
extern "C" void imprimir_tabla_de_simbolos();
extern "C" void agregar_tipoVarible_a_tabla(int posT, int type);
extern "C" int verificar_tipoVariable(int posT);
extern "C" char* nombre_varTabla(int posT);
extern "C" char* tipo_varTabla(int posTbl);
extern "C" void agrConstante(int posTbl);
extern "C" int esConstante(int posTbl);
extern "C" int comprobar_tipo_expresion(int posTbl, int vlAnt);
extern "C" int cant_varTabla();
extern "C" void agrValorConstante(int posTbl, char valor[100]);
extern "C" char* valor_varTabla(int posTbl);
extern "C" int devolver_tipoDato(char valor[100]);
extern "C" int existe_en_tabla_simbolos(char* nombre);
extern FILE *yyin;
// Funcion yyerror
int yyerror(char const*);
// Diferentes variables necesarias.
// 		- posTbl = variable auxiliar para guardar el valor en la tabla de simbolos. Guarda los $1, $2, etc
//		- nroNodo = variable utilizada para recorrer el arbol y colocar su numero de nodo correspondiente
//		- encError = variable para determinar si se encontro algun error. 
//					(0 -> no error | 1 -> si error)
//		- nroTipo = variable utilizada para controlar en la compatibilidad de tipos 
//					(-1 -> valor inicial | 1 -> Int | 2 -> Real | 3 -> String)
//		- errTipo = variable auxiliar para determinar si se encontro algun error de compatibilidad de tipo
//					(0 -> no error | 1 -> si error)
//		- comTipo = variable auxiliar para guardar el valor devuelto por l funcion 'comprobar_tipo_expresion'
//					(0 -> no error |99 -> si error)
//		- numEtiquetas = variable auxiliar pra guardar un indice que servira para diferenciar las diferentes etiquetas
//			en el codigo assembler de las funciones para string
//		- signoc = variable auxiliar para guardar los valores 'AND' y 'OR' para los nodos del arbol
//		- signo = variable auxiliar para guardar los signo de comparacion para los nodos del arbol (<,<=,>,>=,==,<>)
int posTbl, nroNodo, encError, nroTipo, errTipo, comTipo, numEtiquetas;
char signoc[5], signo[5];
// Estructura para el arbol binario
struct tnodo {
	char elemento[100];
	int nroN;
	struct tnodo *izq, *der;
};
typedef struct tnodo arbol;
arbol* arbol_sintactico = NULL;
// Estructura de las pilas
typedef struct{
	tnodo * pila [100];
	int tope;
}tpila;
// Pilas utilizadas
tpila pilaSentencias, pilaExpresion, pilaTermino, pilaFactor, pilaCondicion, pilaComparacion;
// Punteros de los diferentes nodos utilizados en el arbol
tnodo *  Pprograma, *  Psentencia, *  Pasignacion, *  Pexpresion, *  Ptermino, *  Pfactor,
	  *  Pcondicion, *  Pcomparaciones, *  Psalida, *  Pentrada, *  Pdecision, *  Prepeat,
      *  Pqequal, *  Punary, *  Plista, *  Pcuerpo;
// Estructura para guardar los nombres de las constantes creadas de las constantes en tabla de simbolos
// Necesario los nombre para luego ser utilizados en el assembler
struct tc {
	char valor[100];
	char nombre[100];
	struct tc *siguiente;
};
typedef struct tc tablaConst;
tablaConst* tabla_constantes = NULL;
tablaConst* actual_constantes = NULL;
// Estructuta para la lista de enlace doble para las sentencias del programa
struct lstSent {
	int numero;
	char valor[100];
	int der, izq;
	struct lstSent *siguiente, *anterior;
};
typedef struct lstSent lstSentAux;
lstSentAux* lista_sentencias = NULL;
lstSentAux* actual_sentencias = NULL;
// Archivos de notacion intermedia y assembler
FILE * archivoArbolSintactico;
FILE * archivoAsm;
// Funciones para el arbol
arbol* crear_nodo(char* elem, arbol* ni, arbol* nd);
arbol* crear_hoja(char* elem);
%}

/**************			 TOKENS 			**************/
%token DEFVAR
%token ENDDEF
%token CONST
%token INT
%token REAL
%token STRING
%token GET
%token PUT
%token REPEAT
%token UNTIL
%token IF
%token THEN
%token ELSE
%token ENDIF
%token QEQUAL
%token AND
%token OR
%token CTE_REAL
%token CTE_ENTERA
%token CTE_STRING
%token ID
%token MAS
%token MENOS
%token POR
%token DIVIDIDO
%token SIG_ASIGNACION
%token IGUAL
%token MENOR
%token MENOR_IGUAL
%token MAYOR
%token MAYOR_IGUAL
%token DISTINTO
%token NOT
%token PAR_ABRE
%token PAR_CIERRA
%token COR_ABRE
%token COR_CIERRA
%token DEFINE
%token SEPARDOR_COMA
%token SIG_UNARYIF
%token FIN_SENTENCIA
%token SEPARADOR
%token CONCATENACION
%start programastart

%%
programastart:
	programa {if (encError == 0) {imprimir_tabla_de_simbolos(); imprimir_arbol(); crear_archAsm();}}
	;

programa:
	sentenciadeclaracionvar acciones {Pprograma = desapilar(&pilaSentencias);}
	|acciones {Pprograma = desapilar(&pilaSentencias);}
	;
	
sentenciadeclaracionvar:
	DEFVAR {printf("DEFVAR\n");} declaracionvar ENDDEF {printf("ENDDEF\n");}
	;
	
declaracionvar:
	ID {printf("ID\n"); posTbl=$1;} DEFINE {printf("DEFINE\n");} tipo 
	|declaracionvar SEPARDOR_COMA {printf("SEPARDOR_COMA\n");} ID {printf("ID\n"); posTbl=$4;} DEFINE {printf("DEFINE\n");} tipo 
	;
	
acciones:
	acciones accion {apilar(&pilaSentencias, crear_nodo(";", desapilar(&pilaSentencias), Psentencia));}
	|accion {apilar(&pilaSentencias, Psentencia);}
	;
	
accion:
	asignacion {Psentencia = Pasignacion; if (errTipo == 1) {encError = 1; printf("Error de tipos en la asignacion\n");} errTipo = 0; nroTipo = -1;}
	|definicionconstante 
	|entrada {Psentencia = Pentrada;}
	|salida	{Psentencia = Psalida; if (errTipo == 1) {encError = 1; printf("Error de tipos en la expresion\n");} errTipo = 0; nroTipo = -1;}
	|repeat {Psentencia = Prepeat;}
	|if {Psentencia = Pdecision;}
	;
	
asignacion:
	ID {printf("ID\n"); if (verificar_tipoVariable($1) == 1) {printf("Variable '%s' no declarada\n", nombre_varTabla($1)); encError=1;} if (esConstante($1) == 1) {printf("'%s' no puede cambiar su valor porque esta declarada como constante\n", nombre_varTabla($1)); encError=1;}} SIG_ASIGNACION {printf("SIG_ASIGNACION\n");} expresiones FIN_SENTENCIA {printf("FIN_SENTENCIA\n"); comTipo = comprobar_tipo_expresion($1, nroTipo); if (comTipo == 99) {errTipo = 1;} else {if (comTipo != 0) {nroTipo = comTipo;}} Pasignacion = crear_nodo("=", crear_hoja(nombre_varTabla($1)), desapilar(&pilaExpresion));}
	;
	
definicionconstante:
	CONST {printf("CONST\n");} ID {printf("ID\n"); posTbl=$3;} SIG_ASIGNACION {printf("SIG_ASIGNACION\n");} dato FIN_SENTENCIA 
	;
	
expresion:
	expresion MAS {printf("MAS\n");} termino {apilar(&pilaExpresion, crear_nodo("+", desapilar(&pilaExpresion), desapilar(&pilaTermino)));}
	|expresion MENOS {printf("MENOS\n");} termino {apilar(&pilaExpresion, crear_nodo("-", desapilar(&pilaExpresion), desapilar(&pilaTermino)));}
	|termino {apilar(&pilaExpresion, desapilar(&pilaTermino));}
	;
	
termino:
	termino POR {printf("POR\n");} factor {apilar(&pilaTermino, crear_nodo("*", desapilar(&pilaTermino), desapilar(&pilaFactor)));}
	|termino DIVIDIDO {printf("DIVIDIDO\n");} factor {apilar(&pilaTermino, crear_nodo("/", desapilar(&pilaTermino), desapilar(&pilaFactor)));}
	|factor {apilar(&pilaTermino, desapilar(&pilaFactor));}
	;
	
factor:
	ID {printf("ID\n"); if (verificar_tipoVariable($1) == 1) {printf("Variable '%s' no declarada\n", nombre_varTabla($1)); encError=1;} comTipo = comprobar_tipo_expresion($1, nroTipo); if (comTipo == 99) {errTipo = 1;} else {if (comTipo != 0) {nroTipo = comTipo;}} apilar(&pilaFactor, crear_hoja(nombre_varTabla($1)));}
	|PAR_ABRE expresion PAR_CIERRA  {apilar(&pilaFactor, desapilar(&pilaExpresion));} 
	|unaryif {apilar(&pilaFactor, Punary); if (errTipo == 1) {encError = 1; printf("Error de tipos en la unaryif\n");} errTipo = 0; nroTipo = -1;}
	|qequal {apilar(&pilaFactor, Pqequal); if (errTipo == 1) {encError = 1; printf("Error de tipos en la qequal\n");} errTipo = 0; nroTipo = -1;}
	|CTE_ENTERA {printf("CTE_ENTERA\n"); agregar_tipoVarible_a_tabla($1,3); comTipo = comprobar_tipo_expresion($1, nroTipo); if (comTipo == 99) {errTipo = 1;} else {if (comTipo != 0) {nroTipo = comTipo;}} apilar(&pilaFactor, crear_hoja(nombre_varTabla($1)));}
	|CTE_REAL {printf("CTE_REAL\n"); agregar_tipoVarible_a_tabla($1,4); comTipo = comprobar_tipo_expresion($1, nroTipo); if (comTipo == 99) {errTipo = 1;} else {if (comTipo != 0) {nroTipo = comTipo;}} apilar(&pilaFactor, crear_hoja(nombre_varTabla($1)));}
	;
	
expresion_str:
	idstring CONCATENACION {printf("CONCATENACION\n");} ID {printf("ID\n"); if (verificar_tipoVariable($4) == 1) {printf("Variable '%s' no declarada\n", nombre_varTabla($4));} apilar(&pilaExpresion, crear_nodo("++", desapilar(&pilaTermino), crear_hoja(nombre_varTabla($4)))); comTipo = comprobar_tipo_expresion($4, nroTipo); if (comTipo == 99) {errTipo = 1;} else {if (comTipo != 0) {nroTipo = comTipo;}}}
	|idstring CONCATENACION {printf("CONCATENACION\n");} CTE_STRING {printf("CTE_STRING\n"); agregar_tipoVarible_a_tabla($4,5); apilar(&pilaExpresion, crear_nodo("++", desapilar(&pilaTermino), crear_hoja(nombre_varTabla($4)))); comTipo = comprobar_tipo_expresion($4, nroTipo); if (comTipo == 99) {errTipo = 1;} else {if (comTipo != 0) {nroTipo = comTipo;}}}
	|CTE_STRING {printf("CTE_STRING\n"); agregar_tipoVarible_a_tabla($1,5); apilar(&pilaExpresion, crear_hoja(nombre_varTabla($1))); comTipo = comprobar_tipo_expresion($1, nroTipo); if (comTipo == 99) {errTipo = 1;} else {if (comTipo != 0) {nroTipo = comTipo;}}}
	;
	
idstring:
	ID {printf("ID\n"); if (verificar_tipoVariable($1) == 1) {printf("Variable '%s' no declarada\n", nombre_varTabla($1)); encError=1;} apilar(&pilaTermino, crear_hoja(nombre_varTabla($1))); comTipo = comprobar_tipo_expresion($1, nroTipo); if (comTipo == 99) {errTipo = 1;} else {if (comTipo != 0) {nroTipo = comTipo;}}}
	|CTE_STRING {printf("CTE_STRING\n"); agregar_tipoVarible_a_tabla($1,5); apilar(&pilaTermino, crear_hoja(nombre_varTabla($1))); comTipo = comprobar_tipo_expresion($1, nroTipo); if (comTipo == 99) {errTipo = 1;} else {if (comTipo != 0) {nroTipo = comTipo;}}}
	;
	
repeat:
	REPEAT {printf("REPEAT\n");} acciones UNTIL {printf("UNTIL\n");} condicion FIN_SENTENCIA {printf("FIN_SENTENCIA\n"); Prepeat = crear_nodo("REPEAT", desapilar(&pilaSentencias), desapilar(&pilaCondicion));}
	;
	
if:
	IF {printf("IF\n");} condicion THEN cuerpoif ENDIF {printf("ENDIF\n"); Pdecision = crear_nodo("IF", desapilar(&pilaCondicion), Pcuerpo);}
	;
	
cuerpoif:
	acciones ELSE {printf("ELSE\n");} acciones {Pcuerpo = crear_nodo("ELSE", desapilar(&pilaSentencias), desapilar(&pilaSentencias));}
	|acciones {Pcuerpo = desapilar(&pilaSentencias);}
	;

	
unaryif:
	PAR_ABRE condicion SIG_UNARYIF {printf("UNARYIF\n");} cuerpounaryif PAR_CIERRA {Punary = crear_nodo("?", desapilar(&pilaCondicion), Pcuerpo);}
	;
	
cuerpounaryif:
	expresion SEPARDOR_COMA {printf("SEPARDOR_COMA\n");} expresion {Pcuerpo = crear_nodo("COMA", desapilar(&pilaExpresion), desapilar(&pilaExpresion));}
	|expresion_str SEPARDOR_COMA {printf("SEPARDOR_COMA\n");} expresion_str {Pcuerpo = crear_nodo("COMA", desapilar(&pilaExpresion), desapilar(&pilaExpresion));}
	;
	
qequal:
	QEQUAL {printf("QEQUAL\n");} PAR_ABRE expresiones SEPARDOR_COMA {printf("SEPARDOR_COMA\n");} lista PAR_CIERRA {Pqequal = crear_nodo("QEqual", desapilar(&pilaExpresion), Plista);}
	;
	
entrada:
	GET {printf("GET\n");} ID {printf("ID\n"); if (verificar_tipoVariable($3) == 1) {printf("Variable '%s' no declarada\n", nombre_varTabla($3)); encError=1;} if (esConstante($3) == 1) {printf("'%s' no puede cambiar su valor porque esta declarada como constante\n", nombre_varTabla($3)); encError=1;}} FIN_SENTENCIA {printf("FIN_SENTENCIA\n"); Pentrada = crear_nodo("GET", NULL, crear_hoja(nombre_varTabla($3)));}
	;
	
salida:
	PUT {printf("PUT\n");} expresiones FIN_SENTENCIA {printf("FIN_SENTENCIA\n"); Psalida = crear_nodo("PUT", NULL, desapilar(&pilaExpresion));}
	;
	
condicion:
	comparacion oper_cond comparacion {apilar(&pilaCondicion, crear_nodo(signoc, desapilar(&pilaComparacion), desapilar(&pilaComparacion)));}
	|NOT {printf("NOT\n");} comparacion {apilar(&pilaCondicion, crear_nodo("NOT", NULL, desapilar(&pilaComparacion)));}
	|comparacion {apilar(&pilaCondicion, desapilar(&pilaComparacion));}
	|comparacion_str oper_cond comparacion_str {apilar(&pilaCondicion, crear_nodo(signoc, desapilar(&pilaComparacion), desapilar(&pilaComparacion)));}
	|comparacion_str {apilar(&pilaCondicion, desapilar(&pilaComparacion));}
	|comparacion_str oper_cond comparacion {apilar(&pilaCondicion, crear_nodo(signoc, desapilar(&pilaComparacion), desapilar(&pilaComparacion)));}
	|comparacion oper_cond comparacion_str {apilar(&pilaCondicion, crear_nodo(signoc, desapilar(&pilaComparacion), desapilar(&pilaComparacion)));}
	;
	
oper_cond:
	AND {printf("AND\n"); strcpy(signoc, "AND");}
	|OR {printf("OR\n"); strcpy(signoc, "OR");}
	;
	
comparacion:
	expresion oper_comp expresion {if (errTipo == 1) {encError = 1; printf("Error de tipos en la comparacion\n");} errTipo = 0; nroTipo = -1; apilar(&pilaComparacion, crear_nodo(signo, desapilar(&pilaExpresion), desapilar(&pilaExpresion)));}
	;

oper_comp:
	MENOR {printf("MENOR\n"); strcpy(signo, "<");}
	|MAYOR {printf("MAYOR\n"); strcpy(signo, ">");}
	|MENOR_IGUAL {printf("MENOR_IGUAL\n"); strcpy(signo, "<=");}
	|MAYOR_IGUAL {printf("MAYOR_IGUAL\n"); strcpy(signo, ">=");}
	|IGUAL {printf("IGUAL\n"); strcpy(signo, "==");}
	|DISTINTO {printf("DISTINTO\n"); strcpy(signo, "<>");} 
	;
	
comparacion_str:
	expresion_str IGUAL {printf("IGUAL\n");} expresion_str {if (errTipo == 1) {encError = 1; printf("Error de tipos en la comparacion\n");} errTipo = 0; nroTipo = -1; apilar(&pilaComparacion, crear_nodo("==", desapilar(&pilaExpresion), desapilar(&pilaExpresion)));}
	|expresion_str DISTINTO {printf("DISTINTO\n");} expresion_str {if (errTipo == 1) {encError = 1; printf("Error de tipos en la comparacion\n");} errTipo = 0; nroTipo = -1; apilar(&pilaComparacion, crear_nodo("<>", desapilar(&pilaExpresion), desapilar(&pilaExpresion)));}
	;
	
expresiones:
	expresion
	|expresion_str
	;
	
entero:
	CTE_ENTERA {printf("CTE_ENTERA\n"); agregar_tipoVarible_a_tabla($1,3); if (verificar_tipoVariable(posTbl) == 0) {printf("La constante '%s' esta declarada mas de una vez\n", nombre_varTabla(posTbl)); encError=1;} else {agregar_tipoVarible_a_tabla(posTbl,0); agrConstante(posTbl); agrValorConstante(posTbl, nombre_varTabla($1));}}
	;	
	
real:
	CTE_REAL {printf("CTE_REAL\n"); agregar_tipoVarible_a_tabla($1,4); if (verificar_tipoVariable(posTbl) == 0) {printf("La constante '%s' esta declarada mas de una vez\n", nombre_varTabla(posTbl)); encError=1;} else {agregar_tipoVarible_a_tabla(posTbl,1); agrConstante(posTbl); agrValorConstante(posTbl, nombre_varTabla($1));}}
	;
	
string:
	CTE_STRING {printf("CTE_STRING\n"); agregar_tipoVarible_a_tabla($1,5); if (verificar_tipoVariable(posTbl) == 0) {printf("La constante '%s' esta declarada mas de una vez\n", nombre_varTabla(posTbl)); encError=1;} else {agregar_tipoVarible_a_tabla(posTbl,2); agrConstante(posTbl); agrValorConstante(posTbl, nombre_varTabla($1));}}
	;
	
dato:
	entero
	|real
	|string
	;
	
lista:
	COR_ABRE {printf("COR_ABRE\n");} elementolista COR_CIERRA {printf("COR_CIERRA\n");}
	;
	
elementolista:
	expresiones {Plista = desapilar(&pilaExpresion);}
	|elementolista SEPARDOR_COMA {printf("SEPARDOR_COMA\n");} expresiones {Plista = crear_nodo("COMA", Plista, desapilar(&pilaExpresion));}
	;
	
tipo:
	INT {printf("INT\n"); if (verificar_tipoVariable(posTbl) == 0) {printf("La variable '%s' esta declarada mas de una vez\n", nombre_varTabla(posTbl)); encError=1;} else {agregar_tipoVarible_a_tabla(posTbl,0);}}
	|REAL {printf("REAL\n"); if (verificar_tipoVariable(posTbl) == 0) {printf("La variable '%s' esta declarada mas de una vez\n", nombre_varTabla(posTbl)); encError=1;} else {agregar_tipoVarible_a_tabla(posTbl,1);}}
	|STRING {printf("STRING\n"); if (verificar_tipoVariable(posTbl) == 0) {printf("La variable '%s' esta declarada mas de una vez\n", nombre_varTabla(posTbl)); encError=1;} else {agregar_tipoVarible_a_tabla(posTbl,2);}}
	;
%%
/*****************			 BNF 			*****************/
// Controles adicionales que se tiene en cuenta:
//		- Que los nombre de variables y constantes no se repitan
//		- Que todas las variables que se utilicen sean declaradas previamente
//		- Que no se intente cambiar el valor de una constante
//		- Que en las expresiones los variables involucradas sean de tipo compatible
// Actualizan la tabla de simbolos para:
//		- Agregar los tipos a variables y constantes
//		- Agregar los valores a las constantes con nombre
//		- Agregar una marca a las constantes con nombre
/************************************************************/

/************ FUNCIONES DE IMPRESION DEL ARBOL *************/
// Funciones que imprimen el arbol en un archivo txt
// Funcion recursiva. El arbol es recorrido inOrden
// Formato: Nodo nro : nroNi,valor,nroNd
void imprimir_nodos_inorder(arbol* arbol_sint) {
	char linea[50], lineaf[50];
	char sNro[20];
	if (arbol_sint != NULL) {
		imprimir_nodos_inorder(arbol_sint->izq);
		if (arbol_sint->izq == NULL) {
			strcpy(linea,"-");
		} else {
			itoa(arbol_sint->izq->nroN, sNro, 10);
			strcpy(linea, sNro);
		}
		if (arbol_sint->der == NULL) {
			strcpy(lineaf,"-");
		} else {
			itoa(arbol_sint->der->nroN, sNro, 10);
			strcpy(lineaf, sNro);
		}
		fprintf(archivoArbolSintactico, "nodo %d : %s,%s,%s\n", arbol_sint->nroN, linea, arbol_sint->elemento, lineaf);
		imprimir_nodos_inorder(arbol_sint->der);
	}
}
// Funcion auxiliar. Recorre el arbol y va colocando el numero de nodo
// Funcion recursiva. Recorre el arbol inOrden
void nroNodoColocar(arbol* arbol_sint) {
	if (arbol_sint != NULL) {
		nroNodoColocar(arbol_sint->izq);
		if (arbol_sint->izq != NULL) {
			nroNodo = nroNodo + 1;
		}
		arbol_sint->nroN = nroNodo;
		if (arbol_sint->der != NULL) {
			nroNodo = nroNodo + 1;
		}
		nroNodoColocar(arbol_sint->der);
	}
}
void imprimir_arbol() {	
	nroNodo = 1;
	archivoArbolSintactico = fopen("./Intermedia.txt","w+t");
	fprintf(archivoArbolSintactico, "\nARBOL SINTACTICO:\n================\n\n");
	arbol_sintactico = Pprograma;
	nroNodoColocar(arbol_sintactico);
	imprimir_nodos_inorder(arbol_sintactico);
	
	fclose(archivoArbolSintactico);
}

/********* FUNCIONES PARA LA CONSTRUCCION DEL ARBOL **********/
// Funcion de crear nodo y crear hoja para el arbol
arbol* crear_nodo(char* elem, arbol* ni, arbol* nd) {
	arbol* nuevo_nodo = (arbol *)malloc(sizeof(arbol));
	
	strcpy(nuevo_nodo->elemento,elem);
	nuevo_nodo->izq = ni;
	nuevo_nodo->der = nd;
	
	return nuevo_nodo;
}
arbol* crear_hoja(char* elem) {
	arbol* nueva_hoja = (arbol *)malloc(sizeof(arbol));
	
	strcpy(nueva_hoja->elemento,elem);
	nueva_hoja->izq = NULL;
	nueva_hoja->der = NULL;
	
	return nueva_hoja;
}

/************ FUNCIONES PARA UTILIZAR LAS PILAS *************/
// Funcion de Apilar y Desapilar para las pilas utilizadas
tnodo* apilar (tpila * Ppila, tnodo * tnodo) {
  Ppila->tope++;
  Ppila->pila[Ppila->tope] = tnodo;  
  return Ppila->pila[Ppila->tope] ;
}
tnodo* desapilar(tpila * Ppila) {
     tnodo * tnodo;
     tnodo =  Ppila->pila[Ppila->tope];
     Ppila->tope--;
     return tnodo;
}

/************ FUNCIONES PARA PARSEAR INFO NODOS *************/
// Diferentes funciones que parsean la linea del archivo de notacion intermedio
// Separa lo que es el valor, numero de nodo, numero de nodos de derecha e izquierda
int nro_nodo(char* linea) {
	const char del[7] = "nodo :";
	char *token;
	
	token = strtok(linea, del);
	return atoi(token);
}
int der_nodo(char* linea) {
	const char del[4] = " :\n";
	const char del2[2] = ",";
	char *token;
	char *aux, *aux2;
	
	token = strtok(linea, del);
	while ( token != NULL ) {
		aux = token;
		token = strtok(NULL, del);
	}
	
	token = strtok(aux, del2);
	
	if (strcmp(token, "-") == 0) {
		return 0;
	} else {
		return atoi(token);
	}
}
int izq_nodo(char* linea) {
	const char del[4] = " :\n";
	const char del2[2] = ",";
	char *token;
	char *aux, *aux2;
	
	token = strtok(linea, del);
	while ( token != NULL ) {
		aux = token;
		token = strtok(NULL, del);
	}
	
	token = strtok(aux, del2);
	
	while ( token != NULL ) {
		aux2 = token;
		token = strtok(NULL, del2);
	}
	
	if (strcmp(aux2, "-") == 0) {
		return 0;
	} else {
		return atoi(aux2);
	}
}
char* val_nodo(char* linea) {
	const char del[4] = ":\n";
	const char del2[2] = ",";
	char *token;
	char *aux, *aux2;
	
	token = strtok(linea, del);
	while ( token != NULL ) {
		aux = token;
		token = strtok(NULL, del);
	}
	
	token = strtok(aux, del2);
	token = strtok(NULL, del2);
	
	return token;
}

/******** FUNCION GUARDAR NOMBRES CONSTANTES CREADAS *********/
// Funcion que guarda los nombres de las constantes creadas
// para las constantes sin nombre de la tabla de simbolos
void agregar_tblConstante(char nombre[100], char valor[100]) {
	tablaConst *nuevo_reg = (tablaConst *)malloc(sizeof(tablaConst));
	
	strcpy(nuevo_reg->valor, valor);
	strcpy(nuevo_reg->nombre, nombre);
	nuevo_reg->siguiente = NULL;
	
	if (tabla_constantes == NULL) {
		tabla_constantes = nuevo_reg;
	} else {
		actual_constantes->siguiente = nuevo_reg;
	}
	actual_constantes = nuevo_reg;
}

/********* FUNCION LEER ARCHIVO NOTACION INTERMEDIA **********/
// Lee el archivo de notacion intermedia y crea una lista con enlace doble
// Cada nodo contiene el valor, numero de nodo, numero de nodo izquierdo
// numero de nodo derecho, punteros para elemento anterior y siguiente
void leer_ArchIntermedia() {
	char linea[100], laux[100], valNodo[100];
	int nodoActual, nodoDer, nodoIzq;

	archivoArbolSintactico = fopen("./Intermedia.txt","r");
	for (int i = 0; i < 5; i+=1) {
		fgets(linea, 100, archivoArbolSintactico);
	}
	
	while (feof(archivoArbolSintactico) == 0) {
		strcpy(laux, linea);
		nodoActual = nro_nodo(laux);
		strcpy(laux, linea);
		nodoDer = der_nodo(laux);
		strcpy(laux, linea);
		nodoIzq = izq_nodo(laux);
		strcpy(valNodo,val_nodo(linea));
	
		printf("%d - %d %s %d\n", nodoActual, nodoDer, valNodo, nodoIzq);
		
		lstSentAux *nuevo_reg = (lstSentAux *)malloc(sizeof(lstSentAux));
		strcpy(nuevo_reg->valor, valNodo);
		nuevo_reg->numero = nodoActual;
		nuevo_reg->izq = nodoIzq;
		nuevo_reg->der = nodoDer;
	
		if (lista_sentencias == NULL) {
			nuevo_reg->siguiente = NULL;
			nuevo_reg->anterior = NULL;
			lista_sentencias = nuevo_reg;
		} else {
			actual_sentencias->siguiente = nuevo_reg;
			nuevo_reg->anterior = actual_sentencias;
		}
		actual_sentencias = nuevo_reg;
		
		fgets(linea, 100, archivoArbolSintactico);
	}
}

/************ FUNCIONES GENERACION DE ASSEMBLER *************/
// Diferentes funciones para crear el assembler de la notacion intermedia
void imprimirFld(char valor[100]) {
	if (devolver_tipoDato(valor) == 1) {
		fprintf(archivoAsm, "\tfld _%s\n", valor);
	} else {
		actual_constantes = tabla_constantes;
			
		while (strcmp(actual_constantes->valor, valor) != 0)
			actual_constantes = actual_constantes->siguiente;
		
		fprintf(archivoAsm, "\tfld %s\n", actual_constantes->nombre);
	}
}

// Funcion que imprime el codigo assembler de las diferentes operaciones (+,-,*,/,++)
// dependiendo del tipo de los valores
void imprimirFldOperacion(char valor[100], char operador[5], int tipo) {
	if (strcmp(operador, "VAR") == 0) {
		switch (valor[0]) { 
			case '+':
				imprimirFld(actual_sentencias->siguiente->valor);
				fprintf(archivoAsm, "\tfadd\n");
				break;
			case '-':
				imprimirFld(actual_sentencias->siguiente->valor);
				fprintf(archivoAsm, "\tfsub\n");
				break;
			case '*':
				if (devolver_tipoDato(actual_sentencias->siguiente->valor) == 1) {
					if (tipo == 1) {
						fprintf(archivoAsm, "\tfimul _%s\n", actual_sentencias->siguiente->valor);
					} else {
						fprintf(archivoAsm, "\tfld _%s\n", actual_sentencias->siguiente->valor);
						fprintf(archivoAsm, "\tfmul\n");
					}
				} else {
					actual_constantes = tabla_constantes;
				
					while (strcmp(actual_constantes->valor, actual_sentencias->siguiente->valor) != 0)
					actual_constantes = actual_constantes->siguiente;
			
					if (tipo == 1) {
						fprintf(archivoAsm, "\tfimul %s\n", actual_constantes->nombre);
					} else {
						fprintf(archivoAsm, "\tfld %s\n", actual_constantes->nombre);
						fprintf(archivoAsm, "\tfmul\n");
					}
				}				
				break;
			case '/':
				if (devolver_tipoDato(actual_sentencias->siguiente->valor) == 1) {
					if (tipo == 1) {
						fprintf(archivoAsm, "\tfidiv _%s\n", actual_sentencias->siguiente->valor);
					} else {
						fprintf(archivoAsm, "\tfld %s\n", actual_sentencias->siguiente->valor);
						fprintf(archivoAsm, "\tfdiv\n");
					}
				} else {
					actual_constantes = tabla_constantes;
				
					while (strcmp(actual_constantes->valor, actual_sentencias->siguiente->valor) != 0)
					actual_constantes = actual_constantes->siguiente;
					
					if (tipo == 1) {
						fprintf(archivoAsm, "\tfidiv %s\n", actual_constantes->nombre);
					} else {
						fprintf(archivoAsm, "\tfld %s\n", actual_constantes->nombre);
						fprintf(archivoAsm, "\tfdiv\n");
					}
				}					
				break;
		}
	} else {
		switch (valor[0]) { 
			case '+':
				fprintf(archivoAsm, "\tpop %s\n", operador);
				fprintf(archivoAsm, "\tfld %s\n", operador);
				fprintf(archivoAsm, "\tfadd\n");
				break;
			case '-':
				fprintf(archivoAsm, "\tpop %s\n", operador);
				fprintf(archivoAsm, "\tfld %s\n", operador);
				fprintf(archivoAsm, "\tfsub\n");
				break;
			case '*':
				fprintf(archivoAsm, "\tpop %s\n", operador);
				if (tipo == 1) {
					fprintf(archivoAsm, "\tfimul %s\n", operador);
				} else {
					fprintf(archivoAsm, "\tfld %s\n", operador);
					fprintf(archivoAsm, "\tfmul\n");
				}
				break;
			case '/':
				fprintf(archivoAsm, "\tpop %s\n", operador);
				if (tipo == 1) {
					fprintf(archivoAsm, "\tfidiv %s\n", operador);
				} else {
					fprintf(archivoAsm, "\tfld %s\n", operador);
					fprintf(archivoAsm, "\tfdiv\n");
				}
				break;
		}
	}
}

// Funcion que imprime el assembler necesario para calcular la longitud de un string
void imprimirStrlenString() {
	fprintf(archivoAsm, "\tmov bx, 0\n");
	fprintf(archivoAsm, "strel%d:\n",numEtiquetas);
	fprintf(archivoAsm, "\tcmp BYTE PTR [SI+BX], '$'\n");
	fprintf(archivoAsm, "\tje strend%d\n", numEtiquetas);
	fprintf(archivoAsm, "\tinc bx\n");
	fprintf(archivoAsm, "\tjmp strel%d\n", numEtiquetas);
	fprintf(archivoAsm, "strend%d:\n", numEtiquetas);
}

// Funcion que imprime el assembler para hacer un copiado de string de una variable a otra
void imprimirCopiarString() {
	fprintf(archivoAsm, "\tcmp bx, MAXTEXTSIZE\n");
	fprintf(archivoAsm, "\tjle copiarsizeok%d\n", numEtiquetas);
	fprintf(archivoAsm, "\tmov bx, MAXTEXTSIZE\n");
	fprintf(archivoAsm, "copiarsizeok%d:\n", numEtiquetas);
	fprintf(archivoAsm, "\tmov cx, bx\n");
	fprintf(archivoAsm, "\tcld\n");
	fprintf(archivoAsm, "\trep movsb\n");
	fprintf(archivoAsm, "\tmov al, '$'\n");
	fprintf(archivoAsm, "\tmov BYTE PTR [DI], al\n\n");
}

// Funcion que imprime el assembler necesario para hacer la concatenacion de dos string
void imprimirConcatString() {
	fprintf(archivoAsm, "\tpush ds\n");
	fprintf(archivoAsm, "\tpush si\n");
	imprimirStrlenString();
	numEtiquetas += 1;
	fprintf(archivoAsm, "\tmov dx, bx \n");
	fprintf(archivoAsm, "\tmov si,di\n");
	fprintf(archivoAsm, "\tpush es\n");
	fprintf(archivoAsm, "\tpop ds\n");
	imprimirStrlenString();
	numEtiquetas += 1;
	fprintf(archivoAsm, "\tadd di, bx\n");
	fprintf(archivoAsm, "\tadd bx, dx\n");
	fprintf(archivoAsm, "\tcmp bx, MAXTEXTSIZE\n");
	fprintf(archivoAsm, "\tjg concatsizemal%d\n", numEtiquetas);
	fprintf(archivoAsm, "concatsizeok%d:\n", numEtiquetas);
	fprintf(archivoAsm, "\tmov cx, dx\n");
	fprintf(archivoAsm, "\tjmp concatsigo%d\n", numEtiquetas);
	fprintf(archivoAsm, "concatsizemal%d:\n", numEtiquetas);
	fprintf(archivoAsm, "\tsub bx, MAXTEXTSIZE\n");
	fprintf(archivoAsm, "\tsub dx, bx\n");
	fprintf(archivoAsm, "\tmov cx, dx\n");
	fprintf(archivoAsm, "concatsigo%d:\n", numEtiquetas);
	fprintf(archivoAsm, "\tpush ds\n");
	fprintf(archivoAsm, "\tpop es\n");
	fprintf(archivoAsm, "\tpop si\n");
	fprintf(archivoAsm, "\tpop ds\n");
	fprintf(archivoAsm, "\tcld\n");
	fprintf(archivoAsm, "\trep movsb\n");
	fprintf(archivoAsm, "\tmov al, '$'\n");
	fprintf(archivoAsm, "\tmov BYTE PTR [DI], al\n");
}

// Funcion que crea el codigo assembler de una asignacion
// Funcion recursiva
// Va creando nodos nuevos para cada operacion (+,-,*,/) y reemplazandolos de la expresion
// hasta llegar a una asignacion simple 'a = valor'
// Se utilizan dos constantes @aux1 y @aux2 (Int/Real) @aux3 (String) para el codigo assembler 
// y asi poder hacer las operaciones
// Ademas se utiliza la pila (push, pop) para ir guardando los valores intermedios
void imprimir_asignacion(int indIni, int indFin, char auxVal[100], int tipo) {
	actual_sentencias = lista_sentencias;
	if (indIni == indFin) {
		while (actual_sentencias->numero < indIni) 
			actual_sentencias = actual_sentencias->siguiente;

		if (tipo == 3) {
			if (strcmp(actual_sentencias->valor, "@AUX") == 0) {
				fprintf(archivoAsm, "\tmov si, OFFSET @aux3\n");
				fprintf(archivoAsm, "\tmov di, OFFSET _%s\n", auxVal);
				imprimirStrlenString();
				imprimirCopiarString();
				numEtiquetas += 1;
			} else {
				if (devolver_tipoDato(actual_sentencias->valor) == 1) {
					fprintf(archivoAsm, "\tmov si, OFFSET _%s\n", actual_sentencias->valor);
				} else {
					actual_constantes = tabla_constantes;
			
					while ((actual_constantes != NULL) && (strcmp(actual_constantes->valor, actual_sentencias->valor) != 0)) 
						actual_constantes = actual_constantes->siguiente;
				
					if (actual_constantes != NULL) {
						fprintf(archivoAsm, "\tmov si, OFFSET %s\n", actual_constantes->nombre);
					}
				}
				fprintf(archivoAsm, "\tmov di, OFFSET _%s\n", auxVal);
				imprimirStrlenString();
				imprimirCopiarString();
				numEtiquetas += 1;
			}
		} else {
			if (strcmp(actual_sentencias->valor, "@AUX") == 0) {
				fprintf(archivoAsm, "\tpop @aux1\n");
				fprintf(archivoAsm, "\tfld @aux1\n");
			} else {
				imprimirFld(actual_sentencias->valor);
			}
		
			fprintf(archivoAsm, "\tfstp _%s\n\n", auxVal);
		}
	} else {
		while (actual_sentencias->numero < indIni + 1) 
			actual_sentencias = actual_sentencias->siguiente;
			
		while ((actual_sentencias->numero < indFin) && ((actual_sentencias->der != actual_sentencias->anterior->numero) || (actual_sentencias->izq != actual_sentencias->siguiente->numero))) 
			actual_sentencias = actual_sentencias->siguiente;		
		
		if ((actual_sentencias->der == actual_sentencias->anterior->numero) && (actual_sentencias->izq == actual_sentencias->siguiente->numero)) {
			lstSentAux *nuevo_reg = (lstSentAux *)malloc(sizeof(lstSentAux));
			
			if (tipo == 3) {
				if (devolver_tipoDato(actual_sentencias->anterior->valor) == 1) {
					fprintf(archivoAsm, "\tmov si, OFFSET _%s\n", actual_sentencias->anterior->valor);
				} else {
					actual_constantes = tabla_constantes;
			
					while ((actual_constantes != NULL) && (strcmp(actual_constantes->valor, actual_sentencias->anterior->valor) != 0)) 
						actual_constantes = actual_constantes->siguiente;
				
					if (actual_constantes != NULL) {
						fprintf(archivoAsm, "\tmov si, OFFSET %s\n", actual_constantes->nombre);
					}
				}
				fprintf(archivoAsm, "\tmov di, OFFSET @aux3\n");
				imprimirStrlenString();
				imprimirCopiarString();
				numEtiquetas += 1;
				if (devolver_tipoDato(actual_sentencias->siguiente->valor) == 1) {
					fprintf(archivoAsm, "\tmov si, OFFSET _%s\n", actual_sentencias->siguiente->valor);
				} else {
					actual_constantes = tabla_constantes;
			
					while ((actual_constantes != NULL) && (strcmp(actual_constantes->valor, actual_sentencias->siguiente->valor) != 0)) 
						actual_constantes = actual_constantes->siguiente;
				
					if (actual_constantes != NULL) {
						fprintf(archivoAsm, "\tmov si, OFFSET %s\n", actual_constantes->nombre);
					}
				}
				fprintf(archivoAsm, "\tmov di, OFFSET @aux3\n");
				imprimirConcatString();
				numEtiquetas += 1;
			} else {
				if ((strcmp(actual_sentencias->anterior->valor, "@AUX") == 0) && (strcmp(actual_sentencias->siguiente->valor, "@AUX") == 0)) {
					fprintf(archivoAsm, "\tpop @aux2\n");
					fprintf(archivoAsm, "\tfld @aux2\n");
				} else if ((strcmp(actual_sentencias->anterior->valor, "@AUX") == 0) && (strcmp(actual_sentencias->siguiente->valor, "@AUX") != 0)) {
					fprintf(archivoAsm, "\tpop @aux1\n");
					fprintf(archivoAsm, "\tfld @aux1\n");
				} else {
					imprimirFld(actual_sentencias->anterior->valor);
				}
				if (strcmp(actual_sentencias->siguiente->valor, "@AUX") == 0) {
					imprimirFldOperacion(actual_sentencias->valor, "@aux1", tipo);
				} else {
					imprimirFldOperacion(actual_sentencias->valor, "VAR", tipo);
				}			
			
				fprintf(archivoAsm, "\tfstp @aux1\n");
				fprintf(archivoAsm, "\tpush @aux1\n");
			}
			
			nuevo_reg->numero = actual_sentencias->der;
			strcpy(nuevo_reg->valor, "@AUX");
			nuevo_reg->izq = 0;
			nuevo_reg->der = 0;
			
			nuevo_reg->anterior = actual_sentencias->anterior->anterior;
			actual_sentencias->anterior->anterior->siguiente = nuevo_reg;
			if (actual_sentencias->anterior->anterior->izq == actual_sentencias->numero) {
				actual_sentencias->anterior->anterior->izq = nuevo_reg->numero;
			}
			if (actual_sentencias->siguiente->siguiente != NULL) {
				nuevo_reg->siguiente = actual_sentencias->siguiente->siguiente;
				actual_sentencias->siguiente->siguiente->anterior = nuevo_reg;
				if (actual_sentencias->siguiente->siguiente->der == actual_sentencias->numero) {
					actual_sentencias->siguiente->siguiente->der = nuevo_reg->numero;
				}
			} else {
				nuevo_reg->siguiente = NULL;
			}
			
			if (actual_sentencias->siguiente->numero ==  indFin) {
				indFin = nuevo_reg->numero;
			}
			
			imprimir_asignacion(indIni, indFin, auxVal, tipo);
		}
	}
}

// Imprime la cabecera del codigo assembler
void imp_model() {
	fprintf(archivoAsm, "include Macros.asm\n"
						".MODEL LARGE\n"
						".STACK 200h\n"
						".386\n\n");
}

// Imprime la parte de .data del assembler
// Imprime primero variables ya predeterminadas
// luego agrega las variables y constantes de la tabla de simbolos
// para las constantes sin nombre crea un nombre que lo guarda en una lista 
void imp_data() {
	char nombre[100], tipo[100], nmbConst[10], buffer[10], valor[100];
	int cantTabla = cant_varTabla();
	int esCst;
	int nro = 1;
	
	fprintf(archivoAsm, ".DATA\n"
						"MAXTEXTSIZE equ 30\n"
						"tempStr db 25 dup (?), '$'\n"
						"Int1 dd ?\n"
						"Int2 dd ?\n"
						"realTen dd 10.0\n"
						"integerTen dd 10\n"
						"places dw ?\n"
						"TooLarge db 10, 13, 'The value entered '\n"
						"         db 'has too many digits.', 10, 13, '$'\n"
						"@aux1 dd ?\n"
						"@aux2 dd ?\n"
						"@aux3 db MAXTEXTSIZE dup(?), '$'\n\n");
	
	for(int i = 1; i <= cantTabla; i+=1) {
		strcpy(nombre, nombre_varTabla(i));
		strcpy(tipo, tipo_varTabla(i));
		esCst = esConstante(i);		
		
		if ((strcmp(tipo,"INT") == 0) || (strcmp(tipo,"REAL") == 0)) {
			if (esCst == 1) {
				fprintf(archivoAsm, "_%s dd %s\n", nombre, valor_varTabla(i));
			} else {
				fprintf(archivoAsm, "_%s dd ?\n", nombre);
			}
		}
		if (strcmp(tipo,"STRING") == 0) {
			if (esCst == 1) {
				strcpy(valor, valor_varTabla(i));
				fprintf(archivoAsm, "_%s db %s, '$', %d dup(?)\n", nombre, valor, (30 - strlen(valor)));
			} else {
				fprintf(archivoAsm, "_%s db MAXTEXTSIZE dup(?), '$'\n", nombre);
			}
		}
		if ((strcmp(tipo,"CTE_INT") == 0) || (strcmp(tipo,"CTE_REAL") == 0)) {
			strcpy(nmbConst, "_cte_");
			itoa(nro, buffer, 10);
			strcat(nmbConst, buffer);
			agregar_tblConstante(nmbConst, nombre_varTabla(i));
			fprintf(archivoAsm, "_cte_%d dd %s\n", nro, nombre);			
			nro+=1;
		}
		if (strcmp(tipo,"CTE_STRING") == 0) {
			strcpy(nmbConst, "_cte_");
			itoa(nro, buffer, 10);
			strcat(nmbConst, buffer);
			agregar_tblConstante(nmbConst, nombre_varTabla(i));
			fprintf(archivoAsm, "_cte_%d db %s, '$', %d dup(?)\n", nro, nombre, (30 - strlen(nombre)));
			nro+=1;
		}		
	}
	
	fprintf(archivoAsm, "\n");
}

// Imprime la primer parte de .code
void imp_code() {
	fprintf(archivoAsm, ".CODE\n"
						"\tmov ax,@DATA\n"
						"\tmov ds,ax\n"
						"\tmov es,ax\n\n"
						"\tFINIT\n\n");
}

// Funcion que dependiendo del parametro 'numOper' llama a las diferentes funciones
// que crean el assembler de las sentencias del programa
void imp_sentencia(int numOper, int indIni, int indFin, char auxVal[100], int tipo) {
	switch (numOper) {
		case 1:
			imprimir_asignacion(indIni, indFin, auxVal, tipo);		
			break;
		
	}
}

// Funcion que va leyendo la lista de enlace doble con los nodos de la notacion intermedia
// Filtra por palabras claves en los nodos para setear la variable 'tipoOper' 
// y llama a 'imp_sentencia'
void imp_codeSent() {
	int tipoOper = 0; // expresion
	int indIni, indFin, tipo;
	char auxVal[100];
	
	actual_sentencias = lista_sentencias;
	indIni = actual_sentencias->numero;
	
	while (actual_sentencias != NULL) {
		if (strcmp(actual_sentencias->valor, "=") == 0) {
			tipoOper = 1; // Asignacion
			strcpy(auxVal, actual_sentencias->anterior->valor);
			tipo = comprobar_tipo_expresion(existe_en_tabla_simbolos(actual_sentencias->anterior->valor), -1);
			indIni = actual_sentencias->siguiente->numero;
		} else if (strcmp(actual_sentencias->valor, "IF") == 0) {
			
		} else if (strcmp(actual_sentencias->valor, "ELSE") == 0) {
			
		} else if (strcmp(actual_sentencias->valor, "REPEAT") == 0) {
			
		} else if (strcmp(actual_sentencias->valor, "GET") == 0) {
			
		} else if (strcmp(actual_sentencias->valor, "PUT") == 0) {
			
		} else if (strcmp(actual_sentencias->valor, "?") == 0) {
			
		} else if (strcmp(actual_sentencias->valor, "QEqual") == 0) {
			
		} else if (strcmp(actual_sentencias->valor, "COMA") == 0) {
			
		} else if (strcmp(actual_sentencias->valor, ";") == 0) {
			imp_sentencia(tipoOper, indIni, indFin, auxVal, tipo);
			tipoOper = 0;
			indIni = actual_sentencias->siguiente->numero;
		} else if (strcmp(actual_sentencias->valor, "NOT") == 0) {
			
		} else if (strcmp(actual_sentencias->valor, "AND") == 0) {
			
		} else if (strcmp(actual_sentencias->valor, "OR") == 0) {
			
		} else if (strcmp(actual_sentencias->valor, "==") == 0) {
			
		} else if (strcmp(actual_sentencias->valor, "<>") == 0) {
			
		} else if (strcmp(actual_sentencias->valor, "<") == 0) {
			
		} else if (strcmp(actual_sentencias->valor, "=<") == 0) {
			
		} else if (strcmp(actual_sentencias->valor, ">") == 0) {
			
		} else if (strcmp(actual_sentencias->valor, "=>") == 0) {
			
		} else {
			indFin = actual_sentencias->numero;
		}
		actual_sentencias = actual_sentencias->siguiente;
	}
		
	imp_sentencia(tipoOper, indIni, indFin, auxVal, tipo);
}

// Imprime final del archivo assembler
void imp_endcode() {
	fprintf(archivoAsm, "\tmov ax, 4C00h\n"
						"\tint 21h\n"
						"END\n");
}

// Funcion principal de crear archivo assembler
void crear_archAsm() {
	archivoAsm = fopen("./FINAL.ASM","w+b");
	imp_model();
	imp_data();
	imp_code();
	leer_ArchIntermedia();
	imp_codeSent();	
	imp_endcode();
	
	fclose(archivoArbolSintactico);
	fclose(archivoAsm);
}

/************ FUNCIONES INICIALIZACION DE DATOS *************/
// Inicializa pilas y variables necesarias
void inicializarPila (tpila * Ppila ) {
    Ppila->tope = -1;
}  
void inicializarDatos() {
	encError = 0;
	nroTipo = -1;
	errTipo = 0;
	comTipo = 0;
	numEtiquetas = 0;
	inicializarPila(& pilaExpresion);
    inicializarPila(& pilaSentencias);
    inicializarPila(& pilaTermino);
    inicializarPila(& pilaFactor);
    inicializarPila(& pilaCondicion);
	inicializarPila(& pilaComparacion);
}

/***************** FUNCION ERROR DE SINTAXIS *****************/
int yyerror(char const*) {
	printf("Error de sintaxis");
}

/************ 				MAIN				 *************/

int main(int argc, char *argv[]) {
	inicializarDatos();
	if((yyin = fopen(argv[1],"rt")) == NULL) {	
		printf("No se puede abrir el archivo\n");
	} else {
		yyparse();
	}
	fclose(yyin);
	
	return 0;
}
