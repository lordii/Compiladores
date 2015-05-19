/*seccion declaraciones*/
%{ 
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<ctype.h>
int yyerror(char const*);
extern int yyparse();
extern "C" int yylex();
extern FILE *yyin;
int yystopparser=0;
%}

/*seccion tokens*/
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

/*reglas*/
/***
aca van las reglas (bnf)
los terminales tienen que ser los tokens que estan arriba
no se si esto admite comentarios borrar todo despues
termina en ;
***/

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
	identificador SIG_ASIGNACION {printf("SIG_ASIGNACION\n");} expresion fin_sentencia
	|identificador SIG_ASIGNACION {printf("SIG_ASIGNACION\n");} expresion_str fin_sentencia
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
	|par_apertura expresion par_cierre
	|unaryif
	|qequal
	|CTE_ENTERA {printf("CTE_ENTERA\n");}
	|CTE_REAL {printf("CTE_REAL\n");}
	;
	
expresion_str:
	cte_string
	|cte_string CONCATENACION {printf("CONCATENACION\n");} cte_string
	;
	
repeat:
	REPEAT {printf("REPEAT\n");} acciones UNTIL condicion fin_sentencia
	;
	
if:
	IF {printf("IF\n");} cuerpoif ENDIF {printf("ENDIF\n");}
	;
	
cuerpoif:
	condicion THEN acciones
	|condicion THEN acciones ELSE acciones
	;
	
unaryif:
	par_apertura condicion SIG_UNARYIF {printf("UNARYIF\n");} expresion SEPARDOR_COMA expresion par_cierre {printf("FINUNARYIF\n");}
	|par_apertura condicion SIG_UNARYIF {printf("UNARYIF\n");} expresion_str SEPARDOR_COMA expresion_str par_cierre {printf("FINUNARYIF\n");}
	;
	
qequal:
	QEQUAL {printf("QEQUAL\n");} PAR_ABRE expresion SEPARDOR_COMA lista PAR_CIERRA {printf("FINQEQUAL\n");}
	;
	
entrada:
	GET {printf("GET\n");} identificador fin_sentencia
	;
	
salida:
	PUT {printf("PUT\n");} expresion fin_sentencia
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
	string IGUAL {printf("IGUAL\n");} string
	|string DISTINTO {printf("DISTINTO\n");} string
	;
	
identificador:
	ID {printf("ID\n");}
	;
	
numero:
	CTE_ENTERA {printf("CTE_ENTERA\n");}
	;
	
entero:
	numero
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

	
cte_string:
	string
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

par_apertura:
	PAR_ABRE {printf("PAR_ABRE\n");}
	;

par_cierre:
	PAR_CIERRA {printf("PAR_CIERRA\n");}
	;
	
fin_sentencia:
	FIN_SENTENCIA {printf("FIN_SENTENCIA\n");}
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
	return 0;

}

