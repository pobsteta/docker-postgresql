Docker notes
============

Using a docker repository
-------------------------

Login to docker.io servers and push a named image to the server.

```sh
sudo docker.io login
sudo docker.io push pobsteta/docker-postgresql
```

Get the image from docker.io :

```sh
sudo docker.io pull pobsteta/docker-postgresql
```

Using a Trusted Build
---------------------

In order to automate things better and save download/upload time, it is better to setup Trusted builds on docker.io

The docker_io branch from this repository is a Trusted Build on docker.io.
Each commit to the docker_io branch will automatically trigger a build on docker.io and make a new version of the pobsteta/docker-postgresql image.

See more information on docker.io Trusted Build here : http://docs.docker.io/docker-io/builds/
