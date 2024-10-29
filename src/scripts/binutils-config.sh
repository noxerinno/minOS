#!/bin/sh

CROSS_TARGET=$1
CROSS_PREFIX=/opt/cross/${CROSS_TARGET}

../binutils-2.41/configure --target=${CROSS_TARGET} --prefix="${CROSS_PREFIX}" --with-sysroot --disable-nls --disable-werror
make
make install
