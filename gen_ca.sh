#!/bin/bash

HOSTNAME=$(hostname)

mkdir -p ca
openssl genrsa 2048 > ./ca/ca-key.pem
openssl req -new -x509 -nodes -sha256 -days 52560 \
   -subj "/C=HX/O=ALL YOUR BASE ARE BELONG TO US CA/CN=ROGUE CA - ${HOSTNAME}" \
   -addext basicConstraints=critical,CA:TRUE,pathlen:1 \
   -key ./ca/ca-key.pem \
   -out ./ca/ca-cert.pem
