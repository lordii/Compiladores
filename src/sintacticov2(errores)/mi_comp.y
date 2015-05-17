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
%token ASIGNACION
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
	DEFVAR '\n' declaracionvar '\n' ENDDEF '\n' {printf("Declaraciones de variables\n");}
	|DEFVAR declaracionvar declaracionvar ENDDEF
	;
	
declaracionvar:
	identificador DEFINE tipo FIN_SENTENCIA{printf("definicion de variables\n");} 
	|declaracionvar SEPARDOR_COMA identificador DEFINE tipo FIN_SENTENCIA{printf("definicion de variables\n");}
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
	identificador ASIGNACION expresion FIN_SENTENCIA
	|identificador ASIGNACION expresion_str FIN_SENTENCIA
	;
	
definicionconstante:
	CONST identificador ASIGNACION dato
	;
	
expresion:
	expresion MAS termino
	|expresion MENOS termino
	|termino
	;
	
termino:
	termino POR factor
	|termino DIVIDIDO factor
	|factor
	;
	
factor:
	identificador
	|PAR_ABRE expresion PAR_CIERRA
	|unaryif
	|qequal
	|CTE_ENTERA
	|CTE_REAL
	;
	
expresion_str:
	cte_string
	|cte_string CONCATENACION cte_string
	;
	
repeat:
	REPEAT acciones UNTIL condicion FIN_SENTENCIA
	;
	
if:
	IF condicion THEN acciones ENDIF
	|IF condicion THEN acciones ELSE acciones ENDIF
	;
	
unaryif:
	PAR_ABRE condicion SIG_UNARYIF expresion SEPARDOR_COMA expresion PAR_CIERRA
	|PAR_ABRE condicion SIG_UNARYIF expresion_str SEPARDOR_COMA expresion_str PAR_CIERRA
	;
	
qequal:
	QEQUAL PAR_ABRE expresion SEPARDOR_COMA lista PAR_CIERRA
	;
	
entrada:
	GET identificador FIN_SENTENCIA
	;
	
salida:
	PUT expresion FIN_SENTENCIA
	;
	
condicion:
	comparacion
	|comparacion AND comparacion
	|comparacion OR comparacion
	|NOT comparacion
	|comparacion_str
	|comparacion_str AND comparacion_str
	|comparacion_str OR comparacion_str
	|comparacion_str AND comparacion
	|comparacion_str OR comparacion
	|comparacion AND comparacion_str
	|comparacion OR comparacion_str
	;
	
comparacion:
	expresion MENOR expresion
	|expresion MAYOR expresion
	|expresion MENOR_IGUAL expresion
	|expresion MAYOR_IGUAL expresion
	|expresion IGUAL expresion
	|expresion DISTINTO expresion
	;
	
comparacion_str:
	string IGUAL string
	|string DISTINTO string
	;
	
identificador:
	ID
	;
	
numero:
	CTE_ENTERA
	;
	
entero:
	numero
	;	
	
real:
	CTE_REAL
	;
	
string:
	CTE_STRING
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
	COR_ABRE elementolista COR_CIERRA
	;
	
elementolista:
	expresion
	|elementolista SEPARDOR_COMA expresion
	;
	
tipo:
	INT
	|REAL
	|STRING
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

