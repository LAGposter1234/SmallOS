SFS_START_SECTOR equ 17
SFS_FILECOUNT    equ 32
SFS_FILE_SIZE    equ 3
SFS_METADATA_SIZE equ 34

sfs_format:
    mov ax, SFS_START_SECTOR
    mov si, sfs_basic_header
    call write_sector
    ret

; DS:SI = output buffer
; CF = error

sfs_dir:
    mov di, si
    mov bx, 1

.loop:
    mov ax, bx
    mov si, sfs_buffer

    push bx
    call sfs_read_file
    pop bx

    jc .error

    cmp byte [sfs_buffer], 0
    je .next

    mov si, sfs_buffer

.copy:
    lodsb
    test al, al
    jz .name_done

    mov [di], al
    inc di
    jmp .copy

.name_done:
    mov byte [di], ' '
    inc di

.next:
    inc bx
    cmp bx, SFS_FILECOUNT + 1
    jb .loop

    mov byte [di], 0
    clc
    ret

.error:
    stc
    ret

sfs_buffer:
    times 512 db 0

; AX = file ID
; DS:SI = destination for metadata sector
; CF = error

sfs_read_file:
    cmp ax, 1
    jb .error

    cmp ax, SFS_FILECOUNT
    ja .error

    dec ax
    mov bx, ax
    shl ax, 1
    add ax, bx
    add ax, SFS_START_SECTOR + 1

    mov bx, si
    push ds
    pop es

    call read_sector
    jc .error

    mov bx, [si + 32]
    mov es, bx
    xor bx, bx

    inc ax
    mov cx, 2
    call read_sectors
    jc .error

    clc
    ret

.error:
    stc
    ret

; AX = file ID (1-based)
; DS:SI = file buffer (including metadata), should be 1536 bytes exactly
; CF = error

sfs_write_file:
    cmp ax, SFS_FILECOUNT
    ja .error

    dec ax
    mov bx, ax
    shl ax, 1
    add ax, bx
    add ax, SFS_START_SECTOR + 1

    push ax
    push si

    call write_sector

    pop si
    pop ax

    jc .error

    inc ax
    add si, 512

    call write_sector
    jc .error

    inc ax
    add si, 512

    call write_sector
    jc .error

    clc
    ret

.error:
    stc
    ret

; AX = file ID
; DS:SI = filename (null terminated)
; DS:DI = file contents (null terminated)
; CF = error

sfs_write_file_string:
    cmp ax, SFS_FILECOUNT
    ja .error

    ; Preserve arguments
    push ax
    push si
    push di

    ; Clear buffer
    mov di, sfs_buffer
    xor al, al
    mov cx, 1536
    rep stosb

    ; Restore pointers
    pop di
    pop si
    pop ax

    ; Save file ID
    push ax

    ; Copy filename
    mov bx, sfs_buffer

.copy_name:
    lodsb
    mov [bx], al
    inc bx
    test al, al
    jnz .copy_name

    ; Load segment
    mov word [sfs_buffer + 32], 0x5000

    ; Copy contents
    mov si, di
    mov bx, sfs_buffer + 512

.copy_data:
    lodsb
    mov [bx], al
    inc bx
    test al, al
    jz .write

    cmp bx, sfs_buffer + 1536
    jae .error

    jmp .copy_data

.write:
    pop ax

    ; Calculate first sector
    dec ax
    mov bx, ax
    shl ax, 1
    add ax, bx
    add ax, SFS_START_SECTOR + 1

    ; Write 3 sectors
    mov si, sfs_buffer
    call write_sector
    jc .error

    inc ax
    mov si, sfs_buffer + 512
    call write_sector
    jc .error

    inc ax
    mov si, sfs_buffer + 1024
    call write_sector
    jc .error

    clc
    ret

.error:
    pop ax
    stc
    ret


; DS:SI = filename
; AX = 1 if found, 0 if not
; CF = error

sfs_find_file:
    push si
    mov bx, 1

.loop:
    mov ax, bx
    mov si, sfs_buffer

    push bx
    call sfs_read_file
    pop bx

    jc .error

    pop si
    push si

    mov di, sfs_buffer
    mov cx, 32

.compare:
    lodsb
    cmp al, [di]
    jne .next_file

    test al, al
    jz .found

    inc di
    loop .compare

.found:
    pop si
    mov ax, bx
    clc
    ret

.next_file:
    inc bx
    cmp bx, SFS_FILECOUNT + 1
    jb .loop

    pop si
    xor ax, ax
    clc
    ret

.error:
    pop si
    xor ax, ax
    stc
    ret

; AX = file ID
; CF = error

sfs_exec_file:
    clc
    cmp ax, 1
    jb .error

    cmp ax, SFS_FILECOUNT
    ja .error

    ; AX = metadata LBA
    dec ax
    mov bx, ax
    shl ax, 1
    add ax, bx
    add ax, SFS_START_SECTOR + 1

    ; Read metadata
    mov bx, sfs_buffer
    push ds
    pop es
    call read_sector
    jc .error

    ; ES = load segment
    mov bx, [sfs_buffer + 32]
    mov es, bx

    ; First program sector -> ES:0000
    xor bx, bx
    inc ax
    call read_sector
    jc .error

    ; Second program sector -> ES:0200
    mov bx, 512
    inc ax
    call read_sector
    jc .error

    clc
    ret

.error:
    stc
    ret

sfs_basic_header:
    db "SFS" ;magic
    dw SFS_FILECOUNT ;filecount

    times 512 - ($ - sfs_basic_header) db 0 ;padding

null_file:
    times 32 db 0 ; null filename
    dw 5000h      ; safe load
    times 512 - ($ - null_file) db 0 ; 0 the rest of metadata
    db 0xCD, 0x21 ; safe code (int 21h)
    times (3 * 512) - ($ - null_file) db 0 ; 0 the rest of data
