%{ 
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<ctype.h>
int yyerror(char const*);
extern yyparse();
extern "C" void imprimir_tabla_de_simbolos();
extern "C" int yylex();
extern FILE *yyin;
int yystopparser=0;
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
	identificador DEFINE {printf("DEFINE\n");} tipo 
	|declaracionvar SEPARDOR_COMA {printf("SEPARDOR_COMA\n");} identificador DEFINE {printf("DEFINE\n");} tipo 
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
	identificador SIG_ASIGNACION {printf("SIG_ASIGNACION\n");} expresiones FIN_SENTENCIA {printf("FIN_SENTENCIA\n");}
	;
	
definicionconstante:
	CONST {printf("CONST\n");} identificador SIG_ASIGNACION {printf("SIG_ASIGNACION\n");} dato
	;
	
expresion:
	expresion MAS {printf("MAS\n");} termino
	|expresion MENOS {printf("MENOS\n");} termino
	|termino
	;
	
termino:
	termino POR {printf("POR\n");} factor
	|termino DIVIDIDO {printf("DIVIDIDO\n");} factor
	|factor
	;
	
factor:
	identificador
	|PAR_ABRE expresion PAR_CIERRA  { $$ = $2; } 
	|unaryif
	|qequal
	|CTE_ENTERA {printf("CTE_ENTERA\n");}
	|CTE_REAL {printf("CTE_REAL\n");}
	;
	
expresion_str:
	|string CONCATENACION {printf("CONCATENACION\n");} string
	|CTE_STRING {printf("CTE_STRING\n");}
	;
	
repeat:
	REPEAT {printf("REPEAT\n");} acciones UNTIL {printf("UNTIL\n");} condicion FIN_SENTENCIA {printf("FIN_SENTENCIA\n");}
	;
	
if:
	IF {printf("IF\n");} condicion THEN cuerpoif ENDIF {printf("ENDIF\n");}
	;

cuerpoif:
	acciones
	| acciones ELSE {printf("ELSE\n");} acciones
	;
	
unaryif:
	PAR_ABRE condicion SIG_UNARYIF {printf("UNARYIF\n");} cuerpounaryif PAR_CIERRA
	;
	
cuerpounaryif:
	expresion SEPARDOR_COMA expresion
	|expresion_str SEPARDOR_COMA expresion_str
	;
	
qequal:
	QEQUAL {printf("QEQUAL\n");} PAR_ABRE expresion SEPARDOR_COMA {printf("SEPARDOR_COMA\n");} lista PAR_CIERRA
	;
	
entrada:
	GET {printf("GET\n");} identificador FIN_SENTENCIA {printf("FIN_SENTENCIA\n");}
	;
	
salida:
	PUT {printf("PUT\n");} expresiones FIN_SENTENCIA {printf("FIN_SENTENCIA\n");}
	;
	
condicion:
	comparacion
	|comparacion AND {printf("AND\n");} comparacion
	|comparacion OR {printf("OR\n");} comparacion
	|NOT {printf("NOT\n");} comparacion
	|comparacion_str
	|comparacion_str AND {printf("AND\n");} comparacion_str
	|comparacion_str OR {printf("OR\n");} comparacion_str
	|comparacion_str AND {printf("AND\n");} comparacion
	|comparacion_str OR {printf("OR\n");} comparacion
	|comparacion AND {printf("AND\n");} comparacion_str
	|comparacion OR {printf("OR\n");} comparacion_str
	;
	
comparacion:
	expresion MENOR {printf("MENOR\n");} expresion
	|expresion MAYOR {printf("MAYOR\n");} expresion
	|expresion MENOR_IGUAL {printf("MENOR_IGUAL\n");} expresion
	|expresion MAYOR_IGUAL {printf("MAYOR_IGUAL\n");} expresion
	|expresion IGUAL {printf("IGUAL\n");} expresion
	|expresion DISTINTO {printf("DISTINTO\n");} expresion
	;
	
comparacion_str:
	expresion_str IGUAL {printf("IGUAL\n");} expresion_str
	|expresion_str DISTINTO {printf("DISTINTO\n");} expresion_str
	;
	
expresiones:
	expresion
	| expresion_str
	;
	
identificador:
	ID {printf("ID\n");}
	;
	
entero:
	CTE_ENTERA {printf("CTE_ENTERA\n");}
	;	
	
real:
	CTE_REAL {printf("CTE_REAL\n");}
	;
	
string:
	CTE_STRING {printf("CTE_STRING\n");}
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
	INT {printf("INT\n");}
	|REAL {printf("REAL\n");}
	|STRING {printf("STRING\n");}
	;
	
%%


int yyerror(char const*)
{
	printf("Error de sintaxis");
}

int main(int argc, char *argv[])
{
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
	return 0;

}
