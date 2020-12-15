#!/bin/bash
##########################################
#                                        #
# Montagem de servidor web Apache httpd  #
#                                        #
#                                        #
##########################################
#Apagar se existir

echo "Apagar imagem"
docker system prune -y --all

#Baixar a imagem Docker

echo "Baixando imagem..."
docker pull nginx

#Executar imagem

echo "Executando imagem na porta 8080"
docker run nginx --p 80:8080