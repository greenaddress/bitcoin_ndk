#!/bin/bash
set -eo pipefail
export NDK_VERSION=android-ndk-r20b
export NDK_FILENAME=${NDK_VERSION}-linux-x86_64.zip

sha256_file=8381c440fe61fcbb01e209211ac01b519cd6adf51ab1c2281d5daad6ca4c8c8c

apt-get -yqq update &> /dev/null
apt-get -yqq upgrade &> /dev/null
apt-get -yqq install python python3-{pip,virtualenv} curl build-essential libtool autotools-dev automake pkg-config bsdmainutils unzip git gettext &> /dev/null

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
