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
GPIO_PORTL_AHB				EQU	   0x40062000


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
GPIO_PORTL					EQU	   0xA

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
									
		EXPORT Timer_Init
		EXPORT Timer_set_count
		EXPORT Timer0A_Handler
									
		; Se chamar alguma função externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; funÃ§Ã£o <func>
        IMPORT current_mult_table
        IMPORT Write_to_LEDs
        IMPORT Toggle_LEDs_activation
        IMPORT multipliers


;--------------------------------------------------------------------------------
;Timer_Init()
;
; Entrada:
;	void
; Saida:
;	void
;
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
	MOV R1, #0x2
	STR R1, [R0]
	
	LDR R0, =TIMER_TIMER0_GPTMTAPR_R
	MOV R1, #0x0
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
	LSL R1, R1, #TIMER_0A_NVIC
	STR R1, [R0]

	LDR R1, =TIMER_INITIAL_COUNT
	BL Timer_set_count
	
	POP {LR}
	BX LR

;--------------------------------------------------------------------------------
;Timer_set_count()
;
;Entrada:
;	R1 -> Valor da contagem do timer
;
;Saida:
;	void
;
Timer_set_count
    PUSH{R0, R1, LR}
	LDR R0, =TIMER_TIMER0_GPTMTAIL_R
	STR R1, [R0]
	
	LDR R0, =TIMER_TIMER0_GPTMCTL_R
	MOV R1, #0x1
	STR R1, [R0]
	
    POP{R0, R1, LR}
	BX LR

;--------------------------------------------------------------------------------
;Timer0A_Handler()
Timer0A_Handler
    PUSH {R0-R4, LR}

    ;ACK interrupt
    LDR R1, =TIMER_TIMER0_GPTMICR_R
    MOV R0, #1
    STR R0, [R1]

    ;Set timer count to 100ms * current_mult_table
    LDR R1, =current_mult_table
    LDRB R0, [R1]
    LDR R2, =TIMER_INITIAL_COUNT
    MUL R1, R0, R2
    BL Timer_set_count

    ;Write to LEDs and toggle activation
	LDR R3, =multipliers
	LDRB R0, [R3, R0]
	SUB R0, #1
	CMP R0, #-1
	MOVEQ R0, #9
    MOV R1, #0xFF
    MOV R2, #8
    SUB R2, R0
    CMP R0, #9
    LSRLO R1, R2
    MOV R0, R1
    BL Write_to_LEDs
    BL Toggle_LEDs_activation

    POP {R0-R4, LR} ; retorno da interrupÃ§Ã£o
    BX LR

	ALIGN
    END
