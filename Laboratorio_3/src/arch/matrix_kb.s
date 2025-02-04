; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>

; PORT BASES
GPIO_PORTK_AHB				EQU	   0x40061000
GPIO_PORTM_AHB				EQU	   0x40063000
GPIO_PORTL_AHB				EQU	   0x40062000
	
; OFFSETS
GPIO_DATA_OFF				EQU	   0x3FC 
GPIO_AMSEL_OFF				EQU	   0x528
GPIO_PCTL_OFF				EQU	   0x52C
GPIO_DIR_OFF				EQU	   0x400
GPIO_AFSEL_OFF				EQU	   0x420
GPIO_DEN_OFF				EQU	   0x51C
GPIO_PUR_OFF				EQU	   0x510
	

; -------------------------------------------------------------------------------
; Área de Dados - Declarações de variáveis
		AREA  DATA, ALIGN=2
		; Se alguma variável for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a variável <var> a 
		                                   ; partir de outro arquivo
										   
;<var>	SPACE <tam>                        ; Declara uma variável de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posição da RAM	
										 

; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma função do arquivo for chamada em outro arquivo	
									; Permite chamar a função Start a partir de 
			                        ; outro arquivo. No caso startup.s
		 EXPORT Read_keyboard
		 EXPORT Pos_to_char
									
		; Se chamar alguma função externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; função <func>
		IMPORT SysTick_Wait1ms
		IMPORT SysTick_Wait1us
; -------------------------------------------------------------------------------
; Read_keyboard
; 
; Retorno:
; 	R5/R0 -> linha e coluna da tecla pressionada. Apenas o byte menos significa
;		   tivo é utilizado
;		   Os quatro bits menos significativos dizem respeito
;		   a coluna e os 4 mais significativos a linha.
;		   
;		   Exemplo: 
;		     Linha 3, Coluna 0 pressionado => R5 <- #2_0001_1000 == 0x18
;		   
;	Caso nenhuma tecla tenha sido ativada, a funcao retornara 0xFF,
;	um valor convencionado como invalido.
;	
Read_keyboard
	PUSH{R0-R4, R6, LR}
	;R0 -> Coluna sendo lida
	;R5 -> Valor de retorno
	MOV R0, #0x04
	MOV R5, #0x00
	
columns
	;configura a coluna sendo lida como saida
	;e as demais como entrada
	MOV R4, #0x01
	; R1 <- 1 << coluna
	LSL R1, R4, R0
	LDR R2, =GPIO_PORTM_AHB
	LDR R3, [R2, #GPIO_DIR_OFF]
	AND R3, #0x0F
	ORR R1, R3
	STR R1, [R2, #GPIO_DIR_OFF]
	
	; escreve 0 na saida da coluna sendo lida
	; Bits pertinentes ao teclado -> PM4-7
	LDR R3, [R2, #GPIO_DATA_OFF]
	;seleciona informacoes dos 4bits menos significativo
	AND R3, #0x0F
	STR R3, [R2, #GPIO_DATA_OFF]
	
	MOV R6, R0
	MOV R0, #0x0A
	BL SysTick_Wait1us
	MOV R0, R6
	
	;Le entradas PL0-3
	LDR R2, =GPIO_PORTL_AHB
	LDR R1, [R2, #GPIO_DATA_OFF]
	AND R1, #0x0F
	
	;verifica se alguma tecla foi pressionada
	;se sim, guarda tecla lida e encerra loop
	; bit == 0, i.e, R1 != 0x0F => tecla pressionada
	CMP R1, #0x0F
	BNE store_key
	
	ADD R0, #0x01
	CMP R0, #0x08
	BLT columns
	MOV R5, #0xFF
	B finish_read
	
store_key
	;Inverte bits em R1
	EOR R1, #0x0F
	;Filtra bits de interesse
	AND R1, #0x0F
	
	;guarda valores na memoria:
	; usa apenas o bytes menos significativo de R5,
	; os 4 bits mais significativos são relativos a coluna
	; e os 4 menos a linha.
	; R0 <- 1 << R0
	MOV R4, #0x01
	LSL R0, R4, R0
	
	; R0 == X0
	; R1 == 0Y
	; R0 || R1 -> XY
	ORR R5, R1, R0
	
finish_read
	;Configura PM4-7 como saidas
	LDR R0, =GPIO_PORTM_AHB
	LDR R1, [R0, #GPIO_DIR_OFF]
	ORR R1, #0xF0
	STR R1, [R0, #GPIO_DIR_OFF]
	
	POP{R0-R4, R6, LR}
	MOV R0, R5
	BX LR

; -------------------------------------------------------------------------------
; Pos_to_char
; 
; Parametros:
;	R0 -> Posicao da tecla pressionada
;
; Saida:
;	R0 -> Character correspondente a tecla pressionada

Pos_to_char
	PUSH{R1, R6}
	MOV R5, R0
	;seleciona os bits de coluna
	AND R1, R5, #0xF0
	
	;garante que inicialmente R0 == 0
	MOV R0, #0x00
	
	;seleciona bits de linha
	AND R6, R5, #0x0F
	
	;pula para 
	CMP R1, #0x80
	BHS column_3
	
	CMP R1, #0x40
	BHS column_2
	
	CMP R1, #0x20
	BHS column_1
	
	B column_0
	
column_0
	CMP R6, #0x02
	MOVHS R0, #'4'
	
	CMP R6, #0x04
	MOVHS R0, #'7'
	
	CMP R6, #0x08
	MOVHS R0, #'*'
	
	;default
	CMP R0, #0x00
	MOVEQ R0, #'1'
	
	B map_end
column_1
	CMP R6, #0x02
	MOVHS R0, #'5'
	
	CMP R6, #0x04
	MOVHS R0, #'8'
	
	CMP R6, #0x08
	MOVHS R0, #'0'
	
	;default
	CMP R0, #0x00
	MOVEQ R0, #'2'
	
	B map_end
column_2
	CMP R6, #0x02
	MOVHS R0, #'6'
	
	CMP R6, #0x04
	MOVHS R0, #'9'
	
	CMP R6, #0x08
	MOVHS R0, #'#'
	
	;default
	CMP R0, #0x00
	MOVEQ R0, #'3'
	
	B map_end
column_3
	CMP R6, #0x02
	MOVHS R0, #'B'
	
	CMP R6, #0x04
	MOVHS R0, #'C'
	
	CMP R6, #0x08
	MOVHS R0, #'D'
	
	;default
	CMP R0, #0x00
	MOVEQ R0, #'A'
map_end
	
	POP{R1, R6}
	BX LR

    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo
