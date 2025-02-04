// main.c
// Desenvolvido para a placa EK-TM4C1294XL
// Verifica o estado das chaves USR_SW1 e USR_SW2, acende os LEDs 1 e 2 caso estejam pressionadas independentemente
// Caso as duas chaves estejam pressionadas ao mesmo tempo pisca os LEDs alternadamente a cada 500ms.
// Prof. Guilherme Peron

#include <stdint.h>
#include "../include/systick.h"
#include "../include/step_driver.h"
#include "../include/gpio.h"
#include "../lib/tm4c1294ncpdt.h"

uint8_t string_mul = 0;
uint8_t string_label = 0;

int main(void)
{
	PLL_Init();
	SysTick_Init();
	GPIO_Init();
	
	while (1){
			pb_step(512, 0);
			SysTick_Wait1ms(100);
			GPIO_PORTN_DATA_R ^= 0x03; 
	}
}

