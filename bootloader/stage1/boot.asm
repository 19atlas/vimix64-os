[ORG 0x7C00]
[BITS 16]

;the boot manager memory address.
BOOTLOADER_ADDRESS equ 0x1000

jmp short start
nop

bdb_oem:                    db "VIMIX OS"           ; 8 bytes
bdb_bytes_per_sector:       dw 512
bdb_sectors_per_cluster:    db 1
bdb_reserved_sectors:       dw 1
bdb_fat_count:              db 2
bdb_dir_entries_count:      dw 0E0h
bdb_total_sectors:          dw 2880                 ; 2880 * 512 = 1.44MB
bdb_media_descriptor_type:  db 0F0h                 ; F0 = 3.5" floppy disk
bdb_sectors_per_fat:        dw 9                    ; 9 sectors/fat
bdb_sectors_per_track:      dw 18
bdb_heads:                  dw 2
bdb_hidden_sectors:         dd 0
bdb_large_sector_count:     dd 0
fat32_sectors_per_fat:      dd 0
fat32_flags:                dw 0
fat32_fat_version_number:   dw 0
fat32_rootdir_cluster:      dd 0
fat32_fsinfo_sector:        dw 0
fat32_backup_boot_sector:   dw 0
fat32_reserved:             times 12 db 0

; extended boot record
ebr_drive_number:           db 0                    ; 0x00 floppy, 0x80 hdd, useless
                            db 0                    ; reserved
ebr_signature:              db 29h
ebr_volume_id:              db 12h, 34h, 56h, 78h   ; serial number, value doesn't matter
ebr_volume_label:			db 'DISK       ' ; 11 bytes, padded with spaces
ebr_system_id:				db 'FAT12   ' ; 8 bytes

%INCLUDE"bootloader/stage1/araclar/stdlib.S"

start:
	mov bp, 0x0500 ;Initialize the base pointer and the stack pointer
	mov sp, bp
	mov byte[ebr_drive_number], dl ;move the boot disk number to ebr_drive_number
	call clear_screen

	;loads the next sector at memory address 0x7E00.
	;sets the parameters for the read from disk function.
	mov al, 0x01					;number of sectors to read.
	mov bx, 0x7E00					;memory address where to load the data.
	mov cl, 0x02					;sector number to start from.
	call disk_read					;call the read from disk function.
	jmp _bootloader16				;jump to _bootloader16

;include files
%INCLUDE"bootloader/stage1/araclar/disk.S"
%INCLUDE"bootloader/stage1/araclar/gdt32.S"
%INCLUDE"bootloader/stage1/araclar/protected_mode.S"

;fill the rest of the sector excluding the last two octets with 0
TIMES 510-($-$$) db 0x00
;the last two octets must be 0x55 and 0xAA for the disk to be bootable.
dw 0xAA55

_bootloader16:
	cli			;disable the switches.
	mov ax, 0x0000
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7C00
	
	sti			;re-enable the switches.

	;loads the boot manager at the memory address specified above.
	;sets the parameters for the read from disk function.
	mov al, 0x20					;number of sectors to read.
	mov bx, BOOTLOADER_ADDRESS		;memory address where to load the data.
	mov cl, 0x03					;sector number to start from.
	
	call disk_read					;calls the read from disk function.

	call enter_protected			;enter protected mode.
	mov si, basarili_pm
	call osprint
	
	jmp CODE_SEG32:_bootloader32		;jump to the _bootloader32 label.

[BITS 32]
_bootloader32:
	mov ax, DATA_SEG32
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	;enable line A20 to use all available memory
	in al, 0x92
	or al, 2
	out 0x92, al

	;sets up the boot manager and operating system stack.
	mov ebp, 0x10000
	mov esp, ebp

	;jump to the boot manager memory address. (0x1000)
	jmp BOOTLOADER_ADDRESS

basarili_pm: db "protected_mode activited",0

;fill the rest of the sector with 0
TIMES 1024-($-$$) db 0