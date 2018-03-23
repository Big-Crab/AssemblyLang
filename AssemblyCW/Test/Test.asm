.586
.model flat, stdcall
option casemap :none
.stack 4096
ExitProcess proto,dwExitCode:dword

.data	
	; define vars
	X dw 120
	result dw ?
.code
main proc
	push X		; Push X as an argument
	call CtoF	;
	push X
	call FtoC	;
	finish:
		invoke ExitProcess,0
main endp

CtoF proc
	push	ebp				; Create base pointer to access parameters
	mov		ebp, esp		; Establish stack frame
	push	ebx				; Save EBX
	
	mov		eax, [ebp+8]	; X value
	mov		cx, 9			; Prep for multiplication by 9
	mul		cx				; Multiply by 9
	cwd						; Expand AX into DX to make a doubleword
	mov		cx, 5			; Prep for division by 5
	div		cx			    ; Divide by 5

	add		ax, 32			; + 32
	mov		result, ax		; store result
	pop		ebx				; Get original original stack frame
	pop		ebp				; "

	ret

	mov ebp,esp
CtoF endp

FtoC proc
	push	ebp				; Create base pointer to access parameters
	mov		ebp, esp		; Establish stack frame
	push	ebx				; Save EBX
	
	mov		ax, [ebp + 8]	; X value [+8]
	sub		ax, 32			; Subtract 32
	mov		cx, 5			; Prep for multiplication by 5
	mul		cx				; Multiply by 5
	cwd						; Expand AX into DX for doubleword
	mov		cx, 9			; Prep for division by 9
	xor		dx, dx		; Clear the EDX register to stop its contents from being used in the division
	div		cx				; Divide by 9
	mov result, ax			; may need to use ax:dx

	pop		ebx				; Get original original stack frame
	pop		ebp				; "

	ret

	mov ebp,esp
FtoC endp
end