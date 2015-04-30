#include <stdio.h>
#include <ctype.h>
#include <string.h>
//no es necesaria pero te saca 4 warnings xd
#include <malloc.h>

#define ES_LETRA 1
#define ES_DIGITO 2
#define ES_SEPARADOR 3
#define ES_COMILLA 4
#define ES_PUNTO 5
#define ES_SIGNO_EXCALAMACION 6
#define ES_SIGNO_IGUAL 7
#define ES_SIGNO_MAYOR 8
#define ES_SIGNO_MENOR 9
#define ES_AMPERSAND 10
#define ES_PIPE 11
#define ES_SIGNO_MAS 12 
#define ES_SIGNO_MENOS 13
#define ES_SIGNO_POR 14
#define ES_SIGNO_DIVIDIDO 15
#define ES_PARENTESIS_ABIERTO 16
#define ES_PARENTESIS_CERRADO 17
#define ES_LLAVE_ABIERTA 18
#define ES_LLAVE_CERRADA 19
#define ES_CORCHETE_ABIERTO 20 
#define ES_CORCHETE_CERRADO 21
#define ES_PUNTO_Y_COMA 22
#define ES_COMA 23
#define ES_NUMERAL 24 
#define ES_PESOS 25
#define ES_PORCIENTO 26 
#define ES_GUION_BAJO 27
#define ES_INTERROGACION 28
#define ES_UN_DOS_PUNTOS 29
#define ERROR -99
#define FIN_DE_COMPILACION -999
#define LIMITE_IDENTIFICADOR 25


/********   TOKENS  *********/

#define AUX_INICIO_TOKENS 257

/* no modificar el orden... */

#define BEGIN 257
#define END 258
#define DECLARE 259
#define ENDDEC 260
#define FLOAT 261
#define INTEGER 262
#define FILTER 263
#define WHILE 264
#define IF 265
#define ELSE 266
#define PRINT 267
#define CTE_REAL 268
#define CTE_ENTERA 269
#define CTE_STRING 270
#define ID 271
#define MAS 272
#define NOT 273
#define ASIGNACION 274
#define MENOR 275
#define DISTINTO 276
#define IGUAL 277
#define MENOR_IGUAL 278
#define MAYOR 279
#define MAYOR_IGUAL 280
#define AND 281
#define OR 282
#define MENOS 283
#define POR 284
#define COMODIN 285
#define DIVIDIDO 286
#define DEFINE 287
#define PAR_ABRE 288
#define PAR_CIERRA 289
#define LLAVE_ABRE 290
#define LLAVE_CIERRA 291
#define COR_ABRE 292
#define COR_CIERRA 293
#define FIN_SENTENCIA 294
#define SEPARADOR 295

/*********************************/

//Esto tiene que ir aca si o si 
int analiza_caracter(char operator);

char caracter;
char token[100];
int longitud;
double cte_float;
int cte_int;
int yyval;

void completa_token(char dest[100], char c) {
     dest[strlen(dest)] = c;
}

void imprime_token(char tok[100]) {
     int i;
     for (i=0; i<strlen(token); i++) {
         printf("%c",tok[i]);
     }
}

char * get_token_from_yyval(int val) {
     switch (val) {
        case 257 : return "BEGIN";
        case 258 : return "END";
        case 259 : return "DECLARE";
        case 260 : return "ENDDEC";
        case 261 : return "FLOAT";
        case 262 : return "INTEGER";
        case 263 : return "FILTER";
        case 264 : return "WHILE";
        case 265 : return "IF";
        case 266 : return "ELSE";
        case 267 : return "PRINT";
        case 268 : return "CTE_REAL";
        case 269 : return "CTE_ENTERA";
        case 270 : return "CTE_STRING";
        case 271 : return "ID";
        case 272 : return "MAS";
        case 273 : return "NOT";
        case 274 : return "ASIGNACION";
        case 275 : return "MENOR";
        case 276 : return "DISTINTO";
        case 277 : return "IGUAL";
        case 278 : return "MENOR_IGUAL";
        case 279 : return "MAYOR";
        case 280 : return "MAYOR_IGUAL";
        case 281 : return "AND";
        case 282 : return "OR";
        case 283 : return "MENOS";
        case 284 : return "POR";
        case 285 : return "COMODIN";
        case 286 : return "DIVIDIDO";
        case 287 : return "DEFINE";
        case 288 : return "PAR_ABRE";
        case 289 : return "PAR_CIERRA";
        case 290 : return "LLAVE_ABRE";
        case 291 : return "LLAVE_CIERRA";
        case 292 : return "COR_ABRE";
        case 293 : return "COR_CIERRA";
        case 294 : return "FIN_SENTENCIA";
        case 295 : return "SEPARADOR";
              
        default : return "TOKEN_NO_RECONOCIDO";                      
     }
}

void inicializa_token(char tok[100]) {
	//agrege casteo sino tira error gcc 4.9
     memset(tok, (int) NULL, 100);
}

struct ts
{
	char nombre[100];
	char tipo_de_token[100];
	char tipo[100];
	char valor[100];
	int longitud;
	int numero;
	struct ts *siguiente;
};


typedef struct ts tabla;
tabla* tabla_simbolos = NULL;


int insertar(char nombre[100],char tipo_de_token[100],char tipo[100],char valor[100], int longitud)
{         
	tabla *nuevo_reg =(tabla *)malloc(sizeof(tabla));
	nuevo_reg->siguiente=tabla_simbolos;

	strcpy(nuevo_reg->nombre,nombre);
	strcpy(nuevo_reg->tipo_de_token,tipo_de_token);
	strcpy(nuevo_reg->tipo,tipo);
	strcpy(nuevo_reg->valor,valor);
    
	nuevo_reg->longitud = longitud;
	
	if (tabla_simbolos != NULL)
	   nuevo_reg->numero = tabla_simbolos->numero + 1;
    else
       nuevo_reg->numero = 0;
       
    tabla_simbolos = nuevo_reg;
    
    return nuevo_reg->numero;
}

int existe(char* nombre)
{
      tabla *act = tabla_simbolos; 
      while((act != NULL) && strcmp(act->nombre, nombre))             
                act = act->siguiente;
      
      if (act != NULL)
         return act->numero;  
      else
         return -1; 
}

void imprimir_tabla_de_simbolos(FILE *archivo)
{
    tabla *act = tabla_simbolos; 
    fprintf(archivo,"\nTABLA DE SIMBOLOS:\n=================\n\n");
    while(act != NULL){ 
         fprintf(archivo,"Token: %s\nTipo de token:%s\nTipo: %s\nValor: %s\nLongitud: %i\nNumero: %i\n\n",act->nombre,act->tipo_de_token,act->tipo,act->valor,act->longitud,act->numero);
         act = act->siguiente;
    }
}

tabla* variable(int indice)
{
    tabla *act = tabla_simbolos; 
    while((act != NULL) && (act->numero != indice))             
                act = act->siguiente;      
      
    return act; 
}

char* palabras_res[]={"begin","end","declare","enddec","float","integer","filter","while","if","else","print"};

int es_palabra_reservada(char* palabra) {
    int es_reservada = 0;
    char palabra_ingresada[100];
    int i = 0;
    strcpy(palabra_ingresada,palabra);
    while((i<=10) && !es_reservada) {
        //Comparo palabra caracter a caracter...
        if (strcmp(strlwr(palabra_ingresada),palabras_res[i]) == 0) {
            es_reservada = 1;
        }
        else {
             i++;
        }
    }
    
    if (!es_reservada)
       return -1;
    else
       return i;
    
}

int contiene_punto(char* palabra) {
    int tiene_punto = 0;
    int i = 0;
    while ((i<strlen(palabra)) && !tiene_punto) {
        if (strcmp(palabra,".") == 0)
            tiene_punto = 1;
        i++;
    }
    
    return tiene_punto;
}

//Funciones lexicas....
int Error() {
    printf(" ERROR!!! ");
    return ERROR;
}

int Inic_cte_entera() {
    completa_token(token,caracter);
    cte_int = atoi(&caracter);
    longitud = 1;
    return 0;
}

int Cont_cte_entera() {
    completa_token(token,caracter);
    cte_int = cte_int * 10 + atoi(&caracter);
    if (cte_int > 65535) {
       printf(" ERROR!!! INT TOO LONG! ");
       return ERROR;
    }
    longitud++;           
    return 0;
}

int Fin_cte_entera() { 
    int pos_en_tabla = existe(token);
    if (cte_int > 65535) {
       printf(" ERROR!!! INT TOO LONG! ");
       return ERROR;
    }
    else {
         if (pos_en_tabla == -1)
            pos_en_tabla = insertar(token,"CONSTANTE","CTE_INTEGER",token,longitud);
    }
    
    yyval = CTE_ENTERA;
    return pos_en_tabla;
}

int Inic_cte_real() {
    completa_token(token,caracter);
    if (strcmp(&caracter,".") == 0) {
       cte_float = 0.0;
    }
    else {
       cte_float = atof(&caracter); 
    }
    longitud = 1;
    return 0;
}

int Cont_cte_real() {
    completa_token(token,caracter);
    if (strcmp(&caracter,".") == 0) {
       cte_float = cte_float / 10 + atof(&caracter);
    }
    else {
       if (contiene_punto(token)) {
          cte_float = (cte_float / 10) + atof(&caracter);      
       }
       else {
          cte_float = (cte_float * 10) + atof(&caracter); 
       }
    }
    
    longitud++;       
    return 0;
}

int Fin_cte_real() {
    int pos_en_tabla = existe(token);

    if (pos_en_tabla == -1)
       pos_en_tabla = insertar(token,"CONSTANTE","CTE_FLOAT",token,longitud);
    
    yyval = CTE_REAL;
    return pos_en_tabla;
}

int Inic_cte_string() { 
    completa_token(token,caracter);
    longitud = 1;
    return 0;
}

int Cont_cte_string() { 
    if (longitud + 1 > 30) {
        return ERROR;
    }
    else {
       completa_token(token,caracter);
       longitud++;
       return 0;
    }
}

int Fin_cte_string() {
    int pos_en_tabla = existe(token);

    if (pos_en_tabla == -1)
        pos_en_tabla = insertar(token,"CONSTANTE","CTE_STRING",token,longitud);
    
    yyval = CTE_STRING;
    return pos_en_tabla;
}

int Inic_oper() {
    completa_token(token,caracter);
    longitud = 1;
    return 0;
}

int Cont_oper() {
    completa_token(token,caracter);
    longitud++;       
    return 0;
}

int Inic_id() {
    completa_token(token,caracter);
    longitud = 1;
    return 0;
}

int Cont_id() {
    completa_token(token,caracter);
    longitud++;
    return 0;
}

int Fin_id() {
    char * tipo;
    int es_reservada;
    int pos_en_tabla;
    
    if (longitud > LIMITE_IDENTIFICADOR) {
        printf("\nIdentificador: \"%s\" demaciado largo!!, solo se admiten identificadores de %i caracteres como maximo.\n",token,LIMITE_IDENTIFICADOR);
        return ERROR;
    }
    
    pos_en_tabla = existe(token);
    
    //Si no esta en la tabla de simbolos...
    if(pos_en_tabla == -1) {
        es_reservada = es_palabra_reservada(token);
        if (es_reservada != -1) {
            tipo = "PR";
            yyval = es_reservada + AUX_INICIO_TOKENS;
            return -1;
        }
        else {
            tipo = "ID";
            yyval = ID;
            pos_en_tabla = insertar(token,tipo,"NO DETERMINADO",token,longitud);
        }       
    }
    //Si esta en la tabla de simbolos
    else {
         //Se que es un id porque las palabras reservadas no van a la tabla de simbolos...
        yyval = ID; 
    }
    return pos_en_tabla;
}

int Oper_Mas() {
    yyval = MAS;
    return -1;
}

int Oper_Not() {
    yyval = NOT;
    return -1;
}

int Oper_Asign() {
    yyval = ASIGNACION;
    return -1;
}

int Oper_Menor() {
    yyval = MENOR;
    return -1;
}

int Oper_Distint() {
    yyval = DISTINTO;
    return -1;
}

int Oper_Igual() {
    yyval = IGUAL;
    return -1;
}

int Oper_Menor_Ig() {
    yyval = MENOR_IGUAL;
    return -1;
}

int Oper_Mayor() {
    yyval = MAYOR;
    return -1;
}

int Oper_Mayor_Ig() {
    yyval = MAYOR_IGUAL;
    return -1;
}

int Oper_And() {
    yyval = AND;
    return -1;
}

int Oper_Or() {
    yyval = OR;
    return -1;
}

int Oper_Menos() {
    yyval = MENOS;
    return -1;
}

int Oper_Mult() {
    yyval = POR;
    return -1;
}

int Oper_Comodin() {
    yyval = COMODIN;
    return -1;
}

int Oper_Dividido() {
    yyval = DIVIDIDO;
    return -1;
}

int Oper_Define() {
    yyval = DEFINE; 
    return -1;
}

int Par_Abre() {
    yyval = PAR_ABRE;
    return -1;
}

int Par_Cierra() {
    yyval = PAR_CIERRA;
    return -1;
}

int Llave_Abre() {
    yyval = LLAVE_ABRE;
    return -1;
}

int Llave_Cierra() {    
    yyval = LLAVE_CIERRA;
    return -1;
}

int Corch_Abre() {
    yyval = COR_ABRE;
    return -1;
}

int Corch_Cierra() {
    yyval = COR_CIERRA;
    return -1;
}

int Fin_Sentencia() {
    yyval = FIN_SENTENCIA;
    return -1;
}

int Separador() {
    yyval = SEPARADOR;
    return -1;
}

//FUNCIONES QUE NO DEBERIAN RETORNAR TOKENS...

int Inic_coment() {
    return -2; // VERRRRR!! que devuelvo?? 0 es token OJO!!
}

int Sin_transicion() {
    return -2; // VERRRRR!! que devuelvo?? 0 es token OJO!!
}

int Cont_coment() {
    return -2; // VERRRRR!! que devuelvo?? 0 es token OJO!!
}

//Matriz de nuevo estado....  
int matriz_nvo_estado[45][29] = {
                            {1,3,6,5,21,22,23,16,18,19,20,30,31,33,34,35,36,37,38,39,41,42,40,8,-1,-1,32,-1,0},
                            {1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99},
                            {2,3,2,24,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,4,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {-1,4,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
                            {6,6,7,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6},
                            {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {-1,-1,-1,-1,9,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
                            {9,9,9,9,12,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,10,9,9,9,9,9},
                            {9,9,9,9,11,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9},
                            {11,11,11,11,14,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,44,11,11,11,11,11},
                            {13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,15,13,13,13,13,13},
                            {13,13,13,13,12,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,43,13,13,13,13,13},
                            {11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,13,11,11,11,11,11},
                            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
                            {2,2,2,2,2,17,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {-1,-1,-1,-1,-1,-1,-1,-1,28,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
                            {-1,-1,-1,-1,-1,-1,-1,-1,-1,29,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1},
                            {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,2,2,2,2,25,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,2,2,2,2,26,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,2,2,2,2,27,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,24,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
                            {13,13,13,13,-1,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13},
                            {11,11,11,11,-1,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11}};

//Matriz de punteros a funciones semanticas...
int (* matriz_punteros[45][29])(void) = {
    {Inic_id,Inic_cte_entera,Inic_cte_string,Inic_cte_real,Inic_oper,Inic_oper,Inic_oper,Inic_oper,Inic_oper,Inic_oper,Inic_oper,Inic_oper,Inic_oper,Inic_oper,Inic_oper,Inic_oper,Inic_oper,Inic_oper,Inic_oper,Inic_oper,Inic_oper,Inic_oper,Inic_oper,Inic_coment,Error,Error,Inic_oper,Error,Sin_transicion},
    {Cont_id,Cont_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id,Fin_id},
    {NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL},
    {Fin_cte_entera,Cont_cte_entera,Fin_cte_entera,Cont_cte_real,Fin_cte_entera,Fin_cte_entera,Fin_cte_entera,Fin_cte_entera,Fin_cte_entera,Fin_cte_entera,Fin_cte_entera,Fin_cte_entera,Fin_cte_entera,Fin_cte_entera,Fin_cte_entera,Fin_cte_entera,Fin_cte_entera,Fin_cte_entera,Fin_cte_entera,Fin_cte_entera,Fin_cte_entera,Fin_cte_entera,Fin_cte_entera,Fin_cte_entera,Fin_cte_entera,Fin_cte_entera,Fin_cte_entera,Fin_cte_entera,Fin_cte_entera},
    {Fin_cte_real,Cont_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real},
    {Error,Cont_cte_real,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error},
    {Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string,Cont_cte_string},
    {Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string,Fin_cte_string},
    {Error,Error,Error,Error,NULL,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error},
    {NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL},
    {NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL},
    {NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL},
    {NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL},
    {NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL},
    {NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL},
    {NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL},
    {Oper_Mayor,Oper_Mayor,Oper_Mayor,Oper_Mayor,Oper_Mayor,Cont_oper,Oper_Mayor,Oper_Mayor,Oper_Mayor,Oper_Mayor,Oper_Mayor,Oper_Mayor,Oper_Mayor,Oper_Mayor,Oper_Mayor,Oper_Mayor,Oper_Mayor,Oper_Mayor,Oper_Mayor,Oper_Mayor,Oper_Mayor,Oper_Mayor,Oper_Mayor,Oper_Mayor,Oper_Mayor,Oper_Mayor,Oper_Mayor,Oper_Mayor,Oper_Mayor},
    {Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig,Oper_Mayor_Ig},
    {Error,Error,Error,Error,Error,Error,Error,Error,Cont_oper,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error},
    {Error,Error,Error,Error,Error,Error,Error,Error,Error,Cont_oper,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error,Error},
    {Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas,Oper_Mas},
    {Oper_Not,Oper_Not,Oper_Not,Oper_Not,Oper_Not,Cont_oper,Oper_Not,Oper_Not,Oper_Not,Oper_Not,Oper_Not,Oper_Not,Oper_Not,Oper_Not,Oper_Not,Oper_Not,Oper_Not,Oper_Not,Oper_Not,Oper_Not,Oper_Not,Oper_Not,Oper_Not,Oper_Not,Oper_Not,Oper_Not,Oper_Not,Oper_Not,Oper_Not},
    {Oper_Asign,Oper_Asign,Oper_Asign,Oper_Asign,Oper_Asign,Cont_oper,Oper_Asign,Oper_Asign,Oper_Asign,Oper_Asign,Oper_Asign,Oper_Asign,Oper_Asign,Oper_Asign,Oper_Asign,Oper_Asign,Oper_Asign,Oper_Asign,Oper_Asign,Oper_Asign,Oper_Asign,Oper_Asign,Oper_Asign,Oper_Asign,Oper_Asign,Oper_Asign,Oper_Asign,Oper_Asign,Oper_Asign},
    {Oper_Menor,Oper_Menor,Oper_Menor,Oper_Menor,Oper_Menor,Cont_oper,Oper_Menor,Oper_Menor,Oper_Menor,Oper_Menor,Oper_Menor,Oper_Menor,Oper_Menor,Oper_Menor,Oper_Menor,Oper_Menor,Oper_Menor,Oper_Menor,Oper_Menor,Oper_Menor,Oper_Menor,Oper_Menor,Oper_Menor,Oper_Menor,Oper_Menor,Oper_Menor,Oper_Menor,Oper_Menor,Oper_Menor},
    {Fin_cte_real,Cont_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real,Fin_cte_real},
    {Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint,Oper_Distint},
    {Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual,Oper_Igual},
    {Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig,Oper_Menor_Ig},
    {Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And,Oper_And},
    {Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or,Oper_Or},
    {Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos,Oper_Menos},
    {Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult,Oper_Mult},
    {Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin,Oper_Comodin},
    {Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido,Oper_Dividido},
    {Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre,Par_Abre},
    {Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra,Par_Cierra},
    {Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre,Llave_Abre},
    {Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra,Llave_Cierra},
    {Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre,Corch_Abre},
    {Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra,Corch_Cierra},
    {Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define,Oper_Define},
    {Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia,Fin_Sentencia},
    {Separador,Separador,Separador,Separador,Separador,Separador,Separador,Separador,Separador,Separador,Separador,Separador,Separador,Separador,Separador,Separador,Separador,Separador,Separador,Separador,Separador,Separador,Separador,Separador,Separador,Separador,Separador,Separador,Separador},
    {NULL,NULL,NULL,NULL,Error,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL},
    {NULL,NULL,NULL,NULL,Error,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL}};

FILE * archivo_a_compilar;

/*
* Esta funcion retorna el numero de columan correspondiente al caracter
* analizado, o -1 en caso de error.
*/
int get_evento(char c) {
    int resultado = analiza_caracter(c);
    switch (resultado) {            
        case (ES_LETRA) : return 0;
        case (ES_DIGITO) : return 1;
        case (ES_COMILLA) : return 2;
        case (ES_PUNTO) : return 3;
        case (ES_SIGNO_EXCALAMACION) : return 4;
        case (ES_SIGNO_IGUAL) : return 5;
        case (ES_SIGNO_MENOR) : return 6;
        case (ES_SIGNO_MAYOR) : return 7;
        case (ES_AMPERSAND) : return 8;
        case (ES_PIPE) : return 9;
        case (ES_SIGNO_MAS) : return 10; 
        case (ES_SIGNO_MENOS) : return 11;
        case (ES_SIGNO_POR) : return 12;
        case (ES_SIGNO_DIVIDIDO) : return 13;
        case (ES_PARENTESIS_ABIERTO) : return 14;
        case (ES_PARENTESIS_CERRADO) : return 15;
        case (ES_LLAVE_ABIERTA) : return 16;
        case (ES_LLAVE_CERRADA) : return 17;
        case (ES_CORCHETE_ABIERTO) : return 18; 
        case (ES_CORCHETE_CERRADO) : return 19;
        case (ES_PUNTO_Y_COMA) : return 20;
        case (ES_COMA) : return 21;
        case (ES_UN_DOS_PUNTOS) : return 22;
        case (ES_NUMERAL) : return 23; 
        case (ES_PESOS) : return 24;
        case (ES_PORCIENTO) : return 25; 
        case (ES_GUION_BAJO) : return 26;
        case (ES_INTERROGACION) : return 27;
        case (ES_SEPARADOR) : return 28;
        
        default : return ERROR;
    }
}

//ESTAS FUNCIONES VAN ARRIBA DEL MAIN SINO NO VA A COMPILAR
// y se hace declaracion previa

/*
* Esta funcion analiza el caracter que recibe y retorna un entero
* representando dicho caracter. Cada entero esta definido arriba y
* su nombre denota lo que es.
*/
int analiza_caracter(char c) {
    if (isupper(c) | islower(c) == 2) {
       return ES_LETRA;
    }
    else {
         if (isdigit(c)) {
            return ES_DIGITO;
         }
         else {
            if (isspace(c) | !isprint(c)) {
               return ES_SEPARADOR;
            }
            else {
                if (ispunct(c)) {
                      switch (c) {
                          case '\"' : return ES_COMILLA;
                          case '.' : return ES_PUNTO;
                          case '!' : return ES_SIGNO_EXCALAMACION;
                          case '=' : return ES_SIGNO_IGUAL;
                          case '>' : return ES_SIGNO_MAYOR;
                          case '<' : return ES_SIGNO_MENOR;
                          case '&' : return ES_AMPERSAND;
                          case '|' : return ES_PIPE;
                          case '+' : return ES_SIGNO_MAS;
                          case '-' : return ES_SIGNO_MENOS;
                          case '*' : return ES_SIGNO_POR;
                          case '/' : return ES_SIGNO_DIVIDIDO;
                          case '(' : return ES_PARENTESIS_ABIERTO;
                          case ')' : return ES_PARENTESIS_CERRADO;
                          case '{' : return ES_LLAVE_ABIERTA;
                          case '}' : return ES_LLAVE_CERRADA;
                          case '[' : return ES_CORCHETE_ABIERTO;
                          case ']' : return ES_CORCHETE_CERRADO;
                          case ';' : return ES_PUNTO_Y_COMA;
                          case ':' : return ES_UN_DOS_PUNTOS;
                          case ',' : return ES_COMA;
                          case '#' : return ES_NUMERAL;
                          case '$' : return ES_PESOS;
                          case '%' : return ES_PORCIENTO;
                          case '_' : return ES_GUION_BAJO;
                          case '?' : return ES_INTERROGACION;
                          default : return ERROR;                      
                      }
                } 
            }
         }
    }
}


int main (int argc, char *argv[])
{    
    int result;
    FILE * archivoResumenCompilacion;
    char * nombreArchivo = argv[1];
    char caracterLeido;

    printf ( "\nIniciando compilacion de archivo: %s...\n",nombreArchivo );
    
    //Imprimo el archivo a compilar en el resumen...
    archivo_a_compilar = fopen (nombreArchivo, "r");
    
    if (archivo_a_compilar == NULL) {
		//sentencia return vacia?
       printf("\nEl archivo indicado no existe!\n");
       return -1;
    }
    
    archivoResumenCompilacion = fopen("./resumenCompilacion.txt","w+t");
    fprintf(archivoResumenCompilacion,"\nPROGRAMA COMPILADO:\n==================\n\n");
    
    while (feof(archivo_a_compilar) == 0) {
          caracterLeido = fgetc(archivo_a_compilar);
          if (isspace(caracterLeido) | isprint(caracterLeido)) {
              fprintf(archivoResumenCompilacion,"%c",caracterLeido);
          }
    }
    
    fprintf(archivoResumenCompilacion,"\n\nANALISIS COMPILACION:\n====================\n\n"); 
    
    //Reabro el archivo para compilar...
    fclose (archivo_a_compilar);
    archivo_a_compilar = fopen (nombreArchivo, "r");
    
    while (feof(archivo_a_compilar) == 0) {
          inicializa_token(token);
          result = yylex();
          if (result != FIN_DE_COMPILACION)
             fprintf (archivoResumenCompilacion, "Analizado: --> %s <--, token resultante --> %s <-- (yyval = %i), yylex() retorno: --> %i <--\n\n",token,get_token_from_yyval(yyval),yyval,result);
          if (result == ERROR)
             break;
    }
    
    imprimir_tabla_de_simbolos(archivoResumenCompilacion);
    fclose(archivoResumenCompilacion);
    
    printf ( "\nCompilacion finalizada!\n" );
    printf ( "\n\nPresione ENTER para finalizar...\n" );
    fgets (nombreArchivo, 150, stdin);
	
    
    return 0;
}

int yylex() {
    
    //char caracter;
    int columna, estado, estado_final, token_resultante;
    
    estado = 0;
    estado_final= 2;
    
    if (feof(archivo_a_compilar) != 0) {
       printf ("\nEl archivo esta vacio!!\n");
       return 1;
    }
    
    while (estado != estado_final) { 
          
          if (feof(archivo_a_compilar) != 0) {
             if (estado == 0) {
                 return FIN_DE_COMPILACION;
             } 
             else {
                 printf ("\nFin de archivo inesperado!!\n");
                 return ERROR;
             }
          }
          else {
             caracter = fgetc(archivo_a_compilar);
          }
          
          columna = get_evento(caracter);
          
          if (columna == ERROR) {
             printf ("\nATENCION!! --> no se reconoce el caracter: %c\n",caracter);
             return ERROR;
          }
          
          //printf ( "---> Voy desde estado: \"%i\" con caracter: \"%c\" a nuevo estado: %i\n",estado,caracter,matriz_nvo_estado[estado][columna]);
          
          if (matriz_punteros[estado][columna] != NULL) {
             token_resultante = (* matriz_punteros[estado][columna]) ();
          }
          estado = matriz_nvo_estado[estado][columna];
          
          if (estado == -1) {
             printf ("\nError de sintaxis!!\n");
             return ERROR;
          }           
    }
    
    if (estado == estado_final) {
        ungetc(caracter,archivo_a_compilar);
        return token_resultante;     
    }
     
}


