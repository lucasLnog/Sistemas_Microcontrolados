#include <stdint.h>
#include "../include/speed_timer.h"
#include "../lib/tm4c1294ncpdt.h"

//Inicializa Timer 2A
//32 bits periodico
void speed_timer_init(){
	SYSCTL_RCGCTIMER_R |= SYSCTL_RCGCTIMER_R2;
	while(!(SYSCTL_PRTIMER_R & SYSCTL_PRTIMER_R2));

	//Desabilita timer2A
	TIMER2_CTL_R &= ~(TIMER_CTL_TAEN);

	//Config de 32 bits
	TIMER2_CFG_R = TIMER_CFG_32_BIT_TIMER;

	TIMER2_TAMR_R = TIMER_TAMR_TAMR_PERIOD;

	//clk = 80MHz, 1s == 80_000_000 ticks
	TIMER2_TAILR_R = 80000000;

	//Config interrupcoes
	TIMER2_IMR_R |= TIMER_IMR_TATOIM;
	NVIC_EN0_R |= (1 << 23);
	NVIC_PRI5_R |= 3 << NVIC_PRI5_INT23_S;
}

void speed_timer_en(){
    TIMER2_ICR_R = TIMER_ICR_TATOCINT;
    TIMER2_CTL_R |= TIMER_CTL_TAEN;
}

void speed_timer_dis(){
    TIMER2_CTL_R &= ~(TIMER_CTL_TAEN);
}