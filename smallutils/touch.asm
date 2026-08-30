bits 16
org 0

touch:
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

    mov si, filename_str
    int 22h

    mov si, filename_buffer
    int 23h

    push si
    mov si, newline
    int 22h
    pop si

    ; get output index

    mov si, fileindex_str
    int 22h

    mov si, fileindex_buf
    int 23h

    push si
    mov si, newline
    int 22h
    pop si

    ; htoi interrupt

    int 24h

    ;index is in ax
    mov si, filename_buffer
    ;filename in si
    mov di, buffer
    ;file contents in di
    int 2Ah ; write file interrupt

    int 21h

buffer times (1000 - 140) db 0
filename_buffer times 32 db 0
filename_str db "output file? ", 0
fileindex_str db "output index? ", 0
fileindex_buf times 16 db 0
newline db 0dh, 0ah, 0
