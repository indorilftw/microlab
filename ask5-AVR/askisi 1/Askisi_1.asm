.include "m16def.inc"
.def temp=r16

.cseg
.org 0
ldi temp,HIGH(RAMEND)
out SPH,temp
ldi temp,LOW(RAMEND)
out SPL,temp
reset:
	ser r26
	out DDRA,r26	;Set PORTA as output
	clr r26
	out DDRB,r26	;Set PORTB as input
    ser r26
    out PORTB,r26  ;Activate pull-up resistors
	ldi r26,1	;r26 will control the LEDs

down:
	out PORTA,r26	;Turn on the LED
	ldi r24,0xf4	;Set 0x01f4 = 0d500 to r25:r24
	ldi r25,0x01
	rcall wait_msec	;wait for 500 sec
	jmp button_down	;Check if button pressed
bpd:
	rol r26		;If not set the next LED
	brcc down	;Loop until the 8th LED
	ror r26		;Set the 7th LED
	ror r26
up:
	out PORTA, r26	;Do the same job backwards
	ldi r24,0xf4	;Set 0x01f4 = 0d500 to r25:r24
	ldi r25,0x01
	rcall wait_msec
	jmp button_up
bpu:
	ror r26
	brcc up
	rol r26
	rol r26
	jmp down

button_up:		;Button check when you go down
	in  r23,PINB	;Read input from PORTB
	bst r23, 0	;If nothing pressed exit
	brtc exit_up
pressed_up:
	in  r23, PINB   ;Else wait until button released
	bst r23,0
	brts pressed_up
exit_up:
	jmp bpu

button_down:		;Button check when you go up
	in  r23, PINB
	bst r23, 0
	brtc exit_down
pressed_down:
	in  r23, PINB
	bst r23,0
	brts pressed_down
exit_down:
	jmp bpd
.include "wait.asm"
