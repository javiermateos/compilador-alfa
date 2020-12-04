#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "simbolo.h"

/* Informacion de un simbolo */
struct s_simbolo {
  char *lexema;        /* identificador */
  CATEGORIA categoria; /* categoria */
  TIPO tipo;           /* tipo */
  CLASE clase;         /* clase */
  int adicional1; /* valor si escalar, longitud si vector, numero de parametros
                     si funcion */
  int adicional2; /* posicion en llamada a funcion si parametro, posicion de
                     declaracion si variable local de funcion, numero de
                     variables locales si funcion */
};

simbolo *crear_simbolo(const char *lexema, CATEGORIA categoria, TIPO tipo,
                       CLASE clase, int adic1, int adic2) {
  simbolo *p_simbolo = NULL;

  if (!lexema) {
    return NULL;
  }

  p_simbolo = (simbolo *)malloc(sizeof(simbolo));
  if (!p_simbolo) {
    return NULL;
  }

  p_simbolo->lexema = (char*)malloc(strlen(lexema) + 1);
  p_simbolo->categoria = categoria;
  p_simbolo->tipo = tipo;
  p_simbolo->clase = clase;
  p_simbolo->adicional1 = adic1;
  p_simbolo->adicional2 = adic2;

  strcpy(p_simbolo->lexema, lexema);

  return p_simbolo;
}

void liberar_simbolo(simbolo *simbolo) {
  if (!simbolo) {
    return;
  }

  if (simbolo->lexema) {
    free(simbolo->lexema);
  }

  free(simbolo);
}


void print_simbolo(FILE * f, simbolo *simbolo){
  if(!f || !simbolo) return;

  fprintf(f, "%s %d\n",simbolo->lexema, simbolo->adicional1);
}