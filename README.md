# Obsidian backup  

Basicamente este es un shellscript que permite hacer una copia de respaldo de una boveda de obsidian  
en una memoria extraible USB. Tambien permite actualizar la boveda local con la informacion del USB.  
Este script es una pequeña muestra de los conocimientos en linux aprendidos tanto en la universidad  
en la catedra de Sistemas Operativos (SOP) como tambien los conocimientos aprendidos autodidactamente  
aplicados a un script que uso para hacer una copia de seguridad en un USB.  

El ejecutable mm (magma manager) usa los datos almacenados en data backup, que tiene que estar en el mismo 
directorio, el cual debe ser modificado con los siguientes campos:  

* NO uses comillas dentro de las comillas si tus rutas tienen espacios.

### Ruta completa a tu bóveda local de Obsidian.
LOCAL_VAULT_PATH="/home/mi_usuario/mi_boveda"

### Ruta completa al directorio en tu USB donde se guardará el backup.
#### El script NO montará el USB, debe estar ya montado.
USB_BACKUP_PATH="/media/mi_usuario/mi_usb/mi_boveda"

### Nombre del proceso de Obsidian para poder cerrarlo.
#### Suele ser "obsidian".
OBSIDIAN_PROCESS_NAME="obsidian"

# --- Configuración de Google Drive (Opcional) ---

### Nombre del "remote" que configuraste en rclone para Google Drive.
#### Lo obtienes de `rclone listremotes`.
GDRIVE_REMOTE_NAME="gdrive"

### Ruta dentro de Google Drive donde quieres guardar el backup.
#### Rclone la creará si no existe.
GDRIVE_BACKUP_PATH="Backups/mi_boveda"
