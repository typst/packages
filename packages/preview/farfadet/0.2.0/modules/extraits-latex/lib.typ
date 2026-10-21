// farfadet-latex — Extraits LaTeX compilés au Ctrl+S (latex-avec) et démon rendus_tex.
//
//   #import "lib.typ": *
//
// Ce fichier n'exporte QUE les noms publics (façade) et le module `interne` (noms du moteur, seul point
// d'entrée des autres paquets). Aucun nom LaTeX n'existe ici (outil propre à Typst) : `latex-avec` garde
// son nom ; les réglages suivent le mécanisme du socle, par un seul setter (`setbflatex`). Guide : docs/guide.pdf.

// Noms du moteur (pour les autres paquets farfadet-*)
#import "interne.typ"

// Extraits LaTeX : fabrique de la fonction `latex` du document
#import "src/moteur/latex.typ": latex, latex-avec

// Personnalisation
#import "src/latex.typ": setbflatex
