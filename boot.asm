bits 16
org 0x7c00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov [boot_drive], dl
    mov [0x8000], dl

    mov ah, 00h
    mov al, 03h
    int 10h

    mov si, boot_msg
    call print_msg

    ; load 16 bit kernel
    mov ax, 0x1000
    mov es, ax ; segment
    mov ah, 02h ; read sectors
    mov al, 10h ; 16 of them
    mov ch, 0 ; cylander 0
    mov cl, 2 ; sector 2? ig?
    mov dh, 0 ; head 0
    mov dl, [boot_drive] ; drive
    mov bx, 0 ; offset
    int 13h ; me fav interrupt (totally)

    jc error ; jump if error

    jmp 0x1000:0x0000

    jmp $

error:
    mov si, error_msg
    call print_msg
    cli
    hlt

; arg1 - si
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

boot_msg:
    db "SmallOS Booting...", 0Dh, 0Ah, 0

error_msg:
    db "Disk Error!", 0Dh, 0Ah, 0

boot_drive:
    db 0

times 446-($-$$) db 0

db 0x80
db 0x01, 0x01, 0x00
db 0xDA
db 0xFE, 0xFF, 0xFF
dd 0x00000001
dd 0x0000003F

times 48 db 0

dw 0xAA55
