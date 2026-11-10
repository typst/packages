// =============================================================================
// starchy-junia — point d'entrée de la librairie
// =============================================================================
// Importé via `#import "@preview/starchy-junia:0.3.0": *`
// Seule l'API publique est exportée : le modèle, les fonctions à placer dans
// le document et les quelques fonctions des paquets internes utiles à la
// rédaction. Les paquets de dessin et de visualisation (cetz, fletcher,
// lilaq…) sont importés côté projet, dans `ressources/commun.typ`.
// =============================================================================

// Le modèle
#import "src/modele.typ": modele-junia

// Blocs de contenu et insertion de PDF
#import "src/composants.typ": (
  fbc-lexique, fbc-sommaire, fbc-liste-figure, fbc-liste-tableau, fbc-liste-programme, fbc-bibliographie,
  fm-afficher-pdf,
)

// Zones du document
#import "src/zones.typ": fmp-corps-document, fmp-annexes

// Paquets internes : réexportés pour garantir la même version que celle utilisée par le modèle
// - glossarium : citation des entrées du lexique sous forme de fonction (`@cle` reste la forme courante)
// - codly : module complet, pour les réglages d'un bloc (`codly.new(..., highlights: ...)`) ou
//   de tous les blocs suivants (`#show: codly.set_(...)`, `#show: codly.theme(...)`)
#import "src/outils.typ": gls, glspl
#import "src/paquets.typ": codly
