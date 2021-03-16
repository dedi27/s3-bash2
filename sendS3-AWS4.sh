#!/bin/sh

S3KEY="<access_key>"
S3SECRET="<secret_key>"

shName=$0
path=$1
file=$2
cameraUID=$3
bucket='<bucket>'
aws_path="/videos/p2p/$cameraUID/"
destiny="https://s3.portal-tio.unifique-hd.net$aws_path$file"
host=$bucket.s3.portal-tio.unifique-hd.net

date=$(date -u +"%Y%m%dT%H%M%SZ")
date2=$(date -u +"%Y%m%d")
acl='x-amz-acl:public-read'
content_type='application/octet-stream'
#content_type='video/mp4'
filesize=$(stat -c%s "$path/$file")

amz_date="X-Amz-Date: $date"
Algorithm="AWS4-HMAC-SHA256"
Algorithm2="AWS"
RequestDateTime="$date"
CredentialScope="$date2/us-east-1/execute-api/aws4_request"


HTTPRequestMethod="PUT"
CanonicalURI="$aws_path$file"
CanonicalHeaders="x-amz-date:$date\nhost:$host\n$acl\ncontent-type:$content_type\ncontent-length:$filesize\n"
CanonicalQueryString=""
SignedHeaders="x-amz-date;host;x-amz-acl;content-type;content-length\n"
RequestPayload="$HTTPRequestMethod\n$CanonicalURI\n$CanonicalQueryString\n$CanonicalHeaders\n$SignedHeaders"
#RequestPayload=""
HashedPayload=$(printf "$RequestPayload" | openssl dgst -hex -sha256 | sed 's/^.* //')
CanonicalRequest="$HTTPRequestMethod\n$CanonicalURI\n$CanonicalQueryString\n$CanonicalHeaders\n$SignedHeaders\n$HashedPayload"


HashedCanonicalRequest=$(printf "$CanonicalRequest" | openssl dgst -sha256 | sed 's/^.* //')
StringToSign="$Algorithm\n$RequestDateTime\n$CredentialScope\n$HashedCanonicalRequest" 
signature=$(printf "$StringToSign" | openssl dgst -hex -sha256 -hmac "${S3SECRET}" | sed 's/^.* //')

echo "**********"
echo -e "$CanonicalURI"
echo -e "$CanonicalHeaders"
echo -e "$SignedHeaders"
echo -e "$CanonicalRequest"
echo "**********"
echo -e "###\n$RequestPayload\n###"

#echo "curl -v -w  --cacert /etc/cacert.pem --connect-timeout 30 -m 180  -X PUT --data-binary \"\@$path/$file\" \\"
echo "curl -v -X PUT --data-binary \"\@$path/$file\" \\"
echo "-H \"Host: $host\" \\"
echo "-H \"Content-Type: $content_type\" \\"
echo "-H \"Content-Length: $filesize\" \\"
echo "-H \"$acl\" \\"
echo "-H \"$amz_date\" \\"

echo "-H \"Authorization: AWS4-HMAC-SHA256 Credential=$S3KEY/$CredentialScope, SignedHeaders=$SignedHeaders, Signature=$signature\" \\"
echo "$destiny"

printf "\n\n\n\n"


