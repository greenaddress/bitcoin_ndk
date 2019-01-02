#! /bin/bash
set -e

DOCKERBUILDER=greenaddress/core_builder_for_android

REPO_CORE=https://github.com/bitcoin/bitcoin.git

DOCKERHASH=8be296601b9f2dbb2b0572c96ad8815f16ce52b814b1724023e762be2ab7ef89
COMMIT_CORE=ef70f9b52b851c7997a9f1a0834714e3eebc1fd8

REPO_KNOTS=https://github.com/bitcoinknots/bitcoin.git

COMMIT_KNOTS=ab05daa871db7c5772e6477c0bdddaa6f3808afd

repos="${REPO_CORE}_${COMMIT_CORE} ${REPO_KNOTS}_${COMMIT_KNOTS}"
for repo in ${repos}; do
  TOOLCHAIN=arm-linux-androideabi-clang
  TARGETHOST=arm-linux-androideabi
  docker run -v $PWD:/repo $DOCKERBUILDER@sha256:$DOCKERHASH /bin/bash -c "/repo/fetchbuild.sh ${repo/_/ } $TOOLCHAIN $TARGETHOST 32" &
  TOOLCHAIN=aarch64-linux-android-clang
  TARGETHOST=aarch64-linux-android
  docker run -v $PWD:/repo $DOCKERBUILDER@sha256:$DOCKERHASH /bin/bash -c "/repo/fetchbuild.sh ${repo/_/ } $TOOLCHAIN $TARGETHOST 64" &
  TOOLCHAIN=x86_64-clang
  TARGETHOST=x86_64-linux-android
  docker run -v $PWD:/repo $DOCKERBUILDER@sha256:$DOCKERHASH /bin/bash -c "/repo/fetchbuild.sh ${repo/_/ } $TOOLCHAIN $TARGETHOST 64" &
  TOOLCHAIN=x86-clang
  TARGETHOST=i686-linux-android
  docker run -v $PWD:/repo $DOCKERBUILDER@sha256:$DOCKERHASH /bin/bash -c "/repo/fetchbuild.sh ${repo/_/ } $TOOLCHAIN $TARGETHOST 32" &
done


wait

echo "DONE"

