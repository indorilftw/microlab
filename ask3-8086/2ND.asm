INCLUDE MACROS.TXT

STACK_SEG SEGMENT STACK
    DW 128 DUP(?)
ENDS

DATA_SEG SEGMENT
    PKEY DB "press any key to restart or 'Q' to exit!..$"
    IN_MSG DB "GIVE FOUR NUMBERS: $"
    OUT_MSG DB "HEX = $"
	ENTER_MSG DB "PLEASE PRESS ENTER!$"
    LINE DB 0AH,0DH,"$"
ENDS

CODE_SEG SEGMENT
    ASSUME CS:CODE_SEG,SS:STACK_SEG,DS:DATA_SEG,ES:DATA_SEG
MAIN PROC FAR
    ;SET SEGMENT REGISTERS
    MOV AX,DATA_SEG
    MOV DS,AX
    MOV ES,AX
;=-=-=-=-==-=-=-=-=-=-=-CODE-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-=-=
START:
    PRINT_STRING IN_MSG
    CALL DEC_4DIG_IN   ;DX has the inputed number!
NOT_ENTER:
	READ
	CMP AL,0DH
	JNE NOT_ENTER
    PRINT_STRING LINE
;	PRINT_STRING ENTER_MSG
;	PRINT_STRING LINE
    PRINT_STRING OUT_MSG
    CALL PRINT_HEX      ;Must have in DX the number
    PRINT_STRING LINE
    PRINT_STRING PKEY
    READ
    CMP AL,'q'
    JE EXODOS
    CMP AL,'Q'
    JE EXODOS
    PRINT_STRING LINE
    JMP START
EXODOS:
    EXIT
MAIN ENDP
;-=-=-=-=-=-=-=-=-=-=-=-ROUTINES-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
DEC_4DIG_IN PROC NEAR
    MOV DX,0
	MOV BH,0
    MOV CX,4
IGNORE: 
    READ            ;Read changes AX: puts input in AL and gives DOS function code with AH
	CMP AL,'q'
	JE EXODOS
	CMP AL,'Q'
	JE EXODOS
    CMP AL,30H
    JL IGNORE
    CMP AL,39H
    JG IGNORE       ;If we pass we have accepted value
    PRINT AL		;We have read withouth echo
    SUB AL,30H      ;AX<-(0-9)
	MOV BL,AL		;BX<-00000000 (AL) the new decimal digit
	MOV AX,DX		;put the number in AX
	MOV DX,10		;DX<-10 multiplier
	MUL DX			;AX*DX : Result is returned to DX-AX, but it can't be >9999, so it fits in AX
	MOV DX,AX
	ADD DX,BX		;Add NEW digit
    LOOP IGNORE     ;loop for 10 times to import 10 bits  
    RET   			;Finally we have the number in DX
DEC_4DIG_IN ENDP

PRINT_HEX PROC NEAR
;    PUSH AX
;    PUSH BX
;    PUSH CX
;    PUSH DX
    MOV AX,DX   ;Put number in AX
    MOV BX,16   ;Put the divisor in BX
    MOV CX,0    ;Counts the number of decimal digits
AGAIN:
    MOV DX,0
    DIV BX      ;quotient in AX and remainder in DX
    PUSH DX
    INC CX
    CMP AX,0    ;Check if quotient = 0 (all digits stored in stack)
    JNE AGAIN
PRINT_LOOP:
    POP DX
    CMP DL,9	;i know that in char is something between 00000000 and 00001111
	JBE DEC_DEC	;if A<=9 jump to DEC_DEC
	ADD DL,07H;we add total 37H, if we have something A-F
DEC_DEC:
	ADD DL,30H
	MOV AH,02H
	INT 21H		;To print the DL
    LOOP PRINT_LOOP
;    POP DX
;    POP CX
;    POP BX
;    POP AX  
    RET
PRINT_HEX ENDP

CODE_SEG ENDS

END MAIN
