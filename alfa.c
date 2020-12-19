#include "alfa.h"

const char* errors[19] = {
  "****Error morfologico en [lin %d, col %d]: Simbolo no permitido (%s).\n",
  "****Error en [lin %d, col %d]: Identificador demasiado largo (%s).\n",
  "****Error sintáctico en [lin %d, col %d].\n",
  "****Error semantico en [lin %d]: Declaracion duplicada.\n",
  "****Error semantico en [lin %d]: Acceso a variable no declarada (%s).\n",
  "****Error semantico en [lin %d]: Operacion aritmetica con operandos boolean.\n",
  "****Error semantico en [lin %d]: Operacion logica con operandos int.\n",
  "****Error semantico en [lin %d]: Comparacion con operandos boolean.\n",
  "****Error semantico en [lin %d]: Condicional con condicion de tipo int.\n",
  "****Error semantico en [lin %d]: Bucle con condicion de tipo int.\n",
  "****Error semantico en [lin %d]: Numero incorrecto de parametros en llamada a funcion.\n",
  "****Error semantico en [lin %d]: Asignacion incompatible.\n",
  "****Error semantico en [lin %d]: El tamanyo del vector %s excede los limites permitidos (1,64).\n",
  "****Error semantico en [lin %d]: Intento de indexacion de una variable que no es de tipo vector.\n",
  "****Error semantico en [lin %d]: El indice en una operacion de indexacion tiene que ser de tipo entero.\n",
  "****Error semantico en [lin %d]: Funcion %s sin sentencia de retorno.\n",
  "****Error semantico en [lin %d]: Sentencia de retorno fuera del cuerpo de una función.\n",
  "****Error semantico en [lin %d]: No esta permitido el uso de llamadas a funciones como parametros de otras funciones.\n",
  "****Error semantico en [lin %d]: Variable local de tipo no escalar..\n"
};

void compiler_error(COMPILER_ERRORS tipo, int row, int col, char* info) {
  fprintf(stderr, errors[tipo], row, col, info);
}
