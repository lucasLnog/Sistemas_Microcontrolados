#include <stdint.h>
#include "../lib/tm4c1294ncpdt.h"
#include "../include/systick.h"
#include "../include/gpio.h"
#include "../include/timer.h"
#include "../include/globals.h"
#include "../include/uart.h"

char hello [] = "Hello World!\n";

int main(void)
{
	PLL_Init();
	timerInit();
	SysTick_Init();
	//GPIO_Init();
	UART_Init();
	//Display_Init();
	while (1){
		uint32_t read_count = 0;
		while(!read_count ){
			read_count = read_message(rx_buffer, 50);
		}
		send_message(hello, 13);
		waitMs(500);
	}
}
