// farfadet-maths — Commandes de maths et de texte de bfcours : ensembles, intervalles, coordonnées, mise en
// valeur, connecteurs, expressions signées, nombres et unités.
//
//   #import "lib.typ": *
//
// Ce fichier n'exporte QUE les noms publics (façade) et le module `interne` (noms du moteur, seul point
// d'entrée des autres paquets). Réglages : `setbfmaths` (maths et texte) et `sisetup` (nombres et unités).
// Documentation : docs/guide.pdf.

// Noms du moteur (pour les autres paquets farfadet-*)
#import "interne.typ"

// Réglages : `setbfmaths` (maths et texte), `sisetup` (nombres et unités) ; styles par `definir:`, remise à zéro par `reinitialiser:`
#import "src/regler.typ": setbfmaths, sisetup

// Maths : ensemble DD, vecteurs, coordonnées, repère, intervalles, crochets
#import "src/maths.typ": crochetd, crochetg, coordonnees, dd, rep, vect, intervalle

// Nombre relatif entre parenthèses
#import "src/aff.typ": affiche

// Texte : mise en valeur, guillemets, outil du cours, lien interne, place réservée
#import "src/texte.typ": acc, encadrer, frquote, lien, needspace, outilcours, pascalc, surligner

// Connecteurs logiques
#import "src/connecteurs.typ": alors, car, donc, et, mais, puisque, ssi, si

// Nombres et unités (zero, noms de siunitx ; `np` = alias de `num`)
#import "src/nombres.typ": np, num, qty, unit
