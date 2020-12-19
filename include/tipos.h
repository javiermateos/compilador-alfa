#ifndef __TIPOS_H_
#define __TIPOS_H_

/* Tipos de retorno de una funcion */
typedef enum { ERR = -1, OK = 0 } STATUS;

/* Categoria de un simbolo: variable, parametro de funcion o funcion */
typedef enum { VARIABLE=1, PARAMETRO, FUNCION } CATEGORIA;

/* Tipo de un dato: solo se trabajara con enteros y booleanos */
typedef enum { ENTERO=1, BOOLEAN } TIPO;

/* Clase de un simbolo: pueden ser variables atomicas (escalares) o listas/arrays (vectores) */
typedef enum { ESCALAR=1, VECTOR } CLASE;

#endif
