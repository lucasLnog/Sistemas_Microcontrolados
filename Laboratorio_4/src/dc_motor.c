#include <stdint.h>
#include "../lib/tm4c1294ncpdt.h"
#include "../include/dc_motor.h"
#include "../include/gpio.h"

/* ============================ AUX FUNCTIONS DECLARATIONS ============================ */


void motor_pins_init();
void pwm_init();

/* ============================= FUNCTION IMPLEMENTATIONS ============================= */

void dc_motor_init(){
    motor_pins_init();
    pwm_init();
}

//Inicializa os pinos PF2, PE0 e PE1
void motor_pins_init(){
    //Inicializa Port F PF2 (output)
    PortInitGeneric(
        (uint32_t) GPIO_PORTF_AHB_DATA_BITS_R,
        GPIO_PORTF,
        0x04,
        0x04
    );
    GPIO_PORTF_AHB_DATA_R |= 0x04;

    //Inicializa Port E PE0 e PE1 (outputs)
    PortInitGeneric(
        (uint32_t) GPIO_PORTE_AHB_DATA_BITS_R,
        GPIO_PORTE,
        0x03,
        0x03
    );
    GPIO_PORTE_AHB_DATA_R &= ~(0x03);
}

//inicializa Timer 1 para o pwm
void pwm_init(){

}