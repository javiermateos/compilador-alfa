#include "generacion.h"

/* FUNCIONES AUXILIARES */

/*
Obtiene los valores de la cima de la pila y los guarda en ecx y eax, en ese
orden. En caso de que se trate de una referencia, es decir, un valor de memoria,
mueve el contenido en dicha zona de memoria al registro eax y al registro ecx.
*/
void obtener_operandos(FILE *fpasm, int es_variable_1, int es_variable_2)
{
    fprintf(fpasm, "pop dword ecx\n");
    fprintf(fpasm, "pop dword eax\n");

    if (es_variable_1 == 1)
        fprintf(fpasm, "mov dword eax, [eax]\n");

    if (es_variable_2 == 1)
        fprintf(fpasm, "mov dword ecx, [ecx]\n");
}

/*
Obtiene el valor el valor de la cima de la pila y lo guarda en eax. En caso de
que se trate de una referencia, es decir, un valor de memoria, mueve el contenido
en dicha zona de memoria al registro eax.
*/
void obtener_operando(FILE *fpasm, int es_variable)
{
    fprintf(fpasm, "pop dword eax\n");

    if (es_variable)
        fprintf(fpasm, "mov dword eax, [eax]\n");
}


/* FUNCIONES DE INICIALIZACION Y FINALIZACION DE PROGRAMAS */

void escribir_cabecera_bss(FILE *fpasm)
{
    fprintf(fpasm, "segment .bss\n");
    fprintf(fpasm, "__esp resd 1\n");
}

void escribir_subseccion_data(FILE *fpasm)
{
    fprintf(fpasm, "segment .data\n");
    fprintf(fpasm, "div0_err db \"Division by 0 error\",0\n");
    fprintf(fpasm, "ior_err db \"Index out of range\",0\n");
}

void declarar_variable(FILE *fpasm, char *nombre, int tipo, int tamano)
{
    /* Todos los datos son de 32 bits */
    fprintf(fpasm, "_%s resd %d\n", nombre, tamano);
}

void escribir_segmento_codigo(FILE *fpasm)
{
    fprintf(fpasm, "segment .text\n");
    fprintf(fpasm, "global main\n");
    fprintf(fpasm, "extern print_int, print_boolean, print_string, print_blank\n");
    fprintf(fpasm, "extern print_endofline, scan_int, scan_boolean\n");
}

void escribir_inicio_main(FILE *fpasm)
{
    fprintf(fpasm, "main:\n");
    fprintf(fpasm, "mov dword [__esp], esp\n");
}

void escribir_fin(FILE *fpasm)
{
    fprintf(fpasm, "jmp near fin\n");

    /* Gestion de errores */
    fprintf(fpasm, "div0_err_handler:\n");
    fprintf(fpasm, "push dword div0_err\n");
    fprintf(fpasm, "call print_string\n");
    fprintf(fpasm, "add esp, 4\n");
    fprintf(fpasm, "call print_endofline\n");
    fprintf(fpasm, "jmp near fin\n");

    fprintf(fpasm, "ior_err_handler:\n");
    fprintf(fpasm, "push dword ior_err\n");
    fprintf(fpasm, "call print_string\n");
    fprintf(fpasm, "add esp, 4\n");
    fprintf(fpasm, "call print_endofline\n");
    fprintf(fpasm, "jmp near fin\n");

    /* Salida del programa */
    fprintf(fpasm, "fin:\n");
    fprintf(fpasm, "mov esp, [__esp]\n");
    fprintf(fpasm, "ret\n");
}

void escribir_operando(FILE *fpasm, char *nombre, int es_variable)
{
    if (es_variable)
        fprintf(fpasm, "push dword _%s\n", nombre);
    else
        fprintf(fpasm, "push dword %s\n", nombre);
}

void asignar(FILE *fpasm, char *nombre, int es_variable)
{
    obtener_operando(fpasm, es_variable);
    fprintf(fpasm, "mov dword [_%s], eax\n", nombre);
}


/* FUNCIONES ARITMÉTICO-LÓGICAS BINARIAS */

void sumar(FILE *fpasm, int es_variable_1, int es_variable_2)
{
    obtener_operandos(fpasm, es_variable_1, es_variable_2);

    fprintf(fpasm, "add eax, ecx\n");
    fprintf(fpasm, "push dword eax\n");
}

void restar(FILE *fpasm, int es_variable_1, int es_variable_2)
{
    obtener_operandos(fpasm, es_variable_1, es_variable_2);

    fprintf(fpasm, "sub eax, ecx\n");
    fprintf(fpasm, "push dword eax\n");
}

void multiplicar(FILE *fpasm, int es_variable_1, int es_variable_2)
{
    obtener_operandos(fpasm, es_variable_1, es_variable_2);

    fprintf(fpasm, "imul ecx\n");
    fprintf(fpasm, "push dword eax\n");
}

void dividir(FILE *fpasm, int es_variable_1, int es_variable_2)
{
    obtener_operandos(fpasm, es_variable_1, es_variable_2);

    /* Comprobacion division por 0*/
    fprintf(fpasm, "cmp ecx, 0\n");
    fprintf(fpasm, "je near div0_err_handler\n");

    fprintf(fpasm, "cdq\n");
    fprintf(fpasm, "idiv ecx\n");

    fprintf(fpasm, "push dword eax\n");
}

void o(FILE *fpasm, int es_variable_1, int es_variable_2)
{
    obtener_operandos(fpasm, es_variable_1, es_variable_2);

    fprintf(fpasm, "or eax, ecx\n");
    fprintf(fpasm, "push dword eax\n");
}

void y(FILE *fpasm, int es_variable_1, int es_variable_2)
{
    obtener_operandos(fpasm, es_variable_1, es_variable_2);

    fprintf(fpasm, "and eax, ecx\n");
    fprintf(fpasm, "push dword eax\n");
}

void cambiar_signo(FILE *fpasm, int es_variable)
{
    obtener_operando(fpasm, es_variable);

    fprintf(fpasm, "neg eax\n");

    fprintf(fpasm, "push dword eax\n");
}

void no(FILE *fpasm, int es_variable, int cuantos_no)
{
    obtener_operando(fpasm, es_variable);

    fprintf(fpasm, "cmp eax, 0\n");
    fprintf(fpasm, "je no_cero_%d\n", cuantos_no);

    fprintf(fpasm, "mov dword eax, 0\n");
    fprintf(fpasm, "jmp fin_no_%d\n", cuantos_no);

    fprintf(fpasm, "no_cero_%d:\n", cuantos_no);
    fprintf(fpasm, "mov dword eax, 1\n");

    fprintf(fpasm, "fin_no_%d:\n", cuantos_no);

    fprintf(fpasm, "push dword eax\n");
}


/* FUNCIONES COMPARATIVAS */

void igual(FILE *fpasm, int es_variable1, int es_variable2, int etiqueta)
{
    obtener_operandos(fpasm, es_variable1, es_variable2);

    fprintf(fpasm, "cmp eax, ecx\n");

    fprintf(fpasm, "je near igual_%d\n", etiqueta);

    fprintf(fpasm, "push dword 0\n");

    fprintf(fpasm, "jmp near fin_igual_%d\n", etiqueta);

    fprintf(fpasm, "igual_%d:\n", etiqueta);

    fprintf(fpasm, "push dword 1\n");

    fprintf(fpasm, "fin_igual_%d:\n", etiqueta);
}

void distinto(FILE *fpasm, int es_variable1, int es_variable2, int etiqueta)
{
    obtener_operandos(fpasm, es_variable1, es_variable2);

    fprintf(fpasm, "cmp eax, ecx\n");

    fprintf(fpasm, "jne near distinto_%d\n", etiqueta);

    fprintf(fpasm, "push dword 0\n");

    fprintf(fpasm, "jmp near fin_distinto_%d\n", etiqueta);

    fprintf(fpasm, "distinto_%d:\n", etiqueta);

    fprintf(fpasm, "push dword 1\n");

    fprintf(fpasm, "fin_distinto_%d:\n", etiqueta);
}

void menor_igual(FILE *fpasm, int es_variable1, int es_variable2, int etiqueta)
{
    obtener_operandos(fpasm, es_variable1, es_variable2);

    fprintf(fpasm, "cmp eax, ecx\n");

    fprintf(fpasm, "jle near menorigual_%d\n", etiqueta);

    fprintf(fpasm, "push dword 0\n");

    fprintf(fpasm, "jmp near fin_menorigual_%d\n", etiqueta);

    fprintf(fpasm, "menorigual_%d:\n", etiqueta);

    fprintf(fpasm, "push dword 1\n");

    fprintf(fpasm, "fin_menorigual_%d:\n", etiqueta);
}

void mayor_igual(FILE *fpasm, int es_variable1, int es_variable2, int etiqueta)
{
    obtener_operandos(fpasm, es_variable1, es_variable2);

    fprintf(fpasm, "cmp eax, ecx\n");

    fprintf(fpasm, "jge near mayorigual_%d\n", etiqueta);

    fprintf(fpasm, "push dword 0\n");

    fprintf(fpasm, "jmp near fin_mayorigual_%d\n", etiqueta);

    fprintf(fpasm, "mayorigual_%d:\n", etiqueta);

    fprintf(fpasm, "push dword 1\n");

    fprintf(fpasm, "fin_mayorigual_%d:\n", etiqueta);
}

void menor(FILE *fpasm, int es_variable1, int es_variable2, int etiqueta)
{
    obtener_operandos(fpasm, es_variable1, es_variable2);

    fprintf(fpasm, "cmp eax, ecx\n");

    fprintf(fpasm, "jl near menor_%d\n", etiqueta);

    fprintf(fpasm, "push dword 0\n");

    fprintf(fpasm, "jmp near fin_menor_%d\n", etiqueta);

    fprintf(fpasm, "menor_%d:\n", etiqueta);

    fprintf(fpasm, "push dword 1\n");

    fprintf(fpasm, "fin_menor_%d:\n", etiqueta);
}

void mayor(FILE *fpasm, int es_variable1, int es_variable2, int etiqueta)
{
    obtener_operandos(fpasm, es_variable1, es_variable2);

    fprintf(fpasm, "cmp eax, ecx\n");

    fprintf(fpasm, "jg near mayor_%d\n", etiqueta);

    fprintf(fpasm, "push dword 0\n");

    fprintf(fpasm, "jmp near fin_mayor_%d\n", etiqueta);

    fprintf(fpasm, "mayor_%d:\n", etiqueta);

    fprintf(fpasm, "push dword 1\n");

    fprintf(fpasm, "fin_mayor_%d:\n", etiqueta);
}

/* FUNCIONES DE ESCRITURA Y LECTURA */

void leer(FILE *fpasm, char *nombre, int tipo, int local)
{
    if (!local) {
      fprintf(fpasm, "push dword _%s\n", nombre);
    }

    if (tipo == ENTERO)
    {
        fprintf(fpasm, "call scan_int\n");
    }
    else if (tipo == BOOLEAN)
    {
        fprintf(fpasm, "call scan_boolean\n");
    }
    fprintf(fpasm, "add esp, 4\n");
}

void escribir(FILE *fpasm, int es_variable, int tipo)
{
    obtener_operando(fpasm, es_variable); /* WARNING: Puede que este mal */
    fprintf(fpasm, "push dword eax\n");
    if (tipo == ENTERO)
    {
        fprintf(fpasm, "call print_int\n");
    }
    else if (tipo == BOOLEAN)
    {
        fprintf(fpasm, "call print_boolean\n");
    }
    fprintf(fpasm, "add esp, 4\n");
    fprintf(fpasm, "call print_endofline\n");
}


/* FUNCIONES MANIPULACION DE VECTORES, FUNCIONES, BLUCLES Y ESTRUCTURAS CONDICIONALES */

/* MANIPULACION DE BUCLES Y ESTRUCTURAS CONDICIONALES */
void ifthenelse_inicio(FILE *fpasm, int exp_es_variable, int etiqueta)
{
    obtener_operando(fpasm, exp_es_variable);

    fprintf(fpasm, "cmp eax, 0\n");

    fprintf(fpasm, "je near fin_si_%d\n", etiqueta);
}

void ifthen_inicio(FILE *fpasm, int exp_es_variable, int etiqueta)
{
    obtener_operando(fpasm, exp_es_variable);

    fprintf(fpasm, "cmp eax, 0\n");

    fprintf(fpasm, "je near fin_si_%d\n", etiqueta);
}

void ifthen_fin(FILE *fpasm, int etiqueta)
{
    fprintf(fpasm, "fin_si_%d:\n", etiqueta);
}

void ifthenelse_fin_then(FILE *fpasm, int etiqueta)
{
    fprintf(fpasm, "jmp near fin_sino_%d\n", etiqueta);

    fprintf(fpasm, "fin_si_%d:\n", etiqueta);
}

void ifthenelse_fin(FILE *fpasm, int etiqueta)
{
    fprintf(fpasm, "fin_sino_%d:\n", etiqueta);
}

void while_inicio(FILE *fpasm, int etiqueta)
{
    fprintf(fpasm, "inicio_while_%d:\n", etiqueta);
}

void while_exp_pila(FILE *fpasm, int exp_es_variable, int etiqueta)
{
    obtener_operando(fpasm, exp_es_variable);

    fprintf(fpasm, "cmp eax, 0\n");

    fprintf(fpasm, "je near fin_while_%d\n", etiqueta);
}

void while_fin(FILE *fpasm, int etiqueta)
{
    fprintf(fpasm, "jmp near inicio_while_%d\n", etiqueta);
    fprintf(fpasm, "fin_while_%d:\n", etiqueta);
}


/* MANIPULACION DE VECTORES*/

void escribir_elemento_vector(FILE *fpasm, char *nombre_vector, int tam_max, int exp_es_direccion)
{
    obtener_operando(fpasm, exp_es_direccion);

    fprintf(fpasm, "cmp eax, 0\n");

    fprintf(fpasm, "jl near ior_err_handler\n");

    fprintf(fpasm, "cmp eax, %d\n", tam_max - 1);

    fprintf(fpasm, "jg near ior_err_handler\n");

    fprintf(fpasm, "mov dword edx, _%s\n", nombre_vector);

    fprintf(fpasm, "lea eax, [edx + eax*4]\n");

    fprintf(fpasm, "push dword eax\n");
}


/* MANIPULACION DE FUNCIONES */

void declararFuncion(FILE *fpasm, char *nombre_funcion, int num_var_loc)
{
    fprintf(fpasm, "_%s:\n", nombre_funcion);
    fprintf(fpasm, "push dword ebp\n");
    fprintf(fpasm, "mov dword ebp, esp\n");
    fprintf(fpasm, "sub esp, %d\n", 4 * num_var_loc);
}

void retornarFuncion(FILE *fpasm, int es_variable)
{
    obtener_operando(fpasm, es_variable);
    fprintf(fpasm, "mov dword esp, ebp\n");
    fprintf(fpasm, "pop dword ebp\n");
    fprintf(fpasm, "ret\n");
}

void escribirParametro(FILE *fpasm, int pos_parametro, int num_total_parametros)
{
    int posicion = 0;

    /* Calculo la posicion del parametro a poner en la cima de la pila */
    posicion = 4 * (1 + (num_total_parametros - pos_parametro));

    fprintf(fpasm, "lea eax, [ebp+ %d]\n", posicion);
    fprintf(fpasm, "push dword eax\n");
}

void escribirVariableLocal(FILE *fpasm, int posicion_variable_local)
{
    int posicion = 0;

    posicion = 4 * posicion_variable_local;

    fprintf(fpasm, "lea eax, [ebp - %d]\n", posicion);
    fprintf(fpasm, "push dword eax\n");
}

void asignarDestinoEnPila(FILE *fpasm, int es_varible)
{
    /* Primero obtengo la direccion */
    fprintf(fpasm, "pop dword edx\n");

    /* Ahora extraigo el valor */
    obtener_operando(fpasm, es_varible);

    fprintf(fpasm, "mov dword [edx], eax\n");
}

void operandoEnPilaAArgumento(FILE *fd_asm, int es_variable)
{
    if (es_variable)
    {
        fprintf(fd_asm, "pop dword eax\n");
        fprintf(fd_asm, "mov dword eax, [eax]\n");
        fprintf(fd_asm, "push dword eax\n");
    }
}

void llamarFuncion(FILE *fd_asm, char *nombre_funcion, int num_argumentos)
{
    fprintf(fd_asm, "call _%s\n", nombre_funcion);
    limpiarPila(fd_asm, num_argumentos);
    fprintf(fd_asm, "push dword eax\n");
}

void limpiarPila(FILE *fd_asm, int num_argumentos)
{
    fprintf(fd_asm, "add esp, %d\n", 4 * num_argumentos);
}
