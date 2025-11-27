#!/bin/sh

touch debug.txt
echo "Makefile :\n" > debug.txt
cat Makefile >> debug.txt
echo "\n\nbootloader.asm :\n" >> debug.txt
cat ./src/bootloader.asm >> debug.txt
echo "\n\nkernel.c :\n" >> debug.txt
cat ./src/kernel.c >> debug.txt
echo "\n\nlinker.ld :\n" >> debug.txt
cat ./src/linker.ld >> debug.txt
