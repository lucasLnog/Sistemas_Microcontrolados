#include <stdint.h>

void dc_motor_init();

void set_motor_speed(uint16_t speed, uint8_t dir);

uint16_t get_motor_speed();

uint8_t get_motor_dir();

void set_duty_cycle(uint8_t duty);