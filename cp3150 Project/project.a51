;#include <reg932.inc>
;CS 1350 Project 2
;Lucas Coon, Andrew Van Horn, Corey Kitch
;11/29/18
;Implements Add and Shift, Booth's Algorithm, and Modified Booth's Algorithm multiplication 

;Bank Assignments
;B0 = Add and Shift
;B1 = Booth's Algorithm
;B2 = Extedned Booth's Algorithm
;B3 = Scratchpad Memory

;Register Assignments
;R0 = MulitplicandHB => Execution time HB
;R1 = MultiplicandLB => Execution TIme LB
;R2 = ResultHHB
;R3 = ResultHLB
;R4 = ResultLHB
;R5 = ResultLLB
;R6 = Number of Additions
;R7 = Unused

;Other Assgnments
;18 = Loop counter
;Input Operands Here
MULTIPLICANDHB EQU 06H ;Multiplicand HB value
MULTIPLICANDLB EQU 0E5H ;Multiplicand LB value
MULTIPLIERHB   EQU 05H ;Multiplier HB Value
MULTIPLIERLB   EQU 55H ;Multiplier LB Value 

;Main Code Bock
		ORG 0000H
		MOV	81H, #20H	;Set Stack Pointer to 20H
		LCALL	AANDS
		LCALL	B1ALG
		LCALL	B2ALG
LOOP:	SJMP	LOOP	;Loop Forever

;Loads Operand values into bank
LOAD:	MOV R0, #MULTIPLICANDHB	;Load Multiplicand
		MOV R1, #MULTIPLICANDLB
		MOV	R2, #00H			;Set Result HB to 0
		MOV R3, #00H
		MOV	R4, #MULTIPLIERHB	;Load Multiplier
		MOV R5, #MULTIPLIERLB
		MOV	R6, #00H			;Set Loop counter to 0
		RET
		
;Shifts Result 		
SHIFT:	MOV	A, R2
		MOV C, ACC.7;Store sign-bit in C
		RRC	A		;Rotate ResultHHB Right
		MOV	R2, A
		MOV	A, R3
		RRC	A		;Rotate ResultHLB Right
		MOV	R3, A
		MOV	A, R4
		RRC	A		;Rotate ResultLHB Right
		MOV	R4, A
		MOV	A, R5
		RRC	A		;Rotate ResultLLB Right
		MOV	R5, A
		RET

	
;Adds Multiplicand and HB Result
ADD1:	CLR		C
		MOV		A, R3
		ADDC  	A, R1		;Add Multiplicand LB to R3
		MOV  	R3, A
		MOV 	A, R2
		ADDC 	A, R0		;Add Multiplicand HB w/ C to R2
		MOV	 	R2, A
		INC		R6			;Increment ADD/SUB Counter
		RET

SUB1:	CLR		C
		MOV		A, R3
		SUBB  	A, R1		;Sub Multiplicand LB from R3
		MOV  	R3, A
		MOV 	A, R2
		SUBB 	A, R0		;Sub Multiplicand HB from R2
		MOV	 	R2, A
		INC		R6			;Increment ADD/SUB Counter
		RET

;Initializes Timer 0
STRTMR:	CLR	8CH				;Stop Timer
		MOV	8AH, #00H
		MOV	8CH, #00H		;Set timer to 0
		MOV	89H, #01000000B	;Set timer to Mode 1
		SETB 8CH 			;Start Timer
		RET
		
;Stops Timer 0 and loads result to R0, R1
ENDTMR:	CLR		8CH			;Stop Timer
		MOV		R0, 8CH
		MOV		R1, 8AH		;Move timer value to R0, R1
		RET

;Add and Shift function;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
AANDS:	MOV		0D0H, #00000000B	;Set Bank 0
		LCALL 	STRTMR		;Start Timer
		MOV 	18H, #10H	;Initializ loop counter
		LCALL	LOAD		;Load operands into bank
ALOOP:	MOV		A, R5		;Move LLB to ACC
		JNB		ACC.0, ASKIP	;if ACC = 0, skip add
		LCALL	ADD1		;Add Muliplicand to Result HB	
ASKIP:	LCALL	SHIFT 		;Shift Right
		DJNZ	18H, ALOOP	;Repeat Loop 16 times
		LCALL 	ENDTMR		;Stop Timer
		RET

;Booth's Algorithm Funciton;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
B1ALG:	MOV		0D0H, #00001000B	;Set Bank 1
		LCALL 	STRTMR		;Start Timer
		MOV 	18H, #10H	;Initializ loop counter
		CLR		C			;Clar Carry
		LCALL	LOAD		;Load operands into bank
B1LOOP:	MOV		A, R5		;Move LLB to ACC
		JNB		PSW.7, B1C0		;If C=0, Jump to B1C0
		JB		ACC.0, B1SKIP;If C=1, A.0=1, Skip ADD
B1ADD:	LCALL	ADD1		;If C=1, A.0=0, ADD
		SJMP	B1SKIP
B1C0:	JNB		ACC.0, B1SKIP;If C=0, A.0=0, skip SUB
B1SUB:	LCALL	SUB1		;If C=0, A.0=1, Sub
		SJMP	B1SKIP
B1SKIP:	LCALL	SHIFT 		;Shift Right
		DJNZ	18H, B1LOOP	;Repeat Loop 16 times
		LCALL 	ENDTMR		;Stop Timer
		RET
		
;Extended Booth's Function;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
B2ALG:	MOV		0D0H, #00010000B	;Set Bank 2
		LCALL 	STRTMR		;Start Timer
		MOV 	18H, #08H	;Initializ loop counter
		LCALL	LOAD		;Load operands into bank
		CLR		C
B2LOOP:	MOV		A, R5		;Move LLB to ACC
		RLC		A			;Move Carry into ACC
		ANL		A, #00000111B;Bit Mask low 3 bits
		CJNE	A, #00000000B, NEXT1 ;If 000 shift
		SJMP	B2SHIFT
NEXT1:	CJNE	A, #00000001B, NEXT2;if 001 add and shift
		LCALL 	ADD1
		SJMP	B2SHIFT
NEXT2:	CJNE	A, #00000010B, NEXT3;if 010 add and shift
		LCALL 	ADD1
		SJMP	B2SHIFT
NEXT3:	CJNE	A, #00000011B, NEXT4;if 011 addx2 and shift
		LCALL 	ADD1
		LCALL 	ADD1
		SJMP	B2SHIFT
NEXT4:	CJNE	A, #00000100B, NEXT5;if 100 subx2 and shift
		LCALL 	SUB1
		LCALL 	SUB1
		SJMP	B2SHIFT
NEXT5:	CJNE	A, #00000101B, NEXT6;if 101 subx2 and shift
		LCALL 	SUB1
		SJMP	B2SHIFT
NEXT6:	CJNE	A, #00000110B, NEXT7;if 110 subx2 and shift
		LCALL 	SUB1
		SJMP	B2SHIFT
NEXT7:	CJNE	A, #00000111B, B2SHIFT;if 111  shift
		SJMP	B2SHIFT
B2SHIFT:LCALL	SHIFT 		;Shift Rightx2
		LCALL	SHIFT
		DJNZ	18H, B2LOOP	;Repeat Loop 16 times
		LCALL 	ENDTMR		;Stop Timer
		RET

END
