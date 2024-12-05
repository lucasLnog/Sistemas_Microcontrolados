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
NVIC_EN1			 EQU 	0xE000E104
NVIC_PRI12 			 EQU	0xE000E430
	
; ========================
; Definicoes dos Ports

; PORT BASES
GPIO_PORTA_AHB				EQU    0x40058000
GPIO_PORTB_AHB				EQU	   0x40059000
GPIO_PORTJ_AHB				EQU	   0x40060000
GPIO_PORTN_AHB				EQU	   0x40064000
GPIO_PORTP_AHB				EQU	   0x40065000
GPIO_PORTQ_AHB				EQU	   0x40066000
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
GPIO_IS_OFF					EQU	   0x404
GPIO_IBE_OFF				EQU	   0x408
GPIO_IEV_OFF				EQU	   0x40C
GPIO_IM_OFF					EQU	   0x410
GPIO_ICR_OFF				EQU	   0x41C
	
;GPIO SYSCTL MAPING
GPIO_PORTA					EQU	   0x0
GPIO_PORTB					EQU	   0x1
GPIO_PORTJ					EQU	   0x8
GPIO_PORTN					EQU	   0xC
GPIO_PORTP					EQU	   0xD
GPIO_PORTQ					EQU	   0xE
GPIO_PORTK					EQU	   0x9
GPIO_PORTM					EQU	   0xB
GPIO_PORTL					EQU	   0xA

;TIMER
TIMER_TIMER0_GPTMCTL_R      EQU    0x4003000C
TIMER_TIMER0_GPTMCFG_R 		EQU	   0x40030000
TIMER_TIMER0_GPTMTAM_R 		EQU	   0x40030004
TIMER_TIMER0_GPTMIMR_R 		EQU	   0x40030018
TIMER_TIMER0_GPTMICR_R		EQU	   0x40030024
TIMER_TIMER0_GPTMTAIL_R 	EQU	   0x40030028

TIMER_0 					EQU    0x1
TIMER_0A_NVIC				EQU    19
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
									
		EXPORT GPIO_Init
        EXPORT Toggle_LEDs_activation
        EXPORT Write_to_LEDs

									
		; Se chamar alguma função externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; função <func>

; -------------------------------------------------------------------------------
; Função main()
GPIO_Init
	PUSH{LR}
	; R3 -> Endereco base da porta, e.g GPIO_PORTA_AHB
	; R4 -> Bit correspondente a porta nos registradores de SYSCTL
	; R5 -> Mapeamento dos pinos de saida e entrada digital da porta
	; R6 -> Pinos da porta a serem habilitados
	
	;PORTK K0-7 saida
	LDR R3, =GPIO_PORTK_AHB
	MOV R4, #GPIO_PORTK
	MOV R5, #0xFF
	MOV R6, #0xFF
	BL PORT_Init_Generic
	
	;PORTM M0-2 M4-7 saida
	LDR R3, =GPIO_PORTM_AHB
	MOV R4, #GPIO_PORTM
	MOV R5, #0xF7
	MOV R6, #0xF7
	BL PORT_Init_Generic
	
	;PORTL L0-3 entrada
	;Configurar PURs
	LDR R3, =GPIO_PORTL_AHB
	MOV R4, #GPIO_PORTL
	MOV R5, #0x00
	MOV R6, #0x0F
	BL PORT_Init_Generic
	
	MOV R5, #0x0F
	STR R5, [R3, #GPIO_PUR_OFF]
	
	;PORTJ J0-1 entrada
	;Configurar PUR
	;Configurar Interrupcoes
	LDR R3, =GPIO_PORTJ_AHB
	MOV R4, #GPIO_PORTJ
	MOV R5, #0x00
	MOV R6, #0x01 ;Ativa PJ0
	BL PORT_Init_Generic
	BL GPIOJ_Interrupt_Init
	
	MOV R5, #0x01
	STR R5, [R3, #GPIO_PUR_OFF]
	
	;PORTQ Q0-3 saida
	LDR R3, =GPIO_PORTQ_AHB
	MOV R4, #GPIO_PORTQ
	MOV R5, #0x0F
	MOV R6, #0x0F
	BL PORT_Init_Generic
	
	;PORTQ A4-7 saida
	LDR R3, =GPIO_PORTA_AHB
	MOV R4, #GPIO_PORTA
	MOV R5, #0xF0
	MOV R6, #0xF0
	BL PORT_Init_Generic
	
	;PORTP P5 saida
	LDR R3, =GPIO_PORTP_AHB
	MOV R4, #GPIO_PORTP
	MOV R5, #0x20
	MOV R6, #0x20
	BL PORT_Init_Generic
	
	
	POP{LR}
	BX LR

;--------------------------------------------------------------------------------
;Funcao PORT_Init_Generic
;Recebe parametros nos registradores R3, R4 e R5 e R6
; R3 -> Endereco base da porta, e.g GPIO_PORTA_AHB
; R4 -> Bit correspondente a porta nos registradores de SYSCTL
; R5 -> Mapeamento dos pinos de saida e entrada digital da porta
; R6 -> Pinos da porta a serem habilitados
PORT_Init_Generic
	PUSH{R0, R1, R2}
	
	;Habilita Clock na porta 
	LDR R0, =SYSCTL_RCGCGPIO_R
	LDR R1, [R0]
	MOV R2, #0x1
	LSL R2, R2, R4
	ORR R2, R1, R2		;Habilita o PORT  sem alterar os demais ports
	STR R2, [R0]
	
wait_port_ready
	LDR R0, =SYSCTL_PRGPIO_R
	LDR R1, [R0]
	CMP R1, R2
	BNE wait_port_ready	;Espera o periferico
	
	;Desabilita Funcoes Analogicas no PORT 
	MOV R1, #0x0
	STR R1, [R3, #GPIO_AMSEL_OFF]
	
	;Desabilita Funcoes Alternativas no PORT 
	STR R1, [R3, #GPIO_PCTL_OFF]
	STR R1, [R3, #GPIO_AFSEL_OFF]
	
	;Define os pinos como saida ou entrada
	STR R5, [R3, #GPIO_DIR_OFF]
	
	;Habilita a saida digital nos pinos
	STR R6, [R3, #GPIO_DEN_OFF]
	
	POP{R0, R1, R2}
	BX LR

;--------------------------------------------------------------------------------
;Funcao GPIOJ_Interrupt_Init
;Habilita e configura as interrupcoes na porta J 
GPIOJ_Interrupt_Init
	PUSH{R0, R1, LR}
	
	;GPIOIM - Desabilita as interrupcoes nos pinos PJ0 e PJ1
	;para mexermos em sua configuracao
	LDR R0, =GPIO_PORTJ_AHB
	MOV R1, #0x0
	STR R1, [R0, #GPIO_IM_OFF]
	
	;GPIOIS - Configura deteccao por borda
	MOV R1, #0x00
	STR R1, [R0, #GPIO_IS_OFF]
	
	;GPIOIBE - Configura para que a interrupcao ocorra em
	;uma unica borda e seja controlada por GPIOEV
	STR R1, [R0, #GPIO_IBE_OFF]
	
	;GPIOIEV - Configura interrupcao de falling-edge em PJ0
	MOV R1, #2_00000000
	STR R1, [R0, #GPIO_IEV_OFF]
	
	;Limpa as interrupcoes do PORT J para garantir que serao atendidas
	MOV R1, #2_00000001
	STR R1, [R0, #GPIO_ICR_OFF]
	
	;GPIOIM - Habilita que as interrupcoes nos pinos PJ0
	;sejam enviadas ao controlador de interrupcoes
	MOV R1, #2_00000001
	STR R1, [R0, #GPIO_IM_OFF]
	
	;Configura a prioridade das interrup  es do PORTJ
	LDR R0, =NVIC_PRI12
	MOV R1, #0x50 ;prioridade 5 (baixa)
	LSL R1, #0x18
	STR R1, [R0]
	
	;Habilita Interrupcoes a nivel de sistema
	;NVIC_EN1
	LDR R0, =NVIC_EN1
	LDR R1, [R0]
	MOV R2, #1
	LSL R2, R2, #0x13
	ORR R1, R1, R2
	STR R1, [R0]
		
	
	POP{R0, R1, LR}
	BX LR

    LDR R0, =GPIO_PORTP_AHB
    LDR R1, =GPIO_DATA_OFF
    LDR R2, [R0, R1]
    MOV R3, #1
    LSL R3, #5
    EOR R2, R3
    STR R2, [R0, R1]

	POP{R0-R3, LR}
	BX LR

;--------------------------------------------------------------------------------
;Funcao Write_to_LEDs
; R0 -> LEDs
Write_to_LEDs
	PUSH{R1-R3, LR}

    LDR R1, =GPIO_PORTA_AHB
    LDR R2, =GPIO_PORTQ_AHB
	MOV R3, R0
	AND R3, #0x0F
    STR R3, [R2, #GPIO_DATA_OFF]
	MOV R3, R0
	AND R3, #0xF0
    STR R3, [R1, #GPIO_DATA_OFF]

	POP{R1-R3, LR}
	BX LR

;--------------------------------------------------------------------------------
;Funcao Toggle_LEDs_activation
;No parameters
Toggle_LEDs_activation
	PUSH{R0-R3, LR}

    LDR R0, =GPIO_PORTP_AHB
    LDR R1, =GPIO_DATA_OFF
    LDR R2, [R0, R1]
    MOV R3, #1
    LSL R3, #5
    EOR R2, R3
    STR R2, [R0, R1]

	POP{R0-R3, LR}
	BX LR
	
;--------------------------------------------------------------------------------
    ALIGN                          
    END                            
