#include "../include/uart.h"
#include "../lib/tm4c1294ncpdt.h"

/* ============================ AUX FUNCTIONS DECLARATIONS ============================ */


void config_uart0_pins();

/* ============================= FUNCTION IMPLEMENTATIONS ============================= */
void UART_Init(){
	//Habilita Clock no UART0
	SYSCTL_RCGCUART_R = SYSCTL_RCGCUART_R0;
	while((SYSCTL_PRUART_R & SYSCTL_PRUART_R0) != SYSCTL_PRUART_R0);
	
	//Desabilita UARTEN para realizar a configuracao
	UART0_CTL_R = 0x0;
	
	//Configura um Baud Rate de 19200bps
	//80_000_000/(16 * 19200) = 260,4167
	UART0_IBRD_R = 260;
	// 0,4167 * 64 = 26,27 => ~27
	UART0_FBRD_R = 27;
	
	//Escreve em LCRH para aplicar configuracoes de baud
	UART0_LCRH_R =  UART_LCRH_WLEN_8 | UART_LCRH_FEN;
	
	//Seleciona clock do sistema como clock da UART0
	UART0_CC_R = UART_CC_CS_SYSCLK;
	
	//Habilita UART0
	UART0_CTL_R = UART_CTL_RXE | UART_CTL_TXE | UART_CTL_UARTEN;
	
	config_uart0_pins();
	
}

//Pinos PA0 (RX) e PA1 (TX)
void config_uart0_pins(){
	//habilita Clock no Port A
	SYSCTL_RCGCGPIO_R |= SYSCTL_RCGCGPIO_R0;
	while((SYSCTL_PRGPIO_R & SYSCTL_PRGPIO_R0) != SYSCTL_PRGPIO_R0);
	
	//Desabilita funcionalidades analogicas nos pinos PA0 e PA1
	GPIO_PORTA_AHB_AMSEL_R &= ~(0x3);
	
	//Seleciona as funcoes de UART para PA0 e PA1
	GPIO_PORTA_AHB_PCTL_R |= 0x11;
		
	//Habilita as funcoes alternativas nos pinos PA0 e PA1
	GPIO_PORTA_AHB_AFSEL_R |= 0x03;
	
	//Habilita funcoes digitais nos pinas PA0 e PA1
	GPIO_PORTA_AHB_DEN_R |= 0x03;	
}

uint32_t send_message(char* buffer, uint32_t size){
	uint32_t sent_count = 0;
	
	while(sent_count < size && !(UART0_FR_R & UART_FR_TXFF)){
		UART0_DR_R = buffer[sent_count];
		sent_count++;
	}
	return sent_count;
}

uint32_t read_message(char* buffer, uint32_t size){
	uint32_t read_count = 0;
	
	while(read_count < size && !(UART0_FR_R & UART_FR_RXFE)){
		buffer[read_count] = UART0_DR_R;
		read_count++;
	}
	return read_count;
}

