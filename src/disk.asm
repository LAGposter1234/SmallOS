; AX = sector
; ES:BX = destination
; CF = error

read_sector:
    push ax
    push bx
    push cx
    push es
    push si
    mov [dap_lba], ax
    mov [dap_buffer], bx
    mov [dap_segment], es

    mov si, dap
    mov ah, 42h
    int 13h
    pop si
    pop es
    pop cx
    pop bx
    pop ax
    ret

; AX = sector
; ES:BX = destination
; CX = count
; CF = error

read_sectors:
    test cx, cx
    jz .done

.loop:
    call read_sector

    inc ax
    add bx, 512

    loop .loop

.done:
    ret

dap:
    db 10h ; size
    db 00h
    dw 0001h ; sectors to read
dap_buffer:
    dw 0000h ; buffer offset
dap_segment:
    dw 0000h ; buffer segment
dap_lba:
    dq 0000000000000000h ; LBA
