#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <malloc.h>

#include <definiciones.h>

//Esto tiene que ir aca si o si y asi
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
		case 257 : return "DEFVAR";
        case 258 : return "ENDDEF";
        case 259 : return "CONST";
        case 260 : return "INT";
        case 261 : return "REAL";
        case 262 : return "STRING";
        case 263 : return "BOOLEAN";
        case 264 : return "TRUE";
        case 265 : return "FALSE";
        case 266 : return "PUT";
        case 267 : return "GET";
        case 268 : return "REPEAT";
        case 269 : return "UNTIL";
        case 270 : return "IF";
        case 271 : return "THEN";
        case 272 : return "ELSE";
        case 273 : return "ENDIF";
        case 274 : return "QEQUAL";
        case 275 : return "AND";
        case 276 : return "OR";
        case 277 : return "CTE_REAL";
        case 278 : return "CTE_ENTERA";
        case 279 : return "CTE_STRING";
        case 280 : return "ID";
        case 281 : return "MAS";
        case 282 : return "MENOS";
        case 283 : return "POR";
        case 284 : return "DIVIDIDO";
        case 285 : return "ASIGNACION";
        case 286 : return "IGUAL";
        case 287 : return "MENOR";
        case 288 : return "MENOR_IGUAL";
        case 289 : return "MAYOR";
        case 290 : return "MAYOR_IGUAL";
        case 291 : return "DISTINTO";
        case 292 : return "NOT";
        case 293 : return "PAR_ABRE";
        case 294 : return "PAR_CIERRA";
        case 295 : return "COR_ABRE";
        case 296 : return "COR_CIERRA";
        case 297 : return "DEFINE";
        case 298 : return "SEPARDOR_COMA";
        case 299 : return "SIG_UNARYIF";
        case 300 : return "FIN_SENTENCIA";
        case 301 : return "SEPARADOR";
              
        default : return "TOKEN_NO_RECONOCIDO";                   
     }
}

void inicializa_token(char tok[100]) {
	//agrege casteo sino tira error gcc 4.9
     memset(tok, (int) NULL, 100);
}

//no cambiar orden de estas sentencias
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

char* palabras_res[]={"DEFVAR","ENDDEF","CONST","Int","Real","String","Boolean","True","False","GET","PUT",
			"REPEAT","UNTIL","IF","THEN","ELSE","ENDIF","QEqual","AND","OR"};
			
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

int error_com() {
    printf("\nError: Se ha superado la cantidad de niveles anidados de comentarios permitidos.\n");
    return ERROR;
}

int inic_cte() {
    completa_token(token,caracter);
    cte_int = atoi(&caracter);
    longitud = 1;
    return 0;
}

int cont_cte() {
    completa_token(token,caracter);
    cte_int = cte_int * 10 + atoi(&caracter);
    if (cte_int > 65535) {
       printf("\nError: Entero demasiado largo. (No puede superar 65535)\n");
       return ERROR;
    }
    longitud++;           
    return 0;
}

int fin_cte() { 
    int pos_en_tabla = existe(token);

    if (pos_en_tabla == -1)
    	pos_en_tabla = insertar(token,"CONSTANTE","CTE_ENTERA",token,longitud);
    
    yyval = CTE_ENTERA;
    return pos_en_tabla;
}

int inic_real() {
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

int cont_real() {
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

int fin_real() {
    int pos_en_tabla = existe(token);

    if (pos_en_tabla == -1)
       pos_en_tabla = insertar(token,"CONSTANTE","CTE_REAL",token,longitud);
    
    yyval = CTE_REAL;
    return pos_en_tabla;
}

int inic_str() { 
    completa_token(token,caracter);
    longitud = 1;
    return 0;
}

int cont_str() { 
    if (longitud + 1 > 30) {
	printf("\nError: String demasiado largo. (Capacidad maxima: 30 caracteres)\n");
        return ERROR;
    }
    else {
       completa_token(token,caracter);
       longitud++;
       return 0;
    }
}

int fin_str() {
    int pos_en_tabla = existe(token);

    if (pos_en_tabla == -1)
        pos_en_tabla = insertar(token,"CONSTANTE","CTE_STRING",token,longitud);
    
    yyval = CTE_STRING;
    return pos_en_tabla;
}

int inic_id() {
    completa_token(token,caracter);
    longitud = 1;
    return 0;
}

int cont_id() {
    completa_token(token,caracter);
    longitud++;
    return 0;
}

int fin_id() {
    char * tipo;
    int es_reservada;
    int pos_en_tabla;
    
    if (longitud > LIMITE_IDENTIFICADOR) {
        printf("\nIdentificador: \"%s\" demasiado largo!!, solo se admiten identificadores de %i caracteres como maximo.\n",token,LIMITE_IDENTIFICADOR);
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
            pos_en_tabla = insertar(token, tipo,"NO DETERMINADO",token,longitud);
        }       
    }
    //Si esta en la tabla de simbolos
    else {
        //Se que es un id porque las palabras reservadas no van a la tabla de simbolos...
        yyval = ID; 
    }
    return pos_en_tabla;
}

int op_sum() {
    yyval = MAS;
    return -1;
}

int op_res() {
    yyval = MENOS;
    return -1;
}

int op_mult() {
    yyval = POR;
    return -1;
}

int inic_div() {
    completa_token(token,caracter);
    longitud = 1;
    return 0;
}

int op_div() {
    yyval = DIVIDIDO;
    return -1;
}

//terminar estos, estaban en la matriz pero no definidos
int inic_igual_igual(){
	completa_token(token,caracter);
    longitud = 1;
	return 0;
}

int inic_mayor_igual(){
	completa_token(token,caracter);
    longitud = 1;
	return -0;
}

int inic_menor_igual(){
	completa_token(token,caracter);
    longitud = 1;
	return -0;
}

int op_neg() {
    yyval = NOT;
    return -1;
}

int op_asig() {
    yyval = ASIGNACION;
    return -1;
}

int op_menor() {
    yyval = MENOR;
    return -1;
}

int op_menor_igual() {
    yyval = MENOR_IGUAL;
    return -1;
}

int op_mayor() {
    yyval = MAYOR;
    return -1;
}

int op_mayor_igual() {
    yyval = MAYOR_IGUAL;
    return -1;
}

int op_distinto() {
    yyval = DISTINTO;
    return -1;
}

int op_igual_igual() {
    yyval = IGUAL;
    return -1;
}

int par_apertura() {
    yyval = PAR_ABRE;
    return -1;
}

int par_cierre() {
    yyval = PAR_CIERRA;
    return -1;
}

int cor_apertura() {
    yyval = COR_ABRE;
    return -1;
}

int cor_cierre() {
    yyval = COR_CIERRA;
    return -1;
}

int op_define() {
    yyval = DEFINE; 
    return -1;
}

int op_separador() {
    yyval = SEPARDOR_COMA; 
    return -1;
}

int op_unaryif() {
    yyval = SIG_UNARYIF; 
    return -1;
}

int fin_sentencia() {
    yyval = FIN_SENTENCIA;
    return -1;
}

int separador() {
    yyval = SEPARADOR;
    return -1;
}

int inic_com() {
    return -2; // VERRRRR!! que devuelvo?? 0 es token OJO!!
}

int cont_com() {
    return -2; // VERRRRR!! que devuelvo?? 0 es token OJO!!
}

int fin_com() {
    return -2; // VERRRRR!! que devuelvo?? 0 es token OJO!!
}

int sin_transicion() {
    return -2; // VERRRRR!! que devuelvo?? 0 es token OJO!!
}


int matriz_nvo_estado[18][21] = {
				 {2,3,1,4,90,90,90,8,90,90,90,90,90,7,5,6,90,90,90,90,0},
				 {1,1,90,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
				 {2,2,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99},
				 {99,3,99,4,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99},
				 {99,4,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99},
				 {99,99,99,99,99,99,99,99,99,99,99,99,99,90,99,90,99,99,99,99,99},
				 {99,99,99,99,99,99,99,99,99,99,99,99,99,90,99,99,99,99,99,99,99},
				 {99,99,99,99,99,99,99,99,99,99,99,99,99,90,99,99,99,99,99,99,99},
				 {99,99,99,99,99,99,99,99,9,99,99,99,99,99,99,99,99,99,99,99,99},
				 {9,9,9,9,9,9,9,11,10,9,9,9,9,9,9,9,9,9,9,9,9},
								//
				 {9,9,9,9,9,9,9,90,10,9,9,9,9,9,9,9,9,9,9,9,9},
				 {9,9,9,9,9,9,9,11,12,9,9,9,9,9,9,9,9,9,9,9,9},
				 {12,12,12,12,12,12,12,12,13,12,12,12,12,12,12,12,12,12,12,12,12},
				 {12,12,12,12,12,12,12,14,13,12,12,12,12,12,12,12,12,12,12,12,12},
				 {14,14,14,14,14,14,14,14,15,14,14,14,14,14,14,14,14,14,14,14,14},
									   //
				 {14,14,14,14,14,14,14,90,15,14,14,14,14,14,14,14,14,14,14,14,14},
				 {12,12,12,12,12,12,12,12,-1,12,12,12,12,12,12,12,12,12,12,12,12},
				 {14,14,14,14,14,14,14,14,-1,14,14,14,14,14,14,14,14,14,14,14,14}
				};

//Matriz de punteros a funciones semanticas...
int (* matriz_punteros[18][21])(void) = {
					 {inic_id,inic_cte,inic_str,inic_real,op_sum,op_res,op_mult,inic_div,op_neg,op_define,fin_sentencia,op_separador,op_unaryif,inic_igual_igual,inic_menor_igual,inic_mayor_igual,par_apertura,par_cierre,cor_apertura,cor_cierre,sin_transicion},
					 {cont_str,cont_str,fin_str,cont_str,cont_str,cont_str,cont_str,cont_str,cont_str,cont_str,cont_str,cont_str,cont_str,cont_str,cont_str,cont_str,cont_str,cont_str,cont_str,cont_str,cont_str},
					 {cont_id,cont_id,fin_id,fin_id,fin_id,fin_id,fin_id,fin_id,fin_id,fin_id,fin_id,fin_id,fin_id,fin_id,fin_id,fin_id,fin_id,fin_id,fin_id,fin_id,fin_id},
					 {fin_cte,cont_cte,fin_cte,inic_real,fin_cte,fin_cte,fin_cte,fin_cte,fin_cte,fin_cte,fin_cte,fin_cte,fin_cte,fin_cte,fin_cte,fin_cte,fin_cte,fin_cte,fin_cte,fin_cte,fin_cte},
					 {fin_real,cont_real,fin_real,fin_real,fin_real,fin_real,fin_real,fin_real,fin_real,fin_real,fin_real,fin_real,fin_real,fin_real,fin_real,fin_real,fin_real,fin_real,fin_real,fin_real,fin_real},
					 {op_menor,op_menor,op_menor,op_menor,op_menor,op_menor,op_menor,op_menor,op_menor,op_menor,op_menor,op_menor,op_menor,op_menor_igual,op_menor,op_distinto,op_menor,op_menor,op_menor,op_menor,op_menor},
					 {op_mayor,op_mayor,op_mayor,op_mayor,op_mayor,op_mayor,op_mayor,op_mayor,op_mayor,op_mayor,op_mayor,op_mayor,op_mayor,op_mayor_igual,op_mayor,op_mayor,op_mayor,op_mayor,op_mayor,op_mayor,op_mayor},
					 {op_asig,op_asig,op_asig,op_asig,op_asig,op_asig,op_asig,op_asig,op_asig,op_asig,op_asig,op_asig,op_asig,op_igual_igual,op_asig,op_asig,op_asig,op_asig,op_asig,op_asig,op_asig},
					 {op_div,op_div,op_div,op_div,op_div,op_div,op_div,op_div,NULL,op_div,op_div,op_div,op_div,op_div,op_div,op_div,op_div,op_div,op_div,op_div,op_div},
					 {NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL},
					 {NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL},
					 {NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL},
					 {NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL},
					 {NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL},
					 {NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL},
					 {NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL},
					 {NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,error_com,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL},
					 {NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,error_com,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL},
					};


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
        case (ES_SIGNO_MAS) : return 4;
        case (ES_SIGNO_MENOS) : return 5;
        case (ES_SIGNO_POR) : return 6;
        case (ES_SIGNO_DIVIDIDO) : return 7;
        case (ES_SIGNO_EXCALAMACION) : return 8;
        case (ES_DOS_PUNTOS) : return 9;
        case (ES_PUNTO_Y_COMA) : return 10; 
        case (ES_COMA) : return 11;
        case (ES_INTERROGACION) : return 12;
        case (ES_SIGNO_IGUAL) : return 13;
        case (ES_SIGNO_MAYOR) : return 14;
        case (ES_SIGNO_MENOR) : return 15;
        case (ES_PARENTESIS_ABIERTO) : return 16;
        case (ES_PARENTESIS_CERRADO) : return 17;
        case (ES_CORCHETE_ABIERTO) : return 18; 
        case (ES_CORCHETE_CERRADO) : return 19;
        case (ES_SEPARADOR) : return 20;
        
        default : return ERROR;
    }
}

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
                   case '\"': return ES_COMILLA;
                          case '.' : return ES_PUNTO;
                          case '!' : return ES_SIGNO_EXCALAMACION;
                          case '=' : return ES_SIGNO_IGUAL;
                          case '>' : return ES_SIGNO_MAYOR;
                          case '<' : return ES_SIGNO_MENOR;
                          case '+' : return ES_SIGNO_MAS;
                          case '-' : return ES_SIGNO_MENOS;
                          case '*' : return ES_SIGNO_POR;
                          case '/' : return ES_SIGNO_DIVIDIDO;
                          case '(' : return ES_PARENTESIS_ABIERTO;
                          case ')' : return ES_PARENTESIS_CERRADO;
                          case '[' : return ES_CORCHETE_ABIERTO;
                          case ']' : return ES_CORCHETE_CERRADO;
                          case ';' : return ES_PUNTO_Y_COMA;
                          case ':' : return ES_DOS_PUNTOS;
                          case ',' : return ES_COMA;
                          case '?' : return ES_INTERROGACION;
                          default : return ERROR;                      
                      }
                } 
            }
         }
    }
}

FILE * archivo_a_compilar;

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
		  //////////////////////////////////////////////
		  //printf("ACA ENTRA EN UN BUCLE INFINITO");/////
		  //////////////////////////////////////////////
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
    int columna, estado, estado_final, token_resultante,estado_final_retorno;
    
    estado = 0;
    estado_final = 90;
	estado_final_retorno = 99;
    
    if (feof(archivo_a_compilar) != 0) {
       printf ("\nEl archivo esta vacio!!\n");
       return 1;
    }
    
    while ((estado != estado_final)&&(estado != estado_final_retorno)) { 

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
    
    if (estado == estado_final_retorno) {
        ungetc(caracter,archivo_a_compilar);
        return token_resultante;     
    }
     
}



