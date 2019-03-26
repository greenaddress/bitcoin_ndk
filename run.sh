#! /bin/bash
set -e

DOCKERBUILDER=greenaddress/core_builder_for_android

REPO_CORE=https://github.com/bitcoin/bitcoin.git

DOCKERHASH=6603364284e4fe27f973e6d2e42b7eacf418baabf87b89638d46453772652d2e
COMMIT_CORE=2472733a24a9364e4c6233ccd04166a26a68cc65

repos="${REPO_CORE}_${COMMIT_CORE}"
for repo in ${repos}; do
  TARGETHOST=armv7a-linux-androideabi
  docker run -v $PWD:/repo $DOCKERBUILDER@sha256:$DOCKERHASH /bin/bash -c "/repo/fetchbuild.sh ${repo/_/ } $TARGETHOST 32" &
  TARGETHOST=aarch64-linux-android
  docker run -v $PWD:/repo $DOCKERBUILDER@sha256:$DOCKERHASH /bin/bash -c "/repo/fetchbuild.sh ${repo/_/ } $TARGETHOST 64" &
  TARGETHOST=x86_64-linux-android
  docker run -v $PWD:/repo $DOCKERBUILDER@sha256:$DOCKERHASH /bin/bash -c "/repo/fetchbuild.sh ${repo/_/ } $TARGETHOST 64" &
  TARGETHOST=i686-linux-android
  docker run -v $PWD:/repo $DOCKERBUILDER@sha256:$DOCKERHASH /bin/bash -c "/repo/fetchbuild.sh ${repo/_/ } $TARGETHOST 32" &
done


wait

echo "DONE"

