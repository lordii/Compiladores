/*seccion declaraciones*/
%{		//includes,defines,variables globales
	#include<stdio.h>
	#include<stdlib.h>
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
	DEFVAR {printf("Inicio declaraciones")} declaracionvar ENDEF {printf("Fin de declaraciones")}
	|DEFVAR {printf("Inicio de declaraciones")} declaracionvar declaracionvar ENDEF {printf("Fin de declaraciones")}
	;

declaracionvar:
	identificador DEFINE tipo FIN_SENTENCIA
	|declaracionvar identificador DEFINE tipo FIN_SENTENCIA
	;

acciones:
	accion
	|accion accion
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
        |termino DIVIDO factor
        |factor
        ;

factor:
        identificador
        |expresion
        |unariif
        |qequal
        |cte_entero
        |cte_real
        ;

expresion_str:
        cte_string
        |string
        |expresion_str CONCATENACION expresion_str


