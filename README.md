# Compilador ALFA

Repositorio para realizar el proyecto de autómatas y lenguajes. Este proyecto consiste
en realizar un compilador completo para el lenguaje alfa, cuya especificación se recoge
en la carpeta [ref](./ref) en el archivo [Gramática Alfa](./ref/GramaticaAlfa.pdf).

Además, la carpeta [ref](./ref) contiene los pdfs necesarios para la realización del
compilador así como la información necesaria aportada por los profesores para la implementación
del compilador.

## Autores

- Adrián Sebastián Gil
- Luis Miguel Nucifora
- Javier Mateos Najari

## Requerimientos

- [Bison](https://www.gnu.org/software/bison/)
- [Flex](https://github.com/westes/flex)
- [Make](https://www.gnu.org/software/make/)
- [GCC](https://www.gnu.org/software/gcc/)
- [Nasm](https://nasm.us/)
- lib32 (32-bit libraries for C)

## Contenido del repositorio

- bison : carpeta con los archivos de bison.
- flex : carpeta con los archivos de flex.
- include : archivos cabecera del proyecto.
- lib : librerías complementarias del proyecto.
- ref : archivos de referencia de teoría.
- src : archivos de código fuente del proyecto.
- test: archivos en lenguaje alfa y sus pruebas.
- compile.sh : script de compilación de los programas alfa.
- Makefile : archivo con las instrucciones de compilación del compilador.
- programa.json: archivo con un mapa conceptual de las reglas del compilador.
- index.png: imagen del mapa conceptual.

nota: para poder abrir y modificar el archivo _programa.json_ es necesario utilizar
la pagina web [Mindmap Make](https://app.mindmapmaker.org/#m:new).

## Instrucciones de compilación y pruebas

```sh
make # genera el ejecutable del compilador
make test # ejecuta todas las pruebas
```

Nota: hay dos archivos de prueba [error_ej1.alf](./test/src/error_ej1.alf) y
[error_ej2.alf](./test/src/error_ej2.alf) que en los test producen un error.
Esto se debe a que los errores son en tiempo de ejecución y no hay archivos
_output_ para los mismos. Para comprobar dichos errores se deben ejecutar
los binarios correspondientes a los mismos.
