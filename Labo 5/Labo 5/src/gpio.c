#include <stdint.h>
#include <stdbool.h>
#include "gpio.h"
#include "uart.h"

#define PERIPH_BASE      0x3F000000UL
#define GPIO_BASE       (PERIPH_BASE + 0x200000)

#define GPFSEL0         (*(volatile uint32_t*)(GPIO_BASE + 0x00))
#define GPFSEL1         (*(volatile uint32_t*)(GPIO_BASE + 0x04))
#define GPFSEL2         (*(volatile uint32_t*)(GPIO_BASE + 0x08))
#define GPSET0          (*(volatile uint32_t*)(GPIO_BASE + 0x1C))
#define GPCLR0          (*(volatile uint32_t*)(GPIO_BASE + 0x28))

// Définition des pins pour chaque couleur
#define PIN_RED     17u
#define PIN_YELLOW  27u
#define PIN_GREEN   22u

//Ici on Configure un pin comme sortie
static inline void gpio_set_output(uint32_t pin) {
    volatile uint32_t* gpfsel;
    uint32_t shift = (pin % 10u) * 3u;
    if (pin < 10u) gpfsel = &GPFSEL0;
    else if (pin < 20u) gpfsel = &GPFSEL1;
    else gpfsel = &GPFSEL2;
    uint32_t val = *gpfsel;
    val &= ~(0x7u << shift); // efface les bits correspondants au pin
    val |=  (0x1u << shift); // configure comme sortie (001)
    *gpfsel = val;

    uart_debug_gpio_set_output(pin);  // message debug
}

// Ici Allume ou éteint un pin
static inline void gpio_write(uint32_t pin, bool on) {
    if (on) GPSET0 = (1u << pin); //HIGH
    else    GPCLR0 = (1u << pin); //LOW

    uart_debug_gpio_write(pin, on); // MESSAGE DEBUG
}

// iCI J'AI InitialisÉ toutes les LEDs et les configure comme sorties
void gpio_init(void) {
    uart_debug_gpio_init(PIN_RED);
    uart_debug_gpio_init(PIN_YELLOW);
    uart_debug_gpio_init(PIN_GREEN);


    gpio_set_output(PIN_RED);
    gpio_set_output(PIN_YELLOW);
    gpio_set_output(PIN_GREEN);


    // LEDs éteintes au départ
    gpio_write(PIN_RED, false);
    gpio_write(PIN_YELLOW, false);
    gpio_write(PIN_GREEN, false);
}

// Utilisation des Fonctions publiques pour contrôler chaque LED
void gpio_set_red(bool on)     { gpio_write(PIN_RED, on);   }
void gpio_set_yellow(bool on)  { gpio_write(PIN_YELLOW, on);}
void gpio_set_green(bool on)   { gpio_write(PIN_GREEN, on); }


//gpio_set_output() configure le pin comme sortie GPIO.
//gpio_write() allume ou éteint la LED.
//gpio_init() initialise les 3 LEDs et les met à LOW (éteintes).