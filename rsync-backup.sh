#!/bin/bash

# Formato dos aquivo
date_format=$(date "+%d-%m-%Y-%H:%M:%S")

# Diretorio Onde sera enviado o arquivo de log
log_file="/var/log/rsync-backup.log"

#######################################
########      testes      #############
#######################################

# Verifica se existe o diretorio para armazenar os logs se nao existir sera criado!
if [ ! -d $log_file ]; then
    touch $log_file
    printf "[$date_format] arquivo de log checado e criado com sucesso!!\n" >> $log_file
fi

#######################################
######### executar script #############
#######################################

#precisa instalar sshpass e rsync
# apt update -y && apt install sshpass rsync -y

#comando para sincronizar diretorio de backup do proxmox com o diretorio remoto
sshpass -p 'senha-ssh' rsync -arzP -e 'ssh -p 88' /var/lib/vz/dump root@subdominio.duckdns.org:/medeia/usb/proxmox

echo "Script rsync para sincronizar direrotio de backup executado com sucesso em $date_format" >> $log_file

# Remove arquivos de logs antigos -05 dias!
find $log_file -type f -mtime +5 -exec rm -rf {} \;
