INCLUDE Irvine32.inc

.data
    array WORD 0, 2, 5, 9, 10      ; [cite: 3]
    gapSum DWORD 0

.code
main PROC
    mov esi, 0                     ; Initialize index
    mov ecx, (LENGTHOF array) - 1  ; Loop count = number of gaps
    mov eax, 0                     ; Clear EAX to store the sum

CalculateGaps:
    movzx ebx, array[esi + 2]      ; Load next element
    movzx edx, array[esi]          ; Load current element
    sub ebx, edx                   ; Calculate the gap
    add eax, ebx                   ; Accumulate the gap sum
    add esi, TYPE array            ; Move to the next word index
    loop CalculateGaps

    mov edx, eax                   ; Move final sum (10) into EDX for dumping
    call DumpRegs                  ; [cite: 16]

    exit
main ENDP
END main