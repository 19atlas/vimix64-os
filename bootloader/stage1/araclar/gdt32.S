;https://wiki.osdev.org/Global_Descriptor_Table
gdt_32start:

gdt_32null:
	dd 0x00000000
	dd 0x00000000

gdt_32code:

	DW 0xFFFF
	DW 0x0000
	DB 0x00
	DB 0x9A
	DB 0xCF
	DB 0x00

gdt_32data:

	DW 0xFFFF
	DW 0x0000
	DB 0x00
	DB 0x92
	DB 0xCF
	DB 0x00  ; Base  (bits 24-31)
gdt_32end:

gdt32_descriptor:
	DW gdt_32end - gdt_32start - 1
	DD gdt_32start

; Define helpers to find pointers to Code and Data segments
CODE_SEG32: equ gdt_32code - gdt_32start
DATA_SEG32: equ gdt_32data - gdt_32start