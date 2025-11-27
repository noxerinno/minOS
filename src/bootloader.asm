[BITS 16]
[ORG 0x7C00]               ; Origin address for the bootloader

global _start

; ========================
; Global variables
CODE_OFFSET equ 0x08        ; GDT code offset
DATA_OFFSET equ 0x10        ; GDT data offset
BOOT_DRIVE equ 0x80
KERNEL_LOAD_ADDR equ 0x1000 ; Address where the kernel will be loaded


; ========================
; Main function
_start:
    call clear_screen       ; Call the function to clear the screen

    ; -------------------------
    ; Print minOS logo
    mov dl, 25              ; Heigth offset to center the logo (80x25 display)
    mov dh, 9               ; Heigth offset to center the logo (80x25 display)
    call set_cursor         ; Call the functioon to set the cursor at the right offset
    mov si, LOGO_LINE_1     ; Load the address of 'my_string' into bx
    call print_screen       ; Call the function to print the string
    
    mov dh, 10              ; Displaying logo's second line
    call set_cursor
    mov si, LOGO_LINE_2
    call print_screen

    mov dh, 11              ; Displaying logo's third line
    call set_cursor
    mov si, LOGO_LINE_3
    call print_screen

    mov dh, 12              ; Displaying logo's fourth line
    call set_cursor
    mov si, LOGO_LINE_4
    call print_screen

    mov dh, 13              ; Displaying logo's fifth line
    call set_cursor
    mov si, LOGO_LINE_5
    call print_screen

    mov dh, 14              ; Displaying logo's sixth line
    call set_cursor
    mov si, LOGO_LINE_6
    call print_screen

    call wait_function
    call clear_screen
    mov dl, 0
    mov dh, 0
    call set_cursor
    
    ; -------------------------
    ; Kernel loading
    mov ax, 0x0000
    mov es, ax
    mov bx, KERNEL_LOAD_ADDR; Load OS source code in memory at address 0x1000
    
    mov dl, BOOT_DRIVE      ; Load from booting disk
    mov ah, 0x02            ; BIOS function to load disk
    mov al, 16              ; Provide the number of sector to load to the BIOS function
    mov cl, 0x02            ; Read from sector 2,...
    mov ch, 0x00            ; ...from cylinder 0...
    mov dh, 0x00            ; ...and from head 0
    int 0x13                ; Call to the BIOS interrupt to pass kernel's main func

    ; -------------------------
    ; Setup GDT & switch to protected mode
    cli                     ; Disable BIOS interrupts
    lgdt[gdt_descriptor]    ; Load the GDT
    in al, 0x92             ; A20 line latch
    or al, 2
    out 0x92, al
    
    mov eax, cr0            ; Load control register 0 (CR0)
    or al, 1                ; Set the PE (Protection Enable) bit
    mov cr0, eax            ; Write back to CR0 to enable protected mode

    jmp CODE_OFFSET:protected_start     ; Long jump
    ; jmp protected_start     ; Long jump
    ; jmp 0x08:0x1000         ; Long jump


; ========================
; GDT definition
; Basic Flat Model (BFM) for the Global Descriptor Table (GDT)
gdt_start:              ; Required null descriptor
    dd 0x0
    dd 0x0

    ; Code segment
    dw 0xffff           ; Span over whole available space
    dw 0x0
    db 0x0
    db 10011010b        ; Readable, executable but not writable
    db 11001111b
    db 0x0

    ; Data semgment
    dw 0xffff           ; Span over whole available space
    dw 0x0
    db 0x0
    db 10010010b        ; Readable, writable but not executable
    db 11001111b
    db 0x0

gdt_end:    

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start


; ========================
; Functions
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

; Qemu doesn't seem to correctly use int 0x15, func 0x86
;wait_function:
;    mov cx, 0               ; Set CX (high word of the delay) to 0, as our delay is less than 65536 ms
;    mov dx, 5000            ; Set DX (low word of the delay) to 5000 milliseconds (5 seconds)
;    
;    mov ah, 0x86            ; BIOS interrupt function 0x86 for waiting (delay)
;    int 0x15                ; Call BIOS interrupt 0x15 to perform the delay 
;    jmp done

; Custom 'sleep' function
wait_function:
    mov cx, 0x4FFF          ; Outer loop counter
outer_loop:
    mov dx, 0xFFFF          ; Inner loop counter
inner_loop:
    dec dx                  ; Decrement inner loop counter
    jnz inner_loop          ; If DX != 0, repeat inner loop
    
    dec cx                  ; Decrement outer loop counter
    jnz outer_loop          ; If CX != 0, repeat outer loop
    
    jmp done

done:
    ret                     ; Return from the function when the string ends


; ========================
; Logo
LOGO_LINE_1 db " __  __ _        ____   _____", 0  ; Null-terminated string
LOGO_LINE_2 db "|  \/  (_)      / __ \ / ____|", 0  
LOGO_LINE_3 db "| \  / |_ _ __ | |  | | (___", 0  
LOGO_LINE_4 db "| |\/| | | '_ \| |  | |\___ \", 0
LOGO_LINE_5 db "| |  | | | | | | |__| |____) |", 0
LOGO_LINE_6 db "|_|  |_|_|_| |_|\____/|_____/", 0


[BITS 32]
protected_start:
    mov ax, DATA_OFFSET     ; Selecting data segments
    mov ds, ax              ; Loading data segments
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax              ; Loading stack data
    mov ebp, 0x9FC00        ; Stack initialisation
    mov esp, ebp

    ; mov byte [0xB8000], 'B'
    ; mov byte [0xB8001], 0x07

    ; jmp $

    jmp CODE_OFFSET:0x1000  ; Long jump to kernel
    ; call _start        ; Call kernel main function

; ========================
; Filler & signature
times 510-($-$$) db 0       ; Fill empty space with '0'
bootSignature dw 0xAA55     ; Write boot signature at the end of the boot sector