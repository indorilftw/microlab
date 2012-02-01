;***********************************************************************************************
;Library file has some usual macros and some definition macros. We have to call these macros, 
;which only make the wanted code of Our Procedures, before "END MAIN" instruction.
;
;FORM
;_______________________________________________________________________________________________
;***********************************************************************************************
;DEFINE_? MACRO
;LOCAL 
;LOCAL 
;LOCAL 
;LOCAL SKIP_?
;JMP SKIP_?
;
;? PROC NEAR
;	[/CODE]
;? ENDP
;
;SKIP_?:
;	DEFINE_? ENDM
;***********************************************************************************************;
;***********************************************************************************************
;--------------------------------R-E-G-U-L-A-R-----M-A-C-R-O-S----------------------------------
SWAP_W MACRO WRD_1,WRD_2
	;swap 2 16bit, except "mem-mem" or "SI-smthing" or "smthing-SI"
	PUSH SI
	PUSH DI
	MOV SI,WRD_1
	MOV DI,WRD_2
	MOV WRD_1,DI
	MOV WRD_2,SI
	POP DI
	POP SI
SWAP_W ENDM
;----------------------------D-E-F-I-N-I-T-I-O-N------M-A-C-R-O-S-------------------------------
DEFINE_AL_ITOA MACRO
LOCAL HIGH_HEX,LOW_CHECK,LOW_HEX
LOCAL AL_ITOA_END,SKIP_AL_ITOA
JMP SKIP_AL_ITOA

AL_ITOA PROC NEAR
;This routine takes the AX number and returns the two hex_chars of it at AH-AL
;Register Affections:AX
	MOV AH,AL		;AH=AL= h3 h2 h1 h0 l3 l2 l1 l0
	SHR AH,4		;AH<-0 0 0 0 h3 h2 h1 h0
	AND AL,0FH		;AL<-0 0 0 0 l3 l2 l1 l0
	CMP AH,9		;If AH>9 is hex_char
	JA HIGH_HEX
	ADD AH,30H		;else is dec_char
	JMP LOW_CHECK	;go on!
HIGH_HEX:
	ADD AH,37H
LOW_CHECK:
	CMP AL,9
	JA LOW_HEX
	ADD AL,30H
	JMP AL_ITOA_END
LOW_HEX:
	ADD AL,37H
AL_ITOA_END:
	RET
AL_ITOA ENDP

SKIP_AL_ITOA:
	DEFINE_AL_ITOA ENDM
;***********************************************************************************************
DEFINE_AX_ATOI MACRO
LOCAL ERROR_END,CHECK_AL,AX_ATOI_END,NORMAL
LOCAL CHECK_HEX_AH_CAPITAL,CHECK_HEX_AH_LOWERCASE
LOCAL CHECK_HEX_AL_CAPITAL,CHECK_HEX_AL_LOWERCASE
LOCAL SKIP_AX_ATOI
JMP SKIP_AX_ATOI

AX_ATOI PROC NEAR
;This routine takes the 2 hex_chars in AH-AL and returns the integer  in AL
;When returns, if  (AH==0) then everything is ok,number in AL. 
;Else if (AH==1) there where no hexadecimal chars (error case)!
;Register Affections:AX
	CMP AH,30H					;
	JB ERROR_END				;error case:AH<30H
	CMP AH,39H					;
	JA CHECK_HEX_AH_CAPITAL		;
	SUB AH,30H					;if we are here AH='0'-'9'
	JMP CHECK_AL
CHECK_HEX_AH_CAPITAL:
	CMP AH,41H
	JB ERROR_END				;error case:39H<AH<41H
	CMP AH,46H
	JA CHECK_HEX_AH_LOWERCASE
	SUB AH,37H					;if we are here AH='A'-'F'
	JMP CHECK_AL
CHECK_HEX_AH_LOWERCASE:
	CMP AH,61H
	JB ERROR_END				;error case:46H<AH<61H
	CMP AH,66H
	JA ERROR_END				;error case:AH>66H
	SUB AH,57H					;if we are here AH='a'-'f'
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
CHECK_AL:
	CMP AL,30H
	JB ERROR_END
	CMP AL,39H
	JA CHECK_HEX_AL_CAPITAL
	SUB AL,30H
	JMP NORMAL
CHECK_HEX_AL_CAPITAL:
	CMP AL,41H
	JB ERROR_END
	CMP AL,46H
	JA CHECK_HEX_AL_LOWERCASE
	SUB AL,37H
	JMP NORMAL
CHECK_HEX_AL_LOWERCASE:
	CMP AL,61H
	JB ERROR_END
	CMP AL,66H
	JA ERROR_END
	SUB AL,57H
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
NORMAL:
	SHL AH,4
	OR AL,AH
	MOV AH,0				;everything ok:AH<-0
	JMP AX_ATOI_END
ERROR_END:
	MOV AH,1				;not ok:AH<-1
AX_ATOI_END:
	RET
AX_ATOI ENDP

SKIP_AX_ATOI:
	DEFINE_AX_ATOI ENDM
;***********************************************************************************************

DEFINE_INPUT_NUMS MACRO
LOCAL IN_NUM1,SIGN_EXPECT
LOCAL NEXT_CHECK,NEXT_HEX
LOCAL IN_NUM2,EQUAL_EXPECT
LOCAL END_CHECK,END_INPUT
LOCAL SKIP_INPUT_NUMS
JMP SKIP_INPUT_NUMS

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

SKIP_INPUT_NUMS:
	DEFINE_INPUT_NUMS ENDM
;***********************************************************************************************
DEFINE_CALCULATION MACRO
LOCAL ADD_NUMS,NOT_OVERFLOW
LOCAL SUB_NUMS,SUB_CALC
LOCAL END_CALCULATION
LOCAL SKIP_CALCULATION
JMP SKIP_CALCULATION

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

SKIP_CALCULATION:
	DEFINE_CALCULATION ENDM
;***********************************************************************************************;
DEFINE_PRINT_RESULTS MACRO
LOCAL PRINT_HEX_RESULT
LOCAL PRINT_DEC_RESULT 
LOCAL SKIP_PRINT_RESULTS
JMP SKIP_PRINT_RESULTS

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

SKIP_PRINT_RESULTS:
	DEFINE_PRINT_RESULTS ENDM
;***********************************************************************************************;
DEFINE_PRINT_HEX_SPEC MACRO
LOCAL NEXT_PRINT0
LOCAL END_PRINT_HEX_SPEC
LOCAL SKIP_PRINT_HEX_SPEC
JMP SKIP_PRINT_HEX_SPEC

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

SKIP_PRINT_HEX_SPEC:
	DEFINE_PRINT_HEX_SPEC ENDM
;***********************************************************************************************;
DEFINE_PRINT_AL MACRO
LOCAL CHECK_1,NEXT_PRINT1
LOCAL CHECK_2,END_PRINT_AL 
LOCAL SKIP_PRINT_AL
JMP SKIP_PRINT_AL

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

SKIP_PRINT_AL:
	DEFINE_PRINT_AL ENDM
;***********************************************************************************************;
DEFINE_PRINT_DEC_SPEC MACRO
LOCAL DIV_LOOP
LOCAL PRINT_LOOP 
LOCAL SKIP_PRINT_DEC_SPEC
JMP SKIP_PRINT_DEC_SPEC

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

SKIP_PRINT_DEC_SPEC:
	DEFINE_PRINT_DEC_SPEC ENDM
;***********************************************************************************************;