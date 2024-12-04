; Desenvolvido para a placa EK-TM4C1294XL

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>
; -------------------------------------------------------------------------------
; Área de Dados - Declarações de variáveis
		AREA  DATA, ALIGN=2
		; Se alguma variável for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a variável <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma variável de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posição da RAM
multTableData SPACE 9

; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma função do arquivo for chamada em outro arquivo	
		EXPORT startMultTable
			
		; Se chamar alguma função externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; função <func>


; -------------------------------------------------------------------------------
; Função startTabuadas()
startMultTable
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

; Comece o código aqui <======================================================


    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo
