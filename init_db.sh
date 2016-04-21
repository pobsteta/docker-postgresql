#!/bin/bash

set -e

SIME_DB=${SIME_DB:-"sime"}

# Attendre que le serveur PostgreSQL soit lancé
echo "Attente du lancement de PostgreSQL..."
sleep 1
while ! /usr/bin/pg_isready -q
do
    sleep 1
    echo -n "."
done

# Le serveur PostgreSQL est lancé
echo "Le serveur PostgreSQL est lancé, initialisation de la base de données."

# Utilisateur PostgreSQL
#
# Création de l'utilisateur postgres

/sbin/setuser postgres /usr/bin/psql -c "CREATE USER $SIME_DB with SUPERUSER PASSWORD '$SIME_DB';"

# == Création de la base de données ==
echo "Création de la base de données $SIME_DB..."
			
# Création de la base de données propriétaire du nouvel utilisateur
/usr/bin/psql -U $SIME_DB -h localhost -c "CREATE DATABASE $SIME_DB WITH OWNER=$SIME_DB ENCODING='UTF8' TEMPLATE=template0 CONNECTION LIMIT=-1;" postgres

# Activation des extensions pour la nouvelle base de données créées
echo "Ajout des extensions (postgis, postgis_topology, postgis_sfcgal, pgrounting, pointcloud) à la base de données $SIME_DB..."
/usr/bin/psql -U $SIME_DB -h localhost -w -c "CREATE EXTENSION postgis; CREATE EXTENSION postgis_topology; CREATE EXTENSION postgis_sfcgal; CREATE EXTENSION pgrouting; CREATE EXTENSION pointcloud; CREATE EXTENSION pointcloud_postgis; drop type if exists texture;
create type texture as (url text,uv float[][]);" $SIME_DB
/usr/bin/psql -U $SIME_DB -h localhost -w -d $SIME_DB -f /usr/share/postgresql/9.5/contrib/postgis-2.2/legacy.sql

echo "Base de données $SIME_DB initialisée. Connexion depuis localhost possible."
echo "Utiliser la commande : psql -h localhost -p 35432 -U $SIME_DB -W $SIME_DB"
echo "Obtenez le <PORT:35432> avec la commande 'docker ps'"
