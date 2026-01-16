# Multiplication en Virgule Flottante - ARMv8

## Auteur

**Nom** : THIERNO RASSID DIALLO  
**Code permanent** : DIAT10010001 
----------------------------------
**Nom** : MAMADOU SANOUSSY BAH  
**Code permanent** : BAHM02080500  
----------------------------------
**Nom** : VREZA kalou Pascal      // on lui a ajouté dans notre groupe
**Code permanent** : VREK01049100
-------------------------------
**Date** : 29 octobre 2025

---
On a ajouté VREZA kalou Pascal dans notre groupe vu qu'il n'avait de groupe par la permission du professeur 
## Description
L’objectif est de simuler **le fonctionnement interne d’une opération flottante** à travers la manipulation directe des bits composant **un nombre IEEE 754** :

1 bit de signe,

8 bits d’exposant,

23 bits de mantisse (fraction).

Toutes les étapes du calcul (signe, exposant, mantisse) ont été réalisées à la main via des instructions logiques, arithmétiques et de décalage.

---

## Structure de notre Programme

Le programme est structuré en **plusieurs sous-routines**, chacune accomplissant une tâche spécifique. L’appel aux sous-routines est effectué avec l’instruction `BL`.

### Étapes principales :

1. Extraction du **bit de signe**
2. Extraction des **exposants** (avec soustraction du biais)
3. Extraction des **mantisses** (et ajout du 1 implicite)
4. Addition des **exposants réels**, puis réapplication du biais
     **Vérification de l’overflow (exposant ≥ 255)**
     **Vérification de l’underflow (exposant < 1)**
5. Multiplication des **mantisses** sur 24 bits à l'aide de UMULL (resultat 64 bits) 
     `Normalisation et arrondi du produit`
6. Assemblage du **résultat final** en format IEEE 754 qui est stocké dans `w13`
      `Le résultat final est stocké dans w13`
---
# Gestion des Cas Spéciaux

# Overflow

Lorsqu’un `overflow` est détecté :
L’exposant dépasse 255.
Le programme renvoie une valeur (infinie), avec le signe correspondant.
Le résultat est placé dans `w13` sous la forme :
0x7F800000 pour +Inf
0xFF800000 pour -Inf

# Underflow

Lorsqu’un `underflow` est détecté :
L’exposant devient inférieur à 1.
Le résultat est fixé à 0.0 (zéro flottant).

# Les Registres qu'on a utilisés


| Registre | Rôle / Signification                                   |
|----------|--------------------------------------------------------|
| `w0`     | Premier opérande (valeur IEEE 754 sur 32 bits)         |
| `w1`     | Deuxième opérande (valeur IEEE 754 sur 32 bits)        |
| `w2`     | Bit de signe du premier opérande                       |
| `w3`     | Bit de signe du deuxième opérande                      |
| `w4`     | Signe du résultat (`w2 XOR w3`)                        |
| `w5`     | Exposant réel (non biaisé) du premier opérande         |
| `w6`     | Exposant réel du deuxième opérande                     |
| `w7`     | Mantisse du premier opérande (avec 1 implicite)        |
| `w8`     | Mantisse du deuxième opérande (avec 1 implicite)       |
| `w9`     | Exposant final (après addition et ajout du biais)      |
| `x10`    | Produit complet des mantisses (64 bits, 48 significatifs) |
| `w11`    | Exposant placé à sa position dans le résultat final    |
| `w12`    | Signe placé à sa position dans le résultat final       |
| `w13`    | Résultat final en format IEEE 754 (stocké ici)  
  `w20/w21`| Registre du signalisaition en cas d'overflow/underflow |

---
# Notre resultat se trouve dans W13 
# Le resultat d'overflow dans w20
# Le resultat d'underflow dans w21

---
nous avons utilisé les valeurs mentionné dans le tp pour tester notre code et nous avons implementé le cas du bit OV du registre de statut pour nous permettre de détecter les changements de signe
anormaux

## Fonctionnement
Fonctionnement Global

L’algorithme suit la structure interne du standard IEEE 754 :
Le code :
1.Sépare ces trois composantes,
2.Réalise le calcul directement sur ces champs,
3.Reconstruit le mot binaire final représentant le résultat IEEE 754.

Les instructions principales utilisées sont :

LSR / LSL : décalages logiques pour isoler ou placer les champs.

AND / ORR / EOR : opérations logiques bit à bit.

ADDS, SUB, CMP, BVS, B.GE, B.LT : opérations arithmétiques et tests de conditions.

UMULL : multiplication entière non signée sur 64 bits (utile pour mantisses).

# Conclusion

Ce travail nous a permis de :

comprendre la structure interne d’un nombre flottant IEEE 754,

simuler manuellement les étapes du calcul flottant sans FPU,

renforcer notre maîtrise de l’assembleur ARMv8 et du contrôle des bits.

Le programme aboutit à une implémentation fidèle et fonctionnelle de la multiplication flottante 32 bits, tout en respectant la logique matérielle du calcul en processeur.
--------------------------------------------------------------------------
# Travail realisé par Bah mamadou sanoussy , DIALLO Thierno Rassid et Vreza Kalou Pascal.
