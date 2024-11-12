OUTPUT_FORMAT(elf32-i386)
ENTRY(_start)

SECTIONS
{
    . = 0x7C00;                 /*BIOS' MBR load adress for the bootloader*/
    .bootloader :
    {
        *(.bootloader)          /* Bootloader code section */
    }

    . = 0x1000; /* Kernel will be load at address 0x1000 */
    .text :
    {
        *(.text)                /* Kernel code */
    }

    .rodata :
    {
        *(.rodata)              /* Read only data (const) */
    }

    .data :
    {
        *(.data)              /* Initialized data */
    }

    .bss :
    {
        *(.bss)               /* Uninitialized data */
    }
}
