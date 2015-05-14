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
	identificador:tipo;
	|declaracionvar identificador:tipo
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
	identificador=expresion
	|identificador=expresion_str
	;

definicionconstante:
	CONST identificador=dato
	;

