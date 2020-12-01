#ifndef __SIMBOLO_H_
#define __SIMBOLO_H_

#include "tipos.h"

/* Informacion de un simbolo */
typedef struct s_simbolo simbolo;

simbolo *crear_simbolo(const char *lexema, CATEGORIA categoria, TIPO tipo,
                       CLASE clase, int adic1, int adic2);
void liberar_simbolo(simbolo *simbolo);
void print_simbolo(FILE *f, simbolo *simbolo);

#endif
