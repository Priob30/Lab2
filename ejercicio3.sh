#!/bin/bash

# Directorio para monitorear
directorio="/home/priscilla/Documents"
datos="/home/priscilla/monitoreo_log.txt"

# Revisar que el archivo log exista
touch "$datos"

# Monitorear con inotifywait
inotifywait -m -r -e create -e modify -e delete \
    --format '%T %w %f %e' --timefmt '%Y-%m-%d %H:%M:%S' "$directorio" | \
while read Fecha Hora directorio archivo Evento; do
    log="$Fecha $Hora - $Evento en $directorio$archivo"
    echo "$log"
    echo "$log" >> "$datos"
done


