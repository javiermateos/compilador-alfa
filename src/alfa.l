/******************************************************************************/
/*  SECCION DEFINICIONES                                                      */
/******************************************************************************/

%{
    /* Directivas include para las acciones */
    #include <stdio.h>
    #include <stdlib.h>

    #include "y.tab.h"

    /* Definicion de macros */
    #define TAM_MAX_IDENTIFICADOR 75

    /* Definicion de variables */
    int row = 1;
    int col = 1;
    int errmorf = 0;
%}

%option noyywrap
%option nounput noinput

DIGITO [0-9]
LETRA [a-zA-Z]
NUMERO {DIGITO}+
ALFANUMERICO ({DIGITO}|{LETRA})
COLA_IDENTIFICADOR {ALFANUMERICO}+

COMENTARIO "//".*\n

/******************************************************************************/
/*  SECCION REGLAS                                                            */
/******************************************************************************/

%%

{COMENTARIO}|"\n"   {col=0; row++;}
[ \t\r]             {col+=yyleng;}

 /* Palabras reservadas */

main    {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return TOK_MAIN;}
int     {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return TOK_INT;}
boolean {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return TOK_BOOLEAN;}
array   {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return TOK_ARRAY;}
function    {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return TOK_FUNCTION;}
if      {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return TOK_IF;}
else    {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return TOK_ELSE;}
while   {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return TOK_WHILE;}
scanf   {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return TOK_SCANF;}
printf  {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return TOK_PRINTF;}
return  {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return TOK_RETURN;}

 /* Simbolos */

";"         {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return yytext[0];}
","         {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return yytext[0];}
"("         {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return yytext[0];}
")"         {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return yytext[0];}
"["         {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return yytext[0];}
"]"         {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return yytext[0];}
"{"         {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return yytext[0];}
"}"         {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return yytext[0];}
"="         {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return yytext[0];}
"+"         {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return yytext[0];}
"-"         {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return yytext[0];}
"/"         {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return yytext[0];}
"*"         {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return yytext[0];}
"&&"        {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return TOK_AND;}
"||"        {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return TOK_OR;}
"!"         {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return TOK_NOT;}
"=="        {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return TOK_IGUAL;}
"!="        {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return TOK_DISTINTO;}
"<="        {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return TOK_MENORIGUAL;}
">="        {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return TOK_MAYORIGUAL;}
"<"         {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return yytext[0];}
">"         {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return yytext[0];}

 /* Identificadores */
{LETRA}({LETRA}|{COLA_IDENTIFICADOR})*  {
                                            if(yyleng > TAM_MAX_IDENTIFICADOR) {
                                                col+=1;
                                                fprintf(stderr, "****Error en [lin %d, col %d]: Identificador demasiado largo (%s)\n", row, col, yytext);
                                                errmorf=1;
                                                return TOK_ERROR;
                                            }
                                            col+=yyleng;
                                            fprintf(yyout, ";D:\t%s\n", yytext);
                                            return TOK_IDENTIFICADOR;
                                        }

 /* Constantes */

true    {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return TOK_TRUE;}
false   {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return TOK_FALSE;}
{NUMERO}    {col+=yyleng; fprintf(yyout, ";D:\t%s\n", yytext); return TOK_CONSTANTE_ENTERA;}

 /* Errores */
.   {
        col+=yyleng;
        errmorf=1;
        fprintf(stderr, "****Error en [lin %d, col %d]: Simbolo no permitido (%s)\n", row, col, yytext);
        return TOK_ERROR;
    }
%%

/******************************************************************************/
/*  SECCION FUNCIONES DE USUARIO                                              */
/******************************************************************************/
