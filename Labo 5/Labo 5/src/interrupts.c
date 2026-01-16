#include <stdint.h>
#include "timer.h"
#include "gpio.h"
#include "stdbool.h"
#include "uart.h"


#define PERIPH_BASE        0x3F000000UL
#define INTC_BASE         (PERIPH_BASE + 0x00B200)

#define IRQ_BASIC_PENDING (*(volatile uint32_t*)(INTC_BASE + 0x00))
#define IRQ_PENDING1      (*(volatile uint32_t*)(INTC_BASE + 0x04))
#define IRQ_PENDING2      (*(volatile uint32_t*)(INTC_BASE + 0x08))
#define IRQ_ENABLE1       (*(volatile uint32_t*)(INTC_BASE + 0x10))
#define IRQ_ENABLE2       (*(volatile uint32_t*)(INTC_BASE + 0x14))
#define IRQ_ENABLE_BASIC  (*(volatile uint32_t*)(INTC_BASE + 0x18))
#define IRQ_DISABLE1      (*(volatile uint32_t*)(INTC_BASE + 0x1C))

#define SYS_TIMER_MATCH1_IRQ (1u << 1)

#define SYS_TIMER_BASE    (PERIPH_BASE + 0x003000)
#define TIMER_CS          (*(volatile uint32_t*)(SYS_TIMER_BASE + 0x00))
#define CS_M1             (1u << 1)

// Durées configurables des feux (en secondes)
// comme demandé dans l'énoncé du TP
static const uint32_t GREEN_DURATION  = 10;
static const uint32_t YELLOW_DURATION = 3;
static const uint32_t RED_DURATION    = 15;

// États possibles du feu
typedef enum {
    STATE_GREEN,
    STATE_YELLOW,
    STATE_RED
} traffic_state_t;

static traffic_state_t current_state = STATE_GREEN; // état initial
static uint32_t tick_count = 0;      // compte les ticks (~10ms chacun)
static uint32_t seconds_in_state = 0; // secondes écoulées dans l'état actuel

// Active le timer pour générer des interruptions
void interrupts_init(void) {
    IRQ_ENABLE1 = SYS_TIMER_MATCH1_IRQ;
}

// Fonction appelée à chaque interruption du timer
void irq_handler(void) {
    if (IRQ_PENDING1 & SYS_TIMER_MATCH1_IRQ) { // interruption timer ?
        if (TIMER_CS & CS_M1) {
            TIMER_CS = CS_M1; // reset flag du timer
            tick_count++;

            // une "seconde" est écoulée (~100 ticks de 10 ms)
            if (tick_count >= 100) {
                tick_count = 0;
                seconds_in_state++;

                switch (current_state) {
                    case STATE_GREEN:
                        if (seconds_in_state == 1) uart_puts("[STATE] GREEN ON\n");
                        if (seconds_in_state >= GREEN_DURATION) {
                            gpio_set_green(false);
                            gpio_set_yellow(true);
                            current_state = STATE_YELLOW;
                            seconds_in_state = 0;
                            uart_puts("[STATE] -> YELLOW\n");
                        }
                        break;

                    case STATE_YELLOW:
                        if (seconds_in_state == 1) uart_puts("[STATE] YELLOW ON\n");
                        if (seconds_in_state >= YELLOW_DURATION) {
                            gpio_set_yellow(false);
                            gpio_set_red(true);
                            current_state = STATE_RED;
                            seconds_in_state = 0;
                            uart_puts("[STATE] -> RED\n");
                        }
                        break;

                    case STATE_RED:
                        if (seconds_in_state == 1) uart_puts("[STATE] RED ON\n");
                        if (seconds_in_state >= RED_DURATION) {
                            gpio_set_red(false);
                            gpio_set_green(true);
                            current_state = STATE_GREEN;
                            seconds_in_state = 0;
                            uart_puts("[STATE] -> GREEN\n");
                        }
                        break;
                }
            }

            timer_schedule_next(); // planifie le prochain tick
        }
    }
}
