#!/bin/sh

CROSS_TARGET=$1
CROSS_PREFIX=/opt/cross/${CROSS_TARGET}

../gcc-13.2.0/configure --target=${CROSS_TARGET} --prefix="${CROSS_PREFIX}" --disable-nls --enable-languages=c,c++ --without-headers
make all-gcc
make all-target-libgcc
make install-gcc
make install-target-libgcc
