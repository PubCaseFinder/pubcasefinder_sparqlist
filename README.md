# pubcasefinder_sparqlist


## Prerequisites
* Docker
* Docker Compose

## Build docker image
Download a SPARQList modules source code.  
* NOTE: Not the source code of this repository.
* NOTE: Image build is required only once for a system.
```
$ cd /your/path/src/
$ git clone https://github.com/dbcls/sparqlist.git
```
Build a SPARQList Docker image from source code. The following command builds with the image name `dbcls/sparqlist`.
```
$ cd sparqlist
$ docker build -t dbcls/sparqlist .
```

## Download source code
Download source code from this repository
```
$ cd /your/path/src/
$ git clone https://github.com/PubCaseFinder/pubcasefinder_sparqlist.git
$ cd pubcasefinder_sparqlist
```

## Configuration environment
Create `.env` file and set values for your environment.
```
$ cp templete.env .env
```
### `CONTAINER_NAME`
(default: `pubcasefinder-sparqlist`)

The name of the docker container. Must be unique in the system.

### `IMAGE_NAME`
(default: `dbcls/sparqlist`)

The name of the docker image. Specify the name of the image built in the previous step.

### `REPOSITORY_PATH`

(default: `./repository`)

Path to SPARQLet repository.

### `PORT`
(default: `3000`)

Port to listen on. Must be unique in the system.

### `ADMIN_PASSWORD`
(default: sercret)

Admin password.

## Start server
```
$ docker compose up -d
### Check of startup status
$ docker compose ps
NAME                      SERVICE     STATUS    PORTS
pubcasefinder-sparqlist   sparqlist   running   0.0.0.0:3000->3000/tcp, :::3000->3000/tcp
```
If you are using a version prior to Docker Compose v2.0.0, use the `docker-compose` command instead of `docker compose`
```
$ docker-compose up -d
```

Check the SPARQList page can be displayed from a browser on the port number specified in the `.env` file. e.g. `http://localhost:3000`