#include <stdint.h>
#include "../include/utils.h"
#include "../include/globals.h"
#include "../include/timer.h"

uint32_t lg2(uint32_t x) {
	uint32_t ans = 0;
	while (x > 1) {
		ans++;
		x /= 2;
	}
	return ans;
}

int32_t readDegsFromKB() {
    uint32_t stable_reads = 0;

    uint32_t last_read = Read_keyboard(); 
    for (uint8_t i = 0; i < 5; i++) {
        waitMs(10);
        uint32_t val = Read_keyboard(); 
        if (val != last_read) {
            return 0;
        }
    }
    uint32_t val = last_read; 
    uint32_t col = lg2((val >> 4) & 0x0F);
    uint32_t row = lg2(val & 0x0F);
    if (col > 3 || row > 2) {
        return 0;
    }
    return kb[row][col];
}

void writeRotToDisplay(int rotation_amount) {
    int anti_clockwise = 0;
    if (rotation_amount < 0) {
        anti_clockwise = 1;
        rotation_amount = -1*rotation_amount;
    }
    int turns = (rotation_amount/360) % 100;
    int degrees = rotation_amount%360;
    char turns_string[] = "Voltas:    ";
		char degree_string[] = " Graus:      PC";
    turns_string[10] = turns%10 + '0';
    turns_string[9] = turns/10 + '0';
    degree_string[11] = degrees%10 + '0';
    degree_string[10] = (degrees/10)%10 + '0';
    degree_string[9] = degrees/100 + '0';
    if (anti_clockwise) {
				if (turns != 0)
					turns_string[8] = '-';
        if (degrees != 0)
					degree_string[8] = '-';
    }
    if (step_mode == 1) {
        degree_string[13] = 'M';
        degree_string[14] = 'P';
    }
    Clear_display();
    Write_to_display(turns_string, 11);
    Break_line();
    Write_to_display(degree_string, 15);
}

