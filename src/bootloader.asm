[BITS 16]

section .text
global _start

BOOT_DRIVE db 0x00

_start:
    mov ax, 0x07C0          ; Load bootloader load address in AX (0x7C0:0000 = 0x7C00)
    mov ds, ax
    call clear_screen       ; Call the function to clear the screen
    
    mov dl, 25              ; Heigth offset to center the logo (80x25 display)
    mov dh, 9               ; Heigth offset to center the logo (80x25 display)
    call set_cursor         ; Call the functioon to set the cursor at the right offset
    mov si, logo_line1      ; Load the address of 'my_string' into bx
    call print_screen       ; Call the function to print the string
    
    mov dh, 10              ; Displaying logo's second line
    call set_cursor
    mov si, logo_line2
    call print_screen

    mov dh, 11              ; Displaying logo's third line
    call set_cursor
    mov si, logo_line3
    call print_screen

    mov dh, 12              ; Displaying logo's fourth line
    call set_cursor
    mov si, logo_line4
    call print_screen

    mov dh, 13              ; Displaying logo's fifth line
    call set_cursor
    mov si, logo_line5
    call print_screen

    mov dh, 14              ; Displaying logo's sixth line
    call set_cursor
    mov si, logo_line6
    call print_screen

    call sleep_5_seconds
    call clear_screen

    jmp $                   ; Infinite loop to stay in the bootloader

    ; Preparing swith to protected mode
    ; Basic Flat Model (BFM) for the Global Descriptor Table (GDT)
    gdt_start:              ; Required null descriptor
        dw 0x0
        dw 0x0
    
    gdt_data:               ; Data semgment
        dw 0xffff           ; Span over whole available space
        dw 0x0
        db 0x0
        db 10010010b        ; Readable, writable but not executable
        db 11001111b
        db 0x0
    
    gdt_code:               ; Code segment
        dw 0xffff           ; Span over whole available space
        dw 0x0
        db 0x0
        db 10011010b        ; Readable, executable but not writable
        db 11001111b
        db 0x0
    
    gdt_end:    
    
    gdt_descriptor:
        dw gdt_end - gdt_start - 1
        dw gdt_start
    
    ;;  Kernel loading
    ;mov bx, 0x1000          ; Load OS source code in memory at address 0x1000
    ;mov dh, 16              ; Laod 16 disk sectors
    ;mov dl, [BOOT_DRIVE]    ; Load from booting disk
    ;mov ah, 0x02            ; BIOS function to load disk
    ;mov al, dh              ; Provide the number of sector to load to the BIOS function
    ;mov cl, 0x02            ; Read from sector 2,...
    ;mov ch, 0x00            ; ...from cylinder 0...
    ;mov dh, 0x00            ; ...and from head 0
    ;int 0x13                ; Call to the BIOS interrupt to pass kernel's main func
    
    cli                     ; Disable BIOS interrupts
    lgdt[gdt_descriptor]    ; Load the GDT
    
    mov eax, cr0            ; Load control register 0 (CR0)
    or al, 1                ; Set the PE (Protection Enable) bit
    mov cr0, eax            ; Write back to CR0 to enable protected mode
    
    jmp 0x08:protected_start; Long jump

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
;sleep_5_seconds:
;    mov cx, 0               ; Set CX (high word of the delay) to 0, as our delay is less than 65536 ms
;    mov dx, 5000            ; Set DX (low word of the delay) to 5000 milliseconds (5 seconds)
;    
;    mov ah, 0x86            ; BIOS interrupt function 0x86 for waiting (delay)
;    int 0x15                ; Call BIOS interrupt 0x15 to perform the delay 
;    jmp done

; Custom 'sleep' function
sleep_5_seconds:
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

logo_line1 db " __  __ _        ____   _____", 0  ; Null-terminated string
logo_line2 db "|  \/  (_)      / __ \ / ____|", 0  
logo_line3 db "| \  / |_ _ __ | |  | | (___", 0  
logo_line4 db "| |\/| | | '_ \| |  | |\___ \", 0
logo_line5 db "| |  | | | | | | |__| |____) |", 0
logo_line6 db "|_|  |_|_|_| |_|\____/|_____/", 0


protected_start:
    ;mov ax, 0x10            ; Selecting data segments
    ;mov ds, ax              ; Loading data segments
    ;mov es, ax
    ;mov fs, ax
    ;mov gs, ax
    ;mov ss, ax              ; Loading stack data

    jmp 0x08:0x1000         ; Long jump to kernel


times 510-($-$$) db 0       ; Fill empty space with '0'
bootSignature dw 0xAA55     ; Write boot signature at the end of the boot sector
