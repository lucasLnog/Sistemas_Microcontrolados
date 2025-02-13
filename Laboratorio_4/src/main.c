#include <stdint.h>
#include "../lib/tm4c1294ncpdt.h"
#include "../include/systick.h"
#include "../include/gpio.h"
#include "../include/timer.h"
#include "../include/globals.h"
#include "../include/uart.h"
#include "../include/state_machine.h"
#include "../include/adc.h"
#include "../include/app_utils.h"
#include "../include/dc_motor.h"



int main(void)
{
	PLL_Init();
	timerInit();
	SysTick_Init();
	UART_Init();
    adc_init();
    adc_disable_int();
	while (1){
        print_state_messsage();
        int32_t new_speed = -1;
        int8_t new_direction = -1;
		uint32_t read_count = 0;
        char message;
        read_count = read_message(&message, 1);
        if (read_count == 0) {
            if (state == Potentiometer) {
                speed_read_potentiometer(&new_speed, &new_direction);
            }
        } else {
            parse_message(message, &new_speed, &new_direction);
            if (new_speed == -1) {
                new_speed = get_motor_speed();
            }
            if (new_direction == -1) {
                new_direction = get_motor_dir();
            }
        }
        set_motor_speed(new_speed, new_direction);
	}
}
