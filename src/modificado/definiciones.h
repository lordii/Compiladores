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
#define LIMITE_ENTEROS 65535
#define LONGITUD_STRING 30
#define COMENTARIO -2

/********   TOKENS  *********/

#define AUX_INICIO_TOKENS 257

#define DEFVAR 257
#define ENDDEF 258
#define CONST 259
#define INT 260
#define REAL 261
#define STRING 262
#define GET 263
#define PUT 264
#define REPEAT 265
#define UNTIL 266
#define IF 267
#define THEN 268
#define ELSE 269
#define ENDIF 270
#define QEQUAL 271
#define AND 272
#define OR 273
#define CTE_REAL 274
#define CTE_ENTERA 275
#define CTE_STRING 276
#define ID 277
#define MAS 278
#define MENOS 279
#define POR 280
#define DIVIDIDO 281
#define ASIGNACION 282
#define IGUAL 283
#define MENOR 284
#define MENOR_IGUAL 285
#define MAYOR 286
#define MAYOR_IGUAL 297
#define DISTINTO 288
#define NOT 289
#define PAR_ABRE 290
#define PAR_CIERRA 291
#define COR_ABRE 292
#define COR_CIERRA 293
#define DEFINE 294
#define SEPARDOR_COMA 295
#define SIG_UNARYIF 296
#define FIN_SENTENCIA 297
#define SEPARADOR 298
