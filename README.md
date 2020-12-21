# pautlen_1312_p10_compilador

Repositorio para realizar la practica 5 del proyecto de automatas y lenguajes, 
correspondiente al compilador completo.

# Notas de implementacion

Cuando se busca si un identificador ha sido declarado solo buscamos en la tabla
local por que las funciones no pueden emplear variables globales dentro
de su cuerpo. Si en algún momento esto fuera posible, habría que modificar
la busqueda de los simbolos en la tabla de simbolos teniendo en cuenta 
esta posibilidad.

# Recordatorios

- Mirar al final del todo si se han implementado todos los mensajes de error.
- Comprobar lo de las llamadas recursivas en funciones...........
