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

uint8_t string_mul;
uint8_t string_label;

int main(void)
{
	PLL_Init();
	SysTick_Init();
	PortInitGeneric(
		GPIO_PORTH_AHB,
		GPIO_PORTH,
		0x0F,
		0x0F
	);
	PortInitGeneric(
		(uint32_t)GPIO_PORTN_DATA_BITS_R,
		GPIO_PORTN,
		0x03,
		0x03
	);
	
	while (1){
			pb_step(512);
			SysTick_Wait1ms(100);
			GPIO_PORTN_DATA_R ^= 0x03; 
	}
}

