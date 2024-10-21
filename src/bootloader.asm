section .text
global _start

_start:
    mov ah, 0x06            ; Clear screen 
    mov al, 0x10
    mov bh, 0x07            ; Write in white on black background
    mov cx, 0x0000          ; Upper left screen coordinate
    mov dx, 0x184F          ; Lower right screen coordinate
    int 0x10

    mov ah, 0x0E            ; Display 'H'
    mov al, 'H'
    int 0x10
    
    mov ah, 0x0E            ; Display 'e'
    mov al, 'e'
    int 0x10
    
    mov ah, 0x0E            ; Display 'l'
    mov al, 'l'
    int 0x10

    mov ah, 0x0E            ; Display 'l'
    mov al, 'l'
    int 0x10

    mov ah, 0x0E            ; Display 'o'
    mov al, 'o'
    int 0x10

    mov ah, 0x0E            ; Display ','
    mov al, ','
    int 0x10

    mov ah, 0x0E            ; Display ' '
    mov al, ' '
    int 0x10

    mov ah, 0x0E            ; Display 'W'
    mov al, 'W'
    int 0x10

    mov ah, 0x0E            ; Display 'o'
    mov al, 'o'
    int 0x10

    mov ah, 0x0E            ; Display 'r'
    mov al, 'r'
    int 0x10

    mov ah, 0x0E            ; Display 'l'
    mov al, 'l'
    int 0x10

    mov ah, 0x0E            ; Display 'd'
    mov al, 'd'
    int 0x10

    mov ah, 0x0E            ; Display '!'
    mov al, '!'
    int 0x10



    hang:                   ; Infinite loop to stay in the bootloader
        jmp hang

    times 510-($-$$) db 0   ; Fill empty space with '0'
    bootSignature dw 0xAA55 ; Write boot signature at the end of the boot sector
