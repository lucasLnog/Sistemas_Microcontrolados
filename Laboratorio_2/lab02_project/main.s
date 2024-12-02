; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declara��es EQU - Defines
;<NOME>         EQU <VALOR>
TIMER_TIMER0_GPTMICR_R		EQU	   0x40030024
; -------------------------------------------------------------------------------
; �rea de Dados - Declara��es de vari�veis
		AREA  DATA, ALIGN=2
		; Se alguma vari�vel for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a vari�vel <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma vari�vel de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posi��o da RAM		

; -------------------------------------------------------------------------------
; �rea de C�digo - Tudo abaixo da diretiva a seguir ser� armazenado na mem�ria de 
;                  c�digo
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma fun��o do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a fun��o Start a partir de 
			                        ; outro arquivo. No caso startup.s
		EXPORT 	Timer0A_Handler
									
		; Se chamar alguma fun��o externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; fun��o <func>
		IMPORT GPIO_Init
		IMPORT Display_Init
		IMPORT Issue_data
		IMPORT Write_to_display
		IMPORT SysTick_Init
		IMPORT PLL_Init
		IMPORT Mult_Table_Init
		IMPORT 	Timer_Init
		IMPORT 	Timer_set_count

; -------------------------------------------------------------------------------
; Função main()
Start 
	BL PLL_Init
	BL SysTick_Init
	BL GPIO_Init
	BL Display_Init
	
	LDR R0, =string_test
	MOV R1, #13
	BL Write_to_display
loop
	BL Read_keyboard
	
	;Nenhum botao foi pressionado
	CMP R5, #0xFF
	BEQ loop
	
	;Entrada:
	;	R5 -> posicao na matriz
	;Retorno:
	;	R0 -> char
	BL Pos_to_char
	
	;verifica se o character pressionado é um numero
	CMP R0, #'0'
	BLO loop
	
	CMP R0, #'9'
	BHI loop
	
	;R0 -> numero pressionado (int)
	;R1 -> multipliers[R0] (int)
	;R2 -> R0 * R3
	;R3 -> &multipliers
	
	; char -> uint
	SUB R0, #0x30
	
	LDR R3, =multipliers
	LDRB R1, [R3]
	
	MUL R2, R0, R1
	
	;Configura Timer
	
	;Dispara Timer
	
	;Insere valores de R0, R1, e R2 nas strings
	BL Format_strings
	
	LDR R0, =string_label
	MOV R1, #0xFFFF
	BL Write_to_display
	
	LDR R0, =string_mul
	BL Write_to_display
	
	
	B loop

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
	PUSH{R3-R6}
	
	;Insere R0 na label
	LDR R3, =string_label
	ADD R4, R0, #0x30
	STRB R4, [R3, #LABEL_NUM]
	
	;Insere R0, R1 e R2 em string_mul
	LDR R3, =string_mul
	BL int_to_string
	
	STRB R4, [R3, #MUL_NUM1]
	ADD R4, R1, #0x30
	STRB R4, [R3, #MUL_NUM2]
	
	LSR R4, R5, #0x08
	
	CMP R5, #'0'
	BEQ load_lsd
	
	ADD R6, R3, #MUL_RES
	STRB R5, [R6], #1
load_lsd
	
	;filtra lsd char
	AND R4, R5, #0x0F
	STRB R4, [R6], #1
	
	;insere \0 char
	MOV R4, #'\0'
	STRB R4, [R6]
	
	POP{R3-R6}
	BX LR

; -------------------------------------------------------------------------------
;int_to_string()
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
	PUSH{R0, R1, R3}
	MOV R5, #0x0
	
	;Obtem MSD
	MOV R3, #0x0A
	UDIV R0, R2, R3
	ADD R5, R0, #0x30
	LSL R5, #0x08
	
	;Obtem LSD
	SUB R1, R2, R0
	ADD R1, #0x030
	ORR R5, R1
	
	POP{R0, R1}
	BX LR

; -------------------------------------------------------------------------------
;Timer0A_Handler
Timer0A_Handler
	LDR R1, =TIMER_TIMER0_GPTMICR_R
	MOV R0, #1
	STR R0, [R1]
	BX LR

; -------------------------------------------------------------------------------
;Variaveis

;strings
string_test DCB "Hello World!/0"
string_label DCB "Tabuado do */0"
string_mul DCB "* x * = *\0\0\0"

;arrays
multipliers DCB 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0

; -------------------------------------------------------------------------------
;END
    ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo
