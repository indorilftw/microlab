INCLUDE Library.inc
INCLUDE MACROS.TXT

STACK_SEG SEGMENT STACK
    DW 128 DUP(?)
ENDS

DATA_SEG SEGMENT
    NEW_LINE DB 0AH,0DH,"$"
    OUT_MSG DB "press any key to replay or 'Q','q' to exit$"
    SIGN DB ?
    RES_SIGN DB ?
    1ST_NZ DB ?                                             
    NUM_1 DW ?
    NUM_2 DW ?
    RES_HIGH DW ?
    RES_LOW DW ?
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
    CALL INPUT_NUMS
    CALL CALCULATION
    CALL PRINT_RESULTS
    PRINT_STRING OUT_MSG
    READ
    CMP AL,'Q'
    JE EXODOS
    CMP AL,'q'
    JE EXODOS
    PRINT_STRING NEW_LINE
    JMP START
EXODOS:
    EXIT            
MAIN ENDP
ENDS              

;Library definitions of procedures
DEFINE_AX_ATOI
DEFINE_AL_ITOA  
DEFINE_INPUT_NUMS
DEFINE_CALCULATION
DEFINE_PRINT_RESULTS
DEFINE_PRINT_HEX_SPEC
DEFINE_PRINT_AL
DEFINE_PRINT_DEC_SPEC

END MAIN