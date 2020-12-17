#!/bin/bash

##########################################
#                                        #
# Exibe informações sobre o sistema      #
#                                        #
##########################################

echo "Script iniciado..."

#Exibir o hostname do sitema
echo "Máquina: $(hostname)"

#Exibir a versão do kernel
echo "Versão do Kernel: $(uname -r)"

#Exibir informações sobre a máquina
echo "Informações sobre a máquina: $(uname -m)"

#Exibir dispositivos em blocos disponíveis
echo "Dispositivos em bloco disponíveis: 
$(lsblk)"

#Exibir espaço no sistema
df -h