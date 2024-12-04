; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declara��es EQU - Defines
;<NOME>         EQU <VALOR>
SYSCTL_RCGCGPIO_R	 EQU	0x400FE608
SYSCTL_RCGCTIMER_R   EQU	0x400FE604
SYSCTL_PRGPIO_R		 EQU    0x400FEA08
SYSCTL_PRTIMER_R     EQU	0x400FEA04
NVIC_EN0			 EQU	0xE000E100
NVIC_PRI4_R			 EQU	0xE000E410
NVIC_EN1_R 			 EQU    0xE000E104
NVIC_PRI12_R		 EQU    0xE000E430
; ========================
; Definicoes dos Ports

;INTERRUP��O DO PORT J
GPIO_PORTJ_AHB_IM_R         EQU    0x40060410
GPIO_PORTJ_AHB_IS_R			EQU    0x40060404
GPIO_PORTJ_AHB_IBE_R		EQU    0x40060408
GPIO_PORTJ_AHB_IEV_R		EQU    0x4006040C
GPIO_PORTJ_AHB_ICR_R		EQU    0x4006041C
PORTJ0_NVIC					EQU    19
	
;PORTJ
GPIO_PORTJ_AHB_PUR_R		EQU    0x40060510
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
									; Permite chamar a fun��o Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		EXPORT PORTJ_Interruption_Set
		EXPORT GPIOPortJ_Handler
									
		; Se chamar alguma fun��o externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; fun��o <func>
		IMPORT Variables_Init

;--------------------------------------------------------------------------------
;Funcao PORTJ_Interrupt_Set
;Par�metros de entrada: Nenhum
;Par�metros de sa�da: Nenhum
PORTJ_Interruption_Set
	;Desabilita a interrup��o no PORT J0
	LDR R0, =GPIO_PORTJ_AHB_IM_R
	MOV R1, #0x00
	STR R1, [R0]
	
	;Seta a detec��o da interrup��o por borda no PORT J0
	LDR R0, =GPIO_PORTJ_AHB_IS_R
	MOV R1, #0x00
	STR R1, [R0]
	
	;Seta detec��o por borda �nica no PORT J0
	LDR R0, =GPIO_PORTJ_AHB_IBE_R
	MOV R1, #0x00
	STR R1, [R0]
	
	;Configurando detec��o em borda de descida para o PORT J0
	LDR R0, =GPIO_PORTJ_AHB_IEV_R
	MOV R1, #0x00
	STR R1, [R0]
	
	;ACK dos registradores para garantir que a interrup��o ser� atendida
	LDR R0, =GPIO_PORTJ_AHB_ICR_R
	MOV R1, #2_00000001
	STR R1, [R0]
	
	;Habilita a interrup��o no PORT J0
	LDR R0, =GPIO_PORTJ_AHB_IM_R
	MOV R1, #2_00000001
	STR R1, [R0]
	
	;Ativa a fonte de interrup��o no NVIC
	LDR R0, =NVIC_EN1_R
	MOV R1, #1
	LSL R1, R1, #PORTJ0_NVIC
	STR R1, [R0]
	
	;Configura a prioridade da fonte de interrup��o
	LDR R0, =NVIC_PRI12_R
	MOV R1, #5
	LSL R1, R1, #29
	STR R1, [R0]
	
	BX LR

;--------------------------------------------------------------------------------
GPIOPortJ_Handler
	;ACK dos registradores para garantir que a interrup��o ser� atendida
	LDR R0, =GPIO_PORTJ_AHB_ICR_R
	MOV R1, #2_00000001
	STR R1, [R0]
	
	;Reinicia as vari�veis
	PUSH {LR}
	BL Variables_Init
	POP {LR}
	
	BX LR

	ALIGN
	END