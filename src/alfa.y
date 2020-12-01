/******************************************************************************/
/*  SECCION DEFINICIONES                                                      */
/******************************************************************************/
 /* Bloque de codigo C */
%{
    /* Directivas include para las acciones */
    #include <stdio.h>
    #include <stdlib.h>

    #include "y.tab.h"

    /* Definicion de macros */

    /* Declaracion de variables */
    extern int row;
    extern int col;
    extern FILE* yyout;
    extern int errmorf;

    /* Declaracion de funciones */
    extern int yylex();
    void yyerror(char* s);

%}

 /* Definicion variable yylval */

 /* Definicion simbolos terminales */
%token TOK_MAIN TOK_INT TOK_BOOLEAN TOK_ARRAY TOK_FUNCTION TOK_IF
%token TOK_ELSE TOK_WHILE TOK_SCANF TOK_PRINTF TOK_RETURN

%token TOK_AND TOK_OR TOK_NOT TOK_IGUAL TOK_DISTINTO TOK_MENORIGUAL
%token TOK_MAYORIGUAL

%token TOK_IDENTIFICADOR

%token TOK_TRUE TOK_FALSE
%token TOK_CONSTANTE_ENTERA

%token TOK_ERROR

 /* Declaracion del tipo de los simbolos no terminales */

 /* Definicion axioma de la gramatica */

 /* Definicion asociatividad y precedencia de operadores */
%left '+' '-' TOK_OR
%left '/' '*' TOK_AND
%left TOK_NOT

/******************************************************************************/
/*  SECCION REGLAS                                                            */
/******************************************************************************/

%%
programa: TOK_MAIN '{' declaraciones funciones sentencias '}'
{
    fprintf(yyout, ";R1:\t<programa> ::= main { <declaraciones> <funciones> <sentencias> }\n");
};

declaraciones: declaracion
{
    fprintf(yyout, ";R2:\t<declaraciones> ::= <declaracion>\n");
} | declaracion declaraciones
{
    fprintf(yyout, ";R3:\t<declaraciones> ::= <declaracion> <declaraciones>\n");
};

declaracion: clase identificadores ';'
{
    fprintf(yyout, ";R4:\t<declaracion> ::= <clase> <identificadores> ;\n");
};

clase: clase_escalar
{
    fprintf(yyout, ";R5:\t<clase> ::= <clase_escalar>\n");
} | clase_vector
{
    fprintf(yyout, ";R6:\t<clase> ::= <clase_vector>\n");
};

clase_escalar: tipo
{
    fprintf(yyout, ";R9:\t<clase_escalar> ::= <tipo>\n");
};

tipo: TOK_INT
{
    fprintf(yyout, ";R10:\t<tipo> ::= int\n");
} | TOK_BOOLEAN
{
    fprintf(yyout, ";R11:\t<tipo> ::= boolean\n");
}

clase_vector: TOK_ARRAY tipo '[' constante_entera ']'
{
    fprintf(yyout, ";R15:\t<clase_vector> ::= array <tipo> [ <constante_entera> ]\n");
};

identificadores: identificador
{
    fprintf(yyout, ";R18:\t<identificadores> ::= <identificador>\n");
} | identificador ',' identificadores
{
    fprintf(yyout, ";R19:\t<identificadores> ::= <identificador> , <identificadores>\n");
};

funciones: funcion funciones
{
    fprintf(yyout, ";R20:\t<funciones> ::= <funcion> <funciones>\n");
} | /* vacio */
{
    fprintf(yyout, ";R21:\t<funciones> ::= \n");
};

funcion: TOK_FUNCTION tipo identificador '(' parametros_funcion ')' '{' declaraciones_funcion sentencias '}'
{
    fprintf(yyout, ";R22:\t<funcion> ::= function <tipo> <identificador> ( <parametros_funcion> ) { <declaraciones_funcion> <sentencias> }");
};

parametros_funcion: parametro_funcion resto_parametros_funcion
{
    fprintf(yyout, ";R23:\t<parametros_funcion> ::= <parametro_funcion> <resto_parametros_funcion>\n");
} | /* vacio */
{
    fprintf(yyout, ";R24:\t<parametros_funcion> ::= \n");
};

resto_parametros_funcion: ';' parametro_funcion resto_parametros_funcion
{
    fprintf(yyout, ";R25:\t<resto_parametros_funcion> ::= ; <parametro_funcion> <resto_parametros_funcion>\n");
} | /* vacio */
{
    fprintf(yyout, ";R26:\t<resto_parametros_funcion> ::= \n");
};

parametro_funcion: tipo identificador
{
    fprintf(yyout, ";R27:\t<parametro_funcion> ::= <tipo> <identificador>\n");
};

declaraciones_funcion: declaraciones
{
    fprintf(yyout, ";R28:\t<declaraciones_funcion> ::= <declaraciones>\n");
} | /* vacio */
{
    fprintf(yyout, ";R29:\t<declaraciones_funcion> ::= \n");
};

sentencias: sentencia
{
    fprintf(yyout, ";R30:\t<sentencias> ::= <sentencia>\n");
} | sentencia sentencias
{
    fprintf(yyout, ";R31:\t<sentencias> ::= <sentencia> <sentencias>\n");
};

sentencia: sentencia_simple ';'
{
    fprintf(yyout, ";R32:\t<sentencia> ::= <sentencia_simple> ;\n");
} | bloque
{
    fprintf(yyout, ";R33:\t<sentencia> ::= <bloque>\n");
};

sentencia_simple: asignacion
{
    fprintf(yyout, ";R34:\t<sentencia_simple> ::= <asignacion>\n");
} | lectura
{
    fprintf(yyout, ";R35:\t<sentencia_simple> ::= <lectura>\n");
} | escritura
{
    fprintf(yyout, ";R36:\t<sentencia_simple> ::= <escritura>\n");
} | retorno_funcion
{
    fprintf(yyout, ";R38:\t<sentencia_simple> ::= <retorno_funcion>\n");
};

bloque: condicional
{
    fprintf(yyout, ";R40:\t<bloque> ::= <condicional>\n");
} | bucle
{
    fprintf(yyout, ";R41:\t<bloque> ::= <bucle>\n");
};

asignacion: identificador '=' exp
{
    fprintf(yyout, ";R43:\t<asignacion> ::= <identificador> = <exp>\n");
} | elemento_vector '=' exp
{
    fprintf(yyout, ";R44:\t<asignacion> ::= <elemento_vector> = <exp>\n");
};

elemento_vector: identificador '[' exp ']'
{
    fprintf(yyout, ";R48:\t<elemento_vector> ::= <identificador> [ <expr> ]\n");
};

condicional: TOK_IF '(' exp ')' '{' sentencias '}'
{
    fprintf(yyout, ";R50:\t<condicional> ::= if ( <exp> ) { <sentencias> }\n");
} | TOK_IF '(' exp ')' '{' sentencias '}' TOK_ELSE '{' sentencias '}'
{
    fprintf(yyout, ";R51:\t<condicional> ::= if ( <exp> ) { <sentencias> } else { <sentencias> }\n");
};

bucle: TOK_WHILE '(' exp ')' '{' sentencias '}'
{
    fprintf(yyout, ";R52:\t<bucle> ::= while ( <exp> ) { <sentencias> }\n");
};

lectura: TOK_SCANF identificador
{
    fprintf(yyout, ";R54:\t<lectura> ::= scanf <identificador>\n");
};

escritura: TOK_PRINTF exp
{
    fprintf(yyout, ";R56:\t<escritura> ::= printf <exp>\n");
};

retorno_funcion: TOK_RETURN exp
{
    fprintf(yyout, ";R61:\t<retorno_funcion> ::= return <exp>\n");
};

exp: exp '+' exp
{
    fprintf(yyout, ";R72:\t<exp> ::= <exp> + <exp>\n");
} | exp '-' exp
{
    fprintf(yyout, ";R73:\t<exp> ::= <exp> - <exp>\n");
} | exp '/' exp
{
    fprintf(yyout, ";R74:\t<exp> ::= <exp> / <exp>\n");
} | exp '*' exp
{
    fprintf(yyout, ";R75:\t<exp> ::= <exp> * <exp>\n");
} | '-' exp
{
    fprintf(yyout, ";R76:\t<exp> ::= - <exp>\n");
} | exp TOK_AND exp
{
    fprintf(yyout, ";R77:\t<exp> ::= <exp> && <exp>\n");
} | exp TOK_OR exp
{
    fprintf(yyout, ";R78:\t<exp> ::= <exp> || <exp>\n");
} | TOK_NOT exp
{
    fprintf(yyout, ";R79:\t<exp> ::= ! <exp>\n");
} | identificador
{
    fprintf(yyout, ";R80:\t<exp> ::= <identificador>\n");
} | constante
{
    fprintf(yyout, ";R81:\t<exp> ::= <constante>\n");
} | '(' exp ')'
{
    fprintf(yyout, ";R82:\t<exp> ::= ( exp )\n");
} | '(' comparacion ')'
{
    fprintf(yyout, ";R83:\t<exp> ::= ( <comparacion> )\n");
} | elemento_vector
{
    fprintf(yyout, ";R85\t<exp> ::= <elemento_vector>\n");
} | identificador '(' lista_expresiones ')'
{
    fprintf(yyout, ";R88\t<exp> ::= <identificador> ( <lista_expresiones> )\n");
};

lista_expresiones: exp resto_lista_expresiones
{
    fprintf(yyout, ";R89\t<lista_expresiones> ::= <exp> <resto_lista_expresiones>\n");
} | /* vacia */
{
    fprintf(yyout, ";R90\t<lista_expresiones> ::= \n");
};

resto_lista_expresiones: ',' exp resto_lista_expresiones
{
    fprintf(yyout, ";R91:\t<resto_lista_expresiones> ::= , <exp> <resto_lista_expresiones>\n");
} | /* vacia */
{
    fprintf(yyout, ";R92:\t<resto_lista_expresiones> ::= \n");
};

comparacion: exp TOK_IGUAL exp
{
    fprintf(yyout, ";R93:\t<comparacion> ::= <exp> == <exp>\n");
} | exp TOK_DISTINTO exp
{
    fprintf(yyout, ";R94:\t<comparacion> ::= <exp> != <exp>\n");
} | exp TOK_MENORIGUAL exp
{
    fprintf(yyout, "R95:\t<comparacion> ::= <exp> <= <exp>\n");
} | exp TOK_MAYORIGUAL exp
{
    fprintf(yyout, ";R96:\t<comparacion> ::= <exp> >= <exp>\n");
} | exp '<' exp
{
    fprintf(yyout, ";R97:\t<comparacion> ::= <exp> < <exp>\n");
} | exp '>' exp
{
    fprintf(yyout, ";R98:\t<comparacion> ::= <exp> > <exp>\n");
};

constante: constante_logica
{
    fprintf(yyout, ";R99:\t<constante> ::= <constante_logica>\n");
} | constante_entera
{
    fprintf(yyout, ";R100:\t<constante> ::= <constante_entera>\n");
};

constante_logica: TOK_TRUE
{
    fprintf(yyout, ";R102\t<constante_logica> ::= true\n");
} | TOK_FALSE
{
    fprintf(yyout, ";R103\t<constante_logica> ::= false\n");
};

constante_entera: TOK_CONSTANTE_ENTERA
{
    fprintf(yyout, ";R104:\t<constante_entera> ::= TOK_CONSTANTE_ENTERA\n");
};

identificador: TOK_IDENTIFICADOR
{
    fprintf(yyout, ";R108:\t<identificador> ::= TOK_IDENTIFICADOR\n");
}

%%

/******************************************************************************/
/*  SECCION FUNCIONES DE USUARIO                                              */
/******************************************************************************/
void yyerror(char* s) {
    if(errmorf != 1) {
        fprintf(stderr, "****Error sintáctico en [lin %d, col %d]\n", row, col);
    }
}
