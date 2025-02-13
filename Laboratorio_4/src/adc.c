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
	
	//Habilita clock para o ADC0
	SYSCTL_RCGCADC_R = SYSCTL_RCGCADC_R0;
	while(!(SYSCTL_PRADC_R & SYSCTL_PRADC_R0));
	
	//Garante que o ADC0 esta configurado com
	//a maior taxa de amostragem possivel
	ADC0_PC_R = ADC_PC_MCR_FULL;
	
	//Configura prioridade dos sequenciadores.
	//SS3 recebe maior prioridade (0).
	ADC0_PSSI_R = (
		  0x00 << ADC_PSSI_SS3
		| 0x01 << ADC_PSSI_SS2
		| 0x02 << ADC_PSSI_SS1
		| 0x03 << ADC_PSSI_SS0
	);
	
	//Garante que os sequenciadores estao desativados
	//antes de configura-los
	ADC0_ACTSS_R &= ~(0x0F);
	
	//Seleciona os gatilhos dos sequenciadores
	//do ADC0.
	ADC0_EMUX_R = ADC_EMUX_EM3_PROCESSOR;
	
	//Seleciona AIN9 como entrada para o SS3
	ADC0_SSEMUX3_R = 0x0;
	ADC0_SSMUX3_R = 0x09;
	
	//Configura o pino como fonte da primeira leitura de SS3
	//Habilita interrupcoes no fim de uma conversao
	ADC0_SSCTL3_R = ADC_SSCTL3_END0 | ADC_SSCTL3_IE0;
	
	//Define prioridade para a interrupcao (4)
	NVIC_PRI4_R |= (0x04 << NVIC_PRI4_INT17_S);
	
	//Limpa interrupcao
	ADC0_ISC_R = ADC_ISC_IN3;
	
	//Habilita Interrupcao a nivel de periferico
	ADC0_IM_R |= ADC_IM_MASK3;
	
	//Habilitar interrupcao a nivel de sistema...
	NVIC_EN0_R |= (1 << 17);
	
	//Habilita SS3
	ADC0_ACTSS_R |= ADC_ACTSS_ASEN3;
	
	
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


void trigger_adc_read(){
	ADC0_PSSI_R = ADC_PSSI_SS3;
}

uint32_t read_adc_blocking(){
	ADC0_PSSI_R = ADC_PSSI_SS3;
	while(!(ADC0_RIS_R & ADC_RIS_INR3));
	
	return ADC0_SSFIFO3_R;
}


void adc_enable_int(){
	//Limpa interrupcao
	ADC0_ISC_R = ADC_ISC_IN3;
	
	//Habilita Interrupcao a nivel de periferico
	ADC0_IM_R |= ADC_IM_MASK3;
	
	//Habilitar interrupcao a nivel de sistema...
	NVIC_EN0_R |= (1 << 17);
}

void adc_disable_int(){
	//Limpa interrupcao
	ADC0_ISC_R = ADC_ISC_IN3;
	
	//Habilita Interrupcao a nivel de periferico
	ADC0_IM_R &= ~ADC_IM_MASK3;
	
	//Habilitar interrupcao a nivel de sistema...
	NVIC_EN0_R &= ~(1 << 17);
}