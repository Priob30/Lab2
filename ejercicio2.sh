#!/bin/bash

#Script para monitoreas procesos del CPU y memoria
if [ -z "$1" ]; then
	echo "Argumento invalido o inexistente"
	exit 1
fi

ejecutable=$1
datos="consumo.log"
grafico="grafico.gnuplot"

> $datos
echo "Ejecutando el proceso '$ejecutable'..."
$ejecutable & 
pid=$!

#Verificar que el proceso se haya ejecutado correctamente y exista un pid
if ! ps -p $pid > /dev/null 2>&1; then
    echo "Error: No se pudo obtener el PID del proceso '$ejecutable'."
    exit 1
fi

echo "T(s) CPU(%) Mem(KB)" >>$datos

tiempo_maximo=30
tiempo_inicial=$(date +%s)

#Verificar si el proceso con el PID esta en ejecucion
while kill -0 $pid 2>/dev/null; do
	tiempo_actual=$(date +%s)
	tiempo_transcurrido=$((tiempo_actual - tiempo_inicial))

	if [ "$tiempo_transcurrido" -ge "$tiempo_maximo" ]; then
		echo "TIempo maximo alcanzado, deteniendo monitoreo"
		kill $pid 2>/dev/null
		break
	fi

#Obtencion de datos del CPU y memoria del PID
cpu=$(ps -p $pid -o %cpu=)
memoria=$(ps -p $pid -o rss=)

#Verificar si las datos se obtuvieron bien o si alguna variable quedo vacia 
if [ -z "$cpu" ] || [ -z "$memoria" ]; then
	echo "Error no se pudieron obtener los datos del CPU y memoria correctamente"
	break
fi

echo "$tiempo_transcurrido $cpu $memoria" >> $datos

#Revisar datos cada 5 segundos 
sleep 5
done
echo "El proceso ha terminado"

#Generar graficos de datos obtenidos 
cat <<EOL > $grafico
set terminal png size 1000,800
set output 'grafico.png'
set multiplot layout 2,1 title 'Monitoreo de CPU y memoria'

#Grafico del uso del CPU
set title 'Uso del CPU (%)'
set xlabel 'Tiempo(s)'
set ylabel 'Uso de CPU(%)'
set grid
plot '$datos' using 1:2 with lines title 'Uso del CPU(%)'

#Grafico de uso de memoria
set title 'Uso de memoria (KB)'
set xlabel 'Tiempo(s)'
set ylabel 'Uso de memoria (KB)'
set grid
plot '$datos' using 1:3 with lines  title 'Uso de memoria(KB)'

unset multiplot
EOL

gnuplot $grafico
echo "El grafico se genero en 'grafico.png'"

#Imprimir resultados
cat consumo.log
xdg-open grafico.png

