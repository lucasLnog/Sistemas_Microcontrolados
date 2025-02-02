
#include "../lib/tm4c1294ncpdt.h"
#include "../include/step_driver.h"


void step(int16_t steps){

}


void step_degrees(int16_t degrees){
	//Convert degrees to steps
	int16_t steps = degrees * 10;
	step(steps);
}

