#!/bin/bash

# Diretorio que sera feito o Backup
backup_path="~/docker"

# Diretorio onde sera enviado o backup
dir_backup="/media/usb/backup"

# Formato dos aquivo
date_format=$(date "+%d-%m-%Y")
final_archive="backup-$date_format.tar.gz"

# Onde sera enviado arquivo de log
log_file="/var/log/rotina-backup.log"

############################################
                #testes#
###########################################

# Verifica se existe o diretorio para armazenar os logs
if [ ! -d $log_file ]; then
    touch $log_file
    printf "[$date_format] arquivo de log checado e criado com sucesso!!" >> $log_file
fi

##########################################
          # Inicio do backup#
# #######################################

echo "Backup do diretorio raiz Iniciado em $date_format \n" >> $log_file

if tar -czSpf "$dir_backup/$final_archive" "$backup_path"; then
        printf "[$date_format] BACKUP REALIZADO COM SUCESSO!!!\n" >> $log_file
fi

DATA_FINAL=`date +%d/%m/%Y-%H:%M:%S`
echo "Backup do diretorio Finalizado em $DATA_FINAL" >> $log_file

# Remove arquivos de backups antigos - 10 dias
find $dir_backup -type f -mtime +10 -exec rm -rf {} \;
