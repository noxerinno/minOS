# Defining cross-compiler vars
CROSS_TARGET=i686-elf
CROSS_PREFIX=/opt/cross/$(CROSS_TARGET)

# Defining global vars
SRC_DIR = ./src
BIN_DIR = $(SRC_DIR)/bin
SCRIPT_DIR = $(SRC_DIR)/scripts
DEBUG_SCRIPT = $(SCRIPT_DIR)/debug.sh
REPORTS_DIR = $(SRC_DIR)/bin/reports
DISK_IMAGE_DIR = $(SRC_DIR)/image

UTILS_DIR = ./utils
BUILD_BINUTILS_DIR = $(UTILS_DIR)/build-binutils
BUILD_GCC_DIR = $(UTILS_DIR)/build-gcc

BOOTLOADER_SRC = $(SRC_DIR)/bootloader.asm
BOOTLOADER_BIN_TARGET = $(BIN_DIR)/bootloader.bin
BOOTLOADER_ELF_TARGET = $(BIN_DIR)/bootloader.elf

CC = $(CROSS_PREFIX)/bin/i686-elf-gcc
CFLAGS = -Wall -g
KERNEL_SRC = $(SRC_DIR)/kernel.c
KERNEL_OBJECT_TARGET = $(BIN_DIR)/kernel.o
KERNEL_BIN_TARGET = $(BIN_DIR)/kernel.bin

LD = $(CROSS_PREFIX)/bin/i686-elf-ld
LINKER = $(SRC_DIR)/linker.ld
OS_ELF_TARGET = $(BIN_DIR)/minOS.elf
OS_DISK_TARGET = $(DISK_IMAGE_DIR)/minOS.img

# Defining prompt colors & utils 
GREEN = \033[0;32m
RED = \033[0;31m
NO_COLOR = \033[0m
NO_PROMPT = 1>/dev/null 2>&1

export PATH := "${PATH}:$(CROSS_PREFIX)/bin"
 	
boot: disk_image
	@ #qemu-system-x86_64 -machine type=pc-i440fx-3.1 -m 512M -drive format=raw,file=$(BOOTLOADER_BIN_TARGET)
	@ #qemu-system-x86_64 -machine type=pc-i440fx-3.1 -m 512M -drive format=raw,file=$(OS_ELF_TARGET)
	@ #qemu-system-x86_64 -drive format=raw,file=$(OS_DISK_TARGET)
	@ qemu-system-i386 -drive format=raw,file=$(OS_DISK_TARGET) 

debug: boot elf_reports
	@ chmod u+x $(DEBUG_SCRIPT)
	@ $(DEBUG_SCRIPT)

disk_image: binaries clean_disk_images create_disk_image_dir
	@ dd if=/dev/zero of=$(OS_DISK_TARGET) bs=512 count=2880 $(NO_PROMPT)			# 2880 in the number of sectors of a 3,5" floppy disk
	@ dd if=$(BOOTLOADER_BIN_TARGET) of=$(OS_DISK_TARGET) conv=notrunc $(NO_PROMPT)
	@ dd if=$(KERNEL_BIN_TARGET) of=$(OS_DISK_TARGET) bs=512 seek=1 conv=notrunc $(NO_PROMPT)
	@ echo "${GREEN}Disk image: ${NO_COLOR}Disk image successfully created at $(OS_DISK_TARGET)"

binaries: clean_bin create_bin_dir
	@ if [ ! -d $(CROSS_PREFIX) ]; then \
		echo "${RED}Binaries: ${NO_COLOR}Cross compiler not found in \"$(CROSS_PREFIX)\"\n\t  To install the i386-elf cross compiler, run the following commands :\n\t\tsudo make cross-compiler &&\n\t\tcd $(BUILD_BINUTILS_DIR) && sudo ./binutils-config.sh $(CROSS_TARGET) && cd - &&\n\t\tcd $(BUILD_GCC_DIR) && sudo ./gcc-config.sh $(CROSS_TARGET) && cd -"; \
		exit 1; \
	fi

	@ nasm -f bin -o $(BOOTLOADER_BIN_TARGET) $(BOOTLOADER_SRC)
	@ $(CC) $(CFLAGS) -o $(KERNEL_OBJECT_TARGET) -c $(KERNEL_SRC)
	@ $(LD) -T $(LINKER) -o $(KERNEL_BIN_TARGET) $(KERNEL_OBJECT_TARGET)
	@ echo "${GREEN}Binaries: ${NO_COLOR}Bootloader & kernel binaries successfully compiled in $(BIN_DIR)"

elf_reports:	create_elf_reports_dir
	@ readelf -a $(BOOTLOADER_ELF_TARGET) > $(REPORTS_DIR)/bootloader_bin_report.txt 
	@ readelf -a $(KERNEL_BIN_TARGET) > $(REPORTS_DIR)/kernel_elf_report.txt
	@ readelf -a $(OS_ELF_TARGET) > $(REPORTS_DIR)/os_elf_report.txt 
	@ echo "${GREEN}Reports: ${NO_COLOR}Reports created"

create_bin_dir:
	@ if [ ! -d $(BIN_DIR) ]; then \
		mkdir $(BIN_DIR); \
		echo "${GREEN}Binaries: ${NO_COLOR}Binaries directory created"; \
	fi

create_disk_image_dir:
	@ if [ ! -d $(DISK_IMAGE_DIR) ]; then \
		mkdir $(DISK_IMAGE_DIR); \
		echo "${GREEN}Binaries: ${NO_COLOR}Binaries directory created"; \
	fi

create_elf_reports_dir:
	@ if [ ! -d $(REPORTS_DIR) ]; then \
		mkdir -p $(REPORTS_DIR); \
		echo "${GREEN}Reports: ${NO_COLOR}Reports directory successfully created"; \
	fi

clean_bin:
	@ rm -rdf $(BIN_DIR)/*
	@ echo "${GREEN}Cleaner: ${NO_COLOR}Binaries cleaned"

clean_disk_images:
	@ rm -rdf $(DISK_IMAGE_DIR)/*
	@ echo "${GREEN}Cleaner: ${NO_COLOR}Disk images cleaned"

mr_proper:
	@ rm -rdf $(BIN_DIR)
	@ rm -rdf $(UTILS_DIR)
	@ echo "${GREEN}Mr Proper: ${NO_COLOR}Project cleaned"



# Cross compiler creation target
cross-compiler: create_binutils_dir create_gcc_dir
	@ sudo apt update $(NO_PROMPT)
	@ sudo apt install build-essential bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo $(NO_PROMPT)
	@ echo "${GREEN}Cross compiler: ${NO_COLOR}Dependencies installed"
	
	@ if ! ls -A $(UTILS_DIR) | grep \"binutils-.*\.tar\.gz\"; then \
		wget https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.gz -P $(UTILS_DIR) $(NO_PROMPT); \
		tar -xzf $(UTILS_DIR)/binutils-2.41.tar.gz -C $(UTILS_DIR) $(NO_PROMPT); \
	fi
	@ if ! ls -A $(UTILS_DIR) | grep \"gcc-.*\.tar\.gz\"; then \
		wget https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.gz -P $(UTILS_DIR) $(NO_PROMPT); \
		tar -xzf $(UTILS_DIR)/gcc-13.2.0.tar.gz -C $(UTILS_DIR) $(NO_PROMPT); \
	fi
	@ echo "${GREEN}Cross compiler: ${NO_COLOR}Sources downloaded"
	
	@ cp $(SCRIPT_DIR)/binutils-config.sh $(BUILD_BINUTILS_DIR)
	@ chmod u+x $(BUILD_BINUTILS_DIR)/binutils-config.sh
	@ echo "${GREEN}Cross compiler: ${NO_COLOR}Binutils configuration setup"

	@ cp $(SCRIPT_DIR)/gcc-config.sh $(BUILD_GCC_DIR)
	@ chmod u+x $(BUILD_GCC_DIR)/gcc-config.sh
	@ echo "${GREEN}Cross compiler: ${NO_COLOR}GCC configuration setup"	

create_binutils_dir:
	@ if [ ! -d $(BUILD_BINUTILS_DIR) ]; then \
		mkdir -p $(BUILD_BINUTILS_DIR); \
		echo "${GREEN}Cross compiler: ${NO_COLOR}Binutils directory created"; \
	fi

create_gcc_dir:
	@ if [ ! -d $(BUILD_GCC_DIR) ]; then \
		mkdir -p $(BUILD_GCC_DIR); \
		echo "${GREEN}Cross compiler: ${NO_COLOR}GCC sources directory created"; \
	fi

clean_utils:
	@ rm -rdf $(UTILS_DIR)
	@ echo "${GREEN}Cleaner: ${NO_COLOR}Utils cleaned"
