.include "m16def.inc"
.def temp=r16

.cseg
.org 0
ldi temp,HIGH(RAMEND)
out SPH,temp
ldi temp,LOW(RAMEND)
out SPL,temp
	
	ser r26 	; Αρχικοποίηση της PORTA
	out DDRA, r26 	; για έξοδο
	clr r26
	out DDRB, r26   ; Αρχικοποίηση της PORTB
        ser r26         ; για είσοδο
        out PORTB, r26

flash:
	in r23, PINB    ; Διάβασε την είσοδο
    	mov r22, r23
	rcall on 	; Άναψε τα LEDs
	andi r23, 0x0f  ; Κράτα τα 4 LSB (leds on)
	inc r23         ; Αύξησε τον αριθμό κατά 1
wait_on:
	ldi r24, 0x64   ; r25:r24 = 100 ms delay
	ldi r25, 0x00
	rcall wait_msec ; Επανάλαβε x+1 καθυστερήσεις των 100 ms
	dec r23
	brne wait_on

	rcall off 	; Σβήσε τα LEDs
	swap r22        ; Κράτα τα 4 MSB (leds off)
	andi r22, 0x0f
	inc r22         ; Αύξησε τον αριθμό κατά 1 (x+1)
wait_off:
	ldi r24, 0x64   ; r25:r24 = 100 ms delay
	ldi r25, 0x00
	rcall wait_msec ; Επανάλαβε x+1 καθυστερήσεις των 100 ms
	dec r22
	brne wait_off
	rjmp flash 	; Επανάλαβε

	;Υπορουτίνα για να ανάβουν τα LEDs
on:
	ser r26 	; Θέσε τη θύρα εξόδου των LED
	out PORTA , r26
	ret 		; Γύρισε στο κύριο πρόγραμμα

	;Υπορουτίνα για να σβήνουν τα LEDs
off:
	clr r26 	; Μηδένισε τη θύρα εξόδου των LED
	out PORTA , r26
	ret 		; Γύρισε στο κύριο πρόγραμμα

.include "wait.asm"
