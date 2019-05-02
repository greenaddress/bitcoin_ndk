#! /bin/bash
set -e

DOCKERBUILDER=greenaddress/core_builder_for_android

REPO_CORE=https://github.com/bitcoin/bitcoin.git
COMMIT_CORE=2472733a24a9364e4c6233ccd04166a26a68cc65

DOCKERHASH=6603364284e4fe27f973e6d2e42b7eacf418baabf87b89638d46453772652d2e


REPO_ELEMENTS=https://github.com/elementsproject/elements.git
COMMIT_ELEMENTS=551483eae50ff2ee48ed17d6b22bb1a26284b635


docker pull $DOCKERBUILDER@sha256:$DOCKERHASH

TARGETHOST=armv7a-linux-androideabi
REPO=${REPO_CORE}_${COMMIT_CORE}


docker run -v $PWD:/repo $DOCKERBUILDER@sha256:$DOCKERHASH /bin/bash -c "/repo/fetchbuild.sh ${REPO/_/ } bitcoin bitcoin '' $TARGETHOST 32 " &

TARGETHOST=aarch64-linux-android
docker run -v $PWD:/repo $DOCKERBUILDER@sha256:$DOCKERHASH /bin/bash -c "/repo/fetchbuild.sh ${REPO/_/ } $TARGETHOST 64" &
TARGETHOST=x86_64-linux-android
docker run -v $PWD:/repo $DOCKERBUILDER@sha256:$DOCKERHASH /bin/bash -c "/repo/fetchbuild.sh ${REPO/_/ } $TARGETHOST 64" &
TARGETHOST=i686-linux-android
docker run -v $PWD:/repo $DOCKERBUILDER@sha256:$DOCKERHASH /bin/bash -c "/repo/fetchbuild.sh ${REPO/_/ } $TARGETHOST 32" &


REPO=${REPO_ELEMENTS}_${COMMIT_ELEMENTS}
TARGETHOST=armv7a-linux-androideabi
docker run -v $PWD:/repo $DOCKERBUILDER@sha256:$DOCKERHASH /bin/bash -c "/repo/fetchbuild.sh ${REPO/_/ } elements liquid '--enable-liquid' $TARGETHOST 32 " &
TARGETHOST=aarch64-linux-android
docker run -v $PWD:/repo $DOCKERBUILDER@sha256:$DOCKERHASH /bin/bash -c "/repo/fetchbuild.sh ${REPO/_/ } elements liquid '--enable-liquid' $TARGETHOST 64" &
TARGETHOST=x86_64-linux-android
docker run -v $PWD:/repo $DOCKERBUILDER@sha256:$DOCKERHASH /bin/bash -c "/repo/fetchbuild.sh ${REPO/_/ } elements liquid '--enable-liquid' $TARGETHOST 64" &
TARGETHOST=i686-linux-android
docker run -v $PWD:/repo $DOCKERBUILDER@sha256:$DOCKERHASH /bin/bash -c "/repo/fetchbuild.sh ${REPO/_/ } elements liquid '--enable-liquid' $TARGETHOST 32" &


wait

echo "DONE"

