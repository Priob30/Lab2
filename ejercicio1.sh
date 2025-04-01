#!/bin/bash

# Verificar si el usuario es root
if [[ $EUID -ne 0 ]]; then
    echo "Error: el script debe ser ejecutado como root" >&2
    exit 1
fi

# Verificar que se reciban exactamente 3 parámetros
if [[ $# -ne 3 ]]; then
    echo "Uso: $0 <usuario> <grupo> <ruta_al_archivo>"
    exit 1
fi

usuario=$1
grupo=$2
archivo=$3

# Verificar que el archivo existe
if [[ ! -f "$archivo" ]]; then
    echo "Error: el archivo '$archivo' no existe"
    exit 1
fi

# Verificar si el grupo existe, si no, crearlo
if getent group "$grupo" > /dev/null; then
    echo "El grupo '$grupo' ya existe"
else
    echo "Creando grupo '$grupo'"
    groupadd "$grupo"
fi

# Verificar si el usuario existe, si no, crearlo
if id "$usuario" &>/dev/null; then
    echo "El usuario '$usuario' ya existe"
else
    echo "Creando usuario '$usuario'"
    useradd -m -g "$grupo" "$usuario"
fi

# Agregar el usuario al grupo (por si ya existía)
usermod -a -G "$grupo" "$usuario"

# Cambiar propiedad del archivo
chown "$usuario:$grupo" "$archivo"

# Modificar permisos
chmod u=rwx,g=r,o= "$archivo"

echo "Proceso completado con éxito."

