#include<stdint.h>
#include "../include/adc.h"
#include "../lib/tm4c1294ncpdt.h"

#define GPIO_PCTL_PMC0 0x00
#define GPIO_PCTL_PMC1 0x04
#define GPIO_PCTL_PMC2 0x08
#define GPIO_PCTL_PMC3 0x0C
#define GPIO_PCTL_PMC4 0x10
#define GPIO_PCTL_PMC5 0x14
#define GPIO_PCTL_PMC6 0x18
#define GPIO_PCTL_PMC7 0x1C

/* ============================ AUX FUNCTIONS DECLARATIONS ============================ */


void adc_pins_init();

/* ============================= FUNCTION IMPLEMENTATIONS ============================= */

void adc_init(){

	
	adc_pins_init();
}


//Inicializa o pino PE4
void adc_pins_init(){
	SYSCTL_RCGCGPIO_R |= SYSCTL_RCGCGPIO_R4;
	while(!(SYSCTL_PRGPIO_R & SYSCTL_PRGPIO_R4));
	
	//Habilita funcoes analogicas no pino PE4
	//e desabilita funcoes digitais neste.
	GPIO_PORTE_AHB_DEN_R &= ~(0x01 << 4);
	GPIO_PORTE_AHB_AMSEL_R |= (0x01 << 4);
	
	//Configura PE4 como entrada
	GPIO_PORTE_AHB_DIR_R &= ~(0x01 << 4);
	
	//Habilita funcoes alternativas em PE4
	GPIO_PORTE_AHB_AFSEL_R &= ~(0x01 << 4);
	
	//Garante que a funcao analogica em GPIO_PCTL esteja
	//selecionada para PE4
	GPIO_PORTE_AHB_PCTL_R &= ~(0x0F << GPIO_PCTL_PMC4);
}