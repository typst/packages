// bfcours-tabvar — tableaux de signes et de variations (équivalent de tkz-tab) pour le lycée.
//
//   #import "lib.typ": *
//
//   #tabvar(
//     ("-oo", "0", "+oo"),
//     tkzTabLine($f'(x)$, ",-,z,+,"),
//     tkzTabVar($f(x)$, ("+", "+oo"), ("-", "-1"), ("+", "+oo")),
//   )
//
//   #setbftabvar(espcl: 1.8cm)                       // réglage global ; style nommé : definir: "nom"
//   #tabvar(…, a-completer: true)                    // version élève : valeurs, signes et flèches vidés
//
// Ce fichier n'exporte QUE les noms publics et le module `interne`. 

// Noms du moteur (pour les autres paquets bfcours-*)
#import "interne.typ"

#import "src/reglages.typ": setbftabvar
#import "src/lignes.typ": tkzTabLine, tkzTabVar
#import "src/moteur.typ": tabvar
