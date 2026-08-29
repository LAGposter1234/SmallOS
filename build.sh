#!/bin/bash

mkdir -p build/

nasm -f bin boot.asm -o boot.bin
nasm -f bin src/kernel.asm -I src/ -o kernel.bin

nasm -f bin example-program.asm -o sfs/hello

python mkfs.sfs.py sfs sfs.img

cat boot.bin kernel.bin sfs.img > smallos.img
