#include<stdint.h>

void UART_Init();

uint32_t send_message(char* buffer, uint32_t size);

uint32_t read_message(char* buffer, uint32_t size);