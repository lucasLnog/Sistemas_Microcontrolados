#include <stdint.h>
#include "../include/adc.h"
#include "../include/globals.h"
#include "../include/uart.h"
#include "../include/dc_motor.h"

void speed_read_potentiometer(int32_t *new_speed, int8_t *new_direction) {
    uint32_t adc_value = read_adc_blocking();
    if (adc_value > 2048) {
        *new_direction = 1;
        *new_speed = adc_value - 2048;
    } else {
        *new_speed = 2047 - adc_value;
        *new_direction = 0;
    }
}

void print_error() {
    char message[] = "Tecla invalida selecionada\n";
    send_message(message, 27);
}

void print_state_messsage() {
    uint32_t message_len;
    char* message;
    uint32_t current_speed = get_motor_speed();
    current_speed = (float)(current_speed)/20.480;
    uint32_t current_direction = get_motor_dir();
    switch (state) {
        case Initial:
            message = "Motor parado, pressione * para iniciar\n";
            message_len = 39;
            break;
        case ChooseControl:
            message = "Pressione p para controle pelo potenciometro e t para controle pelo terminal\n";
            message_len = 77;
            break;
        case TerminalSense:
            message = "Pressione h para sentido horario e a para sentido anti-horario\n";
            message_len = 63;
            break;
        case TerminalSpeed:
            message = "Pressione uma tecla entre 5 e 9 para velocidades intermediarias e 0 para velocidade maxima\nVelocidade:    %, Direcao:  \n";
            message[103] = current_speed/100 + '0';
            message[104] = (current_speed/10)%10 + '0';
            message[105] = current_speed%10 + '0';
            message[118] = current_direction + '0';
            message_len = 120;
            break;
        case Potentiometer:
            message = "Controle pelo potenciometro\nVelocidade:    %, Direcao:  \n";
            message[40] = current_speed/100 + '0';
            message[41] = (current_speed/10)%10 + '0';
            message[42] = current_speed%10 + '0';
            message[55] = current_direction + '0';
            message_len = 57;
            break;
        default:
            break;
    }
    send_message(message, message_len);
}
