#!/bin/sh

CROSS_PREFIX=/opt/cross/i686-elf
CROSS_TARGET=i686-elf

../gcc-13.2.0/configure --target=${CROSS_TARGET} --prefix="${CROSS_PREFIX}" --disable-nls --enable-languages=c,c++ --without-headers
make all-gcc
make all-target-libgcc
make install-gcc
make install-target-libgcc
