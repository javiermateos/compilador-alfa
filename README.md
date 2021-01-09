# Compilador ALFA

Repositorio para realizar la practica 5 del proyecto de autómatas y lenguajes, 
correspondiente al compilador completo.

# Contenido del repositorio

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

# Instrucciones de compilación y pruebas

```sh
make # genera el ejecutable del compilador
make test # ejecuta todas las pruebas
```
nota: alguno de los test muestran como diferencias lineas en blanco. Esto es
por que alguno de los outputs tienen al final del documento una linea de más.
