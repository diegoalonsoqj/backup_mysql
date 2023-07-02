#!/bin/bash

# Directorio de almacenamiento de backups
backup_dir="/backups/mysql"

# Nombre de usuario y contraseña de MySQL
db_user=""
db_password=""

# Host del servidor MySQL
db_host="localhost"

# Obtener la fecha y hora actual
current_datetime=$(date +"%Y%m%d_%H%M")

# Crear el directorio de backups si no existe
mkdir -p "$backup_dir"

# Directorio para guardar el archivo de log
log_dir="/var/log/scripts"
mkdir -p "$log_dir"

# Archivo de log
log_file="$log_dir/backup_mysql.log"

# Función para registrar mensajes en el archivo de log con fecha y hora
function log_message {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" >> "$log_file"
}

# Inicio del script
log_message "Inicio del script de backup de bases de datos MySQL."

# Obtener la lista de bases de datos existentes, excluyendo la base de datos de control "Databases"
database_list=$(mysqlshow -h "$db_host" -u "$db_user" -p"$db_password" | awk '{print $2}' | grep -v '^Database$\|^Databases$')

# Verificar si se encontraron bases de datos válidas
if [ -z "$database_list" ]; then
    log_message "No se encontraron bases de datos válidas para respaldar. Saliendo del script."
    exit 1
fi

# Convertir la lista de bases de datos en un array
readarray -t databases <<< "$database_list"

# Bases de datos propias del motor MySQL que se deben omitir en el respaldo
system_databases=("mysql" "sys" "performance_schema" "information_schema")

# Iterar a través de cada base de datos y realizar el respaldo
for db_name in "${databases[@]}"
do
    # Verificar si el nombre de la base de datos no está vacío y no es una base de datos del sistema
    if [ -n "$db_name" ] && ! [[ "${system_databases[*]}" =~ "$db_name" ]]; then
        # Nombre del archivo de backup
        backup_file="$backup_dir/${db_name}-PROD-${current_datetime}.gz"

        # Registro de hora de inicio del backup
        log_message "Inicio del backup de la base de datos $db_name."

        # Realizar el respaldo utilizando mysqldump y comprimir con gzip
        echo "Ejecutando comando mysqldump para respaldar la base de datos $db_name..."
        mysqldump -h "$db_host" -u "$db_user" -p"$db_password" "$db_name" | gzip > "$backup_file"

        # Verificar si el respaldo se completó correctamente
        if [ $? -eq 0 ]; then
            # Registro de hora de finalización del backup
            log_message "Backup de $db_name completado: $backup_file"

            # Obtener el peso del backup generado
            backup_size=$(du -h "$backup_file" | cut -f 1)
            log_message "Peso del backup: $backup_size"
        else
            log_message "ERROR: Fallo al respaldar $db_name"
        fi
    else
        # Registro de que se encontró una base de datos sin nombre o es una base de datos del sistema
        log_message "ADVERTENCIA: Se encontró una base de datos sin nombre o es una base de datos del sistema. No se realizará el respaldo."
    fi
done

# Borrar archivos con 2 o más días de antigüedad
log_message "Buscando y borrando archivos de backups con 2 o más días de antigüedad..."
find "$backup_dir" -type f -name "*.gz" -mtime +1 -print -delete >> "$log_file" 2>&1

# Finalización del script
log_message "Fin del script de backup de bases de datos MySQL."