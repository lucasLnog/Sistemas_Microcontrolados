#include<stdint.h>

void UART_Init();

//Envia a mensagem contida num buffer. 
//Se a FIFO de TX estiver cheia, a funcao para.
//Retorna a quantidade de caracteres enviados
uint32_t send_message(char* buffer, uint32_t size);

//Le fila de entrada da UART ate que o buffer esteja cheio ou
//A fila esteja vazia.
//Retorna a quantidade de caracteres lidos
uint32_t read_message(char* buffer, uint32_t size);