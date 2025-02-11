#include<stdint.h>

void Display_Init();

void Write_to_Display(char* string, uint32_t len);

void Issue_cmd(uint8_t cmd);

void Issue_data(uint8_t data);

