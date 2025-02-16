#include <stdint.h>
#include "../include/state_machine.h"
#include "../include/dc_motor.h"
#include "../include/uart.h"
#include "../include/timer.h"
#include "../include/globals.h"

/* ========================== GLOBAL VARIABLES DECLARATIONS =========================== */

enum State cur_state = STARTUP;

char startup_str [] = "Motor parado, pressione \'*\' para iniciar.\n\r";
uint32_t startup_str_len = sizeof(startup_str)/sizeof(char);

/* ============================ AUX FUNCTIONS DECLARATIONS ============================ */

void exec_startup_state();
void exec_clictl_state();
void exec_potctl_state();

/* ============================= FUNCTION IMPLEMENTATIONS ============================= */

void exec_state(){
	switch(cur_state){
		case STARTUP:
			exec_startup_state();
			break;
		case CLI_CTL:
			exec_clictl_state();
			break;
		case POT_CTL:
			exec_potctl_state();
			break;
		default:
			exec_startup_state();
	}
}

/* =========================== AUX FUNCTIONS IMPLEMENTATIONS ========================== */

void exec_startup_state(){
	set_motor_speed(0, 0);
	uint16_t proceed = 0;
	
	
	send_message(startup_str, startup_str_len);
	while(!proceed){
		uint16_t read_count = 0;
		read_count = read_message(rx_buffer, 5);
		if(read_count){
			proceed = 1;
		}
	}
	switch_state(rx_buffer[0]);	
}

void exec_clictl_state(){
	
}