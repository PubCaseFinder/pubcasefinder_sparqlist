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


## 本番環境リリース手順


### 1. git pull
まずリポジトリから最新コードを取得
```
git pull
```

### 2. 本番環境と開発環境のコードの差異の有無チェック
本番環境 SPARQList コード (repository以下) について、開発環境のコードと差異がある場合にメッセージを出力する。  
SPARQL エンドポイントの URL だけが異なる場合には差異はないものとする。
```
sh bin/diff_with_dev.sh
```
差異がある場合にはファイルごとに以下のメッセージが表示される。
```
開発環境のコードとEndpoint以外の差異があります. 'pcf_get_omim_data_by_omim_id.md'.
次のコマンドで本番環境にコピーしてリリースできます。 sh bin/release_product_from_dev.sh pcf_get_omim_data_by_omim_id.md
```
どういった差異があるのか確認したい場合は 以下の次のコマンドで diff の結果を確認できる。  
`tmp/repository/***.md.diff`
```
cat tmp/repository/pcf_get_omim_data_by_omim_id.md.diff
```
本番環境にはあるが、開発環境に存在しないファイルがあれば次のようなメッセージが表示される。
```
開発環境にはない md ファイルです. 'test_pubtator3.md'
```

### 3. md ファイルを指定してリリース実行
リリースしたい md ファイルを指定して 開発環境のコードをコピーして本番環境にリリースできる。  
リリースの際に、開発用 SARQL エンドポイントは 本番環境用の置換される。  
修正前: https://dev-pubcasefinder.dbcls.jp/sparql  
修正後: https://pubcasefinder.dbcls.jp/sparql

```
sh bin/release_product_from_dev.sh pcf_get_omim_data_by_omim_id.md
```
正常にリリースできたら以下のメッセージが表示されるので、必要に応じて git に push する。  
複数のファイルをリリースしてから git commit&push してもいい。
```
ファイルが置換されました。次のコマンドで gitに反映して下さい
git add .
git commit -m'ここにコメントを入力'
git push origin main
```

### 4. 開発環境の SPARQL エンドポイントへのアクセスの有無チェック
本番環境で 開発環境の SPARQL エンドポイントにアクセスしているものがないかチェックする。  

```
sh bin/check_dev_endopoint.sh 
```
"/sparql" と "dev" と書かれている行があれば次のようなメッセージが表示される。
```
本番環境の SPARQList に開発環境用 Endpoint が書かれている可能性があります.
pcf_get_omim_data_by_omim_id.md, pcf_get_orpha_data_by_orpha_id.md,
```