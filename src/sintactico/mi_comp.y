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
extern FILE *yyin;
int yystopparser=0;
int posTbl;
struct nodo {
	char elemento[100];
	struct nodo *izq, *der;
};
typedef struct nodo arbol;
arbol* arbol_sintactico = NULL;
arbol* aptr = NULL; 	//asignacion
arbol* eptr = NULL; 	//expresion
arbol* e2ptr = NULL;	//aux expresion
arbol* tptr = NULL;		//termino
arbol* fptr = NULL;		//factor
arbol* cptr = NULL;		//condicion
arbol* coptr = NULL;	//comparacion
arbol* co2ptr = NULL;	//aux comparacion
arbol* cosptr = NULL;	//comparacionstr
arbol* cos2ptr = NULL;	//aux comparacionstr
arbol* uptr = NULL;		//unaryif
arbol* cuptr = NULL;	//cuerpo unaryif
arbol* qptr = NULL;		//qequal
char signoc[5];
char signo[5];
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
%start programa
%%

programa:
	sentenciadeclaracionvar acciones
	|acciones
	;
	
sentenciadeclaracionvar:
	DEFVAR {printf("DEFVAR\n");} declaracionvar ENDDEF {printf("ENDDEF\n");}
	;
	
declaracionvar:
	ID {printf("ID\n"); posTbl=$1;} DEFINE {printf("DEFINE\n");} tipo 
	|declaracionvar SEPARDOR_COMA {printf("SEPARDOR_COMA\n");} ID {printf("ID\n"); posTbl=$4;} DEFINE {printf("DEFINE\n");} tipo 
	;
	
acciones:
	accion
	|acciones accion
	;
	
accion:
	asignacion
	|definicionconstante
	|entrada
	|salida	
	|repeat
	|if
	;
	
asignacion:
	ID {printf("ID\n"); if (verificar_tipoVariable($1) == 1) {printf("Variable '%s' no declarada\n", nombre_varTabla($1));}} SIG_ASIGNACION {printf("SIG_ASIGNACION\n");} expresiones FIN_SENTENCIA {printf("FIN_SENTENCIA\n"); aptr = crear_nodo("=", crear_hoja(nombre_varTabla($1)), eptr);}
	;
	
definicionconstante:
	CONST {printf("CONST\n");} ID {printf("ID\n");} SIG_ASIGNACION {printf("SIG_ASIGNACION\n");} dato FIN_SENTENCIA
	;
	
expresion:
	expresion MAS {printf("MAS\n");} termino {eptr = crear_nodo("+", eptr, tptr);}
	|expresion MENOS {printf("MENOS\n");} termino {eptr = crear_nodo("-", eptr, tptr);}
	|termino {eptr = tptr;}
	;
	
termino:
	termino POR {printf("POR\n");} factor {tptr = crear_nodo("*", tptr, fptr);}
	|termino DIVIDIDO {printf("DIVIDIDO\n");} factor {tptr = crear_nodo("/", tptr, fptr);}
	|factor {tptr = fptr;}
	;
	
factor:
	ID {printf("ID\n"); if (verificar_tipoVariable($1) == 1) {printf("Variable '%s' no declarada\n", nombre_varTabla($1));} fptr = crear_hoja(nombre_varTabla($1));}
	|PAR_ABRE expresion PAR_CIERRA  {fptr = eptr;} 
	|unaryif {fptr = uptr;}
	|qequal {fptr = qptr;}
	|CTE_ENTERA {printf("CTE_ENTERA\n"); agregar_tipoVarible_a_tabla($1,0); fptr = crear_hoja(nombre_varTabla($1));}
	|CTE_REAL {printf("CTE_REAL\n"); agregar_tipoVarible_a_tabla($1,1); fptr = crear_hoja(nombre_varTabla($1));}
	;
	
expresion_str:
	idstring CONCATENACION {printf("CONCATENACION\n");} ID {printf("ID\n"); if (verificar_tipoVariable($4) == 1) {printf("Variable '%s' no declarada\n", nombre_varTabla($4));} eptr = crear_nodo("++", tptr, crear_hoja(nombre_varTabla($4)));}
	|idstring CONCATENACION {printf("CONCATENACION\n");} CTE_STRING {printf("CTE_STRING\n"); agregar_tipoVarible_a_tabla($4,2); eptr = crear_nodo("++", tptr, crear_hoja(nombre_varTabla($4)));}
	|CTE_STRING {printf("CTE_STRING\n"); agregar_tipoVarible_a_tabla($1,2); eptr = crear_hoja(nombre_varTabla($1));}
	;
	
idstring:
	ID {printf("ID\n"); if (verificar_tipoVariable($1) == 1) {printf("Variable '%s' no declarada\n", nombre_varTabla($1));} tptr = crear_hoja(nombre_varTabla($1));}
	|CTE_STRING {printf("CTE_STRING\n"); agregar_tipoVarible_a_tabla($1,2); tptr = crear_hoja(nombre_varTabla($1));}
	;
	
repeat:
	REPEAT {printf("REPEAT\n");} acciones UNTIL {printf("UNTIL\n");} condicion FIN_SENTENCIA {printf("FIN_SENTENCIA\n");}
	;
	
if:
	IF {printf("IF\n");} condicion THEN cuerpoif ENDIF {printf("ENDIF\n");}
	;
	
cuerpoif:
	acciones ELSE {printf("ELSE\n");} acciones
	|acciones 
	;
	
unaryif:
	PAR_ABRE condicion SIG_UNARYIF {printf("UNARYIF\n");} cuerpounaryif PAR_CIERRA {uptr = crear_nodo("?", cptr, cuptr);}
	;
	
cuerpounaryif:
	expresion2 SEPARDOR_COMA {printf("SEPARDOR_COMA\n");} expresion {cuptr = crear_nodo(",", e2ptr, eptr);}
	|expresion_str2 SEPARDOR_COMA {printf("SEPARDOR_COMA\n");} expresion_str {cuptr = crear_nodo(",", e2ptr, eptr);}
	;
	
expresion2:
	expresion {e2ptr = eptr;}
	;
	
expresion_str2:
	expresion_str {e2ptr = eptr;}
	;
	
qequal:
	QEQUAL {printf("QEQUAL\n");} PAR_ABRE expresion SEPARDOR_COMA {printf("SEPARDOR_COMA\n");} lista PAR_CIERRA
	;
	
entrada:
	GET {printf("GET\n");} ID {printf("ID\n"); if (verificar_tipoVariable($3) == 1) {printf("Variable '%s' no declarada\n", nombre_varTabla($3));}} FIN_SENTENCIA {printf("FIN_SENTENCIA\n");}
	;
	
salida:
	PUT {printf("PUT\n");} expresiones FIN_SENTENCIA {printf("FIN_SENTENCIA\n");}
	;
	
condicion:
	comparacion2 oper_cond comparacion {cptr = crear_nodo(signoc, co2ptr, coptr);}
	|NOT {printf("NOT\n");} comparacion
	|comparacion2 {cptr = co2ptr;}
	|comparacion_str2 oper_cond comparacion_str {cptr = crear_nodo(signoc, cos2ptr, cosptr);}
	|comparacion_str2 {cptr = cos2ptr;}
	|comparacion_str2 oper_cond comparacion {cptr = crear_nodo(signoc, cos2ptr, coptr);}
	|comparacion2 oper_cond comparacion_str {cptr = crear_nodo(signoc, co2ptr, cosptr);}
	;
	
oper_cond:
	AND {printf("AND\n"); strcpy(signoc, "AND");}
	|OR {printf("OR\n"); strcpy(signoc, "OR");}
	;
	
comparacion:
	expresion2 oper_comp expresion {coptr = crear_nodo(signo, e2ptr, eptr);}
	;

comparacion2:
	comparacion {co2ptr = coptr;}
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
	expresion_str2 IGUAL {printf("IGUAL\n");} expresion_str {cosptr = crear_nodo("==", e2ptr, eptr);}
	|expresion_str2 DISTINTO {printf("DISTINTO\n");} expresion_str {cosptr = crear_nodo("<>", e2ptr, eptr);}
	;
	
comparacion_str2:
	comparacion_str {cos2ptr = cosptr;}
	;
	
expresiones:
	expresion
	|expresion_str
	;
	
entero:
	CTE_ENTERA {printf("CTE_ENTERA\n"); agregar_tipoVarible_a_tabla($1,0);}
	;	
	
real:
	CTE_REAL {printf("CTE_REAL\n"); agregar_tipoVarible_a_tabla($1,1);}
	;
	
string:
	CTE_STRING {printf("CTE_STRING\n"); agregar_tipoVarible_a_tabla($1,2);}
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
	expresion
	|elementolista SEPARDOR_COMA {printf("SEPARDOR_COMA\n");} expresion
	;
	
tipo:
	INT {printf("INT\n"); agregar_tipoVarible_a_tabla(posTbl,0);}
	|REAL {printf("REAL\n"); agregar_tipoVarible_a_tabla(posTbl,1);}
	|STRING {printf("STRING\n"); agregar_tipoVarible_a_tabla(posTbl,2);}
	;
%%

void imprimir_nodos(arbol* arbol_sint) {
	if (arbol_sint != NULL) {
		fprintf(archivoArbolSintactico, "%s ", arbol_sint->elemento);
		imprimir_nodos(arbol_sint->izq);
		imprimir_nodos(arbol_sint->der);
	}
}

void imprimir_nodos_inorder(arbol* arbol_sint) {
	if (arbol_sint != NULL) {
		imprimir_nodos_inorder(arbol_sint->izq);
		fprintf(archivoArbolSintactico, "%s ", arbol_sint->elemento);
		imprimir_nodos_inorder(arbol_sint->der);
	}
}

void imprimir_arbol() {	
	archivoArbolSintactico = fopen("./arbolSintactico.txt","w+t");
	fprintf(archivoArbolSintactico, "\nARBOL SINTACTICO:\n================\n\n");
	/* cambiar esto para mostrar una cosa u otra */
	arbol_sintactico = aptr;
	imprimir_nodos(arbol_sintactico);
	
	fprintf(archivoArbolSintactico, "\n\n================\n\n");
	imprimir_nodos_inorder(arbol_sintactico);
	
	fclose(archivoArbolSintactico);
}

arbol* crear_nodo(char* elem, arbol* ni, arbol* nd) {
	arbol *nuevo_nodo = (arbol *)malloc(sizeof(arbol));
	
	strcpy(nuevo_nodo->elemento,elem);
	nuevo_nodo->izq = ni;
	nuevo_nodo->der = nd;
	
	return nuevo_nodo;
}

arbol* crear_hoja(char* elem) {
	arbol *nueva_hoja = (arbol *)malloc(sizeof(arbol));
	
	strcpy(nueva_hoja->elemento,elem);
	nueva_hoja->izq = NULL;
	nueva_hoja->der = NULL;
	
	return nueva_hoja;
}

int yyerror(char const*) {
	printf("Error de sintaxis");
}

int main(int argc, char *argv[]) {
	if((yyin = fopen(argv[1],"rt")) == NULL)
	{	
		printf("No se puede abrir el archivo\n");
	}
	else
	{
		yyparse();
	}
	fclose(yyin);
	
	imprimir_tabla_de_simbolos();
	imprimir_arbol();
	
	return 0;
}
