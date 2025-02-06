#include<stdint.h>
#include "../include/handler.h"
#include "../include/globals.h"
#include "../lib/tm4c1294ncpdt.h"


void GPIOPortJ_Handler(){
	//Verifica quais interrupcoes foram acionadas (tratando todas)
	if(GPIO_PORTJ_AHB_MIS_R & 0x01){
		//Altera modo de passo
		step_mode ^= 0x1;
	}
	if(GPIO_PORTJ_AHB_MIS_R & 0x02){
		//Reseta posicao e contagem de voltas
		step_motor_pos = 0x0;
		turn_count = 0x0;
	}
	
	//Limpa Interrupcoes
	GPIO_PORTJ_AHB_ICR_R = 0x03;
}