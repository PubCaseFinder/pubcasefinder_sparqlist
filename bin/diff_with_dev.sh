#!/bin/bash

set -u

###
# 本番環境の repository のうち、開発環境の repository との差異を確認し、
# エンドポイントURL以外で差異があるファイルについて出力する
###

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

# 開発用 respository からのコピーファイルを保存する一時ディレクトリ
DEV_COPY_REPOSITORY_DIR=${SCRIPT_DIR}/../tmp/repository/

# 開発用 respository をコピーする
rm ${DEV_COPY_REPOSITORY_DIR}/*
scp -r ${DEV_REPOSITORY_DIR} ${SCRIPT_DIR}/../tmp/

echo "====="
echo "開発環境と本番環境の repository/*.md を比較します"

find "${PRODUCT_REPOSITORY_DIR}" -type f -name "*.md" | while read -r product_file; do
    filename=$(basename "$product_file")
    dev_file="${DEV_COPY_REPOSITORY_DIR}/$filename"

    # ファイルが比較ディレクトリに存在するかチェック
    if [ -f "${dev_file}" ]; then
        DIFF_FILE=${DEV_COPY_REPOSITORY_DIR}/$filename.diff
        diff -wb "$dev_file" "$product_file" > $DIFF_FILE
        # 実質変更行の"<"や">"で始まり、かつ sparql エンドポイントではない
        result=$(grep -E '^(<|>)' ${DIFF_FILE} | grep -v '/sparql')
        if [ -n "$result" ]; then
            echo "====="
            echo "開発環境のコードとEndpoint以外の差異があります. '$filename'."
            echo "次のコマンドで本番環境にコピー&リリースできます。 sh bin/release_product_from_dev.sh $filename"
        fi
    else
        echo "====="
        echo "開発環境にはない md ファイルです. '$filename'"
    fi
done
