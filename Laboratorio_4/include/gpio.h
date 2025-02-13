#include <stdint.h>


//GPIO SYSCTL MAPING
#define GPIO_PORTA		0x0
#define GPIO_PORTB		0x1
#define GPIO_PORTJ	  0x8
#define GPIO_PORTN	  0xC
#define GPIO_PORTQ		0xE
#define GPIO_PORTK    0x9
#define GPIO_PORTM		0xB
#define GPIO_PORTL		0xA
#define GPIO_PORTP	 (0xD)
#define GPIO_PORTH	 (0x7)
#define GPIO_PORTF	  0x5 
#define GPIO_PORTE	  0x04

//PORT BASES
#define GPIO_PORTA_AHB				     0x40058000
#define GPIO_PORTB_AHB					   0x40059000
#define GPIO_PORTJ_AHB					   0x40060000
#define GPIO_PORTN_AHB					   0x40064000
#define GPIO_PORTP_AHB					   0x40065000
#define GPIO_PORTQ_AHB					   0x40066000
#define GPIO_PORTK_AHB					   0x40061000
#define GPIO_PORTM_AHB					   0x40063000
#define GPIO_PORTL_AHB					   0x40062000
#define GPIO_PORTH_AHB					   0x4005F000


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
	uint32_t base_address,
	uint8_t sysctl_port_bit,
	uint32_t io_map,
	uint32_t pin_map
);