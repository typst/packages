// farfadet-modele — Modèle de document bfcours : page, polices, équations, en-têtes, pied de page, modèles.
//
//   #import "lib.typ": *
//   #show: farfadet.with(niveau: "2nde", theme: [Les vecteurs])
//
// Ce fichier n'exporte QUE les noms publics (façade) et le module `interne` (noms du moteur, seul point
// d'entrée des autres paquets). Noms : `farfadet`, `modele`, `chapitre`, `chap-eval`, `pied-de-page`,
// `SequenceItem`, `choiceFontsDys`. Réglage : `setbfmodele` (identité : `pour: "identite"` ; en-tête :
// `pour: "entete"`, clé `rendu` "bf" | "rd" | "sobre" | "encadre" | fonction ; pied : `pour: "pied-de-page"`).
// Paquet façade d'exemple : exemples/ma-facade/.

// Noms du moteur (pour les autres paquets farfadet-*)
#import "interne.typ"

// Modèle de document
#import "src/modele.typ": farfadet

// En-têtes, pied de page, ligne de progression
#import "src/entetes.typ": sequence-item, chap-eval, chapitre, pied-de-page

// Point d'entrée des modèles : modele("cours" | "documentation", …)
#import "src/modeles.typ": modele

// Réglages : un seul setter (global, par type, styles nommés, remise à zéro), et la police dys
#import "src/reglages.typ": choice-fonts-dys, setbfmodele
