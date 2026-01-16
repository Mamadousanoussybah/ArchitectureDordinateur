# Multiplication signée en assembleur ARM64 : Algorithme de Booth

## Auteur

**Nom** : THIERNO RASSID DIALLO  
**Code permanent** : DIAT10010001 
---------------------------------
**Nom** : MAMADOU SANOUSSY BAH  
**Code permanent** : BAHM02080500  
**Date** : 26 septembre 2025

---

## Description

Ce programme implémente l’algorithme de **Booth** pour réaliser une multiplication entre deux entiers **signés 32 bits**, codés en binaire.

L’algorithme fonctionne sur 32 cycles, chaque cycle examine les bits `Q0` (bit de poids faible du multiplicateur) et `Q(-1)` (bit auxiliaire) pour décider :

- S’il faut ajouter le multiplicande à l’accumulateur `A`,
- S’il faut le soustraire,
- Ou s’il ne faut rien faire.

À chaque étape, on réalise ensuite un décalage arithmétique de l'ensemble `(A, Q, Q-1)`.

---

## Correspondance entre registres et variables de Booth

| Variable (théorique) | Registre ARM64 | Rôle |
|----------------------|----------------|------|
| `M` (multiplicande)  | `w0`           | Valeur à multiplier |
| `Q` (multiplicateur) | `w1`           | Valeur par laquelle on multiplie |
| `A` (accumulateur)   | `w2`           | Accumule les additions/soustractions |
| `Q(-1)`              | `w3`           | Bit de contrôle (fictif) |
| `Compteur`           | `w4`           | Nombre de bits à traiter (32) |
| `Résultat final`     | `w5`           | Partie basse (Q) du résultat |
| Temporaire Q0        | `w6`           | Bit Q0 extrait de Q |
| Temporaire LSB A     | `w7`           | Sert à transférer le bit d’A vers Q |

# Notre resultat se trouve dans W5

---

## Fonctionnement

1. Initialise les registres avec deux entiers.
2. Répète l’algorithme de Booth 32 fois :
   - Applique la règle de Booth selon Q0 et Q(-1).
   - Effectue l’addition ou la soustraction selon le cas.
   - Décale les registres A, Q, Q(-1). 

--------------------------------------------------------------------------
# Travail realisé par Bah mamadou sanoussy et DIALLO Thierno Rassid .
