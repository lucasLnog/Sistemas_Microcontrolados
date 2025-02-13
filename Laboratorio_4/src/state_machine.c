#include "../include/globals.h"
#include "../include/app_utils.h"
#include <stdint.h>

void parse_message(char message, int32_t *new_speed, int8_t *new_direction) {
    switch (message) {
        case '*':
            if (state == Initial) {
                state = ChooseControl;
            } else {
                print_error();
            }
            break;
        case 'p':
            if (state == ChooseControl) {
                state = Potentiometer;
            } else {
                print_error();
            }
            break;
        case 't':
            if (state == ChooseControl) {
                state = TerminalSense;
            } else {
                print_error();
            }
            break;
        case 'h':
            if (state == TerminalSense) {
                state = TerminalSpeed;
                *new_direction = 0;
            } else {
                print_error();
            }
            break;
        case 'a':
            if (state == TerminalSense) {
                state = TerminalSpeed;
                *new_direction = 1;
            } else {
                print_error();
            }
            break;
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
        case '0':
            if (state == TerminalSpeed) {
                *new_speed = (message == '0' ? 2048 : 2048*(((float)(message - '0')) / 10.0));
            } else {
                print_error();
            }
            break;
        case 's':
            if (state == Potentiometer || state == TerminalSpeed) {
                *new_speed = 0;
                *new_direction = 0;
                state = ChooseControl;
            }
            break;
        default:
            print_error();
            break;
    }

}
