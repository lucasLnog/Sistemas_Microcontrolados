
#include "../lib//tm4c1294ncpdt.h"
#include "../include/step_driver.h"
#include "../include/timer.h"


#define ABS(x) (x > 0? x : -x)

uint8_t half_step_seq [8]= {
	0b0001,
	0b0011,
	0b0010,
	0b0110,
	0b0100,
	0b1100,
	0b1000,
	0b1001
};

uint8_t full_step_seq [4]= {
	0x1,
	0x2,
	0x4,
	0x8,
};


//motor de passo utilizado: 28BYJ-48
//2048 steps/rev
//O driver do motor esta conectado nos pinos PH0-3
void pb_step(int16_t steps, uint8_t half_step){
	//sentido horario
	if(steps > 0){
		stepClockWise(steps, half_step);
	}
	//executa passos no sentido anti-horario
	else{
		stepAntiClockWise(steps, half_step);
	}
}


void pb_stepDegrees(int16_t degrees, uint8_t half_step){
	//Convert degrees to steps
	int16_t steps = degrees * 10;
	pb_step(steps, half_step);
}

void stepClockWise(int16_t steps, uint8_t half_step){
	uint8_t *data = full_step_seq;
	uint8_t seq_len = 4;
	
	if(half_step){
		data = half_step_seq;
		seq_len = 8;
	}
	for(uint16_t i = 0; i < steps; i++){
		for(uint8_t j = 0; j < seq_len; j++){
			GPIO_PORTH_AHB_DATA_R = data[j];
			//espera...
			waitMs(5);
		}
	}
}

void stepAntiClockWise(int16_t steps, uint8_t half_step){
	uint8_t *data = full_step_seq;
	uint8_t seq_len = 4;
	steps = -steps;
	
	if(half_step){
		data = half_step_seq;
		seq_len = 8;
	}
	
	for(int16_t i = 0; i < steps; i++){
		for(uint8_t j = seq_len - 1; j >= 0; j--){
			GPIO_PORTH_AHB_DATA_R = data[j];
			//espera...
			waitMs(5);
		}
	}
}

