#include<stdint.h>
#include "../include/handler.h"
#include "../include/globals.h"
#include "../lib/tm4c1294ncpdt.h"


void ADC0Seq3_Handler(){
	adc_reading = ADC0_SSFIFO3_R;
	ADC0_ISC_R = ADC_ISC_IN3;
}

void Timer1A_Handler(){
	if(TIMER1_MIS_R & TIMER_MIS_TAMMIS){
		GPIO_PORTN_DATA_R = 0x01;
	}
	else if(TIMER1_MIS_R & TIMER_MIS_TATOMIS){
		GPIO_PORTN_DATA_R = 0x00;
	}
	TIMER1_ICR_R = TIMER_ICR_TATOCINT | TIMER_ICR_TAMCINT;
}

