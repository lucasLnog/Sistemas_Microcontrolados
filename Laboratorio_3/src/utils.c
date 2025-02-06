#include <stdint.h>
#include "../include/utils.h"
#include "../include/globals.h"
#include "../include/timer.h"

int32_t readDegsFromKB() {
    uint32_t stable_reads = 0;

    uint32_t last_read = Read_keyboard(); 
    for (int i = 0; i < 5; i++) {
        waitMs(10);
        uint32_t val = Read_keyboard(); 
        if (val != last_read) {
            return 0;
        }
    }
    uint32_t val = last_read; 
    uint32_t col = val & 0x0F;
    uint32_t row = val & 0xF0;
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
    char turns_string[] = "Voltas:    , Graus:     ";
    turns_string[10] = turns%10 + '0';
    turns_string[9] = turns/10 + '0';
    turns_string[23] = degrees%10 + '0';
    turns_string[22] = (degrees/10)%10 + '0';
    turns_string[21] = degrees/100 + '0';
    if (anti_clockwise) {
        turns_string[8] = '-';
        turns_string[20] = '-';
    }
    char speed_string[] = "PC";
    if (step_mode == 1) {
        speed_string[0] = 'M';
        speed_string[1] = 'P';
    }
    Clear_display();
    Write_to_display(turns_string, 24);
    Break_line();
    Write_to_display(speed_string, 2);
}

