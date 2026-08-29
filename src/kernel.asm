bits 16
org 0

kernel_start:
    cli

    mov ax, 1000h
    mov ds, ax
    mov ss, ax
    mov sp, 0FFFFh

    ; get boot drive

    push ds
    xor ax, ax
    mov ds, ax
    mov dl, [8000h]
    pop ds

    ; dont modify dl after this

    ; register interrupts

    mov ax, 21h
    mov bx, 1000h
    mov cx, exit_handler
    call register_interrupt

    mov ax, 22h
    mov bx, 1000h
    mov cx, print_handler
    call register_interrupt

    mov ax, 23h
    mov bx, 1000h
    mov cx, get_line_handler
    call register_interrupt

    mov ax, 24h
    mov bx, 1000h
    mov cx, htoi_handler
    call register_interrupt

    mov ax, 25h
    mov bx, 1000h
    mov cx, itoh_handler
    call register_interrupt

    mov ax, 26h
    mov bx, 1000h
    mov cx, read_sectors
    call register_interrupt

    ; load basic

    mov ax, 2000h
    mov es, ax
    mov ax, 17
    mov bx, 0
    mov cx, 16
    call read_sectors

    .os:

    mov si, shell_prefix
    call print_msg

.getline:
    mov si, line_buffer
    call get_line

    push si
    mov si, newline
    call print_msg
    pop si

    call handle_command

    jmp .os

exit_handler:
    mov ax, 1000h
    mov ds, ax
    jmp kernel_start.os

print_handler:
    call print_msg
    iret

get_line_handler:
    call get_line
    iret

read_sectors_handler:
    call read_sectors
    iret

htoi_handler:
    call htoi
    iret
itoh_handler:
    call itoh
    iret

%include "keyboard.asm"
%include "interrupt.asm"
%include "command.asm"
%include "disk.asm"
%include "filesys.asm"

; arg1 - si (this routine is copied from boot.asm)
print_msg:
.start:
    mov al, [si]
    cmp al, 0
    je .done
    ; it is not 0
    ; print the character in al
    mov ah, 0x0e
    int 0x10
    inc si
    jmp .start
.done:
    ret

    ;; THIS IS SEPERATE FUNCTION ABABABDHHFIOWJEF SPLITTER THINGY NOTICE ME
htoi:
    xor bx, bx

.loop:
    lodsb
    test al, al
    jz .done

    cmp al, '0'
    jb .done
    cmp al, '9'
    jbe .number

    and al, 0DFh
    sub al, 'A' - 10
    jmp .add

.number:
    sub al, '0'

.add:
    xor ah, ah
    mov dx, ax

    shl bx, 1
    shl bx, 1
    shl bx, 1
    shl bx, 1

    add bx, dx
    jmp .loop

.done:
    mov ax, bx
    ret

    ; NOTICE AGIAN NEW FUNCTION NOTICE ME AAAAAAAAAAAAAAA

; ax = value
; si = output buffer
; output = 4 hex characters + 0

itoh:
    mov bx, ax
    mov cx, 4

.loop:
    rol bx, 1
    rol bx, 1
    rol bx, 1
    rol bx, 1
    mov al, bl
    and al, 0Fh

    cmp al, 9
    jbe .digit
    add al, 'A' - 10
    jmp .store

.digit:
    add al, '0'

.store:
    mov [si], al
    inc si
    loop .loop

    mov byte [si], 0
    ret

kernel_boot_msg:
    db "SmallOS Kernel Booted!", 0Dh, 0Ah, 0

kernel_version:
    db "SmallOS 0.04", 0Dh, 0Ah, 0

shell_prefix:
    db "SmallSH> ", 0

line_buffer:
    times 128 db 0

newline:
    db 0Dh, 0Ah, 0

cmd_clear:
    db "clear", 0
cmd_reboot:
    db "reboot", 0
cmd_help:
    db "help", 0
cmd_ver:
    db "version", 0
cmd_dir:
    db "ls", 0

times (16*512)-($-$$) db 0
