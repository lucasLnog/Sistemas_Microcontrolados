; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>
LABEL_NUM 		EQU 0x0B
MUL_NUM1		EQU 0x00
MUL_NUM2		EQU 0x04
MUL_RES			EQU	0x08
; -------------------------------------------------------------------------------
; Área de Dados - Declarações de variáveis
		AREA  DATA, ALIGN=2
		; Se alguma variável for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a variável <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma variável de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posição da RAM		
		IMPORT string_label
		IMPORT string_mul

; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma função do arquivo for chamada em outro arquivo	
									; Permite chamar a função Start a partir de 
			                        ; outro arquivo. No caso startup.s
		EXPORT Format_strings
									
		; Se chamar alguma função externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; função <func>


; -------------------------------------------------------------------------------
;Format_strings()
;
; Entrada:
;	R0 -> numero pressinado (int)
;	R1 -> multiplicador (int)
;	R2 -> resultado da multiplicacao (int)
;
; Saida:
;	Nao ha
Format_strings
	PUSH{R3-R7, LR}
	
	;Insere R0 na label
	LDR R3, =string_label
	ADD R4, R0, #0x30
	STRB R4, [R3, #LABEL_NUM]
	
	;Insere R0, R1 e R2 em string_mul
	LDR R3, =string_mul
	BL int_to_string
	
	;insere R0
	STRB R4, [R3, #MUL_NUM1]
	;insere R1
	ADD R4, R1, #0x30
	STRB R4, [R3, #MUL_NUM2]
	
	LSR R4, R5, #0x08
	ADD R6, R3, #MUL_RES
	
	CMP R4, #'0'
	BEQ load_lsd
	
	STRB R4, [R6], #1
load_lsd
	
	;filtra lsd char
	AND R4, R5, #0xFF
	STRB R4, [R6], #1
	
	;insere \0 char
	MOV R4, #'\0'
	STRB R4, [R6]
	
	POP{R3-R7, LR}
	BX LR

; -------------------------------------------------------------------------------
;int_to_string
; 
; Descricao:
;	Converte o numero decimal de ate dois digitos em R2
;	Para uma string, guardada em R6.
;
; Entrada:
;	R2 -> numero
;
; Saida:
;	R5 -> string correspondente
int_to_string
	PUSH{R0, R1, R3, R4}
	MOV R5, #0x0
	
	;Obtem MSD
	MOV R3, #0x0A
	UDIV R0, R2, R3
	ADD R5, R0, #0x30
	LSL R5, #0x08
	
	;Obtem LSD
	MUL R0, R0, R3
	SUB R1, R2, R0
	ADD R1, #0x030
	ORR R5, R1
	
	POP{R0, R1, R3, R4}
	BX LR

; -------------------------------------------------------------------------------


	ALIGN
	END