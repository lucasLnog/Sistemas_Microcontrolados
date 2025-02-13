#include <stdint.h>
#include "../lib/tm4c1294ncpdt.h"
#include "../include/dc_motor.h"
#include "../include/gpio.h"

/* ============================ AUX FUNCTIONS DECLARATIONS ============================ */


void motor_pins_init();
void pwm_init();
void dc_motor_timer_init();
void pwm_gen_init();
void pwm_gen_pins_init();

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
    dc_motor_timer_init();
}

//inicializa Timer 1A para o pwm
void dc_motor_timer_init(){
    //Habilita clock no periferico
    SYSCTL_RCGCTIMER_R |= SYSCTL_RCGCTIMER_R1;
    while(!(SYSCTL_PRTIMER_R & SYSCTL_PRTIMER_R1));

    //desabilita timer 1A
    TIMER1_CTL_R &= ~TIMER_CTL_TAEN;

    // modo de 32 bits
    TIMER1_CFG_R = 0x00;

    //configura eventos em ambas as bordas
    // TIMER1_CTL_R |= TIMER_CTL_TAEVENT_POS;

    //periodico
    TIMER1_TAMR_R = TIMER_TAMR_TAMR_PERIOD;

    //carrega prescaler
    // T = 1ms & clk = 80MHz => 80_000 ticks
    //prescaler = 2, ILR = 40_000
    TIMER1_TAILR_R = 80000000;
    TIMER1_TAMATCHR_R = 40000000;

    //Habilita Interrupcoes
    TIMER1_TAMR_R |= TIMER_TAMR_TAMIE;
    TIMER1_IMR_R = TIMER_IMR_TATOIM | TIMER_IMR_TAMIM;
    NVIC_EN0_R |= (1 << 21);

    //Habilita timer 1A
    TIMER1_CTL_R |= TIMER_CTL_TAEN;
}

// Inicializa o gerador de pwm 0 com f = 1kHz (T = 1ms)
void pwm_gen_init(){
    SYSCTL_RCGCPWM_R = SYSCTL_RCGCPWM_R0;
    while(!(SYSCTL_PRPWM_R));

    pwm_gen_pins_init();

    //clk = 40MHz
    PWM0_CC_R = PWM_CC_USEPWM | PWM_CC_PWMDIV_2;

    //Setup
    PWM0_CTL_R = 0x0;
    PWM0_0_GENA_R = 0x08C;
    PWM0_0_GENB_R = 0x80C;

    //Carrega LR com periodo
    PWM0_0_LOAD_R = 40000 - 1;


}

void pwm_gen_pins_init(){
    //Habilita clock no port F se nao estiver habilitado
    if(!(SYSCTL_PRGPIO_R & SYSCTL_PRGPIO_R5)){
        SYSCTL_RCGCGPIO_R |= SYSCTL_RCGCGPIO_R5;
        while(!(SYSCTL_PRGPIO_R & SYSCTL_PRGPIO_R5));
    }

    //Desabilita funcoes analogicas em PF0 e PF1
    GPIO_PORTF_AHB_AMSEL_R &= ~(0x03);

    //Seleciona funcao de PWM0
    GPIO_PORTF_AHB_PCTL_R |= (0x06 | (0x06 << 4));
    GPIO_PORTF_AHB_AFSEL_R |= 0x03;
    
    GPIO_PORTF_AHB_DEN_R |= 0x03;
}

