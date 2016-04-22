Docker notes
============

Utiliser le dépôt docker
------------------------

Se logguer au serveur docker et pousser l'image sur le serveur.

```sh
sudo docker login
sudo docker push pobsteta/docker-postgresql
```

Recevoir l'image du serveur docker :

```sh
sudo docker pull pobsteta/docker-postgresql
```

Utiliser Trusted Build
----------------------

Pour automatiser les builds successifs, renseigner sur le serveur docker Trusted Buils

Chaque commit réalisé sur le dépôt GitHub réalisera un build automatiquement sur le serveur Docker.
Cette nouvelle version sera tagguée pobsteta/docker-postgresql:latest

Pour plus d'informations sur Trusted Build : http://docs.docker.io/docker-io/builds/
