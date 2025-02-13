#include "../include/timer.h"
#include "../lib//tm4c1294ncpdt.h"

//Inicializa timer A
// 32 bits one-shot mode
void timerInit(){
	//Habilita clock no Timer0
	SYSCTL_RCGCTIMER_R |= SYSCTL_RCGCTIMER_R0;
	while(!(SYSCTL_PRTIMER_R & SYSCTL_PRTIMER_R0));
	
	//Assegura que o Timer 0 esta desabilitado
	TIMER0_CTL_R &= ~(TIMER_CTL_TAEN);
	
	//Configura Timer 0 com 32 bits
	TIMER0_CFG_R = TIMER_CFG_32_BIT_TIMER;
	
	//Configura Timer 0 como one-shot
	TIMER0_TAMR_R = TIMER_TAMR_TAMR_1_SHOT;
	
}

void waitMs(uint16_t ms){
	waitUs(1000 * ms);
}

void waitUs(uint32_t us){
	uint32_t clocks = us * 80;
	//Load Register
	TIMER0_TAILR_R = clocks;
	
	//Launch timer
	TIMER0_CTL_R |= TIMER_CTL_TAEN;
	
	//Wait for time to run out
	while((TIMER0_RIS_R & TIMER_RIS_TATORIS) != TIMER_RIS_TATORIS);
	
	//Clear Interrupt and Disable timer
	TIMER0_ICR_R = TIMER_ICR_TATOCINT;
	TIMER0_CTL_R &= ~(TIMER_CTL_TAEN);
}

