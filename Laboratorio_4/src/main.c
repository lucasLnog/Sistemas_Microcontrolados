#include <stdint.h>
#include "../lib/tm4c1294ncpdt.h"
#include "../include/systick.h"
#include "../include/gpio.h"
#include "../include/timer.h"
#include "../include/globals.h"
#include "../include/uart.h"
#include "../include/state_machine.h"
#include "../include/adc.h"
#include "../include/dc_motor.h"

char hello [] = "Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...\n\r";

int main(void)
{
	PLL_Init();
	timerInit();
	SysTick_Init();
	//GPIO_Init();
	UART_Init();
	adc_init();
	adc_disable_int();
	dc_motor_init();
	
	waitMs(1);
	exec_machine();
}
