## Items de Primer Evaluación

Se describen los cambios hechos por cada item de la evaluación. Estos cambios están actualizados en una nueva versión del contrato. El original es v100 y el nuevo contrato es v101.

1) Hacer withdraw parcial
La función claimMyBid hace eso.
Ejecutada desde un usuario que hizo bids sin tener el bid ganador, le devuelve todos los fondos de cada bid que hizo.
Ejecutada desde el usuario que va ganando, le devuelve el resto de los fondos, exceptuando el monto del bid ganador.
No se hacen cambios

2) Usar short string y no long strings, sobre todo en los requires.
Los únicos strings que hay son en los requires.
Se ajusta un require a longitud <= 32 bytes, el resto ya eran <= a 32 bytes.

3) Los requires siempre lo más arriba posible
Los requires están en la primer línea o después del cálculo de la variable que se usa para el chequeo.
No encontré cambios para hacer.

4) No calcular longitudes dentro del for
Hice el cambio en el loop de claimMyBid() y refundAll()
También declaré la variable que uso en los loops para recorrer los bids afuera del loop y sólo hice la asignación adentro del loop. Cambio en las mismas dos funciones.

5) Nunca hacer más de una lectura y una escritura a una variable de estado en una funcion
No encontré casos. No hice cambios.

6) Documentacion del codigo. funciones=> que hacen, parametros y returnos.
Se agrega a las funciones el propósito, su signature, parámetros y lo que devuelven.
Se agrega documentación de estructuras y constantes.

7) Documentacion y codigo en ingles
Documentación y código ya en inglés. Lo modificado en los items de la evalaución se hacen en inglés.

9) 
