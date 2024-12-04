; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
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

;INTERRUPÇÃO DO PORT J
GPIO_PORTJ_AHB_IM_R         EQU    0x40060410
GPIO_PORTJ_AHB_IS_R			EQU    0x40060404
GPIO_PORTJ_AHB_IBE_R		EQU    0x40060408
GPIO_PORTJ_AHB_IEV_R		EQU    0x4006040C
GPIO_PORTJ_AHB_ICR_R		EQU    0x4006041C
PORTJ0_NVIC					EQU    19
	
;PORTJ
GPIO_PORTJ_AHB_PUR_R		EQU    0x40060510
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
									
		EXPORT PORTJ_Interruption_Set
		EXPORT GPIOPortJ_Handler
									
		; Se chamar alguma função externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; função <func>
		IMPORT Variables_Init

;--------------------------------------------------------------------------------
;Funcao PORTJ_Interrupt_Set
;Parâmetros de entrada: Nenhum
;Parâmetros de saída: Nenhum
PORTJ_Interruption_Set
	;Desabilita a interrupção no PORT J0
	LDR R0, =GPIO_PORTJ_AHB_IM_R
	MOV R1, #0x00
	STR R1, [R0]
	
	;Seta a detecção da interrupção por borda no PORT J0
	LDR R0, =GPIO_PORTJ_AHB_IS_R
	MOV R1, #0x00
	STR R1, [R0]
	
	;Seta detecção por borda única no PORT J0
	LDR R0, =GPIO_PORTJ_AHB_IBE_R
	MOV R1, #0x00
	STR R1, [R0]
	
	;Configurando detecção em borda de descida para o PORT J0
	LDR R0, =GPIO_PORTJ_AHB_IEV_R
	MOV R1, #0x00
	STR R1, [R0]
	
	;ACK dos registradores para garantir que a interrupção será atendida
	LDR R0, =GPIO_PORTJ_AHB_ICR_R
	MOV R1, #2_00000001
	STR R1, [R0]
	
	;Habilita a interrupção no PORT J0
	LDR R0, =GPIO_PORTJ_AHB_IM_R
	MOV R1, #2_00000001
	STR R1, [R0]
	
	;Ativa a fonte de interrupção no NVIC
	LDR R0, =NVIC_EN1_R
	MOV R1, #1
	LSL R1, R1, #PORTJ0_NVIC
	STR R1, [R0]
	
	;Configura a prioridade da fonte de interrupção
	LDR R0, =NVIC_PRI12_R
	MOV R1, #5
	LSL R1, R1, #29
	STR R1, [R0]
	
	BX LR

;--------------------------------------------------------------------------------
GPIOPortJ_Handler
	;ACK dos registradores para garantir que a interrupção será atendida
	LDR R0, =GPIO_PORTJ_AHB_ICR_R
	MOV R1, #2_00000001
	STR R1, [R0]
	
	;Reinicia as variáveis
	PUSH {LR}
	BL Variables_Init
	POP {LR}
	
	BX LR

	ALIGN
	END