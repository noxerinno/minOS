org 0x0000                  ; Offset from load address

section .text
global _start

_start:
    mov ax, 0x07C0          ; Load bootloader load address in AX (0x7C0:0000 = 0x7C00)
    mov ds, ax
    call clear_screen       ; Call the function to clear the screen
    
    mov dl, 33              ; Heigth offset to center "Hello, World!" (80x25 display)
    mov dh, 12              ; Heigth offset to center "Hello, World!" (80x25 display)
    call set_cursor         ; Call the functioon to set the cursor at the right offset

    mov si, my_string       ; Load the address of 'my_string' into bx
    call print_screen       ; Call the function to print the string

    jmp $                   ; Infinite loop to stay in the bootloader

clear_screen:
    mov ah, 0x06            ; BIOS teletype function (0x06) for clearing the screen  
    mov al, 0x00            ; Clear whole screen 
    mov bh, 0x07            ; Write in white on black background
    mov cx, 0x0000          ; Upper left screen coordinate
    mov dx, 0x184F          ; Lower right screen coordinate
    int 0x10
    jmp done

set_cursor:                 ; Position cursor to center print
    mov ah, 0x02            ; BIOS teletype function (0x06) for placing the cursor
    mov bh, 0x00
    int 0x10
    jmp done

print_screen:
    mov al, [si]            ; Load the character pointed to by bx into al
    ; lodsb

    cmp al, 0               ; Check if the character is the null terminator (end of string)
    je done                 ; If it's null (0), jump to 'done'

    mov ah, 0x0E            ; BIOS teletype function (0x0E) for printing a character
    int 0x10                ; Make the BIOS interrupt call to print the character

    add si, 1               ; Increment bx to point to the next character
    jmp print_screen        ; Repeat for the next character

done:
    ret                     ; Return from the function when the string ends


my_string db "Hello, World!", 0  ; Null-terminated string

times 510-($-$$) db 0       ; Fill empty space with '0'
bootSignature dw 0xAA55     ; Write boot signature at the end of the boot sector


    ; mov ah, 0x0E            ; Display 'H'
    ; mov al, 'H'
    ; int 0x10
    ; 
    ; mov ah, 0x0E            ; Display 'e'
    ; mov al, 'e'
    ; int 0x10
    ; 
    ; mov ah, 0x0E            ; Display 'l'
    ; mov al, 'l'
    ; int 0x10
    ;
    ; mov ah, 0x0E            ; Display 'l'
    ; mov al, 'l'
    ; int 0x10
    ;
    ; mov ah, 0x0E            ; Display 'o'
    ; mov al, 'o'
    ; int 0x10
    ;
    ; mov ah, 0x0E            ; Display ','
    ; mov al, ','
    ; int 0x10
    ;
    ; mov ah, 0x0E            ; Display ' '
    ; mov al, ' '
    ; int 0x10
    ;
    ; mov ah, 0x0E            ; Display 'W'
    ; mov al, 'W'
    ; int 0x10
    ;
    ; mov ah, 0x0E            ; Display 'o'
    ; mov al, 'o'
    ; int 0x10
    ;
    ; mov ah, 0x0E            ; Display 'r'
    ; mov al, 'r'
    ; int 0x10
    ;
    ; mov ah, 0x0E            ; Display 'l'
    ; mov al, 'l'
    ; int 0x10
    ;
    ; mov ah, 0x0E            ; Display 'd'
    ; mov al, 'd'
    ; int 0x10
    ;
    ; mov ah, 0x0E            ; Display '!'
    ; mov al, '!'
    ; int 0x10 
