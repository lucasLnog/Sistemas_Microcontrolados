#include <stdint.h>
#include "../include/state_machine.h"
#include "../include/dc_motor.h"
#include "../include/uart.h"
#include "../include/timer.h"
#include "../include/globals.h"
#include "../include/adc.h"
#include "../include/speed_timer.h"

#define MAX_SPEED_DIV 21

/* ========================== GLOBAL VARIABLES DECLARATIONS =========================== */

enum State cur_state = STARTUP;

char startup_str [] = "Motor parado, pressione \'*\' para iniciar.\n\r";
uint32_t startup_str_len = sizeof(startup_str)/sizeof(char);

char ctl_select_str [] = "Controle por CLI (t) ou potenciometro (p):\n\r";
uint32_t ctl_sel_str_len = sizeof(ctl_select_str)/sizeof(char);

char cli_sel_dir_str [] = "Selecione o sentido de rotacao: Horario (h) ou Anti-horario (a):\n\r";
uint32_t cli_sel_dir_len = sizeof(cli_sel_dir_str)/sizeof(char);

char cli_sel_speed_str [] = "Seleciona a velocidade de rotacao 1 = 10\%, 2 = 20\%, ..., 0 = 100\%\n\r";
uint32_t cli_sel_speed_len = sizeof(cli_sel_speed_str)/sizeof(char);

char adc_read_str [] = "Leitura ADC: 0000\n\r";
uint32_t adc_read_len = sizeof(adc_read_str)/sizeof(char);

/* ============================ AUX FUNCTIONS DECLARATIONS ============================ */

char exec_startup_state();
char exec_clictl_state();
char exec_potctl_state();

void switch_state(char input);

uint8_t speed_to_duty(uint16_t speed);

/* ============================= FUNCTION IMPLEMENTATIONS ============================= */

void exec_machine(){
	while(1){
		char val = exec_state();
		switch_state(val);
	}
}

char exec_state(){
	switch(cur_state){
		case STARTUP:
			return exec_startup_state();
		case CLI_CTL:
			return exec_clictl_state();
		case POT_CTL:
			return exec_potctl_state();
		default:
			return exec_startup_state();
	}
}

/* =========================== AUX FUNCTIONS IMPLEMENTATIONS ========================== */

char exec_startup_state(){
	set_motor_speed(0, 0);
	speed_timer_dis();
	
	send_message(startup_str, startup_str_len);
	while(1){
		uint16_t read_count = 0;
		read_count = read_message(rx_buffer, 5);
		
		if(read_count){
			if(rx_buffer[0] == '*')
				send_message(ctl_select_str, ctl_sel_str_len);
			else
				return rx_buffer[0];
		}
	}
}

char exec_clictl_state(){
	send_message(cli_sel_dir_str, cli_sel_dir_len);
	rx_buffer[0]= 'i';
	
	while(rx_buffer[0] != 'h' && rx_buffer[0] != 'a'){
		read_message(rx_buffer, 5);
	}

	uint8_t dir = rx_buffer[0] == 'a'? 1 : 0;
	
	send_message(cli_sel_speed_str, cli_sel_speed_len);
	while(rx_buffer[0] < '0' || rx_buffer[0] > '9'){
		read_message(rx_buffer, 5);
	}
	uint16_t speed = (uint16_t)(rx_buffer[0] - 0x30) * 10;

	set_motor_speed(speed, dir);
	
	speed_timer_en();
	while(1){
		uint32_t read_count = read_message(rx_buffer, 5);
		if(read_count){
			if(rx_buffer[0] >= '0' && rx_buffer[0] <= '9'){
				uint16_t speed = (uint16_t)(rx_buffer[0] - 0x30) * 10;
				if(speed == 0){
					set_motor_speed(100, get_motor_dir());
				} else{
					set_motor_speed(speed, get_motor_dir());
				}
			}
			else if(rx_buffer[0] == 'h' && get_motor_dir() != 0){
				set_motor_speed(get_motor_speed(), 0);
			}
			else if(rx_buffer[0] == 'a' && get_motor_dir() != 1){
				set_motor_speed(get_motor_speed(), 1);
			}
			else if(rx_buffer[0] == 's'){
				return 's';
			}
		}
	}
	
}

char exec_potctl_state(){
	uint32_t count = 0;
	speed_timer_en();
	while(1){
		uint32_t read_count = read_message(rx_buffer, 5);
		if(read_count && rx_buffer[0] == 's'){
			return 's';
		}
		if(count > 500){
			uint32_t pot_read = read_adc_blocking();

			if(pot_read > 2048){
				set_motor_speed(speed_to_duty(pot_read - 2048), 1);
			} else{
				set_motor_speed(speed_to_duty(pot_read), 0);
			}
			count = 0;
		}
		count++;
	}
}

void switch_state(char read_char){
	switch (read_char){
		case 'p':
			cur_state = POT_CTL;
			break;
		case 't':
			cur_state = CLI_CTL;
			break;
		case 's':
			cur_state = STARTUP;
			break;
		default:
			cur_state = STARTUP;
	}
}

uint8_t speed_to_duty(uint16_t speed){
    return speed/MAX_SPEED_DIV;
}