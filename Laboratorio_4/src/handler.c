#include<stdint.h>
#include "../include/handler.h"
#include "../include/globals.h"
#include "../include/dc_motor.h"
#include "../include/uart.h"
#include "../lib/tm4c1294ncpdt.h"

char speed_str [] = "Velocidade: 000\n\r";
uint32_t speed_str_len = sizeof(speed_str)/sizeof(char);

void ADC0Seq3_Handler(){
	adc_reading = ADC0_SSFIFO3_R;
	ADC0_ISC_R = ADC_ISC_IN3;
}

void Timer1A_Handler(){
	if(TIMER1_MIS_R & TIMER_MIS_TATOMIS){
		GPIO_PORTE_AHB_DATA_R &= ~(0x03);
	}
	else if(TIMER1_MIS_R & TIMER_MIS_TAMMIS){
		if(get_motor_dir())
			GPIO_PORTE_AHB_DATA_R |= 0x01;
		else
			GPIO_PORTE_AHB_DATA_R |= 0x02;
	}
	TIMER1_ICR_R = TIMER_ICR_TATOCINT | TIMER_ICR_TAMCINT;
}

void Timer2A_Handler(){
	uint16_t speed = get_motor_speed();
	for(uint8_t i = 0; i < 3; i++){
		speed_str[speed_str_len - (i + 4)] = (char)(speed % 10 + 0x30);
		speed /= 10;
	}
	send_message(speed_str, speed_str_len);
	TIMER2_ICR_R = TIMER_ICR_TATOCINT;
}

