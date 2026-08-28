bits 16
org 0

basic_main:
    cli

    mov ax, 2000h
    mov ds, ax
    mov ss, ax
    mov sp, 0FFFFh

    mov si, str_ready
    int 22h

.basic:
    call create
    mov si, newline
    int 22h
    mov si, are_you_sure
    int 22h
    call get_char

    cmp al, 'y'
    je program_buffer

    cmp al, 'n'
    je .basic

    jmp .basic

get_char:
    mov ah, 00h
    int 16h
    mov ah, 0Eh
    int 10h
    ret

create:
    mov di, program_buffer

.loop:
    call get_char

    cmp al, 03h; Ctrl C
    je .done

    cmp al, 0Dh ; Enter
    je .enter

    cmp al, ' ' ; Space
    je .loop

    mov [hex_buffer], al

    call get_char

    cmp al, 03h
    je .done

    cmp al, 0Dh
    je .loop

    mov [hex_buffer+1], al
    mov byte [hex_buffer+2], 0

    mov si, hex_buffer
    int 24h
    stosb

    jmp .loop

.enter:
    mov si, newline
    int 22h
    jmp .loop

.done:
    ret


hex_buffer:
    times 3 db 0

program_buffer:
    times 1024 db 0
newline:
    db 0Dh, 0Ah, 0

line_buffer:
    times 128 db 0

str_ready:
    db "READY.", 0dh, 0ah, 0

are_you_sure:
    db "Are you sure you want to run this? [y/N]", 0dh, 0ah, 0

times (16*512)-($-$$) db 0
