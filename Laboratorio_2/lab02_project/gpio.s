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

; OFFSETS
GPIO_DATA_OFF				EQU	   0x3FC 
GPIO_AMSEL_OFF				EQU	   0x528
GPIO_PCTL_OFF				EQU	   0x52C
GPIO_DIR_OFF				EQU	   0x400
GPIO_AFSEL_OFF				EQU	   0x420
GPIO_DEN_OFF				EQU	   0x51C
GPIO_PUR_OFF				EQU	   0x510
	
;GPIO SYSCTL MAPING
GPIO_PORTA					EQU	   0x0
GPIO_PORTB					EQU	   0x1
GPIO_PORTJ					EQU	   0x8
GPIO_PORTN					EQU	   0xC
GPIO_PORTP					EQU	   0xD
GPIO_PORTQ					EQU	   0xE
GPIO_PORTK					EQU	   0x9
GPIO_PORTM					EQU	   0xB

;TIMER
TIMER_TIMER0_GPTMCTL_R      EQU    0x4003000C
TIMER_TIMER0_GPTMCFG_R 		EQU	   0x40030000
TIMER_TIMER0_GPTMTAM_R 		EQU	   0x40030004
TIMER_TIMER0_GPTMIMR_R 		EQU	   0x40030018
TIMER_TIMER0_GPTMICR_R		EQU	   0x40030024
TIMER_TIMER0_GPTMTAIL_R 	EQU	   0x40030028
TIMER_TIMER0_GPTMTAPR_R		EQU	   0x40030038

TIMER_0 					EQU    0x1
TIMER_0A_NVIC				EQU    19
	
TIMER_INITIAL_COUNT			EQU    7999999 
; -------------------------------------------
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
	MOV R5, #0x07
	MOV R6, #0x07
	BL PORT_Init_Generic
	
	;PORTL L0-3 entrada
	;Configurar PURs
	
	;PORTJ J0-1 entrada
	;Configurar PUR
	;Configurar Interrupcoes
	
	;PORTA A4-7
	LDR R3, =GPIO_PORTA_AHB
	MOV R4, #GPIO_PORTA
	MOV R5, #2_11110000 ; PA4, PA5, PA6, PA7
	MOV R6, R5
	BL PORT_Init_Generic
	
	;PORTQ Q0-3
	LDR R3, =GPIO_PORTQ_AHB
	MOV R4, #GPIO_PORTQ
	MOV R5, #2_00001111	; PQ0, PQ1, PQ2, PQ3
	MOV R6, R5
	BL PORT_Init_Generic
	
	;PORTP P5
	LDR R3, =GPIO_PORTP_AHB
	MOV R4, #GPIO_PORTP
	MOV R5, #2_00100000 ; PP5
	MOV R6, R5
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
;Funcao Timer_Init
;Parâmetros de entrada: Nenhum
;Parâmetros de saída: Nenhum
Timer_Init
	PUSH {LR}

	LDR R0, =SYSCTL_RCGCTIMER_R
	MOV R1, #2_00000001
	STR R1, [R0]
	
	LDR R0, =SYSCTL_PRTIMER_R
WaitTimer
	LDR R1, [R0]
	CMP R1, #2_00000001
	BNE WaitTimer

	LDR R0, =TIMER_TIMER0_GPTMCTL_R
	MOV R1, #0x0
	STR R1, [R0]
	
	LDR R0, =TIMER_TIMER0_GPTMCFG_R
	MOV R1, #0x00
	STR R1, [R0]
	
	LDR R0, =TIMER_TIMER0_GPTMTAM_R
	MOV R1, 0x2
	STR R1, [R0]
	
	LDR R0, =TIMER_TIMER0_GPTMTAPR_R
	MOV R1, 0x0
	STR R1, [R0]
	
	LDR R0, =TIMER_TIMER0_GPTMICR_R
	MOV R1, #2_0001
	STR R1, [R0]
	
	LDR R0, =TIMER_TIMER0_GPTMIMR_R
	MOV R1, #2_0001
	STR R1, [R0]
	
	LDR R0, =NVIC_PRI4_R
	MOV R1, #4
	LSL R1, R1, #29
	STR R1, [R0]
	
	LDR R0, =NVIC_EN0
	MOV R1, #1
	LSL R1, R1, =TIMER_0A_NVIC
	STR R1, [R0]

	LDR R1, =TIMER_INITIAL_COUNT
	BL TimerSetCount
	
	POP {LR}
	BX LR

;--------------------------------------------------------------------------------
;Funcao TimerSetCount
;Parâmetros de entrada: Recebe como parâmetro o valor armazenado no registrador R1.
;R1 -> Valor da contagem do timer
;Parâmetros de saída: Nenhum
TimerSetCount
	LDR R0, =TIMER_TIMER0_GPTMTAIL_R
	STR R1, [R0]
	
	LDR R0, =TIMER_TIMER0_GPTMCTL_R
	MOV R1, #0x1
	STR R1, [R0]
	
	BX LR

;--------------------------------------------------------------------------------
    ALIGN                          
    END                            
