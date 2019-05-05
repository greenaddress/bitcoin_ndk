#! /bin/bash
set -eo pipefail

repo=$1
commit=$2
reponame=$3
rename=$4
configextra=$5
target_host=$6
bits=$7


unpackdep() {
    curl -sL -o tmp.tar.gz $1
    echo "$2  tmp.tar.gz" | sha256sum --check
    tar xzf tmp.tar.gz
    rm tmp.tar.gz
}


export ANDROID_NDK_HOME=/opt/android-ndk-r19c
export PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:${PATH}
export AR=${target_host/v7a/}-ar
export AS=${target_host}21-clang
export CC=${target_host}21-clang
export CXX=${target_host}21-clang++
export LD=${target_host/v7a/}-ld
export STRIP=${target_host/v7a}-strip
export CFLAGS="-flto"
export LDFLAGS="$CFLAGS -pie -static-libstdc++ -fuse-ld=lld"

NDKARCH=arm
if [ "$target_host" = "i686-linux-android" ]; then
    NDKARCH=x86
elif [ "$target_host" = "x86_64-linux-android" ]; then
    NDKARCH=x86_64
elif [ "$target_host" = "aarch64-linux-android" ]; then
    NDKARCH=arm64
fi

NDKV=19
if [ "$bits" = "64" ]; then
    NDKV=21
fi

num_jobs=4
if [ -f /proc/cpuinfo ]; then
    num_jobs=$(grep ^processor /proc/cpuinfo | wc -l)
fi

# build core
git clone $repo ${reponame}
cd ${reponame}
git checkout $commit
patch -p1 < /repo/0001-android-patches.patch
(cd depends && make HOST=${target_host/v7a/} NO_QT=1 -j ${num_jobs})
./autogen.sh
./configure --prefix=$PWD/depends/${target_host/v7a/} ac_cv_c_bigendian=no ac_cv_sys_file_offset_bits=$bits --disable-bench --enable-experimental-asm --disable-tests --disable-man --without-utils --without-libs --with-daemon --disable-maintainer-mode --disable-glibc-back-compat ${configextra}
make -j ${num_jobs}
make install
$STRIP depends/${target_host/v7a/}/bin/${reponame}d
cd ..

# build tor deps
TORBUILDROOT=$PWD/tor_build_root
mkdir $TORBUILDROOT

# build libevent
unpackdep https://github.com/greenaddress/libevent/archive/release-2.1.8.1-stable-android-patch.tar.gz e2c2bbde3e49fbe5c2c30f825a11c4f0d71b12a1b9cf5ec4a093995f30977199
cd libevent-release-2.1.8.1-stable-android-patch
./autogen.sh
./configure --prefix=$TORBUILDROOT/libevent --enable-static --disable-samples \
            --disable-openssl --disable-shared --disable-libevent-regress --disable-debug-mode \
            --disable-dependency-tracking --host $target_host
make -o configure install -j${num_jobs}
cd ..

# build zlib
unpackdep https://github.com/madler/zlib/archive/v1.2.11.tar.gz 629380c90a77b964d896ed37163f5c3a34f6e6d897311f1df2a7016355c45eff
cd zlib-1.2.11

./configure --static --prefix=$TORBUILDROOT/zlib
make -o configure install -j${num_jobs}
cd ..


# build openssl
unpackdep https://github.com/openssl/openssl/archive/OpenSSL_1_1_1b.tar.gz d6418b0e1e39ef058b630e248bbb3b04241d6fad57bdb86db0b338c2374bda80

cd openssl-OpenSSL_1_1_1b
SSLOPT="no-gost no-shared no-dso no-ssl3 no-idea no-hw no-dtls no-dtls1 \
        no-weak-ssl-ciphers no-comp -fvisibility=hidden no-err no-psk no-srp"

if [ "$bits" = "64" ]; then
    SSLOPT="$SSLOPT enable-ec_nistp_64_gcc_128"
fi
./Configure android-$NDKARCH --prefix=$TORBUILDROOT/openssl $SSLOPT
make depend
make -j${num_jobs} 2> /dev/null
make install_sw
cd ..


# build tor
unpackdep https://github.com/torproject/tor/archive/tor-0.4.0.5.tar.gz f0c5bcb86e0552d00eb8f477f9a2d6c1e33be99ae0f4518f28db1e84dc4e1a20
cd tor-tor-0.4.0.5
./autogen.sh
TOROPT="--disable-system-torrc --disable-asciidoc --enable-static-tor --enable-static-openssl \
        --with-zlib-dir=$TORBUILDROOT/zlib --disable-systemd --disable-zstd \
        --enable-static-libevent --enable-static-zlib --disable-system-torrc \
        --with-openssl-dir=$TORBUILDROOT/openssl --disable-unittests \
        --with-libevent-dir=$TORBUILDROOT/libevent --disable-lzma \
        --disable-tool-name-check --disable-module-dirauth \
        --disable-largefile ac_cv_c_bigendian=no \
        --disable-rust"
./configure $TOROPT --prefix=$TORBUILDROOT/tor --host=$target_host --disable-android
make -o configure install -j${num_jobs}
$STRIP $TORBUILDROOT/tor/bin/tor
mv $TORBUILDROOT/tor/bin/tor ../${reponame}/depends/${target_host/v7a/}/bin
cd ..

# packaging
if [ "${reponame}" != "${rename}" ]; then
    mv ${reponame}/depends/${target_host/v7a/}/bin/${reponame}d ${reponame}/depends/${target_host/v7a/}/bin/${rename}d
    tar -Jcf /repo/${target_host/v7a/}_${rename}.tar.xz -C ${reponame}/depends/${target_host/v7a/}/bin ${rename}d tor
else
    tar -Jcf /repo/${target_host/v7a/}_$(basename $(dirname ${repo})).tar.xz -C ${reponame}/depends/${target_host/v7a/}/bin ${rename}d tor
fi
