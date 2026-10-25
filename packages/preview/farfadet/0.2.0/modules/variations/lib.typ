// farfadet-tabvar — tableaux de signes et de variations (équivalent de tkz-tab) pour le lycée.
//
//   #import "lib.typ": *
//
//   #tabvar(
//     ("-oo", "0", "+oo"),
//     tkz-tab-line($f'(x)$, ",-,z,+,"),
//     tkz-tab-var($f(x)$, ("+", "+oo"), ("-", "-1"), ("+", "+oo")),
//   )
//
//   #setbftabvar(espcl: 1.8cm)                       // réglage global ; style nommé : definir: "nom"
//   #tabvar(…, a-completer: true)                    // version élève : valeurs, signes et flèches vidés
//
// Ce fichier n'exporte QUE les noms publics et le module `interne`. 

// Noms du moteur (pour les autres paquets farfadet-*)
#import "interne.typ"

#import "src/reglages.typ": setbftabvar
#import "src/lignes.typ": tkz-tab-line, tkz-tab-var
#import "src/moteur.typ": tabvar
