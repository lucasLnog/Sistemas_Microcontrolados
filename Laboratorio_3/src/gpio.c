// gpio.c
// Desenvolvido para a placa EK-TM4C1294XL
// Inicializa as portas J e N
// Prof. Guilherme Peron


#include <stdint.h>
#include "../lib/tm4c1294ncpdt.h"
#include "../include/gpio.h"

 
// -------------------------------------------------------------------------------
// Fun��o GPIO_Init
// Inicializa os ports J e N
// Par�metro de entrada: N�o tem
// Par�metro de sa�da: N�o tem
void GPIO_Init(void)
{
	//Inicializa PORT P bits 0-3 como saida
	PortInitGeneric(
		(uint32_t)GPIO_PORTH_AHB_DATA_BITS_R,
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
}	

void PortInitGeneric(
	uint32_t base_address,
	uint8_t sysctl_port_bit,
	uint32_t io_map,
	uint32_t pin_map
){
	//Habilita Clock na placa
	SYSCTL_RCGCGPIO_R |= 1 << sysctl_port_bit;
	while((SYSCTL_PRGPIO_R & (1 << sysctl_port_bit)) != (1 << sysctl_port_bit));
	
	//Desabilta funcoes analogicas na porta
	uint32_t* port_amsel_r = (uint32_t*)(base_address + GPIO_AMSEL_OFF);
	*port_amsel_r = 0x0;
	
	//Desabilita Funcoes alternativas na porta
	uint32_t* port_afsel_r = (uint32_t*)(base_address + GPIO_AFSEL_OFF);
	uint32_t* port_pctl_r = (uint32_t*)(base_address + GPIO_PCTL_OFF);
	*port_pctl_r = 0x0;
	*port_afsel_r = 0x0;
	
	//Define pinos de entrada e saida
	uint32_t* port_dir_r = (uint32_t*)(base_address + GPIO_DIR_OFF);
	*port_dir_r = io_map;
	
	//Habilita funcoes digitais nos pinos
	uint32_t* port_den_r = (uint32_t*)(base_address + GPIO_DEN_OFF);
	*port_den_r = pin_map;
}




