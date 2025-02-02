// gpio.c
// Desenvolvido para a placa EK-TM4C1294XL
// Inicializa as portas J e N
// Prof. Guilherme Peron


#include <stdint.h>
#include "../lib/tm4c1294ncpdt.h"

  
#define GPIO_PORTJ  (0x0100) //bit 8
#define GPIO_PORTN  (0x1000) //bit 12

//OFFSETS
#define GPIO_DATA_OFF					   0x3FC 
#define GPIO_AMSEL_OFF					 0x528
#define GPIO_PCTL_OFF					   0x52C
#define GPIO_DIR_OFF					   0x400
#define GPIO_AFSEL_OFF					 0x420
#define GPIO_DEN_OFF					   0x51C
#define GPIO_PUR_OFF					   0x510
#define GPIO_IS_OFF						   0x404
#define GPIO_IBE_OFF					   0x408
#define GPIO_IEV_OFF					   0x40C
#define GPIO_IM_OFF						   0x410
#define GPIO_ICR_OFF					   0x41C

// -------------------------------------------------------------------------------
// Fun��o GPIO_Init
// Inicializa os ports J e N
// Par�metro de entrada: N�o tem
// Par�metro de sa�da: N�o tem
void GPIO_Init(void)
{
	//1a. Ativar o clock para a porta setando o bit correspondente no registrador RCGCGPIO
	SYSCTL_RCGCGPIO_R = (GPIO_PORTJ | GPIO_PORTN);
	//1b.   ap�s isso verificar no PRGPIO se a porta est� pronta para uso.
  while((SYSCTL_PRGPIO_R & (GPIO_PORTJ | GPIO_PORTN) ) != (GPIO_PORTJ | GPIO_PORTN) ){};
	
	// 2. Limpar o AMSEL para desabilitar a anal�gica
	GPIO_PORTJ_AHB_AMSEL_R = 0x00;
	GPIO_PORTN_AMSEL_R = 0x00;
		
	// 3. Limpar PCTL para selecionar o GPIO
	GPIO_PORTJ_AHB_PCTL_R = 0x00;
	GPIO_PORTN_PCTL_R = 0x00;

	// 4. DIR para 0 se for entrada, 1 se for sa�da
	GPIO_PORTJ_AHB_DIR_R = 0x00;
	GPIO_PORTN_DIR_R = 0x03; //BIT0 | BIT1
		
	// 5. Limpar os bits AFSEL para 0 para selecionar GPIO sem fun��o alternativa	
	GPIO_PORTJ_AHB_AFSEL_R = 0x00;
	GPIO_PORTN_AFSEL_R = 0x00; 
		
	// 6. Setar os bits de DEN para habilitar I/O digital	
	GPIO_PORTJ_AHB_DEN_R = 0x03;   //Bit0 e bit1
	GPIO_PORTN_DEN_R = 0x03; 		   //Bit0 e bit1
	
	// 7. Habilitar resistor de pull-up interno, setar PUR para 1
	GPIO_PORTJ_AHB_PUR_R = 0x03;   //Bit0 e bit1	

}	

// -------------------------------------------------------------------------------
// Fun��o PortJ_Input
// L� os valores de entrada do port J
// Par�metro de entrada: N�o tem
// Par�metro de sa�da: o valor da leitura do port
uint32_t PortJ_Input(void)
{
	return GPIO_PORTJ_AHB_DATA_R;
}

// -------------------------------------------------------------------------------
// Fun��o PortN_Output
// Escreve os valores no port N
// Par�metro de entrada: Valor a ser escrito
// Par�metro de sa�da: n�o tem
void PortN_Output(uint32_t valor)
{
    uint32_t temp;
    //vamos zerar somente os bits menos significativos
    //para uma escrita amig�vel nos bits 0 e 1
    temp = GPIO_PORTN_DATA_R & 0xFC;
    //agora vamos fazer o OR com o valor recebido na fun��o
    temp = temp | valor;
    GPIO_PORTN_DATA_R = temp; 
}

void PORTInitGeneric(
	volatile uint32_t *base_address,
	uint8_t sysctl_port_bit,
	uint32_t io_map,
	uint32_t pin_map
){
	//Habilita Clock na placa
	SYSCTL_RCGCGPIO_R |= 1 << sysctl_port_bit;
	while((SYSCTL_PRGPIO_R & (1 << sysctl_port_bit)) != (1 << sysctl_port_bit));
	
	//Desabilta funcoes analogicas na porta
	volatile uint32_t* port_amsel_r = (base_address + GPIO_AMSEL_OFF);
	*port_amsel_r = 0x0;
	
	//Desabilita Funcoes alternativas na porta
	volatile uint32_t* port_afsel_r = (base_address + GPIO_AFSEL_OFF);
	volatile uint32_t* port_pctl_r = (base_address + GPIO_PCTL_OFF);
	*port_pctl_r = 0x0;
	*port_afsel_r = 0x0;
	
	//Define pinos de entrada e saida
	volatile uint32_t* port_dir_r = (base_address + GPIO_DIR_OFF);
	*port_dir_r = io_map;
	
	//Habilita funcoes digitais nos pinos
	volatile uint32_t* port_den_r = (base_address + GPIO_DEN_OFF);
	*port_den_r = pin_map;
}




