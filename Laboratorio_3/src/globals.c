#include "../include/globals.h"

uint8_t step_mode = 0;

int32_t step_motor_pos;

const int32_t kb[3][4] = {{15, 30, 45, -60},
                          {60, 90, 180, -90},
                          {-15, -30, -45, -180}};
	
