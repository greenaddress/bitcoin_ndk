#! /bin/bash
set -e

url=$1
sha256_file=$2
toolchain=$3
target_host=$4

tarball="/bitcoin.tar.gz"

mkdir build
cd build
curl -sL -o $tarball $url
echo "${sha256_file}  ${tarball}" | shasum -a 256 --check
tar xzf $tarball
rm $tarball
src_dir=$(ls)
cd $src_dir
patch -p1 < /repo/0001-android-patches.patch


export PATH=/opt/$toolchain/bin:${PATH}
export AR=$target_host-ar
export AS=$target_host-clang
export CC=$target_host-clang
export CXX=$target_host-clang++
export LD=$target_host-ld
export STRIP=$target_host-strip
export LDFLAGS="-pie -static-libstdc++"

num_jobs=4
if [ -f /proc/cpuinfo ]; then
    num_jobs=$(grep ^processor /proc/cpuinfo | wc -l)
fi
cd depends
make HOST=$target_host NO_QT=1 -j $num_jobs

cd ..

./autogen.sh
./configure --prefix=$PWD/depends/$target_host ac_cv_c_bigendian=no --disable-bench --enable-experimental-asm --disable-tests --disable-man --without-utils --without-libs --with-daemon

make -j $num_jobs
make install

$STRIP depends/$target_host/bin/bitcoind

tar -zcf /${target_host}_${url##*/} -C depends/$target_host/bin bitcoind
