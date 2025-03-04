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
#include "../include/timer.h"
#include "../include/utils.h"
#include "../include/globals.h"
#include "../include/lcd.h"

uint8_t string_mul = 0;
uint8_t string_label = 0;

int main(void)
{
	PLL_Init();
	timerInit();
	SysTick_Init();
	GPIO_Init();
	Display_Init();
	while (1){
        int32_t rotation_amount = readDegsFromKB();
        step_motor_pos += rotation_amount;
				writeRotToDisplay(step_motor_pos);
        pb_stepDegrees(rotation_amount, step_mode);
	}
}
