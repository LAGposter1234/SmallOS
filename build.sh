#!/bin/bash

nasm -f bin boot.asm -o boot.bin
nasm -f bin kernel.asm -o kernel.bin

cat boot.bin kernel.bin > smallos.img
