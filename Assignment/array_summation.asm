INCLUDE Irvine32.inc

.data
    prompt BYTE "Enter 32-bit integer : ", 0             ; [cite: 46]
    resultMsg BYTE "The sum of 32-bit integrs is : +", 0 ; 
    arr DWORD 3 DUP(?)                                   ; 

.code
main PROC
    mov ecx, 3                     ; Set loop for 3 inputs
    mov esi, OFFSET arr            ; Point to array start

InputLoop:
    mov edx, OFFSET prompt
    call WriteString
    call ReadInt                   ; Read 32-bit integer into EAX
    mov [esi], eax                 ; Store in array
    add esi, TYPE arr              ; Move to next DWORD
    loop InputLoop

    mov ecx, 3                     ; Set loop for summation
    mov esi, OFFSET arr
    mov eax, 0                     ; Clear accumulator

SumLoop:
    add eax, [esi]                 ; Add array value to EAX
    add esi, TYPE arr              ; Advance pointer
    loop SumLoop

    mov edx, OFFSET resultMsg
    call WriteString
    call WriteDec                  ; Display the calculated sum 
    call Crlf

    exit
main ENDP
END main