; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>
TIMER_TIMER0_GPTMICR_R		EQU	   0x40030024
; -------------------------------------------------------------------------------
; Área de Dados - Declarações de variáveis
		AREA  DATA, ALIGN=2
		; Se alguma variável for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a variável <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma variável de nome <var>
                                           ; de <tam> bytes a partir da primeira 
<<<<<<< Updated upstream
                                           ; posição da RAM		
=======
                                           ; posição da RAM	

;bytes
last_input SPACE 1

;strings
string_label SPACE 16
string_mul SPACE 12

;arrays
multipliers SPACE 12

		EXPORT string_label [DATA, SIZE=16]
		EXPORT string_mul   [DATA, SIZE=12]
>>>>>>> Stashed changes

; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma função do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a função Start a partir de 
			                        ; outro arquivo. No caso startup.s
		EXPORT Variables_Init
									
<<<<<<< Updated upstream
=======
									
>>>>>>> Stashed changes
		; Se chamar alguma função externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; função <func>
		IMPORT GPIO_Init
		IMPORT Display_Init
		IMPORT Issue_data
		IMPORT Write_to_display
		IMPORT SysTick_Init
		IMPORT PLL_Init
<<<<<<< Updated upstream
		IMPORT startMultTable
		IMPORT 	Timer_Init
		IMPORT 	TimerSetCount
		EXPORT 	Timer0A_Handler
=======
		IMPORT Read_keyboard
		IMPORT Pos_to_char
		IMPORT SysTick_Wait1us
		IMPORT Issue_cmd
		IMPORT Format_strings

; -------------------------------------------------------------------------------
; Função main()
Start 
	BL PLL_Init
	BL SysTick_Init
	BL GPIO_Init
	BL Display_Init
	BL Variables_Init
	
	LDR R0, =string_test
	MOV R1, #12
	BL Write_to_display
loop
	BL Read_keyboard
	
	;Pega ultimo valor lido do teclado,
	;salva em R1 e guarda o valor recem lido
	LDR R0, =last_input
	LDRB R1, [R0]
	STRB R5, [R0]
	
	
	;Nenhum botao foi pressionado
	CMP R5, #0xFF
	BEQ loop
	
	;Permite a continuacao da execucao apenas se o ultimo
	;valor lido foi 0xFF (default, nenhuma tecla apertada)
	CMP R1, #0xFF
	BNE loop
	
	
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
	
	;multiplier = multipliers[num]
	LDR R3, =multipliers
	LDRB R1, [R3, R0]
	
	MUL R2, R0, R1
	
	;Configura Timer
	
	;Dispara Timer
	
	;Insere valores de R0, R1, e R2 nas strings
	BL Format_strings
	
	;atualiza valor do multiplicador
	;se atingir 0, o valor retorna a 1
	ADD R1, #0x01
	CMP R1, #0x0A
	MOVGE R1, #0x00
	
	STRB R1, [R3, R0]
	
	;Limpa display
	MOV R0, #0x01
	BL Issue_cmd
	
	MOV R0, #1640
	;BL SysTick_Wait1us
	
	
	;Retorna cursor para primera linha
	MOV R0, #0x02
	BL Issue_cmd
	
	MOV R0, #1640
	BL SysTick_Wait1us
	
	LDR R0, =string_label
	MOV R1, #16
	BL Write_to_display
	
	;move cursor para segunda linha
	MOV R0, #0xC0
	BL Issue_cmd
	
	MOV R0, #1640
	BL SysTick_Wait1us
	
	
	LDR R0, =string_mul
	MOV R1, #12
	BL Write_to_display
	
	
	B loop
>>>>>>> Stashed changes


; -------------------------------------------------------------------------------
; Função main()
Start
	BL startMultTable
;	BL PLL_Init
;	BL SysTick_Init
;	BL GPIO_Init
;	BL Display_Init
;	
;	LDR R0, =string_test
;	MOV R1, #13
;	BL Write_to_display
;	
;loop

;	B loop
	
; Comece o código aqui <======================================================
Timer0A_Handler
	LDR R1, =TIMER_TIMER0_GPTMICR_R
	MOV R0, #1
	STR R0, [R1]
	BX LR
	
UpdateLeds

<<<<<<< Updated upstream
=======
; -------------------------------------------------------------------------------
;Constantes

string_test DCB "Hello World!\0"

; -------------------------------------------------------------------------------
;FIM
>>>>>>> Stashed changes
    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo
