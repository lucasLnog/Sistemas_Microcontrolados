; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>
LABEL_NUM 		EQU 0x0B
MUL_NUM1		EQU 0x00
MUL_NUM2		EQU 0x05
MUL_RES			EQU	0x09
; -------------------------------------------------------------------------------
; Área de Dados - Declarações de variáveis
		AREA  DATA, ALIGN=2
		; Se alguma variável for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a variável <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma variável de nome <var>
                                           ; de <tam> bytes a partir da primeira 
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


; -------------------------------------------------------------------------------
; Init_variables()
Variables_Init
	PUSH{R0, R1}

	;Init string_mul
	;string_mul <- "* x * = *\0\0\0"
	LDR R0, =string_mul
	
	MOV R1, #'*'
	STRB R1, [R0], #0x01
	
	MOV R1, #' '
	STRB R1, [R0], #0x01
	
	MOV R1, #'x'
	STRB R1, [R0], #0x01
	
	MOV R1, #' '
	STRB R1, [R0], #0x01
	
	MOV R1, #'*'
	STRB R1, [R0], #0x01
	
	MOV R1, #' '
	STRB R1, [R0], #0x01
	
	MOV R1, #'='
	STRB R1, [R0], #0x01
	
	MOV R1, #' '
	STRB R1, [R0], #0x01
	
	MOV R1, #'*'
	STRB R1, [R0], #0x01
	
	MOV R1, #'\0'
	STRB R1, [R0], #0x01
	
	MOV R1, #'\0'
	STRB R1, [R0], #0x01
	
	MOV R1, #'\0'
	STRB R1, [R0], #0x01
	
	;Init string_label
	;string_label <- "Tabuada do *\0"
	LDR R0, =string_label
	
	MOV R1, #'T'
	STRB R1, [R0], #0x01
	
	MOV R1, #'a'
	STRB R1, [R0], #0x01
	
	MOV R1, #'b'
	STRB R1, [R0], #0x01
	
	MOV R1, #'u'
	STRB R1, [R0], #0x01
	
	MOV R1, #'a'
	STRB R1, [R0], #0x01
	
	MOV R1, #'d'
	STRB R1, [R0], #0x01
	
	MOV R1, #'a'
	STRB R1, [R0], #0x01
	
	MOV R1, #' '
	STRB R1, [R0], #0x01
	
	MOV R1, #'d'
	STRB R1, [R0], #0x01
	
	MOV R1, #'o'
	STRB R1, [R0], #0x01
	
	MOV R1, #' '
	STRB R1, [R0], #0x01
	
	MOV R1, #'*'
	STRB R1, [R0], #0x01
	
	MOV R1, #'\0'
	STRB R1, [R0], #0x01
	
	;Init multipliers
	LDR R0, =multipliers
	ADD R1, R0, #0x0A
	MOV R3, #0x00
load_zero
	STRB R3, [R0], #0x01
	
	CMP R0, R1
	BLO load_zero
	
	;Init last_input
	LDR R0, =last_input
	MOV R1, #0xFF
	STRB R1, [R0]
	
	POP{R0, R1}
	BX LR

; -------------------------------------------------------------------------------
;Constantes

string_test DCB "Hello World!\0"

; -------------------------------------------------------------------------------
;FIM
    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo
