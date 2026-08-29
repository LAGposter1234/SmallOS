; IN:  SI = string 1 DI = string 2
; OUT: AX = 1 if equal, 0 if not equal
strcmp:
    push si
    push di
.loop:
    mov al, [si]
    cmp al, [di]
    jne .not_equal

    cmp al, 0
    je .equal

    inc si
    inc di
    jmp .loop

.equal:
    mov ax, 1
    jmp .done

.not_equal:
    xor ax, ax
    jmp .done

.done:
    pop di
    pop si
    ret

%macro cmpstr 1
    mov di, %1
    call strcmp
    cmp ax, 1
%endmacro

%include "handlecmd.asm"

help_str db "clear - clear the screen", 0Dh, 0Ah, "reboot - reboot SmallOS", 0Dh, 0Ah, "help - show this", 0Dh, 0Ah, "version - show version", 0Dh, 0Ah, "basic - run BASICCE", 0dh, 0ah, 0
address_str db "segment? ", 0
offset_str db "offset? ", 0
byte_str db "byte? ", 0
quit_str db "quit", 0
sucsess_str db "sucsess!!1", 0dh, 0ah, 0
returned_str db "returned!!!", 0dh, 0ah, 0
no_cmd db "Command not found", 0Dh, 0Ah, 0
run_ptr dw 0, 0
empty db 0
output_buffer times 5 db 0
