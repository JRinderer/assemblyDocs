global _start

section .data
message: db 'hello world!', 10

section.text
_start:
	mov	rax, 1; write teh system call number
	mov	rdi, 1; stdout descriptor
	mov	rsi, message; string address
	mov	rdx, 14; string length in bytes
	syscall; execute the system call

	mov rax, 60; exit sys call number
	xor rdi, rdi; clear the register rdi 
	syscall
