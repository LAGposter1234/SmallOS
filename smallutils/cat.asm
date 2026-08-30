bits 16
org 0

cat_main:
    push cs
    pop ds

    mov si, buffer
    int 23h

    push si
    mov si, newline
    int 22h
    pop si

    int 22h
    mov si, newline
    int 22h
    int 21h

buffer times 128 db 0
newline db 0dh, 0ah, 0
