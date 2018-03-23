.586
.model flat, stdcall
option casemap :none
.stack 4096
extrn ExitProcess@4: proc

GetStdHandle proto :dword
ReadConsoleA  proto :dword, :dword, :dword, :dword, :dword
WriteConsoleA proto :dword, :dword, :dword, :dword, :dword
MessageBoxA proto	:dword, :dword, :dword, :dword
STD_INPUT_HANDLE equ -10
STD_OUTPUT_HANDLE equ -11

.data
		bufSize = 80				; A healthy estimate for a buffer size
 	 	inputHandle DWORD ?			; To store the input handle from the Windows API
 	    buffer db bufSize dup(?)	; buffer size
 	    bytes_read  DWORD ?			; Bytes actually read
		
		sum_string db "Conversion: ",0
		promptStringVal db "Enter value: ",0
		promptStringUnit db "Enter unit to convert to (C or F): ",0
		centigradeChar db "C",0		; Char for Centigrade
		fahrenheitChar db "F",0		; Char for Fahrenheit

 	 	outputHandle DWORD ?		; To store the output handle from the Windows API
		bytes_written dd ?			; Number of bytes actually written
		actualNumber dw 0			; The converted number
		resultNumber dw 0			; The resultant number
		asciiBuf db 4 dup (" ")		; Buffer for chars
.code
	main proc

		; Print first message
		invoke GetStdHandle, STD_OUTPUT_HANDLE
 	    mov outputHandle, eax
		mov	eax,LENGTHOF promptStringVal
		invoke WriteConsoleA, outputHandle, addr promptStringVal, eax, addr bytes_written, 0
		mov eax,0

		; Get and store the input handle
 	    invoke GetStdHandle, STD_INPUT_HANDLE
 	    mov inputHandle, eax

		; Read input for number
 		invoke ReadConsoleA, inputHandle, addr buffer, bufSize, addr bytes_read,0
		sub bytes_read, 2	; -2 to remove \r\n
 		mov ebx,0
	
		mov al, byte ptr buffer+[ebx] 
		sub al,30h
		add	[actualNumber],ax
	
	; Gets the actual numerical value
	getNext:
		; Increment bx
		inc	bx
		; Compare ebx register to the read bytes
		cmp ebx,bytes_read
		; if equal (subtraction was 0), jump to next stage
		jz getUnit

		; Continue to calculate the numerical value of the inputted char
		mov	ax,10
		mul	[actualNumber]
		mov actualNumber,ax
		mov al, byte ptr buffer+[ebx] 
		sub	al,30h
		add actualNumber,ax
		
		jmp getNext
		
	getUnit:
		; Write prompt
		mov	eax,LENGTHOF promptStringUnit
		invoke WriteConsoleA, outputHandle, addr promptStringUnit, eax, addr bytes_written, 0
		mov eax,0

		; Read input for unit
 		invoke ReadConsoleA, inputHandle, addr buffer, 1, addr bytes_read,0
		sub bytes_read, 2	; -2 to remove \r\n
 		mov ebx,0
		mov al, byte ptr buffer+[ebx] 
		
		push actualNumber				; Prep the argument
		test al, centigradeChar			; Is AL the same as the "C"?	
		jz	UseFtoC						; If not the same, do next comparison
		call CtoF						; Call CtoF function
		jmp cont						; Continue

		UseFtoC:						;
		test al, fahrenheitChar			; Is AL the same as "F"?
		jz exitProg						; If not, exit the program - It's not C or F
		call FtoC						; If otherwise, call FtoC
		jmp cont						; Continue
		
		exitProg:						; If wrong, exit program
		call ExitProcess@4				;

	; Print the final result in a message box
	cont:
		mov ax,[resultNumber]
		mov cl,10
		mov	ebx,3
	nextNum:
		div	cl
		add	ah,30h
		mov byte ptr asciiBuf+[ebx],ah
		dec	ebx
		mov	ah,0
		cmp al,0
		ja nextNum
	
		invoke MessageBoxA, 0, addr asciiBuf, addr sum_string,0
		mov eax,0
		mov eax,bytes_written
		push	0

		call	ExitProcess@4
main	endp


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
	mov		resultNumber, ax		; store result
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
	mov resultNumber, ax			; may need to use ax:dx

	pop		ebx				; Get original original stack frame
	pop		ebp				; "

	ret

	mov ebp,esp
FtoC endp

end