#!/bin/sh

CROSS_PREFIX=/opt/cross/i686-elf
CROSS_TARGET=i686-elf

../binutils-2.41/configure --target=${CROSS_TARGET} --prefix="${CROSS_PREFIX}" --with-sysroot --disable-nls --disable-werror
make
make install
