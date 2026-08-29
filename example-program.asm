bits 16
org 0

start:
    push cs
    pop ds

    mov si, msg
    int 22h
    int 21h

msg db "Hello, World!", 0dh, 0ah, 0
