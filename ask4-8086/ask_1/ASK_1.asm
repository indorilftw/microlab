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
    EXIT            ;
MAIN ENDP
;=-=-=-=-=-=-=-=-=-=-===-=-=-=-=-==-=-=-=-=-=-=-=-=-=-===-=-=-=-=
INPUT_NUMS PROC NEAR
    MOV CX,4            ;3 digits input (except 1st obligatory digit input)                                          
    MOV DX,0            ;Initialize for the first number
IN_NUM1:
    READ
    CMP AL,'Q'
    JE EXODOS
    CMP AL,'q'
    JE EXODOS           ;Check if 
    CMP AL,'+'
    JE NEXT_CHECK
    CMP AL,'-'
    JE NEXT_CHECK
    MOV BL,AL           ;Keep printable form in BL
    MOV AH,30H          ;Because we have AX_ATOI procedure,
    CALL AX_ATOI        ;which returns the INTEGER in AL<-0000(from AH) c3 c2 c1 c0(from AL,if it's hex)
    CMP AH,0            ;If (AH==0) we have acceptable character(hexadecimal)
    JNE IN_NUM1         ;Else we have NOT acceptable character 
    PRINT BL            ;We are OK, so print pushed char
    SHL DX,4            ;Create space to add new digit
    ADD DX,AX           ;AX -> AH-AL -> 00000000 - 0000 c3 c2 c1 c0
    LOOP IN_NUM1
;If we are here 4 digits have been inputed and expected SIGN of the calculation
SIGN_EXPECT:
    READ
    CMP AL,'Q'
    JE EXODOS
    CMP AL,'q'
    JE EXODOS
    CMP AL,'+'
    JE NEXT_HEX         ;If '+' then go on
    CMP AL,'-'
    JNE SIGN_EXPECT
    JMP NEXT_HEX        ;If '-' then go on
NEXT_CHECK:
    CMP CX,4            ;Check if at least one digit has been inputed
    JE IN_NUM1          ;If not REREAD!
NEXT_HEX:
    MOV SIGN,AL         ;Save the SIGN of the calculation
    PRINT AL            ;Print it on screen
    MOV NUM_1,DX        ;Save the NUM_1
;Initializations for the second input
    MOV CX,4
    MOV DX,0
IN_NUM2:
    READ
    CMP AL,'Q'
    JE EXODOS
    CMP AL,'q'
    JE EXODOS           ;Check if 
    CMP AL,'='
    JE END_CHECK
    MOV BL,AL           ;Keep printable form in BL
    MOV AH,30H          ;Because we have AX_ATOI procedure,
    CALL AX_ATOI        ;which returns the INTEGER in AL<-0000(from AH) c3 c2 c1 c0(from AL,if it's hex)
    CMP AH,0            ;If (AH==0) we have acceptable character(hexadecimal)
    JNE IN_NUM2         ;Else we have NOT acceptable character 
    PRINT BL            ;We are OK, so print pushed char
    SHL DX,4            ;Create space to add new digit
    ADD DX,AX           ;AX -> AH-AL -> 00000000 - 0000 c3 c2 c1 c0
    LOOP IN_NUM2
;If we are here 4 digits have been inputed and expected EQUAL to calculate
EQUAL_EXPECT:
    READ
    CMP AL,'Q'
    JE EXODOS
    CMP AL,'q'
    JE EXODOS
    CMP AL,'='
    JNE EQUAL_EXPECT    ;Repeat until '=' is given, or exit request
    JMP END_INPUT
END_CHECK:
    CMP CX,4            ;Check if at least one digit has been inputed
    JE IN_NUM2          ;If not REREAD!
END_INPUT:
    MOV NUM_2,DX        ;Save the NUM_2
    PRINT AL            ;Print EQUAL sign
    RET
INPUT_NUMS ENDP
;=-=-=-=-=-=-=-=-=-=-===-=-=-=-=-==-=-=-=-=-=-=-=-=-=-===-=-=-=-=
CALCULATION PROC NEAR
    MOV RES_SIGN,0      ;Initialize sign of result to NONE (positive)
    MOV AX,NUM_1      
    MOV BX,NUM_2        ;RESULT=RES_HIGH - RES_LOW
    MOV RES_HIGH,0      ;The result is 32bit for the case of adding big 16bit-nums
    CMP SIGN,'-'        ;If calculation sign is '-' we hanve subtraction 
    JE SUB_NUMS         ;2 cases: i.'-' or ii.'+'
ADD_NUMS:
    ADD AX,BX
    JNC NOT_OVERFLOW
    MOV RES_HIGH,1
NOT_OVERFLOW:
    MOV RES_LOW,AX
    JMP END_CALCULATION
SUB_NUMS:
    CMP AX,BX
    JAE SUB_CALC
    SWAP_W AX,BX
    MOV RES_SIGN,1      ;The result is negative
SUB_CALC:
    SUB AX,BX           ;AX (minus) BX > 0 in any case
    MOV RES_LOW,AX
END_CALCULATION:
    ;Here we have the result in RES_HIGH - RES_LOW
    ;and the sign of the result in RES_SIGN (0->'+', 1->'-'
    RET
CALCULATION ENDP
;=-=-=-=-=-=-=-=-=-=-===-=-=-=-=-==-=-=-=-=-=-=-=-=-=-===-=-=-=-= 
PRINT_RESULTS PROC NEAR
    MOV DX,RES_HIGH
    MOV BX,RES_LOW
    CMP RES_SIGN,0
    JE PRINT_HEX_RESULT
    PRINT '-'
PRINT_HEX_RESULT:
    CALL PRINT_HEX_SPEC
    PRINT '='
    CMP RES_SIGN,0
    JE PRINT_DEC_RESULT
    PRINT '-'           ;RES_SIGN can only be 0->positive, or 1->negative
PRINT_DEC_RESULT:
    CALL PRINT_DEC_SPEC
    PRINT_STRING NEW_LINE
    RET
PRINT_RESULTS ENDP                                                                             
;=-=-=-=-=-=-=-=-=-=-===-=-=-=-=-==-=-=-=-=-=-=-=-=-=-===-=-=-=-=
PRINT_HEX_SPEC PROC NEAR
    ;We have the num in DX-BX, but DX(=RES_HIGH) is surely 1 or 0
    MOV 1ST_NZ,0        ;Initialize 1ST_NZ - first-non-zero flag
    CMP DL,0
    JE NEXT_PRINT0
    PRINT 31H
    MOV 1ST_NZ,1
NEXT_PRINT0:
    MOV AL,BH
    CALL PRINT_AL
    MOV AL,BL
    CALL PRINT_AL
    CMP 1ST_NZ,0
    JNE END_PRINT_HEX_SPEC
    PRINT 30H 
END_PRINT_HEX_SPEC:
    RET
PRINT_HEX_SPEC ENDP
;=-=-=-=-=-=-=-=-=-=-===-=-=-=-=-==-=-=-=-=-=-=-=-=-=-===-=-=-=-=
PRINT_AL PROC NEAR
    ;We produce from AL(hex) AX<-2hex chars=AH:High Hex Char  - AL:Low Hex Char
    ;1ST_NZ(byte) 0:haven't printed yet non-zero digit 1:have already printed
    CALL AL_ITOA
    CMP AH,30H
    JE CHECK_1
    MOV 1ST_NZ,1
    PRINT AH
    JMP NEXT_PRINT1
CHECK_1:
    CMP 1ST_NZ,0
    JE NEXT_PRINT1
    PRINT AH
NEXT_PRINT1:
    CMP AL,30H
    JE CHECK_2
    MOV 1ST_NZ,1
    PRINT AL
    JMP END_PRINT_AL
CHECK_2:
    CMP 1ST_NZ,0
    JE END_PRINT_AL
    PRINT AL
END_PRINT_AL:
    RET
PRINT_AL ENDP
;=-=-=-=-=-=-=-=-=-=-===-=-=-=-=-==-=-=-=-=-=-=-=-=-=-===-=-=-=-=
PRINT_DEC_SPEC PROC NEAR
    ;We have in DX-BX the 32bit result
    MOV AX,BX
    MOV BX,10
    MOV CX,0
DIV_LOOP:
    DIV BX
    PUSH DX
    INC CX
    MOV DX,0
    CMP AX,0
    JNE DIV_LOOP
PRINT_LOOP:
    POP DX
    ADD DL,30H
    PRINT DL
    LOOP PRINT_LOOP
    RET
PRINT_DEC_SPEC ENDP
;=-=-=-=-=-=-=-=-=-=-===-=-=-=-=-==-=-=-=-=-=-=-=-=-=-===-=-=-=-=
ENDS
DEFINE_AX_ATOI
DEFINE_AL_ITOA
END MAIN