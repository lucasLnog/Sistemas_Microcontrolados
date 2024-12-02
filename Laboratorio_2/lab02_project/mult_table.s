; Desenvolvido para a placa EK-TM4C1294XL

; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declara��es EQU - Defines
;<NOME>         EQU <VALOR>
; -------------------------------------------------------------------------------
; �rea de Dados - Declara��es de vari�veis
		AREA  DATA, ALIGN=2
		; Se alguma vari�vel for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a vari�vel <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma vari�vel de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posi��o da RAM
multTableData SPACE 9

; -------------------------------------------------------------------------------
; �rea de C�digo - Tudo abaixo da diretiva a seguir ser� armazenado na mem�ria de 
;                  c�digo
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma fun��o do arquivo for chamada em outro arquivo	
		EXPORT Mult_table_Init
			
		; Se chamar alguma fun��o externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; fun��o <func>


; -------------------------------------------------------------------------------
; Fun��o startTabuadas()
Mult_Table_Init
	PUSH {LR}

	LDR R0, =multTableData
	MOV R1, #0
	MOV R2, #9
	
loop
	STR R1, [R0], #1
	SUBS R2, R2, #1
	BNE loop
	
	POP {LR}
	BX LR

; Comece o c�digo aqui <======================================================


    ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo
