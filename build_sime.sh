#!/bin/bash

# Stoppe les conteneurs
docker stop $(docker ps -a -q)
# Supprime les conteneurs
docker rm $(docker ps -a -q)
# Supprime les images
docker rmi $(docker images -q)
# Force la suppression des images de base
#docker rmi -f $(docker images -q)
# Construit l'image
docker build -t pobsteta/docker-postgresql:1.0 .
# Lance le container créé détaché (argument -d)
docker run -p 35432:5432 -p 38000:8000 pobsteta/docker-postgresql:1.0 /sbin/my_init
