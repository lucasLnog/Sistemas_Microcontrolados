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
                                           ; posição da RAM		

; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma função do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a função Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma função externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; função <func>
		IMPORT GPIO_Init
		IMPORT Display_Init
		IMPORT Issue_data
		IMPORT Write_to_display
		IMPORT SysTick_Init
		IMPORT PLL_Init
		IMPORT startMultTable
		IMPORT 	Timer_Init
		IMPORT 	TimerSetCount
		EXPORT 	Timer0A_Handler


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

    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo
