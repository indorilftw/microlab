INCLUDE MACROS.TXT

STACK_SEG SEGMENT STACK
    DW 128 DUP(?)
ENDS

DATA_SEG SEGMENT
	ENTAILMENT DB " => $"
    LINE DB 0AH,0DH,"$"
    INPUT_MSG DB "GIVE 20 CHARACTERS (Latin characters,numbers,spaces,/ for exit)",0AH,0DH,"$"
    GIVE_MSG DB "GIVE AND PRESS ENTER:$"
	NUM_TABLE DB 20 DUP(?)
	LOWER_TABLE DB 20 DUP(?)
	UPPER_TABLE DB 20 DUP(?)
	NUM_COUNTER DW 0
	LOWER_COUNTER DW 0
	UPPER_COUNTER DW 0
	INDEX DW 0
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
    PRINT_STRING INPUT_MSG
    PRINT_STRING GIVE_MSG
    CALL INPUT_ROUTINE
	CALL OUTPUT_ROUTINE
	PRINT_STRING LINE
	MOV LOWER_COUNTER,0     ;Resetting Counters for new input
	MOV UPPER_COUNTER,0
	MOV NUM_COUNTER,0
    JMP START
EXODOS:
    EXIT
MAIN ENDP
;-=-=-=-=-=-=-=-=-=-=-=-ROUTINES-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
OUTPUT_ROUTINE PROC NEAR
	MOV CX,NUM_COUNTER
	CMP CX,0
	JE LOWER_START              ;Table is empty -> nothing to print
	MOV BX,OFFSET NUM_TABLE     ;The start address of NUM_TABLE->Address of first data
NUM_PRINT:
	MOV AL,DS:[BX]
	PRINT AL
	INC BX                      ;BX+=1 to locate next data (1Byte-data) 
	LOOP NUM_PRINT              ;Do this NUM_COUNTER times
	PRINT ' '
LOWER_START:                    ;Do the same for the other two tables
	MOV CX,LOWER_COUNTER
	CMP CX,0
	JE UPPER_START
	MOV BX,OFFSET LOWER_TABLE
LOWER_PRINT:
	MOV AL,DS:[BX] 
	PRINT AL
	INC BX
	LOOP LOWER_PRINT
	PRINT ' '
UPPER_START:
	MOV CX,UPPER_COUNTER
	CMP CX,0
	JE PRINT_EJECT
	MOV BX,OFFSET UPPER_TABLE
UPPER_PRINT:
	MOV AL,DS:[BX]
	PRINT AL
	INC BX
	LOOP UPPER_PRINT
PRINT_EJECT:
	RET
OUTPUT_ROUTINE ENDP
	
INPUT_ROUTINE PROC NEAR
;	PUSH DX
;	PUSH BX
;	PUSH CX
;   MOV DX,0	;DH->Counter of Nums
;	MOV BX,0	;BX->Counter of Uppercase, 
;	MOV BP,0	;BP->Counter of Lowercase
    MOV CX,20	;Counter of maximum number of characters inputed
INPUT_LOOP: 
    READ            ;Read changes AX: puts input in AL and gives DOS function code with AH
	CMP AL,0DH		;ODH = ENTER
	JE INPUT_END
	CMP AL,20H		;20H = SPACE
	JE SPACE_LOOP
	CMP AL,2FH		;2FH = '/'
	JE EXODOS
    CMP AL,30H
    JL INPUT_LOOP 
    CMP AL,39H
    JG UPPER_CHECK  ;If we pass we have 0-9 value
	PRINT AL		;We have read withouth echo
NUM_INPUT:
	MOV BX,OFFSET NUM_TABLE
	ADD BX,NUM_COUNTER		
	MOV [BX],AL		;Move Char in Num_Table
	INC NUM_COUNTER	;Increase num-counter
	JMP ENDING_LOOP
UPPER_CHECK:
	CMP AL,41H
    JL INPUT_LOOP
    CMP AL,5AH
    JG LOWER_CHECK  ;If we pass we have A-Z value
	PRINT AL		;We have read withouth echo
UPPER_INPUT:
	MOV BX,OFFSET UPPER_TABLE
	ADD BX,UPPER_COUNTER		
	MOV [BX],AL		;Move Char in Num_Table
	INC UPPER_COUNTER	;Increase upper-counter
	JMP ENDING_LOOP
LOWER_CHECK:
	CMP AL,61H
    JL INPUT_LOOP
    CMP AL,7AH
    JG INPUT_LOOP  	;If we pass we have a-z value
	PRINT AL		;We have read withouth echo
LOWER_INPUT:
	MOV BX,OFFSET LOWER_TABLE
	ADD BX,LOWER_COUNTER		
	MOV [BX],AL			;Move Char in Num_Table
	INC LOWER_COUNTER	;Increase upper-counter
ENDING_LOOP:
	LOOP INPUT_LOOP
ENTER_LOOP:
	READ
	CMP AL,0DH		;ODH = ENTER
	JNE ENTER_LOOP
INPUT_END:
	PRINT_STRING ENTAILMENT
	RET 
SPACE_LOOP:
	PRINT ' '
	JMP ENDING_LOOP
;	POP CX
;	POP BX
;	POP DX
INPUT_ROUTINE ENDP

CODE_SEG ENDS

END MAIN
