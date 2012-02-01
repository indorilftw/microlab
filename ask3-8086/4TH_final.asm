INCLUDE MACROS.TXT

STACK_SEG SEGMENT STACK
    DW 128 DUP(?)
ENDS

DATA_SEG SEGMENT
    LINE DB 0AH,0DH,"$"
    FIRST_NUM DB "FIRST NUMBER:$"
	SECOND_NUM DB "SECOND NUMBER:$"
	RES_NUM DB "RESULT:$"
    QUIT_QUEST DB "PRESS ANY KEY TO RESTART OR '/' TO EXIT...$"
	X0 DW ?
	X1 DW ?
	Y0 DW ?
	Y1 DW ?
	A_HIGH DW ?
	A_LOW DW ?
	B_HIGH DW ?
	B_LOW DW ?
	C_HIGH DW ?
	C_LOW DW ?
	D_HIGH DW ?
	D_LOW DW ?
	RES_0 DW ?
	RES_1 DW ?
	RES_2 DW ?
	RES_3 DW ?
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
;[/reading]
    PRINT_STRING FIRST_NUM
	CALL READ_8HEX_DIG
	MOV X0,BX
	MOV X1,DX
    PRINT_STRING SECOND_NUM
	CALL READ_8HEX_DIG
	MOV Y0,BX
	MOV Y1,DX
;[/reading ends]
	CALL ABCD_MAKE
	CALL CALCULATION
	PRINT_STRING RES_NUM
	CALL PRINT_RESULT
	PRINT_STRING LINE
	PRINT_STRING QUIT_QUEST
	READ
	CMP AL,'/'
	JE EXODOS
	PRINT_STRING LINE
	JMP START
EXODOS:
    EXIT
MAIN ENDP
;-=-=-=-=-=-=-=-=-=-=-=-ROUTINES-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;[/routine = READ_8HEX_DIG]
READ_8HEX_DIG PROC NEAR
;Messes with AX,BX,CX,DX,SI returns 32bit input at DX-BX
	MOV CX,8
	MOV BX,0
	MOV DX,0
INPUT_NUM:
	PUSH DX
IGNORE_READ:
	READ
	CMP AL,'/'
	JE EXODOS
	CMP AL,0DH		;ODH = ENTER (ASCII)
	JE FORCED_END	;Forced end, before 8hex digits have been inputed
	CMP AL,30H
	JL IGNORE_READ
	CMP AL,39H
	JG HEX_CHECK
	PRINT AL
	SUB AL,30H
	JMP READ_OUT
HEX_CHECK:
	CMP AL,'A'
	JL IGNORE_READ
	CMP AL,'F'
	JG IGNORE_READ
	PRINT AL
	SUB AL,37H
READ_OUT:
	POP DX			;Here AL <- 0000 (0000 to 1111)
	;[/code] Shifts left DX-BX, which handled like one 32bit register
	ROL BX,4
	SHL DX,4
	MOV SI,000FH
	AND SI,BX
	OR DX,SI
	AND BX,0FFF0H
	OR BL,AL
	;[/code ends]
	LOOP INPUT_NUM
INPUT_ENDED:
	PRINT_STRING LINE
	RET
FORCED_END:
	POP DX
	JMP INPUT_ENDED
READ_8HEX_DIG ENDP
;[/routine ends]

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

;[/routine = ABCD_MAKE]
ABCD_MAKE PROC NEAR
;MAKING A(32bits) = A_HIGH | A_LOW : X0*Y0 
	MOV AX,X0
	MUL Y0
	MOV A_HIGH,DX
	MOV A_LOW,AX
;MAKING B(32bits) = B_HIGH | B_LOW : X0*Y1
	MOV AX,X0
	MUL Y1
	MOV B_HIGH,DX
	MOV B_LOW,AX
;MAKING C(32bits) = C_HIGH | C_LOW : X1*Y0
	MOV AX,X1
	MUL Y0
	MOV C_HIGH,DX
	MOV C_LOW,AX
;MAKING D(32bits) = D_HIGH | D_LOW : X1*Y1
	MOV AX,X1
	MUL Y1
	MOV D_HIGH,DX
	MOV D_LOW,AX
	RET
ABCD_MAKE ENDP
;[/routine ends]

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

;[/routine = CALCULATION]
CALCULATION PROC NEAR
;RESULT(64bits) = RES_3|RES_2|RES_1|RES_0 : X(32bits) * Y(32bits), WHERE X=X1|X0,Y=Y1|Y0
	MOV CX,0		;CX = CARRY
;MAKING RES_0
	MOV AX,A_LOW
	MOV RES_0,AX
;MAKING RES_1
	MOV AX,A_HIGH
	ADD AX,B_LOW
	JNC NEXT00
	INC CX			;If C=1 must increase CARRY
NEXT00:
	ADD AX,C_LOW	;AX <- A_HIGH + B_LOW + C_LOW
	JNC NEXT01
	INC CX
NEXT01:
	MOV RES_1,AX
;MAKING RES_2
	MOV AX,B_HIGH
	ADD AX,CX
	JNC NEXT02
	MOV CX,1		;Making CARRY=1
	JMP NEXT03
NEXT02:
	MOV CX,0
NEXT03:
	ADD AX,C_HIGH
	JNC NEXT04
	INC CX
NEXT04:
	ADD AX,D_LOW	;AX <- CARRY + B_HIGH + C_HIGH + D_LOW
	JNC NEXT05
	INC CX
NEXT05:
	MOV RES_2,AX
;MAKING RES_3
	MOV AX,D_HIGH
	ADD AX,CX		;Trust math, that tell us there will not be any carry
	MOV RES_3,AX
	RET
CALCULATION ENDP
;[/routine ends]

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

;[/routine = PRINT_HEX]
PRINT_HEX PROC NEAR
;PRINTS DL(hex) <- 0 0 0 0 (0000 - FFFF)
	CMP DL,9
	JG ADDR_42
	ADD DL,30H
	JMP ADDR_R6
ADDR_42:
	ADD DL,37H
ADDR_R6:
	PRINT DL
	RET
PRINT_HEX ENDP
;[/routine ends]

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

;[/routine = PRINT_16BIT]
PRINT_16BIT PROC NEAR
;Having at AX <- LMNO H, and want to print L,M,N and O
	MOV CX,4	;repeat 4 times (4hex digits exist within a 16bit reg)
	CMP SI,0
	JNE PRINT_16_2
PRINT_16:		;If flag is still 0 (nothing non-zero have printed yet) we are here
	ROL AX,4
	MOV DL,0FH
	AND DL,AL
	CMP DL,0
	JNE GO_ON
	LOOP PRINT_16
	JMP END_PRINT_16BIT
GO_ON:
	MOV SI,1				;Flag that from now on must print zeros
	CALL PRINT_HEX
	JMP LOOP_LOOP           ;We don't use DEC CX, because if this has result CX = 0, 
PRINT_16_2:                 ;LOOP PRINT_16_2 will make CX = FFFF H and keep looping !
	ROL AX,4
	MOV DL,0FH
	AND DL,AL
	CALL PRINT_HEX
LOOP_LOOP:
	LOOP PRINT_16_2
END_PRINT_16BIT:
	RET
PRINT_16BIT ENDP
;[/routine ends]

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

;[/routine = PRINT_RESULT]
PRINT_RESULT PROC NEAR
	MOV SI,0			;Flag for first non-zero number to print
	MOV AX,RES_3
	CALL PRINT_16BIT
	MOV AX,RES_2
	CALL PRINT_16BIT
	MOV AX,RES_1
	CALL PRINT_16BIT
	MOV AX,RES_0
	CALL PRINT_16BIT
	CMP SI,0       	    ;If the result is just zero, print it!
	JNE PRINT_RESULT_END
	PRINT 30H
PRINT_RESULT_END:
	RET
PRINT_RESULT ENDP
	
CODE_SEG ENDS

END MAIN
