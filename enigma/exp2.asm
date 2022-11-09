; R5 = Mensagem em claro
; R6 = Mensagem cifrada
; R7 = Trama do Rotor 1
; R8 = Char que vou trabalhar

			.text
			.def EXP2

EXP2:
			push	R5
			push	R6
			push	#EXP2_RT1
			mov.w	#EXP2_MSG, R5
			mov.w	#EXP2_GSM, R6
			mov.w	#EXP2_RT1, R7

ENIGMA2:
			mov.b	@R5+, R8
			cmp.b	#0, R8					; Se eh zero, tchau
			jz		EXP2_QUIT
			sub.w	#65, R8					; Subtraio por 'A'
			add.w	0(SP), R8				; Acho o endereco no rotor
			mov.b	@R8, R8					; Pego o valor do roto
			add.w	#65, R8					; Somo 'A' de novo
			mov.b	R8, 0(R6)
			inc.w	R6
			jmp		ENIGMA2

EXP2_QUIT:
			pop		R4						; So limpo a pilha do rotor
			pop		R6
			pop		R5
			ret

			.data

EXP2_MSG:	.byte	"CABECAFEFACAFAD", 0	; Mensagem em claro
EXP2_GSM:	.byte	"XXXXXXXXXXXXXXX", 0	; Mensagem cifrada
EXP2_RT1:	.byte	2, 4, 1, 5, 3, 0		; Trama do Rotor 1

; Resposta: BCEDBCADACBCACF
