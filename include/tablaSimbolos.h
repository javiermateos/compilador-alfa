#ifndef __TABLASIMBOLOS_H_
#define __TABLASIMBOLOS_H_

#include "simbolo.h"
#include "tipos.h"

#define TH_SIZE 50000

typedef struct s_tabla_simbolos tabla_simbolos;

tabla_simbolos *ts_crear();
void ts_free(tabla_simbolos *p_ts);
STATUS ts_insert(tabla_simbolos *p_ts, const char* lexema, CATEGORIA cat, TIPO t, CLASE cl, int adic1, int adic2);
simbolo* ts_search(tabla_simbolos *p_ts, const char* lexema);
STATUS ts_open_scope(tabla_simbolos *p_ts, const char* lexema, TIPO t, int adic1, int adic2);
STATUS ts_close_scope(tabla_simbolos *p_ts);

#endif
