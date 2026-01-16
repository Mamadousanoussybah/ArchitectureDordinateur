#include <stdint.h>
#include <stdbool.h>

void uart_init(void);
void gpio_init(void);
void timer_init(void);
void interrupts_init(void);
void gpio_set_green(bool on);
void gpio_set_yellow(bool on);
void gpio_set_red(bool on);

int main(void) {
    uart_init();         //iniTialisaTion UART pour le debug   
    gpio_init();         // iniTialisaTion des LEDs
    interrupts_init();   // Sa nous permet d'activé les interruptions timer
    timer_init();        // Sa demmarre le timer

    // Ici on démarre avec la lumiere verte en respectant La logique
    gpio_set_green(true);

    for (;;) {
        __asm__ volatile ("wfi"); // attend les interruptions pour économiser énergie
    }
}

//wfi → "wait for interrupt", CPU attend qu’une interruption le réveille.

//Le feu tourne ensuite indépendamment dans l’interruption.