#!/bin/bash

mkdir -p build/

nasm -f bin boot.asm -o boot.bin
nasm -f bin src/kernel.asm -I src/ -o kernel.bin

rm sfs/*

nasm -f bin example-program.asm -o sfs/hello
nasm -f bin smallutils/cat.asm -o sfs/cat
nasm -f bin smallutils/touch.asm -o sfs/touch

python mkfs.sfs.py sfs sfs.img

cat boot.bin kernel.bin sfs.img > smallos.img
