#include <stdint.h>
#include "../lib/tm4c1294ncpdt.h"
#include "../include/dc_motor.h"

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

}

//inicializa Timer 1 para o pwm
void pwm_init(){

}