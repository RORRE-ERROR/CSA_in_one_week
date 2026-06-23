INCLUDE Irvine32.inc

.data
    startVal DWORD 8               ; [cite: 19]

.code
main PROC
    mov ecx, startVal              ; Outer loop counter (8 rows)
    mov ebx, 1                     ; Starting number for the current row

OuterLoop:
    push ecx                       ; Preserve outer loop counter
    
    mov ecx, startVal              ; Calculate inner loop iterations
    sub ecx, ebx
    add ecx, 1                     ; Inner loop counter = (8 - start + 1)
    
    mov eax, ebx                   ; Initialize value to print

InnerLoop:
    call WriteDec                  ; Print current number
    inc eax                        ; Increment number
    loop InnerLoop

    call Crlf                      ; Print newline
    inc ebx                        ; Increment starting number for next row
    pop ecx                        ; Restore outer loop counter
    loop OuterLoop

    exit
main ENDP
END main