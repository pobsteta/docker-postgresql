Docker notes
============

Using a docker repository
-------------------------

Login to docker servers and push a named image to the server.

```sh
sudo docker login
sudo docker push pobsteta/docker-postgresql
```

Get the image from docker :

```sh
sudo docker pull pobsteta/docker-postgresql
```

Using a Trusted Build
---------------------

In order to automate things better and save download/upload time, it is better to setup Trusted builds on docker

The docker branch from this repository is a Trusted Build on docker.
Each commit to the docker branch will automatically trigger a build on docker and make a new version of the pobsteta/docker-postgresql image.

See more information on docker Trusted Build here : http://docs.docker.io/docker-io/builds/
