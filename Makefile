elfgcc=x86_64-elf-gcc # installation from `yay -S x86_64-elf-gcc`
elfld=x86_64-elf-ld

BUILD_DIR=x86_64-bin

.PHONY: build
build: $(clean)
	mkdir -pv $(BUILD_DIR)
	@printf "\n\e[0;32m==> $(BUILD_DIR) e derleniyor..."
	@nasm "bootloader/stage1/boot.asm" -f bin -o "$(BUILD_DIR)/stage1.bin"
	@nasm "bootloader/stage2/stage2.asm" -f bin -o "$(BUILD_DIR)/kernel.Abin"
	@gcc -ffreestanding -Wno-write-strings -c kernel64/kernel.c -o $(BUILD_DIR)/kernel.o
	$(elfld) -o "$(BUILD_DIR)/bootloader.bin" -T boot.ld "$(BUILD_DIR)/stage1.bin" "$(BUILD_DIR)/bootloader.o" --oformat binary
	$(elfld) -o "$(BUILD_DIR)/kernel.bin" -T kernel.ld "$(BUILD_DIR)/kernel.o" "$(BUILD_DIR)/kernel.Abin" --oformat binary

	cat "$(BUILD_DIR)/bootloader.bin" "$(BUILD_DIR)/kernel.bin" > "$(BUILD_DIR)/boot.bin"
	dd if=/dev/zero of=$(BUILD_DIR)/disk.bin bs=512 count=2880
	mkfs.fat -v -F 12 -n "DISK" $(BUILD_DIR)/disk.bin #kernel and module outputs are on disk
	dd if=$(BUILD_DIR)/boot.bin of=$(BUILD_DIR)/disk.bin conv=notrunc
	@mcopy -v -i $(BUILD_DIR)/disk.bin $(BUILD_DIR)/kernel.bin "::kernel.bin"


.PHONY: help
help:
	@printf "clean: derlenmişi temizler\nbuild: derler\nrun: qemu da açar\noutput: $(BUILD_DIR)"

.PHONY: clean
clean:
	rm -rvf $(BUILD_DIR)/*

.PHONY: run
run:
	qemu-system-x86_64 -m 256M -device VGA,vgamem_mb=128 $(BUILD_DIR)/disk.bin