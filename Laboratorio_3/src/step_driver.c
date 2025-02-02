
#include "../lib/tm4c1294ncpdt.h"
#include "../include/step_driver.h"


#define ABS(x) (x > 0? x : -x)

//motor de passo utilizado: 28BYJ-48
//2048 steps/rev
//O driver do motor esta conectado nos pinos PH0-3
void pfx_step(int16_t steps){
	if(steps > 0){
		//sentido horario
		for(uint16_t i = 0; i < steps; i++){
			uint32_t portp = 0x1;
			while(portp != 0x10){
					GPIO_PORTH_AHB_DATA_R = portp;
					portp = portp << 1;
					//espera...
			}
		}
	} else{
		//executa passos no sentido anti-horario
		for(uint16_t i = 0; i < -steps; i++){
			uint32_t portp = 0x8;
			while(portp != 0x0){
					GPIO_PORTH_AHB_DATA_R = portp;
					portp = portp >> 1;
				//espera...
			}
		}
	}
}


void pfx_stepDegrees(int16_t degrees){
	//Convert degrees to steps
	int16_t steps = degrees * 10;
	pfx_step(steps);
}

