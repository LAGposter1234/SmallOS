handle_command:
    cmpstr cmd_clear
    je .clear

    cmpstr cmd_reboot
    je .reboot

    cmpstr cmd_help
    je .help

    cmpstr cmd_ver
    je .ver

    cmpstr cmd_dir
    je .dir

    cmpstr empty
    je .empty_input
    ; try in fs

    call sfs_find_file
    test ax, ax
    jnz .file

    mov si, no_cmd
    int 22h
    ret

.clear:
    mov ax, 0B800h
    mov es, ax
    xor di, di
    mov ax, 0720h
    mov cx, 2000
    rep stosw

    mov ah, 02h
    xor bh, bh
    xor dx, dx
    int 10h

    int 21h

.reboot:
    call cold_reboot
    hlt

.help:
    mov si, help_str
    int 22h
    int 21h

.ver:
    mov si, kernel_version
    int 22h
    int 21h

.dir:
    mov si, sfs_dir_buffer
    call sfs_dir
    jc .direrror
    mov si, sfs_dir_buffer
    int 22h
    mov si, newline
    int 22h
    int 21h
.direrror:
    mov si, dir_error
    int 22h
    int 21h

.file:
    call sfs_exec_file
    ; jc .fileerror ; dont uncomment this it kinda breaks it i dont fucking know why

    mov ax, [sfs_buffer + 32]
    mov [file_jump + 2], ax
    jmp far [file_jump]

.fileerror:
    mov si, exec_error
    int 22h
    int 21h

.empty_input:
    int 21h

file_jump:
    dw 0
    dw 0

sfs_dir_buffer times 512 db 0
dir_error db "An error occured when trying to list files.", 0dh, 0ah, 0
exec_error db "An error occured when trying to execute that file.", 0dh, 0ah, 0
program_buffer:
    times 1536 db 0
