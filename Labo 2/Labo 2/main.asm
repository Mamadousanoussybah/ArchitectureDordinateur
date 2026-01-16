// ----------------------------------------------------------------------------
// Nom : THIERNO RASSID DIALLO          Code permanent : DIAT10010001
// ----------------------------------------------------------------------------
// Nom : MAMADOU SANOUSSY BAH           Code permanent : BAHM02080500
// ----------------------------------------------------------------------------
// Nom : VREZA kalou Pascal             Code permanent : VREK01049100
//
// vu qu'il navait pas de groupe et le professeur l'avait dit de se joindre a un
// groupe existant donc on lui a rajouté dans note groupe 
// ----------------------------------------------------------------------------
// Cours : 6GEI186 – Architecture des ordinateurs
// Travail : Multiplication en virgule flottante IEEE 754 (32 bits) sans FPU
// ----------------------------------------------------------------------------
// Instructions : assembler avec `aarch64-linux-gnu-as`
// ----------------------------------------------------------------------------

.data

//si vous voulez travailler avec des nombres decimal il faudra decomenter cette partie et commenté l'autre 

// ---------- Test avec valeurs en décimal ----------
//val1:   .float 23.56
//val2:   .float 671.94

// ---------- : test avec valeurs en hexadécimal ----------
val1:   .word 0x41bc7ae1     // 23.56    affectation des nombres virgule flottant
val2:   .word 0x4427fc29     // 671.94   affectation des nombres virgule flottant

         // je préfére passer par data au lieu de LDR w0, =0x41bc7ae1
.text
.global _start

_start:
    // Charger les opérandes (32 bits IEEE 754)
    LDR     x16, =val1
    LDR     w0, [x16]   // ici on a procédé par le mode d'adressage indirect par regisre

    LDR     x16, =val2
    LDR     w1, [x16]   // ici on a procédé par le mode d'adressage indirect par regisre

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
add_exponents:
    ADD     w9, w5, w6            //ici on additionne les deux exposants
    ADD     w9, w9, #127        // et aprés on ajouter le biais final
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
// FIN DES ROUTINES : ===== RACHID AND SANOUSSY WORK ========
#---------------------------------------------------------------------
