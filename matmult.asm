;
; ***************************************************************
;       SKELETON: INTEL ASSEMBLER MATRIX MULTIPLY (LINUX)
; ***************************************************************
;
;
; --------------------------------------------------------------------------
; class matrix {
;     int ROWS              // ints are 64-bit
;     int COLS
;     int elem [ROWS][COLS]
;
;     void print () {
;         output.newline ()
;         for (int row=0; row < this.ROWS; row++) {
;             for (int col=0; col < this.COLS; cols++) {
;                 output.tab ()
;                 output.int (this.elem[row, col])
;             }
;             output.newline ()
;         }
;     }
;
;     void mult (matrix A, matrix B) {
;         for (int row=0; row < this.ROWS; row++) {
;             for (int col=0; col < this.COLS; cols++) {
;                 int sum = 0
;                 for (int k=0; k < A.COLS; k++)
;                     sum = sum + A.elem[row, k] * B.elem[k, col]
;                 this.elem [row, col] = sum
;             }
;         }
;     }
; }
; ---------------------------------------------------------------------------
; main () {
;     matrix matrixA, matrixB, matrixC  ; Declare and suitably initialise
;                                         matrices A, B and C
;     matrixA.print ()
;     matrixB.print ()
;     matrixC.mult (matrixA, matrixB)
;     matrixC.print ()
; }
; ---------------------------------------------------------------------------
;
; Notes:
; 1. For conditional jump instructions use the form 'Jxx NEAR label'  if label
;    is more than 127 bytes from the jump instruction Jxx.
;    For example use 'JGE NEAR end_for' instead of 'JGE end_for', if the
;    assembler complains that the label end_for is more than 127 bytes from
;    the JGE instruction with a message like 'short jump is out of  range'
;
;
; ---------------------------------------------------------------------------

segment .text
        global  _start
_start:

main:
          mov  rax, matrixA     ; matrixA.print ()
          push rax
          call matrix_print
          add  rsp, 8

          mov  rax, matrixB     ; matrixB.print ()
          push rax
          call matrix_print
          add  rsp, 8

          mov  rax, matrixB     ; matrixC.mult (matrixA, matrixB)
          push rax
          mov  rax, matrixA
          push rax
          mov  rax, matrixC
          push rax
          call matrix_mult
          add  rsp, 24          ; pop parameters & object reference

          mov  rax, matrixC     ; matrixC.print ()
          push rax
          call matrix_print
          add  rsp, 8

          call os_return                ; return to operating system

; ---------------------------------------------------------------------

matrix_print:                   ; void matrix_print ()
         push rbp               ; setup base pointer
         mov  rbp, rsp

         call output_newline    ; calling the method output_newline

         mov  r8, [rax]         ; put ROWS into register r8
         mov r9, [rax + 8]      ; put COLS into register r9 

                                ; for(int row = 0; row < this.ROWS; row++)
         mov rcx, 0             ; row = 0
nextr:   cmp rcx, r8            ; compare row and this.ROWS
         jge endloop            ; jump to endloop if row >= this.ROWS

                                ; for(int col = 0; col < this.COLS; cols++)
         mov rdx, 0             ; col = 0
nextc:   cmp rdx, r9            ; compare col and this.COLS
         jge endc               ; jump to endc if col >= this.COLS              

         mov rsi, rcx           ; move row into rsi
         imul rsi,r9            ; row * COLS 
         add rsi, rdx           ; row * COLS + col  

         call output_tab        ; output.tab()        
         mov r10, [rax + 16 + 8 * rsi]
                                ; move the bytes from matrix into r10
         push r10               ; push the values onto the stack

         call output_int        ; output.int() 
         add rsp, 8

         inc rdx                ; col++
         jmp nextc
    
endc:
         call output_newline    ; call the method output.newline()      
         inc rcx                ; row++
         jmp nextr
     
endloop: 
         pop  rbp                ; restore base pointer & return
         ret

;  --------------------------------------------------------------------------

matrix_mult:                       ; void matix_mult (matrix A, matrix B)

         push rbp                  ; setup base pointer
         mov  rbp, rsp

         mov r14, [rbp + 16]       ; locate matrix C 

         mov r8, [r14]             ; put this.ROWS into register r8 (MatC)
         mov r9, [r14 + 8]         ; put this.COLS into register r9 (MatC)
         add r14, 16               ; pointer pointing to the elems in C

         mov r10, [rbp + 24]       ; r10 is now pointing to matrix A
         add r10, 16               ; pointer pointint to the elems in A

         mov r11, [rbp + 32]       ; r11 is now pointing to matrix B
         add r11, 16               ; pointer pointing to the elems in B
       
                                   ; for(int row = 0; row < this.ROWS; row++)
         mov rcx, 0                ; row = 0
forr:    cmp  rcx, r8              ; compare row and this.ROWS
         jge endmulloop            ; jump to endmulloop if row >= this.ROWS

                                   ; for(int col = 0, col < this.COLS; col++)
         mov rdx, 0                ; col = 0
forc:    cmp rdx, r9               ; compare col and this.COLS
         jge endCMul               ; jump to endCMul if col >= this.COLS

         mov rsi, 0                ; sum = 0
                                 
         ; for(int k = 0; k < A.elem[row, k] * B.elem[k, col]
         mov rbx, 0                ; k = 0
fork:    cmp rbx, [r10 - 8]        ; compare k and A.COLS
         jge endk                  ; jump to endk if k >= A.COLS

         mov rdi, rcx              ; move row into rdi
         imul rdi,[r10 - 8]        ; row * A.COLS
         add rdi, rbx              ; row * A.COLS + k

         mov r13,[r10 + 8 * rdi]   ; find the location of elements of matrix A

         mov rdi, rbx              ; move k into rdi
         imul rdi, [r11 - 8]       ; k * B.COLS
         add rdi, rdx              ; k * B.COLS + col 

         imul r13, [r11 + 8 * rdi] ; A.elem[row, k]* B.elem[k, col]
         add rsi, r13              ; sum + A.elem[row, k] * B.elem[k, col]

         inc rbx                   ; k++
         jmp fork                

endk:    
                                   ;this,elem [row, col] = sum; 
         mov rdi, rcx              ; move row into rsi
         imul rdi,r9               ; row * COLS 
         add rdi, rdx              ; row * COLS + col  
         mov [r14 + 8 * rdi], rsi  ; this.elem [row, col] = sum
                               
         inc rdx                   ; col++
         jmp forc
 
endCMul:  
         inc rcx                   ; row++
         jmp forr

endmulloop:
         pop  rbp                ; restore base pointer & return
         ret


; ---------------------------------------------------------------------
;                    ADDITIONAL METHODS

CR      equ     13              ; carriage-return
LF      equ     10              ; line-feed
TAB     equ     9               ; tab
MINUS   equ     '-'             ; minus

LINUX   equ     80H             ; interupt number for entering Linux kernel
EXIT    equ     1               ; Linux system call 1 i.e. exit ()
WRITE   equ     4               ; Linux system call 4 i.e. write ()
STDOUT  equ     1               ; File descriptor 1 i.e. standard output

; ------------------------

os_return:
        mov  rax, EXIT          ; Linux system call 1 i.e. exit ()
        mov  rbx, 0             ; Error code 0 i.e. no errors
        int  LINUX              ; Interrupt Linux kernel

output_char:                    ; void output_char (ch)
        push rax
        push rbx
        push rcx
        push rdx
        push r8                ; r8..r11 are altered by Linux kernel interrupt
        push r9
        push r10
        push r11
        push qword [octetbuffer] ; (just to make output_char() re-entrant...)

        mov  rax, WRITE         ; Linux system call 4; i.e. write ()
        mov  rbx, STDOUT        ; File descriptor 1 i.e. standard output
        mov  rcx, [rsp+80]      ; fetch char from non-I/O-accessible segment
        mov  [octetbuffer], rcx ; load into 1-octet buffer
        lea  rcx, [octetbuffer] ; Address of 1-octet buffer
        mov  rdx, 1             ; Output 1 character only
        int  LINUX              ; Interrupt Linux kernel

        pop qword [octetbuffer]
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        pop  rdx
        pop  rcx
        pop  rbx
        pop  rax
        ret

; ------------------------

output_newline:                 ; void output_newline ()
       push qword LF
       call output_char
       add rsp, 8
       ret

; ------------------------

output_tab:                     ; void output_tab ()
       push qword TAB
       call output_char
       add  rsp, 8
       ret

; ------------------------

output_minus:                   ; void output_minus()
       push qword MINUS
       call output_char
       add  rsp, 8
       ret

; ------------------------

output_int:                     ; void output_int (int N)
       push rbp
       mov  rbp, rsp

       ; rax=N then N/10, rdx=N%10, rbx=10

       push rax                ; save registers
       push rbx
       push rdx

       cmp  qword [rbp+16], 0 ; minus sign for negative numbers
       jge  L88

       call output_minus
       neg  qword [rbp+16]

L88:
       mov  rax, [rbp+16]       ; rax = N
       mov  rdx, 0              ; rdx:rax = N (unsigned equivalent of "cqo")
       mov  rbx, 10
       idiv rbx                ; rax=N/10, rdx=N%10

       cmp  rax, 0              ; skip if N<10
       je   L99

       push rax                ; output.int (N / 10)
       call output_int
       add  rsp, 8

L99:
       add  rdx, '0'           ; output char for digit N % 10
       push rdx
       call output_char
       add  rsp, 8

       pop  rdx                ; restore registers
       pop  rbx
       pop  rax
       pop  rbp
       ret


; ---------------------------------------------------------------------

segment .data

        ; Declare test matrices
matrixA DQ 2                    ; ROWS
        DQ 3                    ; COLS
        DQ 1, 2, 3              ; 1st row
        DQ 4, 5, 6              ; 2nd row

matrixB DQ 3                    ; ROWS
        DQ 2                    ; COLS
        DQ 1, 2                 ; 1st row
        DQ 3, 4                 ; 2nd row
        DQ 5, 6                 ; 3rd row

matrixC DQ 2                    ; ROWS
        DQ 2                    ; COLS
        DQ 0, 0                 ; space for ROWS*COLS ints
        DQ 0, 0                 ; (for filling in with matrixA*matrixB)

; ---------------------------------------------------------------------

        ; The following is used by output_char - do not disturb
        ;
        ; space in I/O-accessible segment for 1-octet output buffer
octetbuffer     DQ 0            ; (qword as choice of size on stack)
