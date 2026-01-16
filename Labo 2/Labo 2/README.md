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
**Date** : 08 octobre 2025

---
On a ajouté VREZA kalou Pascal dans notre groupe vu qu'il n'avait de groupe par la permission du professeur 
## Description

Ce programme réalise la **multiplication de deux nombres à virgule flottante** en **précision simple (32 bits)** selon le standard **IEEE 754**, en **langage assembleur ARMv8-A** (AArch64), **sans utiliser d'instructions flottantes** (FPU).

Nous avons implémenté manuellement les étapes du calcul flottant en manipulant les bits directement : signe, exposant, mantisse.

---

## Structure de notre Programme

Le programme est structuré en **plusieurs sous-routines**, chacune accomplissant une tâche spécifique. L’appel aux sous-routines est effectué avec l’instruction `BL`.

### Étapes principales :

1. Extraction du **bit de signe**
2. Extraction des **exposants** (avec suppression du biais)
3. Extraction des **mantisses** (et ajout du 1 implicite)
4. Addition des **exposants réels**, puis réapplication du biais
5. Multiplication des **mantisses**
6. Assemblage du **résultat final** en format IEEE 754 qui est stocké dans `w13`

---


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
| `w13`    | Résultat final en format IEEE 754 (stocké ici)         |

---
# Notre resultat se trouve dans W13

---
nous avons utilisé les valeurs mentionné dans le tp pour tester notre code et CE sûr aussi que d'autre nombre fonctionne bien 

## Fonctionnement
Et une chose aussi nous avons mis deux choix dans le code soit si vous voulez tester le code en decimal il faudra decomenter le code qui contient l'instruction float SINON vous garder par default celui avec hexadecimal que le code utilise dejà.
--------------------------------------------------------------------------
# Travail realisé par Bah mamadou sanoussy et DIALLO Thierno Rassid .
