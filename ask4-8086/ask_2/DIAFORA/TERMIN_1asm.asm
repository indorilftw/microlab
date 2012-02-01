INCLUDE MACROS.TXT
INCLUDE EXTRA_MACROS.TXT

;PRINT_BIOS MACRO CHAR
;    MOV AH,0AH      ;funct code
;    MOV AL,CHAR     
;    MOV BH,00H      ;page num
;    MOV CX,1        ;times we print char
;    INT 10H
;ENDM 

STACK_SEG SEGMENT STACK
    DW 128 DUP(?)
ENDS

DATA_SEG SEGMENT
    PKEY DB "Press any key...$"
    NEW_LINE DB 0AH,0DH,"$"
    LOC_MSG DB "LOCAL$"
    REM_MSG DB "REMOTE$"
    SEPERATOR DB 80 DUP(0C4H),"$"
    ECHO_MSG DB "With(1) or Without(0) ECHO? $"
    BAUD_RATE_MSG DB "Give Baud Rate:(1)300,(2)600,(3)1200,(4)2400,(5)4800,(6)9600:$"
    LOCAL_LIN DB 0
	LOCAL_COL DB 0
    REMOTE_LIN DB 12
	REMOTE_COL DB 0
	WHERE_2_WRITE DB 0 
	ECHO_FLG DB 0
	B_R_CHOICE DB 0
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
    CALL INPUT_CHOOSE
    MOV AL,B_R_CHOICE               ;sthing 0000 0xxx
    ROL AL,5                        ;AL<-xxx0 0000
    ADD AL,3                        ;AL<-xxx0 0011 (xxx||EVEN_OR_ODD_PARITY|PARITY_ON|NUM_STOP_BIT|WORD_LENGTH_1|WORD_LENGTH_0)
    CALL OPEN_RS232
    CALL PRINT_START_SCRN
    CALL MAIN_LOOP
;    CALL INPUT_METHOD
;    READ
EXODOS:
    SCROLL_UP_WIN 0 0 24 80 0       ;to clear screen
    LOCATE 0 0 0                    ;to locate at the begining
    EXIT    
MAIN ENDP
;*****************************************************************    
INPUT_CHOOSE PROC NEAR
    SCROLL_UP_WIN 0 0 24 80 0
    LOCATE 0 0 0 
    PRINT_STRING ECHO_MSG
ECHO_ERR:
    READ    
    CMP AL,30H
    JB ECHO_ERR
    CMP AL,31H
    JA ECHO_ERR
    PRINT AL
    SUB AL,30H
    MOV ECHO_FLG,AL
    PRINT_STRING NEW_LINE
    PRINT_STRING BAUD_RATE_MSG
BAUD_RATE_ERR:
    READ
    CMP AL,31H
    JB BAUD_RATE_ERR
    CMP AL,36H
    JA BAUD_RATE_ERR
    PRINT AL
    SUB AL,29H          ;example(gave '1'):31h=29h=2h->010->baud rate 300
	MOV B_R_CHOICE,AL
    PRINT_STRING NEW_LINE
    PRINT_STRING PKEY
    READ
    SCROLL_UP_WIN 0 0 3 80 0
INPUT_CHOOSE ENDP
;*****************************************************************    
PRINT_START_SCRN PROC NEAR
    LOCATE LOCAL_LIN LOCAL_COL 00H
    PRINT_STRING LOC_MSG
    ADD LOCAL_LIN,1
    LOCATE 11 0 00H
    PRINT_STRING SEPERATOR
    LOCATE REMOTE_LIN REMOTE_COL 0
    PRINT_STRING REM_MSG
    ADD REMOTE_LIN,1
PRINT_START_SCRN ENDP
;*****************************************************************
INPUT_METHOD PROC NEAR
START_INPUT_METHOD:
    LOCATE LOCAL_LIN LOCAL_COL 00H
    READ
    CMP AL,1BH      ;check if ESC
    JE EXODOS
    CMP AL,0DH      ;check if ENTER
    JNE KEY_PUSHED
    CMP LOCAL_LIN,10
    JE FULL_LOC_WIN
    ADD LOCAL_LIN,1
    MOV LOCAL_COL,0
    ADD REMOTE_LIN,1
    MOV REMOTE_COL,0
    JMP START_INPUT_METHOD
FULL_LOC_WIN:
    SCROLL_UP_WIN 1 0 10 80 1
    SCROLL_UP_WIN 13 0 22 80 1
    MOV LOCAL_COL,0
    MOV REMOTE_COL,0
    JMP START_INPUT_METHOD
KEY_PUSHED:
    PRINT AL
    LOCATE REMOTE_LIN REMOTE_COL 00H
    PRINT AL
    ADD LOCAL_COL,1 
    ADD REMOTE_COL,1
END_INPUT_METHOD:
    JMP START_INPUT_METHOD        
    RET       
INPUT_METHOD ENDP
;*****************************************************************        
ENDS
END MAIN