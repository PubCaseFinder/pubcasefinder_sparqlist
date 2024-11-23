#!/bin/bash

set -u

###
# 本番環境の repository の中で、開発環境のエンドポイントを参照していそうなファイルをチェックしてアラートを出力(or slack送信)する
###

# .envファイルを読み込む
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "[ERROR] .env ファイルが見つかりません。 .env ファイルがあるディレクトリでスクリプトを実行して下さい"
    exit 1
fi

# *.mdファイルを find で検索
file_list=()
script_dir=$(readlink -f "$(dirname "$0")")
PRODUCT_REPOSITORY_DIR=$script_dir/../repository
# 一時ファイルにfindの結果を保存
tempfile=$(mktemp)
find "$PRODUCT_REPOSITORY_DIR" -type f -name "*.md" > "$tempfile"

while IFS= read -r source_file; do
    filename=$(basename "$source_file")
    # "/sparql"と"dev"を含む行を検索
    result=$(grep '/sparql' "$source_file" | grep 'dev')
    if [ -n "$result" ]; then
       file_list+=($filename)
    fi
done < "$tempfile"

# find用の一時ファイルを削除
rm "$tempfile"

# メッセージ出力
output=$(printf "%s, " "${file_list[@]}")
if [[ ${#file_list[@]} -gt 0 ]]; then
    message="本番環境の SPARQList に開発環境用 Endpoint が書かれている可能性があります."
    echo $message
    echo $output
    if [ -z "${WEBHOOK_URL+x}" ]; then
        echo "[WARNING] .env に 'WEBHOOK_URL' で slack への通知URIが記載されていません"
    else
        payload="{
          \"text\": \"$message $output\"
        }"
        echo $payload
        curl -X POST -H 'Content-type: application/json' --data "$payload" "$WEBHOOK_URL"
    fi
else
    echo "開発環境用Endpointは見つかりませんでした."
fi
