#ifndef GENERACION_H
#define GENERACION_H

#include <stdio.h>

#define MAX_ETIQUETAS 256
/* Declaraciones de tipos de datos del compilador */
#define ENTERO 0
#define BOOLEANO 1

/* OBSERVACIÓN GENERAL A TODAS LAS FUNCIONES:
Todas ellas escriben el código NASM a un FILE* proporcionado como primer
argumento.
*/

/* FUNCIONES DE INICIALIZACION Y FINALIZACION DE PROGRAMAS */

/*
Código para el principio de la sección .bss.
Con seguridad sabes que deberás reservar una variable entera para guardar el
puntero de pila extendido (esp). Se te sugiere el nombre __esp para esta
variable.
*/
void escribir_cabecera_bss(FILE *fpasm);

/*
Declaración (con directiva db) de las variables que contienen el texto de los
mensajes para la identificación de errores en tiempo de ejecución.
En este punto, al menos, debes ser capaz de detectar la división por 0.
*/
void escribir_subseccion_data(FILE *fpasm);

/*
Para ser invocada en la sección .bss cada vez que se quiera declarar una
variable:
- El argumento nombre es el de la variable.
- tipo puede ser ENTERO o BOOLEANO (observa la declaración de las constantes
del principio del fichero).
- Esta misma función se invocará cuando en el compilador se declaren
vectores, por eso se adjunta un argumento final (tamano) que para esta
primera práctica siempre recibirá el valor 1.
*/
void declarar_variable(FILE *fpasm, char *nombre, int tipo, int tamano);

/*
Para escribir el comienzo del segmento .text, básicamente se indica que se
exporta la etiqueta main y que se usarán las funciones declaradas en la librería
alfalib.o
*/
void escribir_segmento_codigo(FILE *fpasm);

/*
En este punto se debe escribir, al menos, la etiqueta main y la sentencia que
guarda el puntero de pila en su variable (se recomienda usar __esp).
*/
void escribir_inicio_main(FILE *fpasm);

/*
Al final del programa se escribe:
- El código NASM para salir de manera controlada cuando se detecta un error
en tiempo de ejecución (cada error saltará a una etiqueta situada en esta
zona en la que se imprimirá el correspondiente mensaje y se saltará a la
zona de finalización del programa).
- En el final del programa se debe:
·Restaurar el valor del puntero de pila (a partir de su variable __esp)
·Salir del programa (ret).
*/
void escribir_fin(FILE *fpasm);

/*
Función que debe ser invocada cuando se sabe un operando de una operación
aritmético-lógica y se necesita introducirlo en la pila.
- nombre es la cadena de caracteres del operando tal y como debería aparecer
en el fuente NASM
- es_variable indica si este operando es una variable (como por ejemplo b1)
con un 1 u otra cosa (como por ejemplo 34) con un 0. Recuerda que en el
primer caso internamente se representará como _b1 y, sin embargo, en el
segundo se representará tal y como esté en el argumento (34).
*/
void escribir_operando(FILE *fpasm, char *nombre, int es_variable);
/*
- Genera el código para asignar valor a la variable de nombre nombre.
- Se toma el valor de la cima de la pila.
- El último argumento es el que indica si lo que hay en la cima de la pila es
una referencia (1) o ya un valor explícito (0).
*/
void asignar(FILE *fpasm, char *nombre, int es_variable);

/* FUNCIONES ARITMÉTICO-LÓGICAS BINARIAS */

/*
En todas ellas se realiza la operación como se ha resumido anteriormente:
- Se extrae de la pila los operandos
- Se realiza la operación
- Se guarda el resultado en la pila
Los dos últimos argumentos indican respectivamente si lo que hay en la pila es
una referencia a un valor o un valor explícito.
Deben tenerse en cuenta las peculiaridades de cada operación. En este sentido
sí hay que mencionar explícitamente que, en el caso de la división, se debe
controlar si el divisor es “0” y en ese caso se debe saltar a la rutina de error
controlado (restaurando el puntero de pila en ese caso y comprobando en el
retorno que no se produce “Segmentation Fault”)
*/
void sumar(FILE *fpasm, int es_variable_1, int es_variable_2);
void restar(FILE *fpasm, int es_variable_1, int es_variable_2);
void multiplicar(FILE *fpasm, int es_variable_1, int es_variable_2);
void dividir(FILE *fpasm, int es_variable_1, int es_variable_2);
void o(FILE *fpasm, int es_variable_1, int es_variable_2);
void y(FILE *fpasm, int es_variable_1, int es_variable_2);

/*
Función aritmética de cambio de signo.
Es análoga a las binarias, excepto que sólo requiere de un acceso a la pila ya
que sólo usa un operando.
*/
void cambiar_signo(FILE *fpasm, int es_variable);

/*
Función monádica lógica de negación. No hay un código de operación de la ALU
que realice esta operación por lo que se debe codificar un algoritmo que, si
encuentra en la cima de la pila un 0 deja en la cima un 1 y al contrario.
El último argumento es el valor de etiqueta que corresponde (sin lugar a dudas,
la implementación del algoritmo requerirá etiquetas). Véase en los ejemplos de
programa principal como puede gestionarse el número de etiquetas cuantos_no.
*/
void no(FILE *fpasm, int es_variable, int cuantos_no);

/* FUNCIONES COMPARATIVAS */

/*
Todas estas funciones reciben como argumento si los elementos a comparar son o
no variables. El resultado de las operaciones, que siempre será un booleano (“1”
si se cumple la comparación y “0” si no se cumple), se deja en la pila como en
el resto de operaciones. Se deben usar etiquetas para poder gestionar los saltos
necesarios para implementar las comparaciones.
*/
void igual(FILE *fpasm, int es_variable1, int es_variable2, int etiqueta);
void distinto(FILE *fpasm, int es_variable1, int es_variable2, int etiqueta);
void menor_igual(FILE *fpasm, int es_variable1, int es_variable2, int etiqueta);
void mayor_igual(FILE *fpasm, int es_variable1, int es_variable2, int etiqueta);
void menor(FILE *fpasm, int es_variable1, int es_variable2, int etiqueta);
void mayor(FILE *fpasm, int es_variable1, int es_variable2, int etiqueta);

/* FUNCIONES DE ESCRITURA Y LECTURA */

/*
Se necesita saber el tipo de datos que se va a procesar (ENTERO o BOOLEANO) ya
que hay diferentes funciones de librería para la lectura (idem. escritura) de
cada tipo. Se deben insertar en la pila los argumentos necesarios, realizar la
llamada (call) a la función de librería correspondiente y limpiar la pila.
*/
void leer(FILE *fpasm, char *nombre, int tipo);
void escribir(FILE *fpasm, int es_variable, int tipo);

/* FUNCIONES MANIPULACION DE VECTORES, FUNCIONES, BLUCLES Y ESTRUCTURAS
 * CONDICIONALES */

/* MANIPULACION DE BUCLES Y ESTRUCTURAS CONDICIONALES */

/**
 * Generacion de codigo para el inicio de una estructura if-then-else
 *
 * Como es el inicio de un bloque de control de flujo de programa que requiere
 * de una nueva etiqueta que deben ejecutarse antes las tareas correspondientes
 * a esta situacion
 *
 * exp_es_variable
 *      Es 1 si la expresion de la condicion es algo asimilable a una variable(
 * identificador elemento de vector) Es 0 en caso contrario (constante u otro
 * tipo de expresion)
 */
void ifthenelse_inicio(FILE *fpasm, int exp_es_variable, int etiqueta);

/**
 * Generacion de codigo para el inicio de una estructura if-then
 *
 * Como es el inicio de un bloque de control de flujo de programa que requiere
 * de una nueva etiqueta que deben ejecutarse antes las tareas correspondientes
 * a esta situacion
 *
 * exp_es_variable
 *      Es 1 si la expresion de la condicion es algo asimilable a una variable(
 * identificador elemento de vector) Es 0 en caso contrario (constante u otro
 * tipo de expresion)
 */
void ifthen_inicio(FILE *fpasm, int exp_es_variable, int etiqueta);

/**
 * Generacion de codigo para el fin de una estructura if-then
 *
 * Como es el fin de un bloque de control de flujo de programa que hace uso de
 * la etiqueta del mismo se requiere que antes de su invocacion tome el valor de
 * la etiqueta que le toca
 *
 * Y tras ser invocado debe realizar el proceso para ajustar la informacion de
 * las etiquetas puesto que se ha liberado la ultima de ellas
 */
void ifthen_fin(FILE *fpasm, int etiqueta);

/**
 * Generacion de codigo para el fin de la rama then de una estructura
 * if-then-else
 *
 * Solo necesita usar la etiqueta adecuada, aunque es el final de una rama,
 * luego debe venir otra (la rama else) antes de que se termine la estructura y
 * se tenga que ajustar las etiquetas por lo que solo se necesita que se utilice
 * la etiqueta que corresponde al momento actual
 */
void ifthenelse_fin_then(FILE *fpasm, int etiqueta);

/**
 * Generacion de codigo para el fin de una estructura if-then
 *
 * Como es el fin de un bloque de control de flujo de programa que hace uso de
 * la etiqueta del mismo se requiere que antes de su invocacion tome el valor de
 * la etiqueta que le toca
 *
 * Y tras ser invocado debe realizar el proceso para ajustar la informacion de
 * las etiquetas puesto que se ha liberado la ultima de ellas
 */
void ifthenelse_fin(FILE *fpasm, int etiqueta);

/**
 * Generacion de codigo para el inicio de una estructura while
 *
 * Como es el inicio de un bloque de control de flujo de programa que requiere
 * de una nueva etiqueta deben ejecutarse antes las tareas correspondientes a
 * esta situacion
 *
 * exp_es_variable
 *      Es 1 si la expresion de la condicion es algo asimilable a una variable(
 * identificador elemento de vector) Es 0 en caso contrario (constante u otro
 * tipo de expresion)
 */
void while_inicio(FILE *fpasm, int etiqueta);

/**
 * Generacion de codigo para el momento en el que se ha generado el codigo de la
 * expresion de control del bucle
 *
 * Solo necesita usar la etiqueta adecuada, por lo que solo se necesita que se
 * recupere el valor de la etiqueta que corresponde al momento actual
 *
 * exp_es_variable
 *      Es 1 si la expresion de la condicion es algo asimilable a una variable(
 * identificador elemento de vector) Es 0 en caso contrario (constante u otro
 * tipo de expresion)
 */
void while_exp_pila(FILE *fpasm, int exp_es_variable, int etiqueta);

/**
 * Generacion de codigo para el fin de una estructura while
 *
 * Como es el fin de un bloque de control de flujo de programa que hace uso de
 * la etiqueta del mismo se requiere que antes de su invocacion tome el valor de
 * la etiqueta que le toca
 *
 * Y tras ser invocado debe realizar el proceso para ajustar la informacion de
 * las etiquetas puesto que se ha liberado la ultima de ellas
 */
void while_fin(FILE *fpasm, int etiqueta);

/* MANIPULACION DE VECTORES*/

/**
 * Generacion para indexar un vector
 *      Cuyo nombre es nombre_vector
 *      Declarado con un tamanio tam_max
 *      La expresion que lo indexa esta en la cima de la pila
 *      Puede ser una variable(o algo equivalente) en cuyo caso exo_es_direccion
 * vale 1 Puede ser un valor concreto(en ese caso exp_es_direccion vale 0)
 *
 * Segun se especifica en el material, es suficiente con utilizar dos registros
 * para realizar esta tarea
 */
void escribir_elemento_vector(FILE *fpasm, char *nombre_vector, int tam_max,
                              int exp_es_direccion);

/* MANIPULACION DE FUNCIONES */

/*
Generacion de codigo para iniciar la declaracion de una funcion.
Es necesario proporcionar su nombre y el numero de variables locales.
*/
void declararFuncion(FILE *fpasm, char *nombre_funcion, int num_var_loc);

/*
Generacion de codigo para el retorno de una funcion.
La expresion debe retornarse en la cima de la pila. Esta expresion puede
ser una variable (o algo equivalente), en cuyo caso es_variable vale 1 o
un valor concreto, en cuyo  caso es_variable vale 0.
*/
void retornarFuncion(FILE *fpasm, int es_variable);

/**
 * Funcion para dejar en la cima de la pila la direccion efectiva del parametro
 * que ocupa la posicion pos_parametro(recuerda que los parametros se ordenan
 * con origen 0) de un total de num_total_paramtros
 */
void escribirParametro(FILE *fpasm, int pos_parametro,
                       int num_total_parametros);

/**
 * Funcion para dejar en la cima de la pila la direccion efectiva de la variable
 * local que ocupa la posicion_variable_local(origen 1)
 */
void escribirVariableLocal(FILE *fpasm, int posicion_variable_local);

/**
 * Funcion para poder asignar a un destino que no es una variable "global" (tipo
 * _x) por ejemeplo parametros o variables locales ( ya que en ese caso su
 * nombre real de alto nivel no se tiene en cuenta pues es realmente un
 * desplazamiento a partir de ebp: ebp+4 o ebp-8 por ejemplo)
 *
 * Se debe asumir que en la pila estara
 *      Primero la direccion donde hay que asignar
 *      Debajo lo que hay que asignar
 *
 * es_variable
 *      1 si la expresion es algo asimilable en una varible (id, elemento de
 * vector) 0 en caso contrario
 */
void asignarDestinoEnPila(FILE *fpasm, int es_varible);

/**
 * Los argumentos se pasan por valor, es decir, que siempre se dejan en la pila
 * valores y no variables
 *
 * Esta funcion realiza la tarea de dado un operando escrito en la pila y
 * sabiendo si es variable o no(es_variable) se deja en la pila el valor
 * correspondiente
 */
void operandoEnPilaAArgumento(FILE *fd_asm, int es_variable);

/**
 * Esta funcion genera el codigo para llamar a la funcion de nombre
 * nombre_funcion asumiendo que los argumentos estan en la pila en el orden
 * fijado
 *
 * Debe dejar en la cima de la pila el retorno de la funcion tras haber limpiado
 * sus argumentos
 *
 * Para limpiar la pila puede utilizar limpiarPila
 */
void llamarFuncion(FILE *fd_asm, char *nombre_funcion, int num_argumentos);

/**
 * Genera el codigo para limpiar la pila tras invocar una funcion
 *
 * Esta funcion es necesaria para completar la llamada a metodos, su gestion
 * dificulta el conocimiento por parte de la funcion de la llamada del numero de
 * argumentos que hay en la pila
 */

void limpiarPila(FILE *fd_asm, int num_argumentos);

#endif
