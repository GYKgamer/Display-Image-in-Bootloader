org 0x0000
bits 16

main_start:
    ; Set DS = CS (0x8000)
    mov ax, cs
    mov ds, ax

    ; Set video mode 0x13 (320x200, 256 colors)
    mov ax, 0x0013
    int 0x10

    ; Set VGA palette
    mov si, image_palette  ; Palette starts after main code
    mov dx, 0x03C8
    xor al, al
    out dx, al             ; Start at color 0
    inc dx                 ; Port 0x03C9
    mov cx, 256 * 3        ; 256 colors, 3 bytes each
    cld
    rep outsb              ; Send palette to VGA

    ; Copy pixel data to framebuffer (0xA000:0000)
    mov ax, 0xA000
    mov es, ax
    xor di, di             ; ES:DI = 0xA000:0x0000
    mov si, image_pixels   ; Pixel data starts after palette
    mov cx, 320 * 200      ; Number of pixels
    rep movsb              ; Copy pixels

    ; Halt
    jmp $

; Pad main.bin to 512 bytes
times 512 - ($-main_start) db 0

; Define image data offsets AFTER padding
image_palette equ 512      ; Palette starts at 512 bytes
image_pixels  equ image_palette + 768  ; Pixels start at 1280 bytes