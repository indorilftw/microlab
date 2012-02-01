wait_usec:
	sbiw r24 ,1 	; 2 κύκλοι (0.250 μsec)
	nop 		; 1 κύκλος (0.125 μsec)
	nop 		; 1 κύκλος (0.125 μsec)
	nop 		; 1 κύκλος (0.125 μsec)
	nop 		; 1 κύκλος (0.125 μsec)
	brne wait_usec 	; 1 ή 2 κύκλοι (0.125 ή 0.250 μsec)
	ret 		; 4 κύκλοι (0.500 μsec)

wait_msec:
	push r24 	; 2 κύκλοι (0.250 μsec)
	push r25 	; 2 κύκλοι
	ldi r24 , 0xe6	; φόρτωσε τον καταχ. r25:r24 με 998 (1 κύκλος - 0.125 μsec)
	ldi r25 , 0x03	; 1 κύκλος (0.125 μsec)
	rcall wait_usec ; 3 κύκλοι (0.375 μsec), προκαλεί συνολικά καθυστέρηση 998.375 μsec
	pop r25 	; 2 κύκλοι (0.250 μsec)
	pop r24	 	; 2 κύκλοι
	sbiw r24 , 1 	; 2 κύκλοι
	brne wait_msec 	; 1 ή 2 κύκλοι (0.125 ή 0.250 μsec)
	ret 		; 4 κύκλοι (0.500 μsec)
