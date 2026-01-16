.global _start // ici ce notre Point d'entrée du programme

/* 
 * Implémentation de l’algorithme de Booth pour multiplier deux entiers signés 32 bits.
 * On a utiliser une approche bit-par-bit sur 32 cycles, en simulant l’accumulateur (A),
 * le multiplicateur (Q), le multiplicande (M) et le bit Q(-1) utilisé pour détecter les transitions.
 */

_start:
    mov w0, #517        // Multiplicande M (valeur à multiplier)
    mov w1, #322         // Multiplicateur Q (32-bit signé)
                             // C’est la valeur par laquelle on multiplie

    mov w2, wzr          // Accumulateur A = 0
    mov w3, wzr          // Q(-1) = 0
    mov w4, #32         // Compteur = 32 itérations pour 32 bits

booth_loop:
    // Vérifier Q0 et Q(-1)
    and w6, w1, #1       // w6 = Q0 (bit de poids faible de Q)
    cmp w6, w3
    beq skip_op          // Si Q0 == Q(-1) → ici on fait rien

    // Sinon, appliquer la règle de Booth selon la combinaison Q0 / Q(-1)
    cmp w6, #1
    beq do_sub           //  Si Q0 == 1 et Q(-1) == 0, faire une soustraction C'est a dire (10)
   // Sinon, Q0 == 0 et Q(-1) == 1, faire une addition dans ce cas (01)
do_add:
    add w2, w2, w0 // A = A + M
    b skip_op   // si la condition es vrai part au décalage

do_sub:
    sub w2, w2, w0  // A = A - M

skip_op:
    // ici on essaye de Sauvegarder Q0 dans Q(-1)
    and w3, w1, #1       // Q(-1) = Q0

    // Ici on effecue un décalage arithmétique du couple (A, Q, Q-1)
    mov w7, w2           //Ici on fai un sauvegarde temporaire de A
    asr w2, w2, #1       // A = A >> 1 (arithmétique)

     // On essaye d'extraire le bit de poids faible de A avant le décalage
    and w7, w7, #1       // w7 = LSB de A (bit à insérer dans Q)

    lsr w1, w1, #1       //Ici on a effectuer un decalage logique pour inserer un 0 dans le bit de signe de Q, Q = Q >> 1 (logique)
    orr w1, w1, w7, lsl #31  // Maintenant on Insére le bit de A dans le bit de poids fort de Q

    subs w4, w4, #1      // A chaque fois on décrémente le compteur
    bne booth_loop       //On Reboucle tant que w4 ≠ 0

    // Résultat final : ici on ne garde que les 32 bits de Q (w1)
    
    //sockage de notre resulat 
    mov w5, w1           // Résultat 32 bits (partie basse)

end:
    b end   // Boucle infinie pour terminer notre programme proprement