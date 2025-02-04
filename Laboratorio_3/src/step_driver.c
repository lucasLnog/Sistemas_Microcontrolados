
#include "../lib//tm4c1294ncpdt.h"
#include "../include/step_driver.h"
#include "../include/systick.h"


#define ABS(x) (x > 0? x : -x)


//motor de passo utilizado: 28BYJ-48
//2048 steps/rev
//O driver do motor esta conectado nos pinos PH0-3
void pb_step(int16_t steps){
	//sentido horario
	if(steps > 0){
		stepClockWise(steps);
	}
	//executa passos no sentido anti-horario
	else{
		stepAntiClockWise(steps);
	}
}


void pb_stepDegrees(int16_t degrees){
	//Convert degrees to steps
	int16_t steps = degrees * 10;
	pb_step(steps);
}

void stepClockWise(int16_t steps){
	for(uint16_t i = 0; i < steps; i++){
		uint32_t data = 0x1;
		while(data != 0x10){
			GPIO_PORTH_AHB_DATA_R = data;
			data = data << 1;
			//espera...
			SysTick_Wait1ms(10);
		}
	}
}

void stepAntiClockWise(int16_t steps){
	for(int16_t i = 0; i > -steps; i++){
		uint32_t data = 0x8;
		while(data != 0x0){
			GPIO_PORTH_AHB_DATA_R = data;
			data = data >> 1;
			//espera...
		}
	}
}

