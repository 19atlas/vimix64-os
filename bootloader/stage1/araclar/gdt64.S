gdt_start:
gdt_null:

	DD 0x00000000
	DD 0x00000000

gdt_code:
    dw 0xFFFF           ; Limit (bits 0-15)
    dw 0x0000           ; Base  (bits 0-15)
    db 0x00             ; Base  (bits 16-23)
    db 0b10011010       ; 1st Flags, Type flags
    db 0b10101111       ; 2nd Flags, Limit (bits 16-19)
    db 0x00             ; Base  (bits 24-31)

gdt_data:
    dw 0x0000           ; Limit (bits 0-15)
    dw 0x0000           ; Base  (bits 0-15)
    db 0x00             ; Base  (bits 16-23)
    db 0b10010010       ; 1st Flags, Type flags
    db 0b10100000       ; 2nd Flags, Limit (bits 16-19)
    db 0x00             ; Base  (bits 24-31)

gdt_end:
gdt_descriptor:
	DW gdt_end - gdt_start - 1  ; Size of GDT, one byte less than true size
	DD gdt_start

CODE_SEG: equ gdt_code - gdt_start
DATA_SEG: equ gdt_data - gdt_start