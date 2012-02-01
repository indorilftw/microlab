.include "m16def.inc"

.def temp=r16
.def leds=r17
.def counter=r18
.def icounter=r19
	jmp reset	;Reset Handler
	jmp interr0	;IRQ0 Handler
	
reset:
	ldi temp,high(RAMEND)
	out SPH,temp
	ldi temp,low(RAMEND)
	out SPL,temp			;Setting Stack
	clr temp
	out DDRD,temp
	ser temp
	out PORTD,temp			;Setting PORTD as input
	out DDRA,temp			;Setting PORTA as output
	out DDRB,temp			;Setting PORTB as output
	clr temp
	out PORTB,temp
;-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-
	ldi temp,0x03			;0b0000 0011->ISC01-ISC00 = 11, Sleep enable - off
	out MCUCR,temp			;and Rising edge trigger
	ldi temp,0x40
	out GIMSK,temp			;Setting Interrupt Mask
	sei
	clr counter
	clr icounter
;-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-
loop: 
	out PORTA,counter 			;Print loop counter (Leds A)
	ldi r24,low(100) 			;load r25:r24 with 100
	ldi r25,high(100) 			;delay 100 ms
	rcall wait_msec
	inc counter 				;Increase counter
	rjmp loop 					;Loop!
;-=-=-=-=-=-=-=-=-=-=-==-=-=-=-=-=-
interr0:
	rcall spitha0
	in temp,PIND				;Input port D
	sbrc temp,0					;If (PD0==1) return
	rjmp int0_ext
	inc icounter				;else increase icounter
	out PORTB,icounter			;Print it!
int0_ext:
	sei
	reti						;return

wait_usec:
	sbiw r24 ,1		; 2 cycles (0.250 micro sec)
	nop				; 1 cycles (0.125 micro sec)
	nop				; 1 cycles (0.125 micro sec)
	nop				; 1 cycles (0.125 micro sec)
	nop				; 1 cycles (0.125 micro sec)
	brne wait_usec	; 1 or 2 cycles (0.125 or 0.250 micro sec)
	ret				; 4 cycles (0.500 micro sec)

wait_msec:
	push r24		; 2 cycles (0.250 micro sec)
	push r25		; 2 cycles
	ldi r24 , 0xe6	; load register r25:r24 with 998 (1 cycles - 0.125 micro sec)
	ldi r25 , 0x03	; 1 cycles (0.125 micro sec)
	rcall wait_usec	; 3 cycles (0.375 micro sec), total delay 998.375 micro sec
	pop r25			; 2 cycles (0.250 micro sec)
	pop r24			; 2 cycles
	sbiw r24 , 1	; 2 cycles
	brne wait_msec	; 1 or 2 cycles (0.125 or 0.250 micro sec)
	ret				; 4 cycles (0.500 micro sec)

spitha0:
	ldi temp,0x40		;0b0100 0000
	out GIFR,temp		;Setting zero INTF0
	ldi r24,0x05		
	ldi r25,0x00
	rcall wait_msec		;wait 5 msec
	in temp,GIFR		;Check if INTF0==1
	sbrc temp,6			
	rjmp spitha0		;If INTF0==1 loop
	ret					;If INTF0==0 return
