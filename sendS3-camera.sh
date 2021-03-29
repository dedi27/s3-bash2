#!/bin/bash
file="$1"
key_id="<s3_access_key>"
key_secret="<s3_secret_key>"
path="$file"
bucket="<bucket>"
content_type="application/octet-stream"
date="$(LC_ALL=C date -u +"%a, %d %b %Y %X %z")"
md5="$(openssl md5 -binary < "$file" | base64)"

sig="$(printf "PUT\n$md5\n$content_type\n$date\n/$bucket/$path/$file" | openssl sha1 -binary -hmac "$key_secret" | base64)"

retorno=$(curl -s -i -w "%{http_code}\n" -T $file "https://$bucket.s3.portal-tio.unifique-hd.net/$path/$file" \
        -H "Date: $date" \
        -H "Authorization: AWS $key_id:$sig" \
        -H "Content-Type: $content_type" \
        -H "Content-MD5: $md5" \
        -o /dev/null)
echo "$retorno"
echo "Call function https://unifaas.unifique.com.br/function/certinfo"
echo "curl -d \"$bucket.s3.portal-tio.unifique-hd.net\" -X POST https://unifaas.unifique.com.br/function/certinfo"
echo ""
if [ $retorno -eq 200 ]; then
        curl -d "$bucket.s3.portal-tio.unifique-hd.net" -X POST https://unifaas.unifique.com.br/function/certinfo
fi
exit 0