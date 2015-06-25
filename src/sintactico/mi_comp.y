%{ 
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<ctype.h>
int yyerror(char const*);
extern int yyparse();
extern "C" int yylex();
extern "C" void imprimir_tabla_de_simbolos();
extern "C" void agregar_tipoVarible_a_tabla(int posT, int type);
extern "C" int verificar_tipoVariable(int posT);
extern "C" char* nombre_varTabla(int posT);
extern "C" void agrConstante(int posTbl);
extern "C" int esConstante(int posTbl);
extern FILE *yyin;
int yystopparser=0;
int posTbl, nroNodo, encError;
struct nodo {
	char elemento[100];
	int nroN;
	struct nodo *izq, *der;
};
typedef struct nodo arbol;
arbol* arbol_sintactico = NULL;
typedef struct{
	nodo * pila [100];
	int tope;
}t_pila;
t_pila pilaSentencias, pilaExpresion, pilaTermino, pilaFactor, pilaCondicion, pilaComparacion;
nodo *  Pprograma, *  Psentencia, *  Pasignacion, *  Pexpresion, *  Ptermino, *  Pfactor,
	 *  Pcondicion, *  Pcomparaciones, *  Psalida, *  Pentrada, *  Pdecision, *  Prepeat,
     *  Pqequal, *  Punary, *  Plista, *  Pcuerpo;
char signoc[5], signo[5];
FILE * archivoArbolSintactico;
arbol* crear_nodo(char* elem, arbol* ni, arbol* nd);
arbol* crear_hoja(char* elem);
%}

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
	programa {if (encError == 0) {imprimir_tabla_de_simbolos(); imprimir_arbol();}}
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
	asignacion {Psentencia = Pasignacion;}
	|definicionconstante 
	|entrada {Psentencia = Pentrada;}
	|salida	{Psentencia = Psalida;}
	|repeat {Psentencia = Prepeat;}
	|if {Psentencia = Pdecision;}
	;
	
asignacion:
	ID {printf("ID\n"); if (verificar_tipoVariable($1) == 1) {printf("Variable '%s' no declarada\n", nombre_varTabla($1)); encError=1;} if (esConstante($1) == 1) {printf("'%s' no puede cambiar su valor porque esta declarada como constante\n", nombre_varTabla($1)); encError=1;}} SIG_ASIGNACION {printf("SIG_ASIGNACION\n");} expresiones FIN_SENTENCIA {printf("FIN_SENTENCIA\n"); Pasignacion = crear_nodo("=", crear_hoja(nombre_varTabla($1)), desapilar(&pilaExpresion));}
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
	ID {printf("ID\n"); if (verificar_tipoVariable($1) == 1) {printf("Variable '%s' no declarada\n", nombre_varTabla($1)); encError=1;} apilar(&pilaFactor, crear_hoja(nombre_varTabla($1)));}
	|PAR_ABRE expresion PAR_CIERRA  {apilar(&pilaFactor, desapilar(&pilaExpresion));} 
	|unaryif {apilar(&pilaFactor, Punary);}
	|qequal {apilar(&pilaFactor, Pqequal);}
	|CTE_ENTERA {printf("CTE_ENTERA\n"); agregar_tipoVarible_a_tabla($1,0); apilar(&pilaFactor, crear_hoja(nombre_varTabla($1)));}
	|CTE_REAL {printf("CTE_REAL\n"); agregar_tipoVarible_a_tabla($1,1); apilar(&pilaFactor, crear_hoja(nombre_varTabla($1)));}
	;
	
expresion_str:
	idstring CONCATENACION {printf("CONCATENACION\n");} ID {printf("ID\n"); if (verificar_tipoVariable($4) == 1) {printf("Variable '%s' no declarada\n", nombre_varTabla($4));} apilar(&pilaExpresion, crear_nodo("++", desapilar(&pilaTermino), crear_hoja(nombre_varTabla($4))));}
	|idstring CONCATENACION {printf("CONCATENACION\n");} CTE_STRING {printf("CTE_STRING\n"); agregar_tipoVarible_a_tabla($4,2); apilar(&pilaExpresion, crear_nodo("++", desapilar(&pilaTermino), crear_hoja(nombre_varTabla($4))));}
	|CTE_STRING {printf("CTE_STRING\n"); agregar_tipoVarible_a_tabla($1,2); apilar(&pilaExpresion, crear_hoja(nombre_varTabla($1)));}
	;
	
idstring:
	ID {printf("ID\n"); if (verificar_tipoVariable($1) == 1) {printf("Variable '%s' no declarada\n", nombre_varTabla($1)); encError=1;} apilar(&pilaTermino, crear_hoja(nombre_varTabla($1)));}
	|CTE_STRING {printf("CTE_STRING\n"); agregar_tipoVarible_a_tabla($1,2); apilar(&pilaTermino, crear_hoja(nombre_varTabla($1)));}
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
	expresion oper_comp expresion {apilar(&pilaComparacion, crear_nodo(signo, desapilar(&pilaExpresion), desapilar(&pilaExpresion)));}
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
	expresion_str IGUAL {printf("IGUAL\n");} expresion_str {apilar(&pilaComparacion, crear_nodo("==", desapilar(&pilaExpresion), desapilar(&pilaExpresion)));}
	|expresion_str DISTINTO {printf("DISTINTO\n");} expresion_str {apilar(&pilaComparacion, crear_nodo("<>", desapilar(&pilaExpresion), desapilar(&pilaExpresion)));}
	;
	
expresiones:
	expresion
	|expresion_str
	;
	
entero:
	CTE_ENTERA {printf("CTE_ENTERA\n"); agregar_tipoVarible_a_tabla($1,0); if (verificar_tipoVariable(posTbl) == 0) {printf("La constante '%s' esta declarada mas de una vez\n", nombre_varTabla(posTbl)); encError=1;} else {agregar_tipoVarible_a_tabla(posTbl,0); agrConstante(posTbl);}}
	;	
	
real:
	CTE_REAL {printf("CTE_REAL\n"); agregar_tipoVarible_a_tabla($1,1); if (verificar_tipoVariable(posTbl) == 0) {printf("La constante '%s' esta declarada mas de una vez\n", nombre_varTabla(posTbl)); encError=1;} else {agregar_tipoVarible_a_tabla(posTbl,1); agrConstante(posTbl);}}
	;
	
string:
	CTE_STRING {printf("CTE_STRING\n"); agregar_tipoVarible_a_tabla($1,2); if (verificar_tipoVariable(posTbl) == 0) {printf("La constante '%s' esta declarada mas de una vez\n", nombre_varTabla(posTbl)); encError=1;} else {agregar_tipoVarible_a_tabla(posTbl,2); agrConstante(posTbl);}}
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

void imprimir_nodos(arbol* arbol_sint) {
	if (arbol_sint != NULL) {
		fprintf(archivoArbolSintactico, "%s ", arbol_sint->elemento);
		imprimir_nodos(arbol_sint->izq);
		imprimir_nodos(arbol_sint->der);
	}
}

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

void imprimir_arbol() {	
	nroNodo = 1;
	archivoArbolSintactico = fopen("./Intermedia.txt","w+t");
	fprintf(archivoArbolSintactico, "\nARBOL SINTACTICO:\n================\n\n");
	arbol_sintactico = Pprograma;
	nroNodoColocar(arbol_sintactico);
	imprimir_nodos_inorder(arbol_sintactico);
	
	fprintf(archivoArbolSintactico, "\n\nARBOL SINTACTICO:\n================\n\n");
	
	imprimir_nodos(arbol_sintactico);
	
	fclose(archivoArbolSintactico);
}

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

nodo* apilar (t_pila * Ppila, nodo * tnodo) {
  Ppila->tope++;
  Ppila->pila[Ppila->tope] = tnodo;  
  return Ppila->pila[ Ppila->tope ] ;
}

nodo* desapilar(t_pila * Ppila) {
     nodo * tnodo;
     tnodo =  Ppila->pila[Ppila->tope];
     Ppila->tope--;
     return tnodo;
}

int pilaVacia(t_pila * Ppila) {
    int vacia = 0;
    if(Ppila->tope == -1) {
        vacia= 1;
    }
    return vacia;
}

nodo * verPrimero (t_pila * Ppila) {       
    return  Ppila->pila[Ppila->tope];
}

void inicializarPila (t_pila * Ppila ) {
    Ppila->tope = -1;
}  

int yyerror(char const*) {
	printf("Error de sintaxis");
}

int main(int argc, char *argv[]) {
	encError = 0;
	inicializarPila(& pilaExpresion);
    inicializarPila(& pilaSentencias);
    inicializarPila(& pilaTermino);
    inicializarPila(& pilaFactor);
    inicializarPila(& pilaCondicion);
	inicializarPila(& pilaComparacion);
	if((yyin = fopen(argv[1],"rt")) == NULL) {	
		printf("No se puede abrir el archivo\n");
	} else {
		yyparse();
	}
	fclose(yyin);
	
	return 0;
}
