/******************************************************************************/
/*  SECCION DEFINICIONES                                                      */
/******************************************************************************/
 /* Bloque de codigo C */
%{
  /* Directivas include para las acciones */
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  #include "alfa.h"
  #include "tipos.h"
  #include "tablaSimbolos.h"
  #include "generacion.h"

  #include "y.tab.h"
  /* Definicion de macros */

  /* Declaracion de variables externas*/
  extern int row;
  extern int col;
  extern FILE* yyout;
  extern FILE* yyasm;
  extern int err_morf;

  /* Declaracion de variables locales */
  TIPO tipo_actual;
  CLASE clase_actual;

  int valor_escalar_actual;
  int tamanio_vector_actual;
  int num_variables_locales_actual;
  int pos_variable_local_actual;
  int num_parametros_actual;
  int pos_parametro_actual;
  int num_parametros_llamada_actual;

  tabla_simbolos* tabla;

  char err[160];

  int ambito_local;
  int en_explist;
  TIPO tipo_retorno_funcion;

  int etiqueta;
  int fn_return;

  /* Declaracion de funciones */
  extern int yylex();
  void yyerror(char* s);
%}


 /* Definicion variable yylval */
%union {
  tipo_atributos atributos;
}

 /* Definicion simbolos terminales */
%token TOK_MAIN TOK_INT TOK_BOOLEAN TOK_ARRAY TOK_FUNCTION TOK_IF
%token TOK_ELSE TOK_WHILE TOK_SCANF TOK_PRINTF TOK_RETURN

%token TOK_AND TOK_OR TOK_NOT TOK_IGUAL TOK_DISTINTO TOK_MENORIGUAL
%token TOK_MAYORIGUAL

%token TOK_TRUE TOK_FALSE
%token <atributos> TOK_IDENTIFICADOR TOK_CONSTANTE_ENTERA

%token TOK_ERROR

 /* Declaracion del tipo de los simbolos no terminales */
%type <atributos> condicional
%type <atributos> comparacion
%type <atributos> elemento_vector
%type <atributos> exp
%type <atributos> constante
%type <atributos> constante_entera
%type <atributos> constante_logica
%type <atributos> identificador
%type <atributos> fn_nombre
%type <atributos> fn_declaracion
%type <atributos> idf_llamada_funcion
%type <atributos> if_exp
%type <atributos> if_exp_sentencias
%type <atributos> while_exp
%type <atributos> while

 /* Definicion axioma de la gramatica */

 /* Definicion asociatividad y precedencia de operadores */
%left '+' '-' TOK_OR
%left '/' '*' TOK_AND
%left TOK_NOT

/******************************************************************************/
/*  SECCION REGLAS                                                            */
/******************************************************************************/

%%
programa: inicioTabla TOK_MAIN '{' declaraciones escritura1 funciones escritura2 sentencias '}'
{
    /* Llamada a funciones para escribir el fin del fichero ensamblador */
    escribir_fin(yyasm);
    ts_free(tabla);
    fprintf(yyout, ";R1:\t<programa> ::= main { <declaraciones> <funciones> <sentencias> }\n");
};

inicioTabla: /* vacio */ 
{
  tabla = ts_crear();
};

escritura1: /* vacio */
{
  /* Llamada a funciones para escribir la seccion data con los mensajes generales y
  la tabla de simbolos, asi como todo lo necesario para que lo siguiente ha escribir 
  en el fichero ensamblador sea la sentencia main: */
  escribir_subseccion_data(yyasm);
  escribir_cabecera_bss(yyasm);

  LinkedList *p_lista_simbolos= NULL;
  Ht_item* p_item = NULL;
  simbolo* p_s = NULL;

  for (p_lista_simbolos = ts_get_simbolos(tabla); 
        p_lista_simbolos != NULL; 
        p_lista_simbolos = get_LinkedList_next(p_lista_simbolos)) {
    p_item = get_LinkedList_item(p_lista_simbolos); 
    p_s = get_Htitem_value(p_item);
    if (get_simbolo_clase(p_s) == ESCALAR) {
      declarar_variable(yyasm, get_simbolo_lexema(p_s), get_simbolo_tipo(p_s), 1);
    } else {
      declarar_variable(yyasm, get_simbolo_lexema(p_s), get_simbolo_tipo(p_s), 
                        get_simbolo_adicional1(p_s));
    }
  }

  escribir_segmento_codigo(yyasm);
}

escritura2: /* vacio */
{
  /* Aqui ya puede llamarse a la funcion que escribe inicio main */
  escribir_inicio_main(yyasm);
}

declaraciones: declaracion
{
    fprintf(yyout, ";R2:\t<declaraciones> ::= <declaracion>\n");
}
  | declaracion declaraciones
{
    fprintf(yyout, ";R3:\t<declaraciones> ::= <declaracion> <declaraciones>\n");
};

declaracion: clase identificadores ';'
{
    fprintf(yyout, ";R4:\t<declaracion> ::= <clase> <identificadores> ;\n");
};

clase: clase_escalar
{
    clase_actual =  ESCALAR;
    fprintf(yyout, ";R5:\t<clase> ::= <clase_escalar>\n");
}
  | clase_vector
{
    clase_actual = VECTOR;
    fprintf(yyout, ";R7:\t<clase> ::= <clase_vector>\n");
};

clase_escalar: tipo
{
    fprintf(yyout, ";R9:\t<clase_escalar> ::= <tipo>\n");
};

tipo: TOK_INT
{
    tipo_actual = ENTERO;
    fprintf(yyout, ";R10:\t<tipo> ::= int\n");
} 
  | TOK_BOOLEAN
{
    tipo_actual = BOOLEAN;
    fprintf(yyout, ";R11:\t<tipo> ::= boolean\n");
};

clase_vector: TOK_ARRAY tipo '[' constante_entera ']'
{
    tamanio_vector_actual = $4.valor_entero;
    if ((tamanio_vector_actual < 1) || (tamanio_vector_actual > MAX_TAMANIO_VECTOR)) {
      yyerror("El tamanyo del vector excede los limites permitidos (1,64).");
      return -1;
    }
    fprintf(yyout, ";R15:\t<clase_vector> ::= array <tipo> [ <constante_entera> ]\n");
};

identificadores: identificador
{
    fprintf(yyout, ";R18:\t<identificadores> ::= <identificador>\n");
}
  | identificador ',' identificadores
{
    fprintf(yyout, ";R19:\t<identificadores> ::= <identificador> , <identificadores>\n");
};

funciones: funcion funciones
{
    fprintf(yyout, ";R20:\t<funciones> ::= <funcion> <funciones>\n");
} 
  | /* vacio */
{
    fprintf(yyout, ";R21:\t<funciones> ::= \n");
};

funcion: fn_declaracion sentencias '}'
{
    simbolo *p_s = NULL;

    ts_close_scope(tabla);
    ambito_local = 0;

    p_s = ts_search(tabla, $1.lexema);
    set_simbolo_adicional1(p_s, num_parametros_actual);

    if (!fn_return) {
      sprintf(err, "Funcion %s sin sentencia de retorno", $1.lexema);
      yyerror(err);
    }

    fprintf(yyout, ";R22:\t<funcion> ::= <fn_declaracion> <sentencias> }\n");
};

fn_declaracion: fn_nombre '(' parametros_funcion ')' '{' declaraciones_funcion
{
  simbolo *p_s = NULL;

  p_s = ts_search(tabla, $1.lexema);
  set_simbolo_adicional1(p_s, num_parametros_actual);

  strcpy($$.lexema, $1.lexema);

  declararFuncion(yyasm, $1.lexema, num_variables_locales_actual);

  fprintf(yyout, "R22.1:\t<fn_declaracion> ::= <fn_nombre> ( <parametros_funcion> ) { <declaraciones_funcion>\n");
};

fn_nombre: TOK_FUNCTION tipo TOK_IDENTIFICADOR
{
  STATUS s;

  if (ts_search(tabla, $3.lexema)) {
    yyerror("Declaracion duplicada");
    return -1;
  }

  s = ts_open_scope(tabla, $3.lexema, tipo_actual);
  if (s == ERR) {
    yyerror("Error sin descripcion.");
  }

  num_variables_locales_actual = 0;
  pos_variable_local_actual = 1;
  num_parametros_actual = 0;
  pos_parametro_actual = 0;
  fn_return = 0;
  tipo_retorno_funcion = tipo_actual; 

  ambito_local = 1;

  strcpy($$.lexema, $3.lexema);

  fprintf(yyout, "R22.2:\t<fn_nombre> ::= TOK_FUNCTION <tipo> TOK_IDENTIFICADOR\n");
};

parametros_funcion: parametro_funcion resto_parametros_funcion
{
    fprintf(yyout, ";R23:\t<parametros_funcion> ::= <parametro_funcion> <resto_parametros_funcion>\n");
}
  | /* vacio */
{
    fprintf(yyout, ";R24:\t<parametros_funcion> ::= \n");
};

resto_parametros_funcion: ';' parametro_funcion resto_parametros_funcion
{
    fprintf(yyout, ";R25:\t<resto_parametros_funcion> ::= ; <parametro_funcion> <resto_parametros_funcion>\n");
}
  | /* vacio */
{
    fprintf(yyout, ";R26:\t<resto_parametros_funcion> ::= \n");
};

parametro_funcion: tipo idpf
{
    fprintf(yyout, ";R27:\t<parametro_funcion> ::= <tipo> <identificador>\n");
};

idpf: TOK_IDENTIFICADOR
{
  if (ts_search(tabla, $1.lexema)) {
    yyerror("Declaracion duplicada");
    return -1;
  }
  
  ts_insert(tabla, $1.lexema, PARAMETRO, tipo_actual, clase_actual, 0, pos_parametro_actual);
  pos_parametro_actual++;
  num_parametros_actual++;
}

declaraciones_funcion: declaraciones
{
    fprintf(yyout, ";R28:\t<declaraciones_funcion> ::= <declaraciones>\n");
}
  | /* vacio */
{
    fprintf(yyout, ";R29:\t<declaraciones_funcion> ::= \n");
};

sentencias: sentencia
{
    fprintf(yyout, ";R30:\t<sentencias> ::= <sentencia>\n");
}
  | sentencia sentencias
{
    fprintf(yyout, ";R31:\t<sentencias> ::= <sentencia> <sentencias>\n");
};

sentencia: sentencia_simple ';'
{
    fprintf(yyout, ";R32:\t<sentencia> ::= <sentencia_simple> ;\n");
}
  | bloque
{
    fprintf(yyout, ";R33:\t<sentencia> ::= <bloque>\n");
};

sentencia_simple: asignacion
{
    fprintf(yyout, ";R34:\t<sentencia_simple> ::= <asignacion>\n");
}
| lectura
{
    fprintf(yyout, ";R35:\t<sentencia_simple> ::= <lectura>\n");
}
  | escritura
{
    fprintf(yyout, ";R36:\t<sentencia_simple> ::= <escritura>\n");
}
  | retorno_funcion
{
    fprintf(yyout, ";R38:\t<sentencia_simple> ::= <retorno_funcion>\n");
};

bloque: condicional
{
    fprintf(yyout, ";R40:\t<bloque> ::= <condicional>\n");
}
  | bucle
{
    fprintf(yyout, ";R41:\t<bloque> ::= <bucle>\n");
};

asignacion: TOK_IDENTIFICADOR '=' exp
{
  simbolo* p_s = NULL;
  
  p_s = ts_search(tabla, $1.lexema);
  if(!p_s) {
    sprintf(err, "Acceso a variable no declarada %s", $1.lexema);
    yyerror(err);
    return -1;
  }

  if (get_simbolo_categoria(p_s) == FUNCION ||
              get_simbolo_clase(p_s) == VECTOR ||
              get_simbolo_tipo(p_s) != $3.tipo) {
    yyerror("Asignacion incompatible");
    return -1;
  }

  asignar(yyasm, $1.lexema, $3.es_direccion);

  fprintf(yyout, ";R43:\t<asignacion> ::= <identificador> = <exp>\n");
} 
  | elemento_vector '=' exp
{
  if ($1.tipo != $3.tipo) {
    yyerror("Asignacion incompatible");
    return -1;
  }

  asignarDestinoEnPila(yyasm, $3.es_direccion);

  fprintf(yyout, ";R44:\t<asignacion> ::= <elemento_vector> = <exp>\n");
};

elemento_vector: TOK_IDENTIFICADOR '[' exp ']'
{
  simbolo* p_s = NULL;

  p_s = ts_search(tabla, $1.lexema);
  if(!p_s) {
    sprintf(err, "Acceso a variable no declarada %s", $1.lexema);
    yyerror(err);
    return -1;
  }
  
  if (get_simbolo_clase(p_s) != VECTOR) {
    yyerror("Intento de indexacion de una variable que no es de tipo vector");
    return -1;
  }
  
  if ($3.tipo != ENTERO) {
    yyerror("El indice en una operacion de indexacion tiene que ser de tipo entero");
    return -1;
  }

  $$.tipo = get_simbolo_tipo(p_s);
  $$.es_direccion = 1;
  
  escribir_elemento_vector(yyasm, $1.lexema, MAX_TAMANIO_VECTOR, $3.es_direccion);

  fprintf(yyout, ";R48:\t<elemento_vector> ::= <identificador> [ <expr> ]\n");
};

condicional: if_exp ')' '{' sentencias '}'
{
  ifthen_fin(yyasm, $1.etiqueta);
  
  fprintf(yyout, ";R50:\t<condicional> ::= if ( <exp> ) { <sentencias> }\n");
} 
  | if_exp_sentencias TOK_ELSE '{' sentencias '}'
{
  ifthenelse_fin(yyasm, $1.etiqueta);

  fprintf(yyout, ";R51:\t<condicional> ::= if ( <exp> ) { <sentencias> } else { <sentencias> }\n");
};

bucle: while_exp ')' '{' sentencias '}'
{
  while_fin(yyasm, $1.etiqueta);

  fprintf(yyout, ";R52:\t<bucle> ::= while ( <exp> ) { <sentencias> }\n");
};

if_exp: TOK_IF '(' exp
{
  if($3.tipo != BOOLEAN) {
    yyerror("Condicional con condicion de tipo int");
    return -1;
  }

  $$.etiqueta = etiqueta++;

  ifthen_inicio(yyasm, $3.es_direccion, $$.etiqueta);
}

if_exp_sentencias: if_exp ')' '{' sentencias '}'
{
  $$.etiqueta = $1.etiqueta;

  ifthenelse_fin_then(yyasm, $1.etiqueta);
}

while_exp: while exp
{
  if($2.tipo != BOOLEAN) {
    yyerror("Bucle con condicion de tipo int");
    return -1;
  }

  $$.etiqueta = $1.etiqueta;
  
  while_exp_pila(yyasm, $2.es_direccion, $$.etiqueta);
}

while: TOK_WHILE '('
{
  $$.etiqueta = etiqueta++;

  while_inicio(yyasm, $$.etiqueta);
}

lectura: TOK_SCANF TOK_IDENTIFICADOR
{
  simbolo* p_s = NULL;

  p_s = ts_search(tabla, $2.lexema);
  if (!p_s) {
    sprintf(err, "Acceso a variable no declarada %s", $2.lexema);
    yyerror(err);
    return -1;
  }

  if (get_simbolo_categoria(p_s) ==  FUNCION || get_simbolo_clase(p_s) == VECTOR) {
    yyerror("Error sin descripcion"); 
    return -1;
  }

  if (ambito_local) {
      if (get_simbolo_categoria(p_s) == PARAMETRO) {
        escribirParametro(yyasm, get_simbolo_adicional2(p_s), num_parametros_actual);
      } else {
        escribirVariableLocal(yyasm, get_simbolo_adicional2(p_s));
      } 
  } 

  leer(yyasm, $2.lexema, tipo_actual, ambito_local);

  fprintf(yyout, ";R54:\t<lectura> ::= scanf <identificador>\n");
};

escritura: TOK_PRINTF exp
{
  escribir(yyasm, $2.es_direccion, $2.tipo);

  fprintf(yyout, ";R56:\t<escritura> ::= printf <exp>\n");
};

retorno_funcion: TOK_RETURN exp
{
  if (!ambito_local) {
    yyerror("Sentencia de retorno fuera del cuerpo de una funcion");
    return -1;
  }

  if (tipo_retorno_funcion != $2.tipo) {
    yyerror("Error sin descripcion");
  }

  fn_return++;

  retornarFuncion(yyasm, $2.es_direccion);

  fprintf(yyout, ";R61:\t<retorno_funcion> ::= return <exp>\n");
};

exp: exp '+' exp
{
  if($1.tipo != ENTERO || $3.tipo != ENTERO) {
    yyerror("Operacion arimetica con operandos boolean.");
    return -1;
  }

  $$.tipo = ENTERO;
  $$.es_direccion = 0;

  sumar(yyasm, $1.es_direccion, $3.es_direccion);  

  fprintf(yyout, ";R72:\t<exp> ::= <exp> + <exp>\n");
} 
  | exp '-' exp
{
  if($1.tipo != ENTERO || $3.tipo != ENTERO) {
    yyerror("Operacion arimetica con operandos boolean.");
    return -1;
  }

  $$.tipo = ENTERO;
  $$.es_direccion = 0;

  restar(yyasm, $1.es_direccion, $3.es_direccion);

  fprintf(yyout, ";R73:\t<exp> ::= <exp> - <exp>\n");
} 
  | exp '/' exp
{
  if($1.tipo != ENTERO || $3.tipo != ENTERO) {
    yyerror("Operacion arimetica con operandos boolean.");
    return -1;
  }

  $$.tipo = ENTERO;
  $$.es_direccion = 0;

  dividir(yyasm, $1.es_direccion, $3.es_direccion);

  fprintf(yyout, ";R74:\t<exp> ::= <exp> / <exp>\n");
} 
  | exp '*' exp
{
  if($1.tipo != ENTERO || $3.tipo != ENTERO) {
    yyerror("Operacion arimetica con operandos boolean.");
    return -1;
  }

  $$.tipo = ENTERO;
  $$.es_direccion = 0;

  multiplicar(yyasm, $1.es_direccion, $3.es_direccion);

  fprintf(yyout, ";R75:\t<exp> ::= <exp> * <exp>\n");
} 
  | '-' exp
{
  if($2.tipo != ENTERO) {
    yyerror("Operacion arimetica con operandos boolean.");
    return -1;
  }

  $$.tipo = ENTERO;
  $$.es_direccion = 0;

  cambiar_signo(yyasm, $2.es_direccion); 

  fprintf(yyout, ";R76:\t<exp> ::= - <exp>\n");
} 
  | exp TOK_AND exp
{
  if($1.tipo != BOOLEAN || $3.tipo != BOOLEAN) {
    yyerror("Operacion logica con operandos int.");
    return -1;
  }

  $$.tipo = BOOLEAN;
  $$.es_direccion = 0;

  y(yyasm, $1.es_direccion, $3.es_direccion);

  fprintf(yyout, ";R77:\t<exp> ::= <exp> && <exp>\n");
}
  | exp TOK_OR exp
{
  if($1.tipo != BOOLEAN || $3.tipo != BOOLEAN) {
    yyerror("Operacion logica con operandos int.");
    return -1;
  }

  $$.tipo = BOOLEAN;
  $$.es_direccion = 0;

  o(yyasm, $1.es_direccion, $3.es_direccion);

  fprintf(yyout, ";R78:\t<exp> ::= <exp> || <exp>\n");
} 
  | TOK_NOT exp
{
  if($2.tipo != BOOLEAN) {
    yyerror("Operacion logica con operandos int.");
    return -1;
  }

  $$.tipo = BOOLEAN;
  $$.es_direccion = 0;

  no(yyasm, $2.es_direccion, etiqueta++); 

  fprintf(yyout, ";R79:\t<exp> ::= ! <exp>\n");
} 
  | TOK_IDENTIFICADOR
{
  simbolo* p_s = NULL;
  
  p_s = ts_search(tabla, $1.lexema);
  if(!p_s) {
    sprintf(err, "Acceso a variable no declarada %s", $1.lexema);
    yyerror(err);
    return -1;
  }

  if (get_simbolo_categoria(p_s) == FUNCION ||
              get_simbolo_clase(p_s) == VECTOR) {
    yyerror("Error sin descripcion.");
    return -1;
  }

  $$.tipo = get_simbolo_tipo(p_s);
  $$.es_direccion = 1; /* Es una variable */

  escribir_operando(yyasm, $1.lexema, $$.es_direccion);

  fprintf(yyout, ";R80:\t<exp> ::= <identificador>\n");
} 
  | constante
{
  $$.tipo = $1.tipo;
  $$.es_direccion = $1.es_direccion;

  fprintf(yyout, ";R81:\t<exp> ::= <constante>\n");
} 
  | '(' exp ')'
{
  $$.tipo = $2.tipo;
  $$.es_direccion = $2.es_direccion;

  fprintf(yyout, ";R82:\t<exp> ::= ( exp )\n");
} 
  | '(' comparacion ')'
{
  $$.tipo = $2.tipo;
  $$.es_direccion = $2.es_direccion;

  fprintf(yyout, ";R83:\t<exp> ::= ( <comparacion> )\n");
} 
  | elemento_vector
{
  $$.tipo = $1.tipo;
  $$.es_direccion = $1.es_direccion;

  fprintf(yyout, ";R85\t<exp> ::= <elemento_vector>\n");
} 
  | idf_llamada_funcion '(' lista_expresiones ')'
{

  simbolo* p_s = NULL;

  p_s = ts_search(tabla, $1.lexema);
  if (!p_s) {
    sprintf(err, "Acceso a variable no declarada %s", $1.lexema);
    yyerror(err);
    return -1;
  }

  if(get_simbolo_adicional1(p_s) != num_parametros_llamada_actual) {
    yyerror("Numero incorrecto de parametros en llamada a funcion");
    return -1;
  }

  en_explist = 0;

  $$.tipo = get_simbolo_tipo(p_s);
  $$.es_direccion = 0;

  llamarFuncion(yyasm, $1.lexema, num_parametros_llamada_actual);

  fprintf(yyout, ";R88\t<exp> ::= <identificador> ( <lista_expresiones> )\n");
};

idf_llamada_funcion: TOK_IDENTIFICADOR
{
  simbolo* p_s = NULL;

  p_s = ts_search(tabla, $1.lexema);
  if (!p_s) {
    sprintf(err, "Acceso a variable no declarada %s", $1.lexema);
    yyerror(err);
    return -1;
  }

  if (get_simbolo_categoria(p_s) != FUNCION) {
    yyerror("Error sin descripcion");
    return -1;
  }

  if (en_explist) {
    yyerror("No esta permitido el uso de llamadas a funciones como parametros de otras funciones");
    return -1;
  }

  num_parametros_llamada_actual = 0;
  en_explist = 1;

  strcpy($$.lexema, $1.lexema);
}

lista_expresiones: exp resto_lista_expresiones
{
  num_parametros_llamada_actual++;
  fprintf(yyout, ";R89\t<lista_expresiones> ::= <exp> <resto_lista_expresiones>\n");
} 
  | /* vacia */
{
  fprintf(yyout, ";R90\t<lista_expresiones> ::= \n");
};

resto_lista_expresiones: ',' exp resto_lista_expresiones
{
  num_parametros_llamada_actual++;
  fprintf(yyout, ";R91:\t<resto_lista_expresiones> ::= , <exp> <resto_lista_expresiones>\n");
} 
  | /* vacia */
{
  fprintf(yyout, ";R92:\t<resto_lista_expresiones> ::= \n");
};

comparacion: exp TOK_IGUAL exp
{
  if($1.tipo != ENTERO || $3.tipo != ENTERO) {
    yyerror("Comparacion con operandos boolean.");
    return -1;
  }

  $$.tipo = BOOLEAN;
  $$.es_direccion = 0;

  igual(yyasm, $1.es_direccion, $3.es_direccion, etiqueta++); 

  fprintf(yyout, ";R93:\t<comparacion> ::= <exp> == <exp>\n");
} 
  | exp TOK_DISTINTO exp
{
  if($1.tipo != ENTERO || $3.tipo != ENTERO) {
    yyerror("Comparacion con operandos boolean.");
    return -1;
  }

  $$.tipo = BOOLEAN;
  $$.es_direccion = 0;

  distinto(yyasm, $1.es_direccion, $3.es_direccion, etiqueta++);  

  fprintf(yyout, ";R94:\t<comparacion> ::= <exp> != <exp>\n");
} 
  | exp TOK_MENORIGUAL exp
{
  if($1.tipo != ENTERO || $3.tipo != ENTERO) {
    yyerror("Comparacion con operandos boolean.");
    return -1;
  }

  $$.tipo = BOOLEAN;
  $$.es_direccion = 0;

  menor_igual(yyasm, $1.es_direccion, $3.es_direccion, etiqueta++);

  fprintf(yyout, "R95:\t<comparacion> ::= <exp> <= <exp>\n");
}
  | exp TOK_MAYORIGUAL exp
{
  if($1.tipo != ENTERO || $3.tipo != ENTERO) {
    yyerror("Comparacion con operandos boolean.");
    return -1;
  }

  $$.tipo = BOOLEAN;
  $$.es_direccion = 0;

  mayor_igual(yyasm, $1.es_direccion, $3.es_direccion, etiqueta++);

  fprintf(yyout, ";R96:\t<comparacion> ::= <exp> >= <exp>\n");
}
  | exp '<' exp
{
  if($1.tipo != ENTERO || $3.tipo != ENTERO) {
    yyerror("Comparacion con operandos boolean.");
    return -1;
  }

  $$.tipo = BOOLEAN;
  $$.es_direccion = 0;

  menor(yyasm, $1.es_direccion, $3.es_direccion, etiqueta++);

  fprintf(yyout, ";R97:\t<comparacion> ::= <exp> < <exp>\n");
} 
  | exp '>' exp
{
  if($1.tipo != ENTERO || $3.tipo != ENTERO) {
    yyerror("Comparacion con operandos boolean.");
    return -1;
  }

  $$.tipo = BOOLEAN;
  $$.es_direccion = 0;

  mayor(yyasm, $1.es_direccion, $3.es_direccion, etiqueta++);

  fprintf(yyout, ";R98:\t<comparacion> ::= <exp> > <exp>\n");
};

constante: constante_logica
{
  $$.tipo = $1.tipo;
  $$.es_direccion = $1.es_direccion;

  fprintf(yyout, ";R99:\t<constante> ::= <constante_logica>\n");
} 
  | constante_entera
{
  $$.tipo = $1.tipo;
  $$.es_direccion = $1.es_direccion;

  fprintf(yyout, ";R100:\t<constante> ::= <constante_entera>\n");
};

constante_logica: TOK_TRUE
{
  $$.tipo = BOOLEAN;
  $$.es_direccion = 0;

  escribir_operando(yyasm, "1", 0);

  fprintf(yyout, ";R102\t<constante_logica> ::= true\n");
} 
  | TOK_FALSE
{
  $$.tipo = BOOLEAN;
  $$.es_direccion = 0;

  escribir_operando(yyasm, "0", 0);

  fprintf(yyout, ";R103\t<constante_logica> ::= false\n");
};

constante_entera: TOK_CONSTANTE_ENTERA
{
  char valor[10];

  $$.tipo = ENTERO;
  $$.valor_entero = $1.valor_entero;
  $$.es_direccion = 0;

  sprintf(valor, "%d", $1.valor_entero);
  escribir_operando(yyasm, valor, 0);

  fprintf(yyout, ";R104:\t<constante_entera> ::= TOK_CONSTANTE_ENTERA\n");
};

identificador: TOK_IDENTIFICADOR
{
    STATUS s;
    simbolo* p_s = NULL;

    p_s = ts_search(tabla, $1.lexema);
    if (p_s) {
      yyerror("Declaracion duplicada.");
      return -1;
    }

    s = ts_insert(tabla, $1.lexema, VARIABLE, tipo_actual, clase_actual, valor_escalar_actual, 
                    pos_variable_local_actual);
    if (s == ERR) {
      yyerror("Variable local de tipo no escalar");
      return -1;
    }

    if (ambito_local) {
      pos_variable_local_actual++;
      num_variables_locales_actual++;
    }

    fprintf(yyout, ";R108:\t<identificador> ::= TOK_IDENTIFICADOR\n");
};

%%

/******************************************************************************/
/*  SECCION FUNCIONES DE USUARIO                                              */
/******************************************************************************/
void yyerror(char *s) {
    if (s) {
      fprintf(stderr, "****Error semantico en lin %d: %s\n", row, s);
    }
    else if (!err_morf) {
      fprintf(stderr, "****Error sintáctico en [lin %d, col %d]\n", row, col);
    }
    ts_free(tabla);
}
