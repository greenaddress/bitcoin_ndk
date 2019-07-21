#! /bin/bash
set -xeo pipefail

DOCKERHASH=258aa533635783158aade5fa2ecabb773f986a505f76ff360e0edcaef8093bb4
DOCKERIMAGE=greenaddress/core_builder_for_android@sha256:$DOCKERHASH
docker pull $DOCKERIMAGE

ARCHS="armv7a-linux-androideabi=32 aarch64-linux-android=64 x86_64-linux-android=64 i686-linux-android=32"

build_repo() {
    for TARGETHOST in $ARCHS; do
        docker run -v $PWD:/repo $DOCKERIMAGE /bin/bash -c "/repo/fetchbuild.sh $1 $2 $3 $4 $5 ${TARGETHOST/=/ }" &
    done
}

build_repo https://github.com/bitcoin/bitcoin.git a6cba19831da9de6c5f968849d07c2a006557fe4 bitcoin bitcoin --disable-man
build_repo https://github.com/bitcoinknots/bitcoin.git 5e1c2d13f506e58513064ecbd914e00a944ee6a0 bitcoin bitcoin --disable-man
build_repo https://github.com/elementsproject/elements.git da7b8abda6f7cbe2ca1c8b7a038a969147e1c9cb elements liquid --enable-liquid

wait

echo "DONE"

printpackages() {
    echo
    for f in $(find . -type f -name "*$1.tar.xz" | sort)
    do
        shahash=$(sha256sum $f | cut -d" " -f1)
        filesize=$(ls -lat $f | cut -d" " -f5)
        arch=${f/.\//}
        arch=${arch/$1.tar.xz/}
        echo \"${filesize}${arch}${shahash}\",
    done
    echo
}

set +x
printpackages _bitcoin
printpackages _bitcoinknots
printpackages _liquid
