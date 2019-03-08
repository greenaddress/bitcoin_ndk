#! /bin/bash
set -e

repo=$1
commit=$2
target_host=$3
bits=$4

git clone $repo bitcoin
cd bitcoin
git checkout $commit

patch -p1 < /repo/0001-android-patches.patch

export PATH=/opt/android-ndk-r19c/toolchains/llvm/prebuilt/linux-x86_64/bin:${PATH}
export AR=${target_host/v7a/}-ar
export AS=${target_host}21-clang
export CC=${target_host}21-clang
export CXX=${target_host}21-clang++
export LD=${target_host/v7a/}-ld
export STRIP=${target_host/v7a}-strip
export LDFLAGS="-pie -static-libstdc++"

num_jobs=4
if [ -f /proc/cpuinfo ]; then
    num_jobs=$(grep ^processor /proc/cpuinfo | wc -l)
fi
cd depends
make HOST=${target_host/v7a/} NO_QT=1 -j $num_jobs

cd ..

./autogen.sh
./configure --prefix=$PWD/depends/${target_host/v7a/} ac_cv_c_bigendian=no ac_cv_sys_file_offset_bits=$bits --disable-bench --enable-experimental-asm --disable-tests --disable-man --without-utils --without-libs --with-daemon

make -j $num_jobs
make install

$STRIP depends/${target_host/v7a/}/bin/bitcoind

repo_name=$(basename $(dirname ${repo}))

tar -zcf /repo/${target_host/v7a/}_${repo_name}.tar.gz -C depends/${target_host/v7a/}/bin bitcoind
