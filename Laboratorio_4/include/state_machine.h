#ifndef STATE_MACHINE_H
#define STATE_MACHINE_H

#include <stdint.h>
#define STATE_MACHINE_H
void parse_message(char message, int32_t *new_speed, int8_t *new_direction);

typedef enum state_enum {
    Initial,
    ChooseControl,
    Potentiometer,
    TerminalSense,
    TerminalSpeed
} State;

#endif
