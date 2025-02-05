#include<stdint.h>

uint8_t timer_expired = 0; 

void timerInit();

void launchTimer();

void waitMs(uint16_t ms);

void waitUs(uint16_t us);