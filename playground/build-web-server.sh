#!/bin/bash
##########################################
#                                        #
# Montagem de servidor web Apache httpd  #
#                                        #
#                                        #
##########################################
#Apagar todas imagens

echo "Apagar imagem"
docker system prune --all

#Baixar a imagem Docker

echo "Baixando imagem..."
docker pull nginx

#Executar imagem

echo "Executando imagem na porta 8080"
docker run nginx --p 80:8080