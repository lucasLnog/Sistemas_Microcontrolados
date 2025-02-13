#include<stdint.h>
#include "../include/handler.h"
#include "../include/globals.h"
#include "../lib/tm4c1294ncpdt.h"


void ADC0Seq3_Handler(){
	adc_reading = ADC0_SSFIFO3_R;
	ADC0_ISC_R = ADC_ISC_IN3;
}

