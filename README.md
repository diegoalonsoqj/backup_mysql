# backup_mysql
 El script es una utilidad para respaldar bases de datos MySQL de forma automática. Realiza copias de seguridad, las comprime y guarda en un directorio específico. También registra las operaciones en un archivo de log. Además, elimina backups antiguos con más de 2 días de antigüedad para ahorrar espacio.

Este script es una utilidad para realizar copias de seguridad (backups) de bases de datos MySQL de forma automatizada. A continuación, se detallan los pasos y las funciones principales del script:

Configuración de parámetros:

Se definen varias variables para configurar la ruta de almacenamiento de los backups, las credenciales de acceso a MySQL y el host del servidor MySQL.
También se obtiene la fecha y hora actual usando el comando "date" y se almacena en la variable "current_datetime".
Creación de directorios:

Se crea el directorio de almacenamiento de backups especificado en la variable "backup_dir" utilizando el comando "mkdir -p". Este comando crea el directorio si no existe y no muestra errores si ya está creado.
De manera similar, se crea el directorio para guardar el archivo de log especificado en la variable "log_dir".
Función "log_message":

Se define una función llamada "log_message" para registrar mensajes en el archivo de log con fecha y hora. La función toma un argumento que representa el mensaje a registrar y utiliza el comando "echo" para agregar la fecha y hora actual al mensaje antes de escribirlo en el archivo de log.
Inicio del script:

Se registra en el archivo de log el mensaje "Inicio del script de backup de bases de datos MySQL" utilizando la función "log_message".
Obtención de la lista de bases de datos:

Se utiliza el comando "mysqlshow" para obtener la lista de bases de datos existentes en el servidor MySQL especificado por las variables "db_user", "db_password" y "db_host".
La salida del comando se filtra y procesa utilizando el comando "awk" y "grep" para obtener una lista limpia de nombres de bases de datos en la variable "database_list".
Verificación de bases de datos válidas:

Se verifica si se encontraron bases de datos válidas para respaldar. Si la variable "database_list" está vacía, se registra un mensaje de advertencia en el archivo de log y el script se detiene con un código de salida 1.
Iteración sobre las bases de datos:

La lista de bases de datos se convierte en un array llamado "databases".
Se define un array llamado "system_databases" que contiene los nombres de bases de datos propias del motor MySQL que se deben omitir en el respaldo.
Se itera sobre cada base de datos en el array "databases" y se verifica si el nombre de la base de datos no está vacío y no pertenece a las bases de datos del sistema.
Si la base de datos es válida, se procede a realizar el respaldo.
Respaldos de bases de datos:

Se define el nombre del archivo de backup utilizando el nombre de la base de datos y la fecha actual.
Se registra en el archivo de log el mensaje "Inicio del backup de la base de datos <nombre_de_la_base_de_datos>" utilizando la función "log_message".
Se utiliza el comando "mysqldump" para realizar el respaldo de la base de datos especificada en un archivo temporal.
El contenido del archivo temporal se comprime utilizando el comando "gzip" y se guarda en el archivo de backup definido.
Se verifica si el respaldo se completó correctamente mediante el código de salida del comando "mysqldump". Si es exitoso, se registran en el archivo de log mensajes indicando que el backup se ha completado y el tamaño del archivo de backup generado.
Advertencia para bases de datos del sistema:

Si la base de datos no es válida (es una base de datos del sistema o tiene un nombre vacío), se registra una advertencia en el archivo de log.
Eliminación de backups antiguos:

Se busca y borra los archivos de backups con 2 o más días de antigüedad en el directorio de backups.
Se registra en el archivo de log los archivos de backups que fueron borrados utilizando el comando "find" y "delete".
Finalización del script:

Se registra en el archivo de log el mensaje "Fin del script de backup de bases de datos MySQL" utilizando la función "log_message".