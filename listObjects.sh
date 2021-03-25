#!/bin/bash
key_id="<s3_access_key>"
key_secret="<s3_secret_key>"
path="$1"
bucket="<bucket>"
content_type="application/octet-stream"
date="$(LC_ALL=C date -u +"%a, %d %b %Y %X %z")"
md5="$(openssl md5 -binary < "$file" | base64)"

sig="$(printf "GET\n$md5\n$content_type\n$date\n/$bucket/$path" | openssl sha1 -binary -hmac "$key_secret" | base64)"

curl -v https://$bucket.s3.portal-tio.unifique-hd.net/?list-type=2&prefix=$path \
    -H "Date: $date" \
    -H "Authorization: AWS $key_id:$sig" \
    -H "Content-Type: $content_type" \
    -H "Content-MD5: $md5"
