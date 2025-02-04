#include <stdint.h>

#define GPIO_PORTJ  (0x0100) //bit 8
#define GPIO_PORTN  (0x1000) //bit 12
#define GPIO_PORTP	(0xD)

//OFFSETS
#define GPIO_DATA_OFF					   0x3FC 
#define GPIO_AMSEL_OFF					 0x528
#define GPIO_PCTL_OFF					   0x52C
#define GPIO_DIR_OFF					   0x400
#define GPIO_AFSEL_OFF					 0x420
#define GPIO_DEN_OFF					   0x51C
#define GPIO_PUR_OFF					   0x510
#define GPIO_IS_OFF						   0x404
#define GPIO_IBE_OFF					   0x408
#define GPIO_IEV_OFF					   0x40C
#define GPIO_IM_OFF						   0x410
#define GPIO_ICR_OFF					   0x41C

void GPIO_Init(void);

void PortInitGeneric(
	volatile uint32_t *base_address,
	uint8_t sysctl_port_bit,
	uint32_t io_map,
	uint32_t pin_map
);