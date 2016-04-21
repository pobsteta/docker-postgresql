# PostgreSQL GIS SIME stack
#
# This image includes the following tools
# - PostgreSQL 9.5
# - PostGIS 2.2 with raster, topology and sfcgal support
# - OGR Foreign Data Wrapper
# - PgRouting
# - PDAL master
# - PostgreSQL PointCloud version master
# - Tryton 2.8
# - QGIS server
# - R 3.2
#
# Version 1.0

# Image de base ubuntu modifiée par phusion
FROM phusion/baseimage
MAINTAINER Pascal Obstetar, pascal.obstetar@bioecoforests.com

# On évite les messages debconf
ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

# Régénère les clefs SSH
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Utilise l'initialisation du système de l'image de base
CMD ["/sbin/my_init"]

# On ajoute la locale fr_FR
RUN locale-gen --no-purge fr_FR.UTF-8
ENV LC_ALL fr_FR.UTF-8
RUN update-locale LANG=fr_FR.UTF-8
RUN dpkg-reconfigure --frontend noninteractive locales

# On s'assure que les paquets sont à jour
RUN apt-get update
RUN apt-get -y install wget ca-certificates

# On ajoute le dépôt PostgreSQL
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main 9.5" > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# On ajoute le dépôt QGIS
#RUN echo "deb http://qgis.org/debian trusty main" > /etc/apt/sources.list.d/qgis.list
#RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key 3FF5FFCAD71472C4

# On ajoute le dépôt R
RUN echo "deb https://pbil.univ-lyon1.fr/CRAN/bin/linux/ubuntu trusty/" > /etc/apt/sources.list.d/rcran.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

# On met à jour
RUN apt-get -y update

# On installe les dépendances de PostgreSQL, Tryton, R et QGIS
# 1 - pour PostgreSQL, Postgis, pgrouting
RUN apt-get install -y autoconf build-essential cmake docbook-mathml docbook-xsl libboost-dev libboost-thread-dev libboost-filesystem-dev libboost-system-dev libboost-iostreams-dev libboost-program-options-dev libboost-timer-dev libcunit1-dev libgdal-dev libgeos++-dev libgeotiff-dev libgmp-dev libjson0-dev libjson-c-dev liblas-dev libmpfr-dev libopenscenegraph-dev libpq-dev libproj-dev libxml2-dev postgresql-server-dev-9.5 xsltproc git build-essential wget 

# application packages
RUN apt-get install -y postgresql-9.5

# On télécharge et compile CGAL
RUN wget https://gforge.inria.fr/frs/download.php/file/32994/CGAL-4.3.tar.gz &&\
    tar -xzf CGAL-4.3.tar.gz &&\
    cd CGAL-4.3 &&\
    mkdir build && cd build &&\
    cmake .. &&\
    make -j8 && make install

# On télécharge et compile SFCGAL
RUN git clone https://github.com/Oslandia/SFCGAL.git
RUN cd SFCGAL && cmake . && make -j8 && make install
# cleanup
RUN rm -Rf SFCGAL

# On télécharge et installe GEOS 3.5
RUN wget http://download.osgeo.org/geos/geos-3.5.0.tar.bz2 &&\
    tar -xjf geos-3.5.0.tar.bz2 &&\
    cd geos-3.5.0 &&\
    ./configure && make && make install &&\
    cd .. && rm -Rf geos-3.5.0 geos-3.5.0.tar.bz2

# On télécharge et compile PostGIS
RUN wget http://download.osgeo.org/postgis/source/postgis-2.2.0.tar.gz
RUN tar -xzf postgis-2.2.0.tar.gz
RUN cd postgis-2.2.0 && ./configure --with-sfcgal=/usr/local/bin/sfcgal-config --with-geos=/usr/local/bin/geos-config
RUN cd postgis-2.2.0 && make && make install
# cleanup
RUN rm -Rf postgis-2.2.0.tar.gz postgis-2.2.0

# On télécharge et compile pgrouting
RUN git clone https://github.com/pgRouting/pgrouting.git &&\
    cd pgrouting &&\
    mkdir build && cd build &&\
    cmake -DWITH_DOC=OFF -DWITH_DD=ON .. &&\
    make -j8 && make install
# cleanup
RUN rm -Rf pgrouting

# On télécharge et compile ogr_fdw
RUN git clone https://github.com/pramsey/pgsql-ogr-fdw.git &&\
    cd pgsql-ogr-fdw &&\
    make && make install &&\
    cd .. && rm -Rf pgsql-ogr-fdw

# On télécharge et compile PDAL
RUN git clone https://github.com/PDAL/PDAL.git pdal
RUN mkdir PDAL-build && \
    cd PDAL-build && \
    cmake ../pdal && \
    make -j8 && \
    make install
# cleanup
RUN rm -Rf pdal && rm -Rf PDAL-build

# On télécharge et compile PointCloud
RUN git clone https://github.com/pramsey/pointcloud.git
RUN cd pointcloud && ./autogen.sh && ./configure && make -j8 && make install
# cleanup
RUN rm -Rf pointcloud

# On rend les compilations visibles pour le système
RUN ldconfig

# On nettoie les paquets devenus inutiles

# paquets all -dev
RUN apt-get remove -y --purge autotools-dev libgeos-dev libgif-dev libgl1-mesa-dev libglu1-mesa-dev libgnutls-dev libgpg-error-dev libhdf4-alt-dev libhdf5-dev libicu-dev libidn11-dev libjasper-dev libjbig-dev libjpeg8-dev libjpeg-dev libjpeg-turbo8-dev libkrb5-dev libldap2-dev libltdl-dev liblzma-dev libmysqlclient-dev libnetcdf-dev libopenthreads-dev libp11-kit-dev libpng12-dev libpthread-stubs0-dev librtmp-dev libspatialite-dev libsqlite3-dev libssl-dev libstdc++-4.8-dev libtasn1-6-dev libtiff5-dev libwebp-dev libx11-dev libx11-xcb-dev libxau-dev libxcb1-dev libxcb-dri2-0-dev libxcb-dri3-dev libxcb-glx0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-shape0-dev libxcb-sync-dev libxcb-xfixes0-dev libxdamage-dev libxdmcp-dev libxerces-c-dev libxext-dev libxfixes-dev libxshmfence-dev libxxf86vm-dev linux-libc-dev manpages-dev mesa-common-dev libgcrypt11-dev unixodbc-dev uuid-dev x11proto-core-dev x11proto-damage-dev x11proto-dri2-dev x11proto-fixes-dev x11proto-gl-dev x11proto-input-dev x11proto-kb-dev x11proto-xext-dev x11proto-xf86vidmode-dev xtrans-dev zlib1g-dev

# paquets installés
RUN apt-get remove -y --purge autoconf build-essential cmake docbook-mathml docbook-xsl libboost-dev libboost-filesystem-dev libboost-timer-dev libcgal-dev libcunit1-dev libgdal-dev libgeos++-dev libgeotiff-dev libgmp-dev libjson0-dev libjson-c-dev liblas-dev libmpfr-dev libopenscenegraph-dev libpq-dev libproj-dev libxml2-dev postgresql-server-dev-9.5 xsltproc git build-essential wget 

# paquets de compilation
RUN apt-get remove -y --purge automake m4 make

# ---------- DEBUT --------------

# On initialise le script du serveur PostgreSQL
RUN mkdir /etc/service/postgresql
ADD postgresql.sh /etc/service/postgresql/run

# On initialise le script du serveur Trytond
#RUN mkdir /etc/service/tryton-server
#ADD tryton-server /etc/service/trytond/tryton-server

# On ajuste la configuration de PostgreSQL pour que les connexions soient possibles
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.5/main/pg_hba.conf

# On ajuste les adresses d'écoute et le port du serveur Postgres en 5432
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf

# Expose le port 5432 pour PostgreSQL
EXPOSE 5432

# On ajoute les VOLUMEs
VOLUME  ["/data", "/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Ajoute une base de données de base
ADD pgpass /root/.pgpass
RUN chmod 700 /root/.pgpass
RUN mkdir -p /etc/my_init.d
ADD init_db_script.sh /etc/my_init.d/init_db_script.sh
ADD init_db.sh /root/init_db.sh

# ---------- FIN --------------
#
# Nettoie les APT
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

