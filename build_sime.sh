#!/bin/bash

# Stoppe les containers
docker stop $(docker ps -a -q)
# Supprime les containers
docker rm $(docker ps -a -q)
# Supprime les images
docker rmi $(docker images -q)
# Force la suppression des images de base
#docker rmi -f $(docker images -q)
# Construit l'image
docker build -t bioecoforests/sime:1.0 .
# Lance le container créé détaché (argument -d)
docker run -p 35432:5432 -p 38000:8000 bioecoforests/sime:1.0 /sbin/my_init
#docker run -d -p 35432:5432 -p 38000:8000 bioecoforests/sime:1.0 /sbin/my_init
