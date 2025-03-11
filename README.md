### Obsidian backup  

Basicamente este es un shellscript que permite hacer una copia de respaldo de una boveda de obsidian  
en una memoria extraible USB. Tambien permite actualizar la boveda local con la informacion del USB.  
Este script es una pequeña muestra de los conocimientos en linux aprendidos tanto en la universidad  
en la catedra de Sistemas Operativos (SOP) como tambien los conocimientos aprendidos autodidactamente  
aplicados a un script que uso para hacer una copia de seguridad en un USB.  

El ejecutable obsback usa los datos almacenados en databackup el cual debe ser modificado con los siguientes campos  

obs path -> La direccion de donde se ejecuta obsidian, esto se puede observar con el comando ps pero generalmente se  
encuentra en /app/obsidian  
back id -> Aca va la id que identifica a la memoria extraible  
back name -> Este es el nombre de la memoria extraible  
local vault child -> Aca va la direccion de la carpeta local de la boveda de obsidian, la direccion debe incluir  
el nombre de la boveda  
back path child -> Y por ultimo aca va la direccion de la carpeta de la boveda pero en la memoria extraible, la  
direccion debe incluir el nombre de la boveda
