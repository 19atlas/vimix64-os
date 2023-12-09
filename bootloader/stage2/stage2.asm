[bits 16]

KERNEL_OFFSET equ 0x0100000

load_kernel:
   mov bx, KERNEL_OFFSET
   mov dh, 15
   mov dl, 0

   mov ah, 0x02
   mov al, dh
   mov ch, 0x00
   mov dh, 0x00
   mov cl, 0x02
   int 0x13
   ret