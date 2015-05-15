/*seccion declaraciones*/
%{		//includes,defines,variables globales
	#include<stdio.h>
	#include<stdlib.h>
        extern int yylex(void);
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
	DEFVAR {printf("Inicio declaraciones")} declaracionvar ENDDEF {printf("Fin de declaraciones")}
	|DEFVAR {printf("Inicio de declaraciones")} declaracionvar declaracionvar ENDDEF {printf("Fin de declaraciones")}
	;

declaracionvar:
	identificador DEFINE tipo FIN_SENTENCIA
	|declaracionvar SEPARDOR_COMA identificador DEFINE tipo FIN_SENTENCIA
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
        |termino DIVIDIDO factor
        |factor
        ;

factor:
        identificador
        |expresion
        |unaryif
        |qequal
        |cte_entera
        |cte_real
        ;

expresion_str:
        cte_string
        |string
        |expresion_str CONCATENACION expresion_str
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
	comparacion_str IGUAL comparacion_str
	|comparacion_str DISTINTO comparacion_str
	;	

/* comentarios va , creo que no*/

identificador:
	letra
	|digito
	|alfanumerico
	;

alfanumerico:
	letra
	|digito
	|alfanumerico letra
	|alfanumerico digito
	;
	
numero:
	digito
	|numero digito
	;
	
	
real:
	numero '.' numero
	|'.' numero
	|numero '.'
	;
	
	
string:
	'"' alfanumerico '"'
	;
	
dato:
	entero
	|real
	|string
	;

cte_entera:
	numero
	;
	
cte_real:
	real
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

/*falta ver como definir letra digito y entero*/

int main(int argc,char *argv[]){
	/*aca se pasa el archivo y se llama a yyparse() estoy probando como...*/

}

int yyerror(void){
    printf("Syntax Error");
    system("Pause");
    exit(1);
}
