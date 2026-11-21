// farfadet-enum — Énumérations et colonnage de bfcours : tcbenumerate, MultiColonnes, tcbraster, tcbitem, listes.
//
//   #import "lib.typ": *
//
// Ce fichier n'exporte QUE les noms publics (façade) et le module `interne` (noms du moteur, seul point
// d'entrée des autres paquets). Les noms publics sont ceux de LaTeX, casse comprise ; les clés sont les
// options LaTeX (espaces → tirets). Réglages : UN setter, `setbfenum`.
//
// `cb` et `ccb` (cases à cocher) sont dans farfadet-crep, avec `checkbox`.
// L'API générique `tcolorbox` / `tcbox` reste dans le moteur (interne.typ).

// Noms du moteur (pour les autres paquets farfadet-*)
#import "interne.typ"

// Réglages : le setter unique
#import "src/reglages.typ": setbfenum

// Colonnage : MultiColonnes, tcbraster, tcbitem
#import "src/colonnes.typ": multi-colonnes, tcbitem, tcbraster

// Énumérations : tcbenumerate, itemize, enumerate
#import "src/listes.typ": enumerate, itemize, tcbenumerate

// Compteurs de tcbenumerate : \bfdEnumNum, \bfdEnumLabel, \bfdEnumLevel (clé `niveau` pour les variantes I/II/III)
#import "src/listes.typ": bfd-enum-label, bfd-enum-level, bfd-enum-num
