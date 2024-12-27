ENTRY(_core)
OUTPUT_FORMAT(elf32-i386)

SECTIONS
{
    . = 0x7C00;                  /* bootloader.asm starts at 0x7C00*/
    .bootloader : AT(0x7C00) SUBALIGN(4)
    {
        src/bin/bootloader.elf(.text)
        src/bin/bootloader.elf(.*) 
    }
 
    . = 0x8000;                /* core.c starts at 0x8000*/
    ._core : SUBALIGN(4)
    {
        *(.text*)
        *(.rodata*)
        *(.data*)
    }

    .bss : SUBALIGN(4) {
        __bss_start = .;
        *(COMMON);
        *(.bss*);
    }
    . = ALIGN(4);              /* Round BSS up to 4 byte boundary */
    __bss_end = .;

    kernel_sectors = (SIZEOF(._core) + 511) / 512;

    /DISCARD/ : {
        *(.eh_frame)
        *(.comment)
    }
}
