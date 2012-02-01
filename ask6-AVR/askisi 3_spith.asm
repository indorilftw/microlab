.include "m16def.inc"
.def temp=r16
.def in_thng=r17
.def hi_clck=r18
.def lo_clck=r19
.def fwta=r20

	jmp reset	;Reset Handler
	jmp interr0	;IRQ0  Handler
.org 0x10
	jmp timer1_rout
reset:
	ldi temp,high(RAMEND)
	out SPH,temp
	ldi temp,low(RAMEND)
	out SPL,temp			;Setting Stack
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	ldi temp,0x03			;0b0000 0011->ISC01-ISC00 = 11, Sleep enable - off
	out MCUCR,temp			;and Rising edge trigger
	ldi temp,0x40
	out GIMSK,temp			;Setting Interrupt Mask

	ldi temp,0x05			;0b0000 0101 -> Clock's Frequency Divisor = 1024
	out TCCR1B,temp			
	ldi temp,0x04			;0b0000 0100 -> Enable Timer1
	out TIMSK,temp	
	sei
	
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	clr temp				;Setting PORTD as input
	out DDRD,temp
	ser temp
	out PORTD,temp
	ldi temp,0x02			;0b00000010 : PA0->input PA1(and evrthng else)->output
	out DDRA,temp
	ldi temp,0xfd			;0b11111101 : Setting PULL-UP Resistors
	out PORTA,temp
	
	ldi hi_clck,0xa4		;hi_clck:lo_clck=0xA472 = 0d42098 {=65536-3*7812.5}
	ldi lo_clck,0x72		;8000000/1024=7812.5Hz timer1's frequency
	ldi fwta,0x02			;0b0000 0010 to set lights on!
loop:
	in in_thng,PINA			;Reading input from PORTA
	sbrs in_thng,0			;If PA0==1 exit loop
	rjmp loop				;else loop!
	out PORTA,fwta			;If PA0 has been pressed -> lighs on!
	out TCNT1H,hi_clck		;Setting timer clock!
	out TCNT1L,lo_clck
	rjmp loop				;Loop!
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
interr0:
	rcall spitha0			;Catching false triggering from signal bounce
	out PORTA,fwta			;Lights on
	out TCNT1H,hi_clck		;Resetting Clock
	out TCNT1L,lo_clck
	sei						;Reenabling interrupts
	reti				
	
timer1_rout:
	clr fwta				
	out PORTA,fwta			;Lights off! (when timer is out)
	ldi fwta,0x02			;0b0000 0010 to set lights on next time!
	sei						;Reenabling interrupts
	reti

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
