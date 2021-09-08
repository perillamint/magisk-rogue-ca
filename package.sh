#!/bin/bash

rm -rfv magisk || true
mkdir -p magisk

cp -arv asset/* magisk
KEYID=$(openssl x509 -inform PEM -subject_hash_old -noout -in ./ca/ca-cert.pem)
cat << EOF > magisk/module.prop
id=roguecert-${KEYID}
name=Rogue Certificate: ${KEYID}
version=0.0.1
versionCode=000001
author=ALL YOUR BASE ARE BELONG TO US
description=TESTING PURPOSE ONLY - DO NOT LOAD THIS IN YOUR DAILY DRIVER
EOF

mkdir -p ./magisk/system/etc/security/cacerts
cp ./ca/ca-cert.pem "./magisk/system/etc/security/cacerts/${KEYID}.0"
pushd magisk
zip -r9 "../${KEYID}.zip" *
popd
