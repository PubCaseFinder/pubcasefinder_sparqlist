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

## Production environment release procedure

### 1. git pull
First, retrieve the latest code from the repository.
```
git pull
```

### 2. Check for differences between production and development environment code.

For the production environment SPARQList code (under `repository`), output a message if there are differences between the production environment code and the development environment code.
If only the SPARQL endpoint URL is different, it is considered that there are no differences.

```
sh bin/diff_with_dev.sh
```

If there are differences, the following message will be displayed for each file.
```
開発環境のコードとEndpoint以外の差異があります. 'pcf_get_omim_data_by_omim_id.md'.
次のコマンドで本番環境にコピーしてリリースできます。 sh bin/release_product_from_dev.sh pcf_get_omim_data_by_omim_id.md
```

If you want to check what the differences are, you can check the diff results with the following command.

`tmp/repository/***.md.diff`

```
cat tmp/repository/pcf_get_omim_data_by_omim_id.md.diff
```

If a file exists in the production environment but not in the development environment, the following message will be displayed:
```
開発環境にはない md ファイルです. 'test_pubtator3.md'
```

### 3. Release Execution with Specified MD Files  
Specify the MD files you wish to release. This copies the code from the development environment and releases it to the production environment.  
During release, the development SARQL endpoint is replaced with the production environment endpoint.  
Before: https://dev-pubcasefinder.dbcls.jp/sparql  
After: https://pubcasefinder.dbcls.jp/sparql

```
sh bin/release_product_from_dev.sh pcf_get_omim_data_by_omim_id.md
```
If the release succeeds, the following message will appear. Push to git as needed.  
You may release multiple files before performing a git commit & push.
```
ファイルが置換されました。次のコマンドで gitに反映して下さい
git add .
git commit -m'ここにコメントを入力'
git push origin main
```

### 4. Checking for Access to the Development Environment's SPARQL Endpoint
Check if there are any instances in the production environment accessing the development environment's SPARQL endpoint.

```
sh bin/check_dev_endopoint.sh
```

If there are lines containing "/sparql" and "dev", the following message will be displayed.

```
本番環境の SPARQList に開発環境用 Endpoint が書かれている可能性があります.
pcf_get_omim_data_by_omim_id.md, pcf_get_orpha_data_by_orpha_id.md,
```
