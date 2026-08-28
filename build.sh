#!/bin/bash

mkdir -p build/

nasm -f bin boot.asm -o boot.bin
nasm -f bin src/kernel.asm -I src/ -o kernel.bin
nasm -f bin basic/main.asm -I basic/ -o basic.bin

cat boot.bin kernel.bin basic.bin > smallos.img
