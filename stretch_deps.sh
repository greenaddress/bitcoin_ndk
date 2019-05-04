#!/bin/bash
set -eo pipefail
export NDK_VERSION=android-ndk-r19c
export NDK_FILENAME=${NDK_VERSION}-linux-x86_64.zip

sha256_file=4c62514ec9c2309315fd84da6d52465651cdb68605058f231f1e480fcf2692e1

apt-get -yqq update &> /dev/null
apt-get -yqq upgrade &> /dev/null
apt-get -yqq install python curl build-essential libtool autotools-dev automake pkg-config bsdmainutils unzip git &> /dev/null

mkdir -p /opt

cd /opt && curl -sSO https://dl.google.com/android/repository/${NDK_FILENAME} &> /dev/null
echo "${sha256_file}  ${NDK_FILENAME}" | shasum -a 256 --check
unzip -qq ${NDK_FILENAME} &> /dev/null
rm ${NDK_FILENAME}

if [ -f /.dockerenv ]; then
    apt-get -yqq --purge autoremove unzip
    apt-get -yqq clean
    rm -rf /var/lib/apt/lists/* /var/cache/* /tmp/* /usr/share/locale/* /usr/share/man /usr/share/doc /lib/xtables/libip6*
fi
