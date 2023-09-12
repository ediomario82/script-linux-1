#!/bin/bash

# Formato dos aquivo
date_format=$(date "+%d-%m-%Y-%H:%M:%S")

# Onde sera enviado arquivo de log
log_file="/var/log/rotina-update.log"

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

#######################################
######### executar script #############
#######################################

apt update && apt upgrade -yy 
sleep 3s
apt autoremove -y
apt auto-clean -y
sleep 5s

echo "Script de atualização executado com sucesso em $date_format" >> $log_file

# Remove arquivos de logs antigos -10 dias!
find $log_file -type f -mtime +10 -exec rm -rf {} \;
