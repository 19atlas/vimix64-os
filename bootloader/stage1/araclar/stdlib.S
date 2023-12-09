[bits 16]

;printing in assembly
osprint:                                 
    mov ah, 0x0e
    .dongu:
        lodsb
        or al, al
        jz _break
        int 10h
        jmp .dongu
    ret

_newLine:	
	mov ah, 0x3
	int 0x10
	mov ah, 0x2
	xor dl, dl
	inc dh
	int 0x10
	ret

clear_screen:
    ;clear the screen by resetting the graphics mode.
	mov ah, 0x00					;function for switching the graphics mode
	mov al, 0x03					;graphics mode 0x03 text 80x25 characters
	int 0x10 						;call the 0x10 switch to reset the graphics mode
    ret

_break:
    jmp _break