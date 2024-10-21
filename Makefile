# Defining prompt colors 
GREEN=\033[0;32m
NO_COLOR=\033[0m

# boot: binaries
# 	@ qemu-system-x86_64 -M pc -m 512M -nographic -kernel ./src/bin/bootloader.elf
#
# debug: binaries elf_report
# 	@ qemu-system-x86_64 -machine type=pc-i440fx-3.1 -m 512M -kernel ./src/bin/bootloader.elf --append "console=tty0 console=ttyS0"

boot: binaries
	@ qemu-system-x86_64 -machine type=pc-i440fx-3.1 -m 512M -drive format=raw,file=./src/bin/bootloader.bin

binaries: clean create_bin_directory
	@ nasm -f bin -o ./src/bin/bootloader.bin ./src/bootloader.asm
	@ nasm -f elf32 -o ./src/bin/bootloader.o ./src/bootloader.asm
	@ ld -m elf_i386 -o ./src/bin/bootloader.elf ./src/bin/bootloader.o
	@ echo "${GREEN}Bootloader: ${NO_COLOR}bootloader binaries successfully created"

create_bin_directory:
	@ mkdir ./src/bin
	@ mkdir ./src/bin/reports

debug: boot elf_report

elf_report:
	@ readelf -a ./src/bin/bootloader.o > ./src/bin/reports/bin_report.txt 
	@ readelf -a ./src/bin/bootloader.elf > ./src/bin/reports/elf_report.txt 

clean:
	@ rm -rdf ./src/bin
	@ echo "${GREEN}Cleaner: ${NO_COLOR}binaries successfully cleaned"
