#! /bin/bash
set -xeo pipefail

DOCKERHASH=06e3e394f41bd389a11ce51a2bb4ec46ff082e86d25f4f90644aad5b4faaf0f1
DOCKERIMAGE=greenaddress/core_builder_for_android@sha256:$DOCKERHASH
docker pull $DOCKERIMAGE

ARCHS="armv7a-linux-androideabi=32 aarch64-linux-android=64 x86_64-linux-android=64 i686-linux-android=32"

build_repo() {
    for TARGETHOST in $ARCHS; do
        docker run -v $PWD:/repo $DOCKERIMAGE /bin/bash -c "/repo/fetchbuild.sh $1 $2 $3 $4 $5 ${TARGETHOST/=/ }" &
    done
}

build_repo https://github.com/bitcoin/bitcoin.git 00ffe5aca134f424351b05a85da4eef9c3e4553a bitcoin bitcoin --disable-man
build_repo https://github.com/bitcoinknots/bitcoin.git f8d8a318e8ff7fb396b3102a532c790a7430ed81 bitcoin bitcoin --disable-man
build_repo https://github.com/elementsproject/elements.git c53a31363290a5470b039bf3548d0cadba1926e0 elements liquid --enable-liquid

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
