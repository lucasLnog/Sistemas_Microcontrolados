#include <stdint.h>
#include "../lib/tm4c1294ncpdt.h"
#include "../include/dc_motor.h"
#include "../include/gpio.h"

/* ============================ AUX FUNCTIONS DECLARATIONS ============================ */


void motor_pins_init();
void pwm_init();
void dc_motor_timer_init();
void pwm_gen_init();

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


void pwm_init(){

}

//inicializa Timer 1A para o pwm
void dc_motor_timer_init(){
    //Habilita clock no periferico
    SYSCTL_RCGCTIMER_R |= SYSCTL_RCGCTIMER_R1;
    while(!(SYSCTL_PRTIMER_R & SYSCTL_PRTIMER_R1));

    //desabilita timer 1A
    TIMER1_CTL_R &= ~TIMER_CTL_TAEN;

    // modo de 16 bits
    TIMER1_CFG_R = 0x04;

    //periodico, pwm e sem captura
    TIMER1_TAMR_R = TIMER_TAMR_TAMR_PERIOD | TIMER_TAMR_TAAMS;

    //carrega prescaler
    // T = 1ms & clk = 80MHz => 80_000 ticks
    //prescaler = 2, ILR = 40_000
    TIMER1_TAPR_R = 2;
    TIMER1_TAILR_R = 40000;
    TIMER1_TAMATCHR_R = 0;

    //Habilita Interrupcoes
    TIMER1_TAMR_R |= TIMER_TAMR_TAPWMIE;
    NVIC_EN0_R |= (1 << 21);

    //Habilita timer 1A
    TIMER1_CTL_R |= TIMER_CTL_TAEN;
}

// Inicializa o gerador de pwm 0 com f = 1kHz (T = 1ms)
void pwm_gen_init(){

}