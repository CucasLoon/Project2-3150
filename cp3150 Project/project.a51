;#include <reg932.inc>
;r1 = Mulitplicand
;r2 = Multiplier
;r3 = acc storage
;r4 = Safe Storage
;r7 == booth counter

multiplicand EQU 011111b ;Multiplicand value
multiplier EQU	001011b ;Multiplier Value
clr a


BOOTH:  MOV r7, #multiplicand / 2 ;Gives amount of times Booths algorithm needs to occur
		clr c
		MOV r1, #multiplicand 
		mov r2, #multiplier
		mov r3, a
		DJNZ r7, BOOTH
		jmp stop
		
		
SHIFT:	mov a,r2
		RRC a
		mov r2, a
		mov r4, a ;store a for safety
		ANL A, #10000000b
		jnz	KEEPBIT
SHIFT2: OrL a, r4
		RrC a
		mov r3,a
		mov a, r2
		rrc a
		jmp BOOTH

	
	
	
	
KEEPBIT: 	setb c
			jmp SHIFT2
	
	
	
	
stop: 
		END	
