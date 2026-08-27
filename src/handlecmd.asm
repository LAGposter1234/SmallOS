handle_command:
    cmpstr cmd_clear
    je .clear

    cmpstr cmd_reboot
    je .reboot

    cmpstr cmd_help
    je .help

    cmpstr cmd_ver
    je .ver

    cmpstr empty
    je .empty_input

    mov si, no_cmd
    int 22h
    ret

.clear:
    mov ah, 00h
    mov al, 03h
    int 10h
    int 21h

.reboot:
    mov ax, 0
    int 19h

.help:
    mov si, help_str
    int 22h
    int 21h

.ver:
    mov si, kernel_version
    int 22h
    int 21h

.empty_input:
    int 21h
