OUTPUT_FORMAT(elf32-i386)
ENTRY(_start)

SECTIONS {
    . = 0x000000;
    .bootloader : {
        *(.text)
    }

    . = ALIGN(0x1000);
    .kernel : {
        *(.text) *(.rodata) *(.data) *(.bss)
    }
}
