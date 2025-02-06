#include <stdint.h>

uint32_t Read_keyboard();

void Write_to_display(char* string, int len);

void Break_line(); 

void Clear_display(); 

void writeRotToDisplay(int rotation_amount);

int32_t readDegsFromKB();
