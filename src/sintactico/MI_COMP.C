
# line 2 "mi_comp.y"
 
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<ctype.h>
int yyerror(char const*);
extern int yyparse();
extern "C" int yylex();
extern FILE *yyin;
int yystopparser=0;
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
#define SIG_ASIGNACION 282
#define IGUAL 283
#define MENOR 284
#define MENOR_IGUAL 285
#define MAYOR 286
#define MAYOR_IGUAL 287
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
#define CONCATENACION 299
#ifndef YYSTYPE
#define YYSTYPE int
#endif
YYSTYPE yylval, yyval;
#define YYERRCODE 256

# line 248 "mi_comp.y"



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

FILE *yytfilep;
char *yytfilen;
int yytflag = 0;
int svdprd[2];
char svdnams[2][2];

int yyexca[] = {
  -1, 1,
  0, -1,
  -2, 0,
  -1, 22,
  276, 20,
  -2, 18,
  -1, 75,
  276, 76,
  -2, 61,
  -1, 76,
  276, 78,
  -2, 63,
  -1, 78,
  276, 68,
  -2, 72,
  -1, 79,
  276, 70,
  -2, 74,
  -1, 100,
  276, 52,
  -2, 50,
  0,
};

#define YYNPROD 116
#define YYLAST 356

int yyact[] = {
      64,      65,      92,      64,      65,      84,      80,      82,
      81,      83,      85,      63,     100,      99,      64,      65,
      64,      65,      54,     181,      44,     182,      63,      42,
      41,      53,      18,     168,     159,      56,      99,     167,
     170,     164,     174,      64,      65,     101,      49,      43,
      84,      80,      82,      81,      83,      85,      44,      64,
      65,      42,      41,      86,      18,      13,      61,      55,
      87,      14,      15,      16,      99,      17,      13,     142,
      22,      43,      14,      15,      16,      72,      17,      18,
      67,      68,      18,       4,      73,      13,      64,      65,
      18,      14,      15,      16,      13,      17,      53,      74,
      14,      15,      16,      51,      17,      78,      79,      18,
     132,     133,      53,      75,      76,      59,      18,     123,
     124,     125,      98,      37,      12,     183,      12,      12,
     179,     175,     129,     128,     122,      34,      36,      47,
      37,     131,      57,     120,     119,     118,      30,      12,
      62,      29,      69,      32,      33,     117,      12,       5,
     116,      23,      58,      20,      24,      26,     115,     114,
     113,     107,     105,     112,       3,      38,     110,      19,
     111,      12,     109,      20,       5,      77,      70,     106,
     104,     101,      25,      66,      24,     169,      52,      71,
      26,     139,     138,      46,      27,      26,     126,      45,
      40,      39,      38,      97,      96,      20,      12,      95,
      50,      94,      90,      91,     127,      93,      72,      23,
     102,     140,      74,      57,     121,      31,      60,      30,
      11,      10,       9,      35,      48,     151,     152,     153,
     154,     155,     156,      12,       8,       7,       6,     136,
     137,     166,      88,      58,     102,      89,      47,     103,
      28,      21,       2,      52,     161,     103,     162,     141,
     113,       1,       0,       0,       0,       0,       0,      20,
       0,       0,       0,     114,     115,     116,     117,     118,
     138,       0,      12,     160,     142,       0,     167,      97,
      36,       0,       0,     172,     130,       0,       0,      59,
     175,       0,       0,     180,       0,       0,     122,       0,
     183,      12,       0,     184,      51,       0,     163,     177,
     178,       0,     108,     171,     173,      98,     157,     158,
     122,     171,     144,     165,     146,      60,     147,       0,
     149,     119,     134,     135,     176,      20,     168,       0,
       0,      62,      60,     173,       0,     143,       0,     145,
      58,     104,       3,     148,       0,     150,       0,       0,
       0,       0,       0,       0,     120,     126,       0,       0,
       0,     107,       0,     109,     111,       0,      50,      60,
       0,       0,      95,      35,       0,       0,       0,       0,
       0,       0,       0,       0,     106,       0,     110,       0,
       0,     112,       0,      48,
};

int yypact[] = {
    -182,   -1000,    -175,    -175,   -1000,   -1000,   -1000,   -1000,
   -1000,   -1000,   -1000,   -1000,    -218,   -1000,   -1000,   -1000,
   -1000,   -1000,   -1000,    -175,   -1000,    -203,   -1000,    -203,
    -203,    -225,    -175,    -251,    -240,    -265,    -225,    -190,
    -228,    -286,    -275,    -208,   -1000,   -1000,    -251,   -1000,
   -1000,   -1000,   -1000,   -1000,   -1000,    -197,    -194,    -181,
    -173,   -1000,    -179,    -243,    -232,   -1000,   -1000,   -1000,
   -1000,    -275,    -286,    -297,   -1000,   -1000,   -1000,   -1000,
   -1000,   -1000,   -1000,   -1000,   -1000,    -278,    -284,    -253,
    -251,   -1000,    -175,   -1000,   -1000,    -225,   -1000,   -1000,
   -1000,   -1000,   -1000,   -1000,   -1000,   -1000,   -1000,   -1000,
    -203,    -157,   -1000,   -1000,   -1000,    -178,    -225,    -225,
    -225,    -225,   -1000,   -1000,   -1000,    -225,    -286,    -206,
    -225,    -190,    -225,    -190,   -1000,    -190,    -225,    -190,
    -225,    -225,    -225,    -225,    -225,    -225,    -225,    -190,
    -190,    -266,    -286,   -1000,   -1000,   -1000,    -190,   -1000,
   -1000,   -1000,   -1000,   -1000,   -1000,   -1000,    -208,    -208,
   -1000,   -1000,    -225,    -190,    -262,   -1000,    -175,   -1000,
   -1000,   -1000,   -1000,   -1000,   -1000,   -1000,   -1000,    -200,
    -200,    -200,    -200,    -200,    -200,   -1000,   -1000,   -1000,
   -1000,   -1000,    -264,    -268,    -260,    -175,    -157,    -225,
    -190,    -257,   -1000,    -286,    -231,    -261,   -1000,    -225,
   -1000,   -1000,   -1000,    -274,    -200,   -1000,   -1000,    -225,
    -200,
};

int yypgo[] = {
       0,     233,     226,     148,     225,     224,     107,     221,
     116,     128,     218,     217,     135,     214,     213,     212,
     202,     201,     200,     199,      91,     197,     138,     191,
     189,     188,     185,     203,     183,     180,     118,     179,
     178,     106,     177,     176,     101,     174,     173,     119,
     172,     171,     170,     169,     167,     165,     164,     162,
     204,     160,     159,     157,     184,     154,     152,     150,
     147,     146,     145,     144,     143,     142,     136,     133,
     125,     166,     124,     123,     121,     115,     114,     113,
     112,     109,
};

int yyr1[] = {
       0,       1,       1,       4,       2,       7,       5,      10,
      11,       5,       3,       3,      12,      12,      12,      12,
      12,      12,      19,      13,      21,      13,      23,      24,
      14,      26,      20,      28,      20,      20,      29,      27,
      31,      27,      27,      30,      30,      30,      30,      30,
      30,      22,      37,      22,      38,      17,      40,      18,
      41,      41,      42,      34,      43,      34,      44,      35,
      46,      15,      47,      16,      39,      49,      39,      50,
      39,      51,      39,      39,      53,      39,      54,      39,
      55,      39,      56,      39,      57,      39,      58,      39,
      59,      48,      60,      48,      61,      48,      62,      48,
      63,      48,      64,      48,      66,      52,      67,      52,
       6,      68,      69,      70,      65,      25,      25,      25,
      36,      71,      45,      72,      73,      72,       8,       8,
       8,      32,      33,       9,
};

int yyr2[] = {
       2,       2,       1,       0,       4,       0,       5,       0,
       0,       8,       1,       2,       1,       1,       1,       1,
       1,       1,       0,       5,       0,       5,       0,       0,
       6,       0,       4,       0,       4,       1,       0,       4,
       0,       4,       1,       1,       3,       1,       1,       1,
       1,       1,       0,       4,       0,       6,       0,       4,
       3,       5,       0,       8,       0,       8,       0,       7,
       0,       4,       0,       4,       1,       0,       4,       0,
       4,       0,       3,       1,       0,       4,       0,       4,
       0,       4,       0,       4,       0,       4,       0,       4,
       0,       4,       0,       4,       0,       4,       0,       4,
       0,       4,       0,       4,       0,       4,       0,       4,
       1,       1,       1,       1,       1,       1,       1,       1,
       1,       0,       4,       1,       0,       4,       1,       1,
       1,       1,       1,       1,
};

int yychk[] = {
   -1000,      -1,      -2,      -3,     257,     -12,     -13,     -14,
     -15,     -16,     -17,     -18,      -6,     259,     263,     264,
     265,     267,     277,      -3,     -12,      -4,     282,     -23,
     -46,     -47,     -38,     -40,      -5,      -6,     -19,     -21,
      -6,      -6,     -20,     -27,     -30,      -6,     -32,     -34,
     -35,     275,     274,     290,     271,      -3,     -41,     -39,
     -48,     289,     -52,     -20,     -65,     276,     258,     295,
     294,     -20,     -22,     -36,     -65,     282,      -9,     297,
     278,     279,      -9,     280,     281,     -20,     -39,     -44,
     266,     270,     268,     272,     273,     -51,     272,     273,
     284,     286,     285,     287,     283,     288,     283,     288,
     -10,      -7,      -9,      -9,     299,     -24,     -26,     -28,
     -29,     -31,     -33,     291,     296,     290,     -39,      -3,
     -49,     -57,     -50,     -58,     -48,     -53,     -55,     -54,
     -56,     -59,     -60,     -61,     -62,     -63,     -64,     -66,
     -67,      -6,      -8,     260,     261,     262,     -37,     -25,
     -69,     -70,     -65,     -68,     274,     275,     -27,     -27,
     -30,     -30,     -42,     -43,     -20,      -9,     269,     -48,
     -52,     -48,     -52,     -52,     -48,     -52,     -48,     -20,
     -20,     -20,     -20,     -20,     -20,     -65,     -65,     294,
      -9,     -36,     -20,     -22,     295,      -3,     -11,     295,
     295,     -45,     292,      -8,     -20,     -22,     291,     -71,
      -9,     -33,     -33,     -72,     -20,     293,     295,     -73,
     -20,
};

int yydef[] = {
       0,      -2,       0,       2,       3,      10,      12,      13,
      14,      15,      16,      17,       0,      22,      56,      58,
      44,      46,      96,       1,      11,       0,      -2,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,      29,      34,      35,       0,      37,
      38,      39,      40,     113,      54,       0,       0,       0,
      60,      65,      67,       0,       0,     100,       4,       7,
       5,       0,       0,      41,     104,      23,      57,     115,
      25,      27,      59,      30,      32,       0,       0,       0,
       0,      47,       0,      -2,      -2,       0,      -2,      -2,
      80,      82,      84,      86,      88,      90,      92,      94,
       0,       0,      19,      21,      42,       0,       0,       0,
       0,       0,      36,     114,      -2,       0,       0,      48,
       0,       0,       0,       0,      66,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,     110,     111,     112,       0,      24,
     101,     102,     103,      98,      99,      97,      26,      28,
      31,      33,       0,       0,       0,      45,       0,      62,
      77,      64,      79,      69,      73,      71,      75,      81,
      83,      85,      87,      89,      91,      93,      95,       8,
       6,      43,       0,       0,       0,      49,       0,       0,
       0,       0,     105,       0,       0,       0,      55,       0,
       9,      51,      53,       0,     107,     106,     108,       0,
     109,
};

int *yyxi;


/*****************************************************************/
/* PCYACC LALR parser driver routine -- a table driven procedure */
/* for recognizing sentences of a language defined by the        */
/* grammar that PCYACC analyzes. An LALR parsing table is then   */
/* constructed for the grammar and the skeletal parser uses the  */
/* table when performing syntactical analysis on input source    */
/* programs. The actions associated with grammar rules are       */
/* inserted into a switch statement for execution.               */
/*****************************************************************/


#ifndef YYMAXDEPTH
#define YYMAXDEPTH 200
#endif
#ifndef YYREDMAX
#define YYREDMAX 1000
#endif
#define PCYYFLAG -1000
#define WAS0ERR 0
#define WAS1ERR 1
#define WAS2ERR 2
#define WAS3ERR 3
#define yyclearin pcyytoken = -1
#define yyerrok   pcyyerrfl = 0
YYSTYPE yyv[YYMAXDEPTH];     /* value stack */
int pcyyerrct = 0;           /* error count */
int pcyyerrfl = 0;           /* error flag */
int redseq[YYREDMAX];
int redcnt = 0;
int pcyytoken = -1;          /* input token */


yyparse()
{
  int statestack[YYMAXDEPTH]; /* state stack */
  int      j, m;              /* working index */
  YYSTYPE *yypvt;
  int      tmpstate, tmptoken, *yyps, n;
  YYSTYPE *yypv;


  tmpstate = 0;
  pcyytoken = -1;
#ifdef YYDEBUG
  tmptoken = -1;
#endif
  pcyyerrct = 0;
  pcyyerrfl = 0;
  yyps = &statestack[-1];
  yypv = &yyv[-1];


  enstack:    /* push stack */
#ifdef YYDEBUG
    printf("at state %d, next token %d\n", tmpstate, tmptoken);
#endif
    if (++yyps - &statestack[YYMAXDEPTH] > 0) {
      yyerror("pcyacc internal stack overflow");
      return(1);
    }
    *yyps = tmpstate;
    ++yypv;
    *yypv = yyval;


  newstate:
    n = yypact[tmpstate];
    if (n <= PCYYFLAG) goto defaultact; /*  a simple state */


    if (pcyytoken < 0) if ((pcyytoken=yylex()) < 0) pcyytoken = 0;
    if ((n += pcyytoken) < 0 || n >= YYLAST) goto defaultact;


    if (yychk[n=yyact[n]] == pcyytoken) { /* a shift */
#ifdef YYDEBUG
      tmptoken  = pcyytoken;
#endif
      pcyytoken = -1;
      yyval = yylval;
      tmpstate = n;
      if (pcyyerrfl > 0) --pcyyerrfl;
      goto enstack;
    }


  defaultact:


    if ((n=yydef[tmpstate]) == -2) {
      if (pcyytoken < 0) if ((pcyytoken=yylex())<0) pcyytoken = 0;
      for (yyxi=yyexca; (*yyxi!= (-1)) || (yyxi[1]!=tmpstate); yyxi += 2);
      while (*(yyxi+=2) >= 0) if (*yyxi == pcyytoken) break;
      if ((n=yyxi[1]) < 0) { /* an accept action */
        if (yytflag) {
          int ti; int tj;
          yytfilep = fopen(yytfilen, "w");
          if (yytfilep == NULL) {
            fprintf(stderr, "Can't open t file: %s\n", yytfilen);
            return(0);          }
          for (ti=redcnt-1; ti>=0; ti--) {
            tj = svdprd[redseq[ti]];
            while (strcmp(svdnams[tj], "$EOP"))
              fprintf(yytfilep, "%s ", svdnams[tj++]);
            fprintf(yytfilep, "\n");
          }
          fclose(yytfilep);
        }
        return (0);
      }
    }


    if (n == 0) {        /* error situation */
      switch (pcyyerrfl) {
        case WAS0ERR:          /* an error just occurred */
          yyerror("syntax error");
          yyerrlab:
            ++pcyyerrct;
        case WAS1ERR:
        case WAS2ERR:           /* try again */
          pcyyerrfl = 3;
	   /* find a state for a legal shift action */
          while (yyps >= statestack) {
	     n = yypact[*yyps] + YYERRCODE;
	     if (n >= 0 && n < YYLAST && yychk[yyact[n]] == YYERRCODE) {
	       tmpstate = yyact[n];  /* simulate a shift of "error" */
	       goto enstack;
            }
	     n = yypact[*yyps];


	     /* the current yyps has no shift on "error", pop stack */
#ifdef YYDEBUG
            printf("error: pop state %d, recover state %d\n", *yyps, yyps[-1]);
#endif
	     --yyps;
	     --yypv;
	   }


	   yyabort:
            if (yytflag) {
              int ti; int tj;
              yytfilep = fopen(yytfilen, "w");
              if (yytfilep == NULL) {
                fprintf(stderr, "Can't open t file: %s\n", yytfilen);
                return(1);              }
              for (ti=1; ti<redcnt; ti++) {
                tj = svdprd[redseq[ti]];
                while (strcmp(svdnams[tj], "$EOP"))
                  fprintf(yytfilep, "%s ", svdnams[tj++]);
                fprintf(yytfilep, "\n");
              }
              fclose(yytfilep);
            }
	     return(1);


	 case WAS3ERR:  /* clobber input char */
#ifdef YYDEBUG
          printf("error: discard token %d\n", pcyytoken);
#endif
          if (pcyytoken == 0) goto yyabort; /* quit */
	   pcyytoken = -1;
	   goto newstate;      } /* switch */
    } /* if */


    /* reduction, given a production n */
#ifdef YYDEBUG
    printf("reduce with rule %d\n", n);
#endif
    if (yytflag && redcnt<YYREDMAX) redseq[redcnt++] = n;
    yyps -= yyr2[n];
    yypvt = yypv;
    yypv -= yyr2[n];
    yyval = yypv[1];
    m = n;
    /* find next state from goto table */
    n = yyr1[n];
    j = yypgo[n] + *yyps + 1;
    if (j>=YYLAST || yychk[ tmpstate = yyact[j] ] != -n) tmpstate = yyact[yypgo[n]];
    switch (m) { /* actions associated with grammar rules */
      
      case 3:
# line 75 "mi_comp.y"
      {printf("DEFVAR\n");} break;
      case 4:
# line 75 "mi_comp.y"
      {printf("ENDDEF\n");} break;
      case 5:
# line 79 "mi_comp.y"
      {printf("DEFINE\n");} break;
      case 7:
# line 80 "mi_comp.y"
      {printf("SEPARDOR_COMA\n");} break;
      case 8:
# line 80 "mi_comp.y"
      {printf("DEFINE\n");} break;
      case 18:
# line 98 "mi_comp.y"
      {printf("SIG_ASIGNACION\n");} break;
      case 20:
# line 99 "mi_comp.y"
      {printf("SIG_ASIGNACION\n");} break;
      case 22:
# line 103 "mi_comp.y"
      {printf("CONST\n");} break;
      case 23:
# line 103 "mi_comp.y"
      {printf("SIG_ASIGNACION\n");} break;
      case 25:
# line 107 "mi_comp.y"
      {printf("MAS\n");} break;
      case 27:
# line 108 "mi_comp.y"
      {printf("MENOS\n");} break;
      case 30:
# line 113 "mi_comp.y"
      {printf("POR\n");} break;
      case 32:
# line 114 "mi_comp.y"
      {printf("DIVIDIDO\n");} break;
      case 39:
# line 123 "mi_comp.y"
      {printf("CTE_ENTERA\n");} break;
      case 40:
# line 124 "mi_comp.y"
      {printf("CTE_REAL\n");} break;
      case 42:
# line 129 "mi_comp.y"
      {printf("CONCATENACION\n");} break;
      case 44:
# line 133 "mi_comp.y"
      {printf("REPEAT\n");} break;
      case 46:
# line 137 "mi_comp.y"
      {printf("IF\n");} break;
      case 47:
# line 137 "mi_comp.y"
      {printf("ENDIF\n");} break;
      case 50:
# line 146 "mi_comp.y"
      {printf("UNARYIF\n");} break;
      case 51:
# line 146 "mi_comp.y"
      {printf("FINUNARYIF\n");} break;
      case 52:
# line 147 "mi_comp.y"
      {printf("UNARYIF\n");} break;
      case 53:
# line 147 "mi_comp.y"
      {printf("FINUNARYIF\n");} break;
      case 54:
# line 151 "mi_comp.y"
      {printf("QEQUAL\n");} break;
      case 55:
# line 151 "mi_comp.y"
      {printf("FINQEQUAL\n");} break;
      case 56:
# line 155 "mi_comp.y"
      {printf("GET\n");} break;
      case 58:
# line 159 "mi_comp.y"
      {printf("PUT\n");} break;
      case 61:
# line 164 "mi_comp.y"
      {printf("AND\n");} break;
      case 63:
# line 165 "mi_comp.y"
      {printf("OR\n");} break;
      case 65:
# line 166 "mi_comp.y"
      {printf("NOT\n");} break;
      case 68:
# line 168 "mi_comp.y"
      {printf("AND\n");} break;
      case 70:
# line 169 "mi_comp.y"
      {printf("OR\n");} break;
      case 72:
# line 170 "mi_comp.y"
      {printf("AND\n");} break;
      case 74:
# line 171 "mi_comp.y"
      {printf("OR\n");} break;
      case 76:
# line 172 "mi_comp.y"
      {printf("AND\n");} break;
      case 78:
# line 173 "mi_comp.y"
      {printf("OR\n");} break;
      case 80:
# line 177 "mi_comp.y"
      {printf("MENOR\n");} break;
      case 82:
# line 178 "mi_comp.y"
      {printf("MAYOR\n");} break;
      case 84:
# line 179 "mi_comp.y"
      {printf("MENOR_IGUAL\n");} break;
      case 86:
# line 180 "mi_comp.y"
      {printf("MAYOR_IGUAL\n");} break;
      case 88:
# line 181 "mi_comp.y"
      {printf("IGUAL\n");} break;
      case 90:
# line 182 "mi_comp.y"
      {printf("DISTINTO\n");} break;
      case 92:
# line 186 "mi_comp.y"
      {printf("IGUAL\n");} break;
      case 94:
# line 187 "mi_comp.y"
      {printf("DISTINTO\n");} break;
      case 96:
# line 191 "mi_comp.y"
      {printf("ID\n");} break;
      case 97:
# line 195 "mi_comp.y"
      {printf("CTE_ENTERA\n");} break;
      case 99:
# line 203 "mi_comp.y"
      {printf("CTE_REAL\n");} break;
      case 100:
# line 207 "mi_comp.y"
      {printf("CTE_STRING\n");} break;
      case 105:
# line 222 "mi_comp.y"
      {printf("COR_ABRE\n");} break;
      case 106:
# line 222 "mi_comp.y"
      {printf("COR_CIERRA\n");} break;
      case 108:
# line 227 "mi_comp.y"
      {printf("SEPARDOR_COMA\n");} break;
      case 110:
# line 231 "mi_comp.y"
      {printf("INT\n");} break;
      case 111:
# line 232 "mi_comp.y"
      {printf("REAL\n");} break;
      case 112:
# line 233 "mi_comp.y"
      {printf("STRING\n");} break;
      case 113:
# line 237 "mi_comp.y"
      {printf("PAR_ABRE\n");} break;
      case 114:
# line 241 "mi_comp.y"
      {printf("PAR_CIERRA\n");} break;
      case 115:
# line 245 "mi_comp.y"
      {printf("FIN_SENTENCIA\n");} break;    }
    goto enstack;
}
