#ifndef _ALFA_H
#define _ALFA_H

#include <stdio.h>
#include "tipos.h"

#define MAX_LONG_ID 100
#define MAX_TAMANIO_VECTOR 64

typedef struct {
  char lexema[MAX_LONG_ID + 1]; /* Identificadores */
  TIPO tipo; /* Comprobacion de tipos basicos */
  int valor_entero; /* Constantes enteras */
  int es_direccion; /* Indica si es direccion de memoria o constante */
  int etiqueta; /* Sentencias condicionales e iterativas */
} tipo_atributos;

#endif
