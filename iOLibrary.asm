section .text

string_length:
    xor rax, rax ; clear the registers
.loop:
    cmp byte [rdi+rax], 0 	; compare rdi and rax and determine if null terminator present
    je .end  			;if so (je jump if zero) jump to end
    inc rax 			;increment the rax register
    jmp .loop  			;move back to the toop of the loop
.end:
    ret				;return

print_char:
    push rdi			; pus the rdi onto the stack
    mov rdi, rsp		; move what is in rsp to rdi
    call print_string 		; call the print_string function
    pop rdi			; pop the value of rdi off stack
    ret				; return

print_newline:
    mov rdi, 10			; move 10 into the rdi register
    jmp print_char		; jmp to the print_char function

print_string:
    push rdi			; push the rdi register onto the stack
    call string_length		; call the string_length function
    pop rsi			; pop rsi register off the stack
    mov rdx, rax 		; move the rax register into the rdx register
    mov rax, 1			; move 1 into rax this is the write system call 
    mov rdi, 1 			; stdout file descriptor
    syscall			; run the system calls
    ret				;return

print_uint:
    mov rax, rdi		; move the rdi register into the rax register
    mov rdi, rsp		; move the rsp register into the rdi register
    push 0			; push 0 onto the stack
    sub rsp, 16			; subtract 16 from the rsp register
    
    dec rdi			; decrement the rdi register
    mov r8, 10			; move 10 into r8 this is one of the registers that holds the arguments for syscall

.loop:				;start loop section
    xor rdx, rdx		; clear the rdx register
    div r8			; dvide by r8
    or  dl, 0x30
    dec rdi 			; decrement rdi register
    mov [rdi], dl		; move dl into rdi
    test rax, rax	
    jnz .loop 
   
    call print_string
    
    add rsp, 24
    ret

print_int:
    test rdi, rdi
    jns print_uint
    push rdi
    mov rdi, '-'
    call print_char
    pop rdi
    neg rdi
    jmp print_uint

; returns rax: number, rdx : length
parse_int:
    mov al, byte [rdi]
    cmp al, '-'
    je .signed
    jmp parse_uint
.signed:
    inc rdi
    call parse_uint
    neg rax
    test rdx, rdx
    jz .error

    inc rdx
    ret

    .error:
    xor rax, rax
    ret 

; returns rax: number, rdx : length
parse_uint:
    mov r8, 10
    xor rax, rax
    xor rcx, rcx
.loop:
    movzx r9, byte [rdi + rcx] 
    cmp r9b, '0'
    jb .end
    cmp r9b, '9'
    ja .end
    xor rdx, rdx 
    mul r8
    and r9b, 0x0f
    add rax, r9
    inc rcx 
    jmp .loop 
    .end:
    mov rdx, rcx
    ret

string_equals:
    mov al, byte [rdi]
    cmp al, byte [rsi]
    jne .no
    inc rdi
    inc rsi
    test al, al
    jnz string_equals
    mov rax, 1
    ret
    .no:
    xor rax, rax
    ret 


read_char:
    push 0
    xor rax, rax
    xor rdi, rdi
    mov rsi, rsp 
    mov rdx, 1
    syscall
    pop rax
    ret 

read_word:
    push r14
    push r15
    xor r14, r14 
    mov r15, rsi
    dec r15

    .A:
    push rdi
    call read_char
    pop rdi
    cmp al, ' '
    je .A
    cmp al, 10
    je .A
    cmp al, 13
    je .A 
    cmp al, 9 
    je .A
    test al, al
    jz .C

    .B:
    mov byte [rdi + r14], al
    inc r14

    push rdi
    call read_char
    pop rdi
    cmp al, ' '
    je .C
    cmp al, 10
    je .C
    cmp al, 13
    je .C 
    cmp al, 9
    je .C
    test al, al
    jz .C
    cmp r14, r15
    je .D

    jmp .B

    .C:
    mov byte [rdi + r14], 0
    mov rax, rdi 
   
    mov rdx, r14 
    pop r15
    pop r14
    ret

    .D:
    xor rax, rax
    pop r15
    pop r14
    ret

string_copy:
    mov dl, byte[rdi]
    mov byte[rsi], dl
    inc rdi
    inc rsi
    test dl, dl
    jnz string_copy
    ret
