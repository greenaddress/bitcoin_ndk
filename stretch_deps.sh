#!/bin/bash
set -e
export NDK_VERSION=android-ndk-r18b
export NDK_FILENAME=${NDK_VERSION}-linux-x86_64.zip

sha256_file=4f61cbe4bbf6406aa5ef2ae871def78010eed6271af72de83f8bd0b07a9fd3fd

apt-get -yqq update &> /dev/null
apt-get -yqq upgrade &> /dev/null
apt-get -yqq install python curl build-essential libtool autotools-dev automake pkg-config bsdmainutils unzip git &> /dev/null

mkdir -p /opt

cd /opt && curl -sSO https://dl.google.com/android/repository/${NDK_FILENAME} &> /dev/null
echo "${sha256_file}  ${NDK_FILENAME}" | shasum -a 256 --check
unzip -qq ${NDK_FILENAME} &> /dev/null
rm ${NDK_FILENAME}

/opt/${NDK_VERSION}/build/tools/make-standalone-toolchain.sh --use-llvm --stl=libc++ --platform=21 --toolchain=arm-linux-androideabi-clang --install-dir=/opt/arm-linux-androideabi-clang
/opt/${NDK_VERSION}/build/tools/make-standalone-toolchain.sh --use-llvm --stl=libc++ --platform=21 --toolchain=x86-clang --install-dir=/opt/x86-clang
/opt/${NDK_VERSION}/build/tools/make-standalone-toolchain.sh --use-llvm --stl=libc++ --platform=21 --toolchain=x86_64-clang --install-dir=/opt/x86_64-clang
/opt/${NDK_VERSION}/build/tools/make-standalone-toolchain.sh --use-llvm --stl=libc++ --platform=21 --toolchain=aarch64-linux-android-clang --install-dir=/opt/aarch64-linux-android-clang


if [ -f /.dockerenv ]; then
    apt-get -yqq --purge autoremove unzip
    apt-get -yqq clean
    rm -rf /var/lib/apt/lists/* /var/cache/* /tmp/* /usr/share/locale/* /usr/share/man /usr/share/doc /lib/xtables/libip6* /opt/${NDK_VERSION}
fi
