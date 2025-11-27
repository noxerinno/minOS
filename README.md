# MinOS - Minimalist OS x86 (bootloader ASM + kernel C)

Minimalist operating system composed of an assembly (ASM) bootloader and a simple C kernel.

## Inspiration

The idea for this project comes from [V2F's youtube video](https://www.youtube.com/watch?v=ELTwwTsR5w8).
Through it, I aim to challenge myself in the same conditions as the content creator did. I'll have a week to try and create a basic operating system from scratch.

---

## Repo layout
- src/
  - bootloader.asm    — NASM boot sector (512 bytes)
  - kernel.c          — simple kernel in C (linked at 0x1000)
  - linker.ld         — linker script (places kernel at 0x1000)
  - scripts/          — helper scripts
- bin/                — built binaries (bootloader.bin, kernel.bin)
- build/              — final disk image (minOS.img)
- Makefile            — high-level build targets


## Prerequisites
- make, nasm
- qemu (qemu-system-i386)
- dd (system)
- Optional: i686-elf cross toolchain (default expected at /opt/cross/i686-elf)
- i686-elf cross compiling toolchain:
  - expected by default in `/opt/cross/i686-elf`
  - the Makefile contains a `make cross-compiler` target to assist with installation (requires system dependencies and sudo)


On Debian/Ubuntu:
```sh
sudo apt update
sudo apt install build-essential nasm qemu-system-x86 gcc-multilib
```

## Quick build & run
Recommended high-level target (Makefile should provide these targets):

- Build and boot:
```sh
make boot
```

- Manual sequence:
```sh
make binaries        # assemble bootloader + compile & link kernel
make disk_image      # create build/minOS.img
qemu-system-i386 -drive format=raw,file=build/minOS.img
```

- Test bootloader alone:
```sh
nasm -f bin src/bootloader.asm -o bin/bootloader.bin
qemu-system-i386 -drive format=raw,file=bin/bootloader.bin
```

## Expected behavior
- Bootloader runs (BIOS int 0x10 prints logo), reads kernel sectors into physical address 0x1000, enables protected mode, writes a visible test 'B' to VGA text memory, then jumps to the kernel at 0x1000.
- Kernel writes `Hello from my kernel!` to VGA memory (0xB8000).