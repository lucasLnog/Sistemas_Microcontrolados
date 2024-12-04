; ATENCAO
; ESSE ARQUIVO SUPOE AS SEGUINTES CONEXOES A TIVA TM4C1294EXL:
; 
; RS -> PM0
; RW -> PM1
; EN -> PM2
; D0-7 -> PK0-7
; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>

; UTILS
FIRST_LINE_BASE 			EQU    0x80
SEC_LINE_BASE 				EQU    0xC0
	
; PORT BASES
GPIO_PORTK_AHB				EQU	   0x40061000
GPIO_PORTM_AHB				EQU	   0x40063000
	
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
									
		EXPORT Write_to_display
		EXPORT Display_Init
		EXPORT Issue_data
		EXPORT Issue_cmd
									
		; Se chamar alguma função externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; função <func>
		IMPORT SysTick_Wait1ms
		IMPORT SysTick_Wait1us
; -------------------------------------------------------------------------------
;Inicializa o display
Display_Init
	PUSH{LR}
	
	;espera a conclusao do reset por circuito interno
	MOV R0, #0xA
	BL SysTick_Wait1ms
	
	;configura display:
	; operacoes de 8 bits
	; config 16x2
	; caracteres 5x8
	MOV R0, #0x38
	BL Issue_cmd
	MOV R0, #0x24
	BL SysTick_Wait1us
	
	;liga display e cursor
	;cursor pisca
	;MOV R0, #0x0F
	;BL Issue_cmd
	;MOV R0, #0x24
	;BL SysTick_Wait1us
	
	;configura cursor com autoinc para a direita (0x06)
	MOV R0, #0x06
	BL Issue_cmd
	MOV R0, #0x24
	BL SysTick_Wait1us
	
	;comando de inicializacao do cursor
	;no barramento de dados (0x0E)
	MOV R0, #0x0E
	BL Issue_cmd
	MOV R0, #0x24
	
	;reset display
	MOV R0, #0x01
	BL Issue_cmd
	MOV R0, #1640
	BL SysTick_Wait1us
	
	POP{LR}
	BX LR


; -------------------------------------------------------------------------------
;Escreve a string passada como parametro para o Display
;
; 	Assume que o Display ja foi inicializado
;
; Parametros:
;	R0 -> &string
;	R1 -> string.len()
;  
Write_to_display
	PUSH{LR, R0, R2-R5}
	;R0 -> char
	;R1 -> string.len()
	;R2 -> &string
	;R3 -> index
	;R4 -> branch condition 
	;R5 -> branch condition R
	
	;transfere endereco da string
	;para R2
	MOV R2, R0
	EOR R0, R0
	
	;Zera indexador
	EOR R3, R3

string_loop
	;carrega char
	LDRB R0, [R2, R3]
	
	;escreve dado no LCD
	BL Issue_data
	
	;salva R0 em R6
	MOV R6, R0
	;espera 40us
	MOV R0, #40
	BL SysTick_Wait1us
	MOV R0, R6
	
	ADD R3, #0x1
	
	;compara index e string.len()
	EOR R4, R3, R1
	;compara char com com char NULL, '\0'
	EOR R5, R0, #0x00
	;(index != string.len() && char !== '\0')
	ANDS R4, R5
	
	BNE string_loop
	
	POP{LR, R0, R2-R5}
	BX LR


; -------------------------------------------------------------------------------
; Envia um comando para o display
;
; ATENCAO: 
;	a funcao abaixo nao espera a conclusao
;	do comando. Tal tarefa fica a cargo de
;   quem a chamou.
;
; Parametros:
; 	R0 -> comando
;
Issue_cmd
    PUSH{LR, R1, R2}
	
	;escreve comando no barramento de dados
	LDR R1, =GPIO_PORTK_AHB
	STR R0, [R1, #GPIO_DATA_OFF]
	
	;Habilita modo comando e display
	LDR R1, =GPIO_PORTM_AHB
	MOV R2, #0x04
	STR R2, [R1, #GPIO_DATA_OFF]
	
	;Espera por 10us
	MOV R6, R0
	MOV R0, #0x0A
	BL SysTick_Wait1us
	MOV R0,R6
	
	;Desabilita apenas EN
	MOV R2, #0x00
	STR R2, [R1, #GPIO_DATA_OFF]
	
	POP{LR, R1, R2}
	BX LR
; -------------------------------------------------------------------------------
; Escreve um dado no display
;
; ATENCAO: 
;	a funcao abaixo nao espera a conclusao
;	do comando. Tal tarefa fica a cargo de
;   quem a chamou.
;
; Parametros:
; 	R0 -> dado
;
Issue_data
    PUSH{LR, R1, R2}
	
	;escreve comando no barramento de dados
	LDR R1, =GPIO_PORTK_AHB
	STR R0, [R1, #GPIO_DATA_OFF]
	
	;Habilita modo comando e display
	LDR R1, =GPIO_PORTM_AHB
	MOV R2, #0x05   ; RS = 1, RW = 0, EN = 1
	STR R2, [R1, #GPIO_DATA_OFF]
	
	;Espera por 10us
	MOV R6, R0
	MOV R0, #0x0A
	BL SysTick_Wait1us
	MOV R0,R6
	
	;Desabilita EN
	MOV R2, #0x01
	STR R2, [R1, #GPIO_DATA_OFF]
	
	POP{LR, R1, R2}
	BX LR

; Comece o código aqui <======================================================

    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo
