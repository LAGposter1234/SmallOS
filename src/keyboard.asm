get_char:
    mov ah, 00h
    int 16h
    mov ah, 0x0e
    int 10h
    ret

; SI = buffer
; edits buffer in SI
get_line:
    push si
    push di
    mov di, si

.loop:
    call get_char
    cmp al, 0Dh
    je .done

    cmp al, 08h
    je .backspace

    mov [si], al
    inc si
    jmp .loop

.backspace:
    cmp si, di
    je .notext

    push ax
    mov al, ' '
    mov ah, 0x0e
    int 10h

    mov al, 08h
    int 10h
    pop ax

    dec si
    mov byte [si+1], 0
    jmp .loop

.notext:
    push ax
    mov al, ' '
    mov ah, 0x0e
    int 10h
    pop ax
    jmp .loop

.done:
    mov byte [si], 0
    pop di
    pop si
    ret
