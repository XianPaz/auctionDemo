## Items de Primer Evaluación

Se describen los cambios hechos por cada item de la evaluación. Estos cambios están actualizados en una nueva versión del contrato. El original es v100 y el nuevo contrato es v101.

1) Hacer withdraw parcial <br/>
La función claimMyBid hace eso. <br/>
Ejecutada desde un usuario que hizo bids sin tener el bid ganador, le devuelve todos los fondos de cada bid que hizo. <br/>
Ejecutada desde el usuario que va ganando, le devuelve el resto de los fondos, exceptuando el monto del bid ganador. <br/>
No se hacen cambios. <br/>

2) Usar short string y no long strings, sobre todo en los requires <br/>
Los únicos strings que hay son en los requires. <br/>
Se ajusta un require a longitud <= 32 bytes, el resto ya eran <= a 32 bytes. <br/>

3) Los requires siempre lo más arriba posible <br/>
Los requires están en la primer línea o después del cálculo de la variable que se usa para el chequeo. <br/>
No encontré cambios para hacer. <br/>

4) No calcular longitudes dentro del for <br/>
Hice el cambio en el loop de claimMyBid() y refundAll(). <br/>

5) Nunca hacer más de una lectura y una escritura a una variable de estado en una funcion <br/>
No encontré casos. No hice cambios. <br/>

6) Documentacion del codigo. funciones=> que hacen, parametros y returnos <br/>
Se agrega a las funciones el propósito, su signature, parámetros y lo que devuelven. <br/>
Se agrega documentación de estructuras y constantes. <br/>

7) Documentacion y codigo en ingles <br/>
Documentación y código ya estaba en inglés. Lo modificado en los items de la evaluación se hacen en inglés. <br/>

9) Funcion de recuperacion de eth de emergencia <br/>
La función withdraw() permitía sacar todo el balance luego de finalizado el auction. Quedó modificada para que pueda ejecutarse en cualquier momento. <br/>

10) Usar variables sucias en vez de variables limpias (declararlas fuera del bucles) <br/>
En las funciones claimMyBid() y refundAll() declaré la variable que uso en los loops para recorrer los bids afuera del loop y sólo hice la asignación adentro del loop. <br/>
