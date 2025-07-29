#!/bin/bash

## Configuracion inicial
# -e Hace que cuando algun comando falle, el script sale automaticamente

set -e

## Variables globales

CONFIG_FILE="data_backup.sh"

## Funcion de logger
# Redirige el error, con informacion util, al canal de error estandar osea el 2

error_logger() {
  local exit_code=$?
  echo "----Error de ejecucion---\nError en la linea $BASH_LINEO\nUltimo comando $BASH_COMMAND\nCodigo de salida:$exit_code\n-------------------------" >&2
}

## Funcion de carga de los datos de Configuracion
# Verifica que exista y carga el archivo de configuracion y valida que la variables esten completas
 

load_databackup(){
  local self_dir=`dirname $BASH_SOURCE[0]`
  SCRIPT_DIR=`cd $self_dir && pwd`

  if [[ ! -f "$SCRIPT_DIR/$CONFIG_FILE" ]]; 
  then
        echo "!>> Error: Archivo de configuración '$CONFIG_FILE' no encontrado en el directorio del script."
        echo "!>> Por favor, crea el archivo de configuración y vuelve a intentarlo."
        exit 1
  fi

  source "$SCRIPT_DIR/$CONFIG_FILE"

  if [[ -z "$LOCAL_VAULT_PATH" || -z "$USB_BACKUP_PATH" || -z "$OBSIDIAN_PROCESS_NAME" ]]; 
  then
        echo "!>> Error: Una o más variables esenciales (LOCAL_VAULT_PATH, USB_BACKUP_PATH, OBSIDIAN_PROCESS_NAME) no están definidas en '$CONFIG_FILE'."
        exit 1
  fi
}

## Funcion para verificar si estan instaladas las dependencias
# Verifica que rsync y rclone esten instlados y configurados, este ultimo es opcional asique no termina el programa.

check_dependencies() {

    if ! command -v rclone &> /dev/null; 
    then
        echo "?>> Advertencia: 'rclone' no está instalado. La opción de Google Drive no estará disponible."
        GDRIVE_ENABLED=false
    else
        # Este if verifica que se haya cargado la variable para el google drive y si se configuro algun remote 
        # en el rclone que conicida con el valor cargado en la varible
        if [[ -n "$GDRIVE_REMOTE_NAME" ]] && ! rclone listremotes | grep -q "^${GDRIVE_REMOTE_NAME}:"; 
        then
             echo "?>> Advertencia: El remote de rclone '$GDRIVE_REMOTE_NAME' no parece estar configurado."
             echo "?>> La opción de Google Drive podría fallar. Ejecuta 'rclone config' para configurarlo."
             GDRIVE_ENABLED=false
        else
             GDRIVE_ENABLED=true
        fi
    fi
}

## Funcion para cerrar los procesos de Obsidian
# Verifica si obsidian esta corriendo, si lo esta cierra todos los procesos relacionados a este

kill_obsidian() {
    echo ">>> Verificando si Obsidian está en ejecución..."
    # Si pgrep tira error lo rederige a null y ejecuta un true el cual nunca tiene error
    PIDS=`pgrep -f "$OBSIDIAN_PROCESS_NAME" 2> /dev/null || true` 

    if [[ -n "$PIDS" ]]; 
    then
        echo ">>> Obsidian está en ejecución. Cerrando el proceso..."
        kill -9 $PIDS
        sleep 5 
        echo ">>> Obsidian cerrado. Continuando..."
    else
        echo ">>> Obsidian no está en ejecución. Continuando..."
    fi
}

## Funcion para crear el backup de la boveda hacia el USB
# Comprueba que exista la carpeta para guardar en el USB, cierra obsidian, elimina la carpeta del USB y copia
# la local

make_local_backup() {
    echo ">>> Creando un backup de la boveda hacia el USB..."

    if [[ ! -d "$USB_BACKUP_PATH" ]];
    then
        echo "!>> Error: El directorio de destino en el USB no existe: $USB_BACKUP_PATH"
        echo "!>> Asegúrate de que el USB esté montado y la ruta sea correcta."
        return 1
    fi

    kill_obsidian

    echo ">>> Sincronizando archivos desde '$LOCAL_VAULT_PATH' hacia '$USB_BACKUP_PATH'..."
    rm -r $USB_BACKUP_PATH && mkdir $USB_BACKUP_PATH
    cp -r $LOCAL_VAULT_PATH $USB_BACKUP_PATH/..
    
    echo ">>> Backup local completado con éxito."
}


## Funcion para restaurar la Boveda local desde el USB
# Comprueba que exista la carpeta para restaurar en el USB, cierra obsidian, elimina la carpeta de la boveda 
# y copia la del USB

restore_from_local() {
    read -p ">>> ¿Estás SEGURO de que quieres restaurar la boveda desde el USB? Esto SOBRESCRIBIRÁ tu bóveda local. (s/N): " confirm
    if [[ ! "$confirm" =~ [sS]$ ]]; 
    then
        echo ">>> Restauración cancelada."
        return
    fi
    
    echo ">>> Iniciando restauración LOCAL desde el USB..."

    if [[ ! -d "$USB_BACKUP_PATH" ]];
    then
        echo "!>> Error: El directorio de destino en el USB no existe: $USB_BACKUP_PATH"
        echo "!>> Asegúrate de que el USB esté montado y la ruta sea correcta."
        return 1
    fi

    kill_obsidian

    echo ">>> Sincronizando archivos desde '$USB_BACKUP_PATH' hacia '$LOCAL_VAULT_PATH'..."
    rm -r $LOCAL_VAULT_PATH && mkdir $LOCAL_VAULT_PATH 
		cp -r $USB_BACKUP_PATH $LOCAL_VAULT_PATH/.. 

    echo ">>> Restauración local completada con éxito."
}

## Funcion para hacer el backup en google drive
# Si la opcion esta activada y las variables no estan vacias, cierra obsidian, y crea la copia con rclone

make_gdrive_backup() {
    if ! $GDRIVE_ENABLED; 
    then
        echo "!>> Error: La función de Google Drive no está disponible. Verifica la instalación y configuración de rclone."
        return 1
    fi

    if [[ -z "$GDRIVE_REMOTE_NAME" || -z "$GDRIVE_BACKUP_PATH" ]]; then
        echo "!>> Error: Las variables GDRIVE_REMOTE_NAME o GDRIVE_BACKUP_PATH no están definidas en el archivo de configuración."
        return 1
    fi

    echo ">>> Iniciando backup hacia Google Drive..."
    kill_obsidian

    echo ">>> Sincronizando archivos con rclone hacia '$GDRIVE_REMOTE_NAME:$GDRIVE_BACKUP_PATH'..."
    rclone sync "$LOCAL_VAULT_PATH" "$GDRIVE_REMOTE_NAME:$GDRIVE_BACKUP_PATH" -P

    echo ">>> Backup en Google Drive completado con éxito."
}

## Menu interactivo

main_menu() {
    while true; 
    do
        echo "========================================="
        echo "  GESTOR DE BACKUPS DE BÓVEDA OBSIDIAN"
        echo "========================================="
        echo "---"
        echo "--- Bóveda Local: $LOCAL_VAULT_PATH"
        echo "--- Backup USB:   $USB_BACKUP_PATH"
        if $GDRIVE_ENABLED && [[ -n "$GDRIVE_REMOTE_NAME" ]]; 
        then
            echo "--- Google Drive: ${GDRIVE_REMOTE_NAME}:${GDRIVE_BACKUP_PATH}"
        fi
        echo "---"
        echo "----------------OPCIONES----------------"
        echo "1. Crear backup en USB"
        echo "2. Restaurar desde backup en USB"
        echo "3. Crear/Actualizar backup en Google Drive"
        echo "S. Salir"
        echo "-----------------------------------------"
        read -p "<<< Elige una opción: " choice

        case $choice in
            1)
                make_local_backup
                ;;
            2)
                restore_from_local
                ;;
            3)
                make_gdrive_backup
                ;;
            s | S)
                echo ">>> Saliendo..."
                break
                ;;
            *)
                echo ">>> Opción no válida. Inténtalo de nuevo."
                ;;
        esac
        read -n 1 -s -p "<<< Presiona cualquier tecla para continuar..."
        clear
    done
}


clear

trap 'error_logger' ERR

load_databackup
check_dependencies

main_menu

exit 0
