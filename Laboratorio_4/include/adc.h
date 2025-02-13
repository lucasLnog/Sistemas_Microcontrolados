#include<stdint.h>

void adc_init();

void adc_read();

void trigger_adc_read();

void adc_disable_int();

void adc_enable_int();

uint32_t read_adc_blocking();