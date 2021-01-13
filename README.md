# Compilador ALFA

Repositorio para realizar la practica 5 del proyecto de autómatas y lenguajes, 
correspondiente al compilador completo.

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
