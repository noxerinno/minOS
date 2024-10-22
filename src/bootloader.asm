org 0x0000                  ; Offset from load address

section .text
global _start

_start:
    mov ax, 0x07C0          ; Load bootloader load address in AX (0x7C0:0000 = 0x7C00)
    mov ds, ax
    call clear_screen       ; Call the function to clear the screen
    
    mov dl, 25              ; Heigth offset to center the logo (80x25 display)
    mov dh, 9               ; Heigth offset to center the logo (80x25 display)
    call set_cursor         ; Call the functioon to set the cursor at the right offset
    mov si, logo_line1      ; Load the address of 'my_string' into bx
    call print_screen       ; Call the function to print the string
    
    mov dh, 10
    call set_cursor
    mov si, logo_line2
    call print_screen

    mov dh, 11
    call set_cursor
    mov si, logo_line3
    call print_screen

    mov dh, 12
    call set_cursor
    mov si, logo_line4
    call print_screen


    mov dh, 13
    call set_cursor
    mov si, logo_line5
    call print_screen

    mov dh, 14
    call set_cursor
    mov si, logo_line6
    call print_screen

    jmp $                   ; Infinite loop to stay in the bootloader

clear_screen:
    mov ah, 0x06            ; BIOS teletype function (0x06) for clearing the screen  
    mov al, 0x00            ; Clear whole screen 
    mov bh, 0x07            ; Write in white on black background
    mov cx, 0x0000          ; Upper left screen coordinate
    mov dx, 0x184F          ; Lower right screen coordinate
    int 0x10                ; Make the BIOS interrupt call to print the character
    jmp done

set_cursor:                 ; Position cursor to center print
    mov ah, 0x02            ; BIOS teletype function (0x06) for placing the cursor
    mov bh, 0x00
    int 0x10                ; Make the BIOS interrupt call to print the character
    jmp done

print_screen:
    mov al, [si]            ; Load the character pointed to by bx into al

    cmp al, 0               ; Check if the character is the null terminator (end of string)
    je done                 ; If it's null (0), jump to 'done'

    mov ah, 0x0E            ; BIOS teletype function (0x0E) for printing a character
    int 0x10                ; Make the BIOS interrupt call to print the character

    add si, 1               ; Increment bx to point to the next character
    jmp print_screen        ; Repeat for the next character

done:
    ret                     ; Return from the function when the string ends


; my_string db "Hello, World!", 0  ; Null-terminated string
logo_line1 db " __  __ _        ____   _____", 0  ; Null-terminated string
logo_line2 db "|  \/  (_)      / __ \ / ____|", 0  
logo_line3 db "| \  / |_ _ __ | |  | | (___", 0  
logo_line4 db "| |\/| | | '_ \| |  | |\___ \", 0
logo_line5 db "| |  | | | | | | |__| |____) |", 0
logo_line6 db "|_|  |_|_|_| |_|\____/|_____/", 0



times 510-($-$$) db 0       ; Fill empty space with '0'
bootSignature dw 0xAA55     ; Write boot signature at the end of the boot sector
