// reglages.typ (farfadet-geom) — réglages du style des figures : registre du socle et setter `setbfgeom`.
// Les couleurs par défaut sont des couleurs NOMMÉES de bfcours (marqueur `bf-nommee`) : elles sont lues
// au rendu et suivent `setbfcolors(…)`.

#import "../../socle/lib.typ": interne as _socle
#import _socle: (
  bf-nommee, reglages-choix, reglages-controles, reglages-courants, reglages-definir-style, reglages-paquet,
  reglages-regler, reglages-reinitialiser,
)

#let _C = reglages-controles

/// Noms français des couleurs d'objets (clé `couleur: "rouge"` de chaque macro).
#let noms-couleurs = ("bleu", "rouge", "vert", "orange", "rose", "gris")

#let _R = reglages-paquet(
  "geom",
  (
    // couleurs : la principale est du texte et des traits ordinaires ; les autres sont des couleurs nommées
    couleur: black,
    couleur-bleu: bf-nommee("prop"),
    couleur-rouge: bf-nommee("thm"),
    couleur-vert: bf-nommee("defi"),
    couleur-orange: bf-nommee("demo"),
    couleur-rose: bf-nommee("monrose"),
    couleur-gris: bf-nommee("rem"),
    couleur-grille: bf-nommee("rem!40"),
    // traits
    epaisseur: 0.9pt,
    epaisseur-fine: 0.5pt,
    epaisseur-forte: 1.4pt,
    // points
    forme-point: "croix",
    taille-point: 3pt,
    // codages
    taille-codage: 3pt,
    taille-angle-droit: 0.3cm,
    rayon-angle: 0.65cm,
    // étiquettes : taille du document si `auto`
    taille-texte: auto,
    espace-etiquette: 4pt,
    // flèches
    fleche: "stealth",
  ),
  controles: (
    couleur: _C.couleur,
    couleur-bleu: _C.couleur,
    couleur-rouge: _C.couleur,
    couleur-vert: _C.couleur,
    couleur-orange: _C.couleur,
    couleur-rose: _C.couleur,
    couleur-gris: _C.couleur,
    couleur-grille: _C.couleur,
    epaisseur: _C.longueur,
    epaisseur-fine: _C.longueur,
    epaisseur-forte: _C.longueur,
    forme-point: reglages-choix("croix", "disque"),
    taille-point: _C.longueur,
    taille-codage: _C.longueur,
    taille-angle-droit: _C.longueur,
    rayon-angle: _C.longueur,
    taille-texte: _C.longueur-ou-auto,
    espace-etiquette: _C.longueur,
    fleche: reglages-choix("stealth", ">", "triangle", "straight"),
  ),
  commande: "setbfgeom",
)

/// Réglage du style des figures (convention commune des setters `setbf…`). Les appels s'ajoutent clé par clé ;
/// une clé inconnue ou une valeur invalide arrête la compilation avec la liste des possibilités.
///
/// - pour (none): sans objet (pas de types d'objets) ; gardé pour la signature commune.
/// - reinitialiser (bool, str): `true` repart des défauts avant d'appliquer les clés ; `"tout"` ramène aussi les styles prédéfinis.
/// - definir (none, str): définit le style nommé de ce nom au lieu de régler (appelé ensuite par `style:`).
/// - ..cles: les clés de style (`couleur`, `couleur-bleu`, `epaisseur`, `forme-point`, `taille-point`…).
/// -> content
#let setbfgeom(pour: none, reinitialiser: false, definir: none, ..cles) = {
  let commande = "setbfgeom"
  if cles.pos().len() > 0 {
    panic(commande + " : seuls des arguments nommés sont acceptés ; reçu : " + repr(cles.pos().first()) + ".")
  }
  if pour != none {
    panic(commande + " : les figures n'ont pas de types d'objets : la clé « pour » est sans objet ; reçu : " + repr(pour) + ".")
  }
  if reinitialiser not in (true, false, "tout") {
    panic(commande + " : la clé « reinitialiser » attend true, false ou \"tout\" ; reçu : " + repr(reinitialiser) + ".")
  }
  if definir != none { return reglages-definir-style(_R, definir, ..cles) }
  if reinitialiser == "tout" { reglages-reinitialiser(_R, styles: true) }
  reglages-regler(_R, reinitialiser: reinitialiser != false, ..cles)
}

/// Réglages courants (à appeler dans un `context`).
#let reglages-geom() = reglages-courants(_R)
