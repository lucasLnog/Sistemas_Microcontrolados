#include "../include/globals.h"

char rx_buffer [50];

char tx_buffer[50];

uint16_t adc_reading = 0;

State state = Initial;
