// ----------------------------------------------------------------------------
// Nom : THIERNO RASSID DIALLO          Code permanent : DIAT10010001
// Nom : MAMADOU SANOUSSY BAH           Code permanent : BAHM02080500
// Nom : VREZA kalou Pascal             Code permanent : VREK01049100
// Cours : 6GEI186 – Architecture des ordinateurs
// Travail : Multiplication en virgule flottante IEEE 754 (32 bits) sans FPU
// ----------------------------------------------------------------------------
// Instructions : assembler avec aarch64-linux-gnu-as
// ----------------------------------------------------------------------------

.data

// ---------- Exemple en hex (modifiable selon le test) ----------
// Pour tester l'overflow : 0x71C00000 * 0x58C00000
// Pour tester l'underflow : 0x0DC00000 * 0x26C00000

val1:   .word 0x0DC00000    //   (exemple normal)
val2:   .word 0x26C00000     //   (exemple normal)

.text                   // Début de la section code 
.global _start          // Declaration de l'tiquette comme point d'entrée

_start:                  // Etiquette d'entrée du programme 
    // Charger les opérandes (32 bits IEEE 754)
    LDR     x16, =val1
    LDR     w0, [x16]

    LDR     x16, =val2
    LDR     w1, [x16]

 #--------------------------------------------------------------------
    // Extraire les signes et déterminer le signe final
    BL      extract_sign

 #---------------------------------------------------------------------
    // Extraire les exposants et les mettre au format réel (sans biais)
    BL      extract_exponent

 #---------------------------------------------------------------------
    // Extraire les fractions (mantisses) et ajouter le 1 implicite
    BL      extract_fraction

 #---------------------------------------------------------------------
    // Additionner les exposants et réappliquer le biais
    BL      add_exponents

 #---------------------------------------------------------------------
    // Multiplier les fractions (avec UMULL → 64 bits)
    BL      multiply_fractions

 #---------------------------------------------------------------------
    // Assembler le résultat final (signe + exposant + mantisse)
    BL      assemble_result

 #---------------------------------------------------------------------

    // Le résultat final est maintenant dans w13 (format IEEE 754)
end:
    B end    // Boucle infinie pour debugger (w13 = résultat final)

  svc #0


// -----------------------------------------------------------------------------
// Sous-routines
// -----------------------------------------------------------------------------


// Extraire les signes de w0 et w1 → résultat final dans w4 (XOR)
extract_sign:
    LSR     w2, w0, #31     // w2 = on extrait le bit de signe de w0
    LSR     w3, w1, #31     // w3 = on extrait le bit de signe de w1
    EOR     w4, w2, w3      // w4 = XOR bit de signe du résultat
    RET

#---------------------------------------------------------------------

// Extraire les exposants et enlever le biais de 127
extract_exponent:
    LSR     w5, w0, #23        // Décalage pour isoler les bits 30-23 (exposant)
    AND     w5, w5, #0xFF       // exposant de w0 sans autres bits c'est a dire masquer pour ne garder que les 8 bits
    LSR     w6, w1, #23
    AND     w6, w6, #0xFF       // exposant de w1
    SUB     w5, w5, #127      // ici on enlever le biais
    SUB     w6, w6, #127      // ici on enlever le biais
    RET

#---------------------------------------------------------------------

// Extraire la mantisse (fraction) et ajouter le bit 1 implicite
extract_fraction:
    AND     w7, w0, #0x7FFFFF   // ici on isole les 23 bis de mantisse w0
    ORR     w7, w7, #(1 << 23)  // ici on ajouter le bit 1 implicite

    AND     w8, w1, #0x7FFFFF   // Pareil aussi pour la mantisse w1
    ORR     w8, w8, #(1 << 23)  // ici aussi on ajouter le 1 implicite
    RET

#---------------------------------------------------------------------

// Ajouter les deux exposants réels, puis rajouter le biais
// Détection d'overflow / underflow ici avec le bit OV (flag V) comme mentionné dans le TP
add_exponents:
     // exposants réels additionnés (sans biais)
     ADDS     w9, w5, w6   // (ADDS) addition avec mise à jour des flags  
     
     //Tester le bit V (overflow flag)
     BVS      overflow_detected   // si le bit v=1 -> overflow arithmetique donc branche à overflow_detected

      // Rajouter le biais
     ADD     w9, w9, #127        // w9 = w9 + 127 -> réapplique le biais IEEE754 pour stockage d'exposant
     BVS overflow_detected          // vérifier à nouveau flag V après l'addition du biais

     // Ici on Vérifie overflow IEEE754 : si l'exposant >= 255 ?
     MOV     w10, #255
     CMP     w9, w10
     B.GE    overflow_detected          // si w9 >= 255 -> overflow IEEE754 (exposant trop grand -> Inf)

     // Vérifier underflow IEEE754 : exposant < 1 ?
     CMP     w9, #1
     B.LT    underflow_detected         // si w9 < 1 -> underflow IEEE754 (valeur devient 0)

     RET           // dans ce cas ici Si tout est OK, retour (w9 contient exposant biaisé)

overflow_detected:
    BL      handle_overflow       // Ici on  Gére l'overflow (mettra le résultat à Inf selon le signe)
    RET

underflow_detected:
    BL      handle_underflow      // Ici aussi on Gére l'underflow (mettra le résultat à 0)
    RET

#---------------------------------------------------------------------

// Multiplier les mantisses sur 24 bits → résultat 48 bits (dans x10)
multiply_fractions:
    UMULL   x10, w7, w8         // produit complet 48 bits (qui sera stocké dans x au lieu de w)
    ADD     x10, x10, #(1 << 22)    // Arrondi : + 0.5 ulp nous permet d'arrondir correctement avanT le décalage (equivalent à 0.5)
    LSR     x10, x10, #23       // on essaye de faire la normalisation : pour ramener à 24 bits
    RET

#---------------------------------------------------------------------

// Assemblage du résultat final IEEE 754 [signe][exposant][mantisse]
assemble_result:
    AND     x10, x10, #0x7FFFFF     // ici on garde seulement les 23 bits
    LSL     w11, w9, #23            // ici on place l'exposant dans sa position
    LSL     w12, w4, #31            // ici aussi on place le signe dans sa position
    ORR     w13, w12, w11           // Et on combine signe + exposant
    ORR     w13, w13, w10           // Aprés on ajoute la mantisse
    RET

#---------------------------------------------------------------------
// Handlers overflow / underflow
#---------------------------------------------------------------------

handle_overflow:
    // Stocker 0xFF dans w20 (overflow détecté)
    MOV     w20, #0xFF   // Ici w20 = 255 ; ce juste pour indication/marque (non utilisé pour le résultat)

    // Ici on Place le résultat IEEE754 INF dans w13 selon le signe
    MOV     w11, #0xFF
    LSL     w11, w11, #23          // Ici l'exposant = 255 (Inf)
    TST     w4, #1                 // Dans ce cas ici on teste le bit de signe (w4 & 1) ;et on met à jour les flags mais seul le Z est pertinent ici
    BEQ     .overflow_pos_sign     // ICI Si le signe = 0 -> On  branche à .overflow_pos_sign (positif)
    ORR     w13, w11, #(1 << 31)   // signe négatif
    RET                            // Il retourne (w13= -INF)
.overflow_pos_sign:
    MOV     w13, w11               // w13 = w11 -> ici le resultat egal +INF (signe 0)
    RET                            // Retour 

handle_underflow:
    // Stocker 0xFF dans w21 (underflow détecté)
    MOV     w21, #0xFF              // ici aussi w21 = 255 ;ce  juste pour indiquer/marquer (non utilisé pour le résultat)

    // Mettre le résultat à 0 (underflow → valeur nulle)
    MOV     w13, #0                 // si w13 = 0 -> résultat IEEE754 = 0.0 
    RET                             // Retour

#---------------------------------------------------------------------
// FIN DES ROUTINES : ===== RACHID AND SANOUSSY AND VREZA KALOU PASCAL ========         
//---------------------------------------------------------------------