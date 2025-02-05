#include "../include/timer.h"
#include "../lib//tm4c1294ncpdt.h"

//Inicializa timer A
// 32 bits one-shot mode
void timerInit(){
	//Habilita clock no Timer0
	SYSCTL_RCGCTIMER_R = SYSCTL_RCGCTIMER_R0;
	while(SYSCTL_PRTIMER_R != SYSCTL_PRI2C_R0);
	
	//Assegura que o Timer 0 esta desabilitado
	TIMER0_CTL_R &= ~(TIMER_CTL_TAEN);
	
	//Configura Timer 0 com 32 bits
	TIMER0_CFG_R = TIMER_CFG_32_BIT_TIMER;
	
	//Configura Timer 0 como one-shot
	TIMER0_TAMR_R = TIMER_TAMR_TAMR_1_SHOT;
	
}


