// reglages.typ (farfadet-tabvar) — registre des réglages et setter unique `setbftabvar`.
//
// Les clés reprennent les options de tkz-tab quand elles existent (`lgt`, `espcl`, `deltacl`, `lw`,
// `nocadre`). Toute couleur par défaut est une couleur nommée de bfcours, lue au rendu :
// `setbfcolors(couleur_theme: …)` change le cadre et les flèches, `setbfcolors(monrose: …)` la correction.

#import "../../socle/lib.typ": interne as _socle
#import _socle: (
  reglages-paquet, reglages-regler, reglages-definir-style, reglages-reinitialiser, reglages-controles,
  bf-nommee,
)

#let _c = reglages-controles
#let _largeur = (
  v => v == auto or type(v) in (length, ratio),
  "auto, une longueur ou un pourcentage (100 %)",
)
#let _alignement = (v => type(v) == alignment, "un alignement (center, left, right)")

#let reglages-tabvar = reglages-paquet(
  "tabvar",
  (
    // géométrie (tkz-tab : lgt, espcl, deltacl)
    lgt: auto, // largeur de la colonne des noms de lignes ; auto = selon les noms
    espcl: 2cm, // espace entre deux valeurs de x consécutives (au minimum, voir `largeur`)
    deltacl: auto, // marge entre le cadre et la première ou dernière valeur ; auto = selon les valeurs
    unite: 0.8cm, // hauteur d'une unité de hauteur relative (le `h:` de chaque ligne)
    h-x: 1, // hauteur relative de la ligne des x
    largeur: auto, // auto : largeur naturelle, réduite à la place disponible ; 100 % ou longueur : imposée
    reduire: true, // réduire la taille du texte quand les valeurs ne tiennent plus
    fractions: true, // fractions en grand (style « display ») ; false : fractions réduites du texte courant
    taille: auto, // taille du texte ; auto = celle du document
    alignement: center, // alignement du tableau dans la ligne
    // traits (tkz-tab : lw, nocadre)
    lw: 0.6pt,
    nocadre: false,
    pointilles: (1.6pt, 2pt),
    // flèches
    pointe: 5pt, // longueur de la pointe
    marge-fleches: 2.5pt, // distance minimale entre une flèche et un nombre
    ep-fleches: auto, // épaisseur ; auto = `lw`
    // couleurs : des couleurs nommées de bfcours
    couleur-cadre: bf-nommee("couleur_theme"),
    couleur-fleches: bf-nommee("couleur_theme"),
    couleur-hachures: bf-nommee("couleur_theme!45"),
    correction-color: bf-nommee("monrose"),
    fond: white, // fond des nombres posés sur un trait (zéros, images intermédiaires)
  ),
  controles: (
    lgt: _c.longueur-ou-auto,
    espcl: _c.longueur,
    deltacl: _c.longueur-ou-auto,
    unite: _c.longueur,
    h-x: _c.nombre,
    largeur: _largeur,
    reduire: _c.booleen,
    fractions: _c.booleen,
    taille: _c.longueur-ou-auto,
    alignement: _alignement,
    lw: _c.longueur,
    nocadre: _c.booleen,
    pointilles: _c.tout,
    pointe: _c.longueur,
    marge-fleches: _c.longueur,
    ep-fleches: _c.longueur-ou-auto,
    couleur-cadre: _c.couleur-ou-nom,
    couleur-fleches: _c.couleur-ou-nom,
    couleur-hachures: _c.couleur-ou-nom,
    correction-color: _c.couleur-ou-nom,
    fond: _c.couleur-ou-none,
  ),
  commande: "setbftabvar",
)

/// Setter unique du paquet (signature commune de la famille).
#let setbftabvar(pour: none, reinitialiser: false, definir: none, ..cles) = {
  if reinitialiser not in (true, false, "tout") {
    panic("setbftabvar : la clé « reinitialiser » attend true, false ou \"tout\" ; reçu : " + repr(reinitialiser) + ".")
  }
  if cles.pos().len() > 0 {
    panic("setbftabvar : seules des clés nommées sont permises (par exemple espcl: 2cm).")
  }
  if definir != none { return reglages-definir-style(reglages-tabvar, definir, pour: pour, ..cles) }
  if reinitialiser == "tout" { reglages-reinitialiser(reglages-tabvar, styles: true) }
  reglages-regler(reglages-tabvar, pour: pour, reinitialiser: reinitialiser != false, ..cles)
}
