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
									
		; Se chamar alguma fun��o externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; fun��o <func>
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
; Fun��o main()
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
	
; Comece o c�digo aqui <======================================================
Timer0A_Handler
	LDR R1, =TIMER_TIMER0_GPTMICR_R
	MOV R0, #1
	STR R0, [R1]
	BX LR
	
UpdateLeds

    ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo
