#pragma once
#include <stdbool.h>

// Initialisation de toutes les LEDs du feu de circulation
void gpio_init(void);

// Fonctions pour allumer/éteindre chaque LED
void gpio_set_red(bool on);
void gpio_set_yellow(bool on);
void gpio_set_green(bool on);


//On déclare les fonctions publiques pour utiliser les LEDs dans interrupt.c ou ailleurs.
//bool on → true = allumer, false = éteindre.