#!/bin/bash

set -u

###
# 指定した mdファイルを 開発環境の repository から取得し、
# エンドポイントURLを置換して本番環境に配置する。
###

if [ "$#" -eq 1 ] && [[ "$1" == *.md ]]; then
    UPDATE_FILE_NAME=$1
else
    echo "Error: 引数に .md ファイル名を指定する必要があります."
    echo "Usage: sh bin/deploy_dev_to_product.sh pcf_get_gene_by_mondo_id.md"
    exit 1
fi

# .envファイルを読み込む
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "[ERROR] .env ファイルが見つかりません。 .env ファイルがあるディレクトリでスクリプトを実行して下さい"
    exit 1
fi

# .envファイルに書かれている DEV_REPOSITORY_DIR の値を取得
if [ -z "${DEV_REPOSITORY_DIR+x}" ]; then
    source "[ERROR] .env に 'DEV_REPOSITORY_DIR' で開発版の repository の ディレクトリ指定して下さい"
    exit 1
fi

# このスクリプトからの相対パスで本番用の repository ディレクトリを取得
SCRIPT_DIR=$(readlink -f "$(dirname "$0")")
PRODUCT_REPOSITORY_DIR=${SCRIPT_DIR}/../repository

# 開発用と本番用で切り替える sparql エンドポイントのURL
DEV_ENDPOINT_URL="https://dev-pubcasefinder.dbcls.jp/sparql"
PRODUCT_ENDPOINT_URL="https://pubcasefinder.dbcls.jp/sparql"

# scp で開発用 md ファイルを取得して、 エンドポイントURLを置換する
PRODUCT_MD_FILE=${PRODUCT_REPOSITORY_DIR}/${UPDATE_FILE_NAME}
scp -r ${DEV_REPOSITORY_DIR}/${UPDATE_FILE_NAME} ${PRODUCT_REPOSITORY_DIR}/
perl -pi -e "s#${DEV_ENDPOINT_URL}#${PRODUCT_ENDPOINT_URL}#g" ${PRODUCT_MD_FILE}

echo "ファイルが置換されました。次のコマンドで gitに反映して下さい"
echo "git add ."
echo "git commit -m'ここにコメントを入力'"
echo "git push origin main"