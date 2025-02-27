org 0x7C00
bits 16

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Save drive number
    mov [drive], dl

    ; Read sectors using CHS
    mov ah, 0x02    ; Read sectors
    mov al, 128     ; Read 128 sectors (main.bin + image.bin = ~64KB)
    mov ch, 0       ; Cylinder 0
    mov cl, 2       ; Sector 2 (LBA=1)
    mov dh, 0       ; Head 0
    mov dl, [drive] ; Drive number
    mov bx, 0x8000  ; Segment
    mov es, bx
    xor bx, bx      ; Offset 0x0000 (ES:BX = 0x8000:0x0000)
    int 0x13
    jc .disk_error

    ; Jump to main code at 0x8000:0x0000
    jmp 0x8000:0x0000

.disk_error:
    mov si, error_msg
.print:
    lodsb
    or al, al
    jz .halt
    mov ah, 0x0E
    int 0x10
    jmp .print
.halt:
    hlt

error_msg db "Error loading OS", 0
drive db 0

times 510 - ($-$$) db 0
dw 0xAA55