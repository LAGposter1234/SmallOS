register_interrupt:
    cli
    push es
    push si

    mov si, ax
    shl si, 1
    shl si, 1

    xor ax, ax
    mov es, ax

    mov es:[si], cx
    mov es:[si+2], bx

    pop si
    pop es
    ret
