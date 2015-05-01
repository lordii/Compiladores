/*definiciones*/

#define ES_LETRA 1
#define ES_DIGITO 2
#define ES_COMILLA 3
#define ES_PUNTO 4
#define ES_SIGNO_MAS 5
#define ES_SIGNO_MENOS 6
#define ES_SIGNO_POR 7
#define ES_SIGNO_DIVIDIDO 8
#define ES_SIGNO_EXCALAMACION 9
#define ES_DOS_PUNTOS 10
#define ES_PUNTO_Y_COMA 11
#define ES_COMA 12
#define ES_INTERROGACION 13
#define ES_SIGNO_IGUAL 14
#define ES_SIGNO_MAYOR 15
#define ES_SIGNO_MENOR 16
#define ES_PARENTESIS_ABIERTO 17
#define ES_PARENTESIS_CERRADO 18
#define ES_CORCHETE_ABIERTO 19
#define ES_CORCHETE_CERRADO 20
#define ES_SEPARADOR 21

#define ERROR -99
#define FIN_DE_COMPILACION -999

#define LIMITE_IDENTIFICADOR 25

/********   TOKENS  *********/

#define AUX_INICIO_TOKENS 257

#define DEFVAR 257
#define ENDDEF 258
#define CONST 259
#define INT 260
#define REAL 261
#define STRING 262
#define BOOLEAN 263
#define TRUE 264
#define FALSE 265
#define GET 266
#define PUT 267
#define REPEAT 268
#define UNTIL 269
#define IF 270
#define THEN 271
#define ELSE 272
#define ENDIF 273
#define QEQUAL 274
#define AND 275
#define OR 276
#define CTE_REAL 277
#define CTE_ENTERA 278
#define CTE_STRING 279
#define ID 280
#define MAS 281
#define MENOS 282
#define POR 283
#define DIVIDIDO 284
#define ASIGNACION 285
#define IGUAL 286
#define MENOR 287
#define MENOR_IGUAL 288
#define MAYOR 289
#define MAYOR_IGUAL 290
#define DISTINTO 291
#define NOT 292
#define PAR_ABRE 293
#define PAR_CIERRA 294
#define COR_ABRE 295
#define COR_CIERRA 296
#define DEFINE 297
#define SEPARDOR_COMA 298
#define SIG_UNARYIF 299
#define FIN_SENTENCIA 300
#define SEPARADOR 301