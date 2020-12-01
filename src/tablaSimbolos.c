#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "simbolo.h"
#include "tablaHash.h"
#include "tablaSimbolos.h"

struct s_tabla_simbolos {
  HashTable *tabla_global;
  HashTable *tabla_local;
};

tabla_simbolos *ts_crear() {
  tabla_simbolos *p_ts = NULL;

  p_ts = (tabla_simbolos *)malloc(sizeof(tabla_simbolos));
  if (!p_ts) {
    return NULL;
  }
  p_ts->tabla_global = ht_create(TH_SIZE);
  if (!p_ts->tabla_global) {
    free(p_ts);
    return NULL;
  }
  p_ts->tabla_local = NULL;

  return p_ts;
}

void ts_free(tabla_simbolos *p_ts) {

  if (!p_ts) {
    return;
  }
  if (p_ts->tabla_local) {
    ht_free(p_ts->tabla_local);
  }

  ht_free(p_ts->tabla_global);
  free(p_ts);
}

STATUS ts_insert(tabla_simbolos *p_ts, const char *lexema, int n) {
  HashTable *ht = NULL;
  simbolo *s = NULL;

  if (!p_ts || !lexema) {
    return ERR;
  }
  if (p_ts->tabla_local) {
    ht = p_ts->tabla_local;
  } else {
    ht = p_ts->tabla_global;
  }

  s = crear_simbolo(lexema, VARIABLE, ENTERO, ESCALAR, n, 0);
  if (!s) {
    return ERR;
  }

  if(ht_insert(ht, lexema,s) == ERR){
    liberar_simbolo(s);
    return ERR;
  }

  return OK;
}

simbolo *ts_search(tabla_simbolos *p_ts, const char *lexema) {
  simbolo *ret = NULL;

  if (!p_ts || !lexema) {
    return NULL;
  }

  if (p_ts->tabla_local) {
    ret = ht_search(p_ts->tabla_local, lexema);
    if (ret) {
      return ret;
    }
  }

  return ht_search(p_ts->tabla_global, lexema);
}

STATUS ts_open_scope(tabla_simbolos *p_ts, const char *lexema, int n) {

  simbolo *s = NULL;

  if (!p_ts || !lexema) {
    return ERR;
  }

  /* No es necesario por el enunciado de la P4 */
  /* if (p_ts->tabla_local) { */
  /*   return ERR; */
  /* } */

  p_ts->tabla_local = ht_create(TH_SIZE);
  if (!p_ts->tabla_local) {
    return ERR;
  }

  s = crear_simbolo(lexema, VARIABLE, ENTERO, ESCALAR, n, 0);
  if (!s) {
    return ERR;
  }

  if (ht_insert(p_ts->tabla_global, lexema, s) == ERR) {
    liberar_simbolo(s);
    ht_free(p_ts->tabla_local);
    p_ts->tabla_local = NULL;
    return ERR;
  }

  s = crear_simbolo(lexema, VARIABLE, ENTERO, ESCALAR, n, 0);
  if (!s) {
    return ERR;
  }

  if (ht_insert(p_ts->tabla_local, lexema, s) == ERR) {
    liberar_simbolo(s);
    ht_free(p_ts->tabla_local);
    p_ts->tabla_local = NULL;
    return ERR;
  }

  return OK;
}

STATUS ts_close_scope(tabla_simbolos *p_ts) {
  if (!p_ts) {
    return ERR;
  }

  /* No es necesario por el enunciado de la P4 */
  /* if (!p_ts->tabla_local) { */
  /*     return ERR; */
  /* } */

  ht_free(p_ts->tabla_local);
  p_ts->tabla_local = NULL;

  return OK;
}
