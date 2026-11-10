// Import de la partie `configuration` du modèle

// Import des bibliothèques
#import "000-paquets.typ": *
// Import des variables
#import "001-variables.typ": *
// Import des fonctions
#import "002-fonctions.typ": *
// Import du noyau commun
#import "003-communs.typ": *
// Import du modèle JUNIA
#import "004-modeles.typ": *

// Import lié à l'architecture de dossiers — spécifique au modèle complet.
// Les modèles autonomes (léger, expert) n'importent pas ce fichier
// et passent leur propre liste via le paramètre `glossaire` de junia-core().
#import "../04-ressources/040-lexique/E-lexique.typ": *

// Import de la partie `utilisateurs` du modèle
#import "../01-utilisateurs/010-auxiliaires.typ": *
#import "../01-utilisateurs/011-figures.typ": *