;#include <reg932.inc>
;CS 1350 Project 2
;Lucas Coon, Andrew Van Horn, Corey Kitch
;11/29/18
;Implements add-an shift, booth's algorithm, and exteded booths algorithm multiplication 
;
;Bank Assignments
;B0 = Add and Shift
;B1 = Booth's Algorithm
;B2 = Extedned Booth's Algorithm
;B3 = Scratchpad Memory
;
;Register Assignments
;R0 = MulitplicandHB
;R1 = MultiplicandLB
;R2 = ResultHHB
;R3 = ResultHLB
;R4 = ResultLHB
;R5 = ResultLLB
;R6 = Number of Additions
;R7 = Execution Time
;
;Other Assgnments
;18 = Loop counter
;
MULTIPLICANDHB EQU 06H ;Multiplicand HB value
MULTIPLICANDLB EQU 0E5H ;Multiplicand LB value
MULTIPLIERHB   EQU 05H ;Multiplier HB Value
MULTIPLIERLB   EQU 55H ;Multiplier LB Value 
ORG 0000H
INC R1
AANDS:						;Set Bank 0
		MOV 	18H, #08H	;Initializ loop counter
		LCALL	LOAD
		MOV		A, R5
		JNB		0E7H, J1
J1:		JMP 	J1 
		
		

LOAD:	MOV R0, #MULTIPLICANDHB
		MOV R1, #MULTIPLICANDLB
		MOV	R2, #00H
		MOV R3, #00H
		MOV	R4, #MULTIPLIERHB
		MOV R5, #MULTIPLIERLB
		ret
		
		
SHIFT:	CLR C		;Clear Cary Bit
		MOV	A, R2
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
END
