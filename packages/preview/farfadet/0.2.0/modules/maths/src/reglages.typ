// reglages.typ (farfadet-maths) — description des réglages du paquet, par le mécanisme du socle.
//
// DEUX registres :
// - `_M` (état « bfr-maths ») : mise en valeur, connecteurs, coordonnées, intervalles, expressions signées.
//   Réglage global : `setbfmaths`. Types : un par commande (« acc », « encadrer », « Si »…).
// - `_N` (état « bfr-nombres ») : nombres et unités, clés de siunitx. Réglage global : `sisetup`.
//   Types : « num », « qty », « unit ».
//
// Priorité (socle) : clé locale > style nommé > réglage du type > réglage global > défaut.
// Les valeurs par défaut reproduisent EXACTEMENT les cotes de LaTeX (bfcours-commands, bfcours-mathsCommands).
// Les couleurs par défaut sont des couleurs nommées (`bf-nommee`), lues au rendu : `setbfcolors` les change.

#import "../../socle/lib.typ": interne as _socle
#import _socle: (
  reglages-paquet, reglages-regler, reglages-definir-style, reglages-reinitialiser, reglages-controles,
  reglages-choix, reglages-ou, reglages-liste, pvfr, ptl, bf-nommee,
)

// ---------------------------------------------------------------------
// Contrôles de valeurs
// ---------------------------------------------------------------------

/// Noms de tailles LaTeX acceptés par les clés `taille` et `fontupper`.
#let _noms-tailles = ("tiny", "scriptsize", "footnotesize", "small", "normalsize", "large", "Large", "LARGE", "huge", "Huge")

#let _taille = reglages-ou(reglages-choix(.._noms-tailles), reglages-controles.longueur)
// Contrôles du socle (ils acceptent aussi un `symbol` : `sym.space.thin`, `sym.times`…).
#let _contenu = reglages-controles.contenu
#let _contenu-ou-none = reglages-controles.contenu-ou-none
#let _graisse = (v => type(v) in (str, int), "une graisse : \"bold\", \"regular\", 700…")
#let _pourcent = (v => type(v) in (int, float) and v >= 0 and v <= 100, "un pourcentage entre 0 et 100")

// ---------------------------------------------------------------------
// Défauts communs de familles de clés
// ---------------------------------------------------------------------

// Cotes des crochets (moteur/maths.typ : `_cr`), longueur d'un « ex » (`_ex`).
#let _crochets = (trait: 0.8pt, patte: 0.30em, marge: 0.10em, ecart: 0.16em, approche: 0.06em, ex: 0.449em)

// Boîte en ligne (tcbox) : clés tcolorbox, longueurs en points TeX converties (ptl).
#let _tcbox(arc, boxsep, haut-bas, gauche-droite, boxrule: 0.4) = (
  arc: ptl(arc), boxsep: ptl(boxsep), top: ptl(haut-bas), bottom: ptl(haut-bas),
  left: ptl(gauche-droite), right: ptl(gauche-droite), boxrule: ptl(boxrule),
)

#let _connecteur(couleur, mot, fontupper) = (
  couleur: couleur, mot: mot, fontupper: fontupper, colback: auto, colframe: auto, colupper: auto,
  fond: 10, filet: 10, texte: 75, espace-apres: true,
) + _tcbox(0, 0, 2, 3)

/// Les huit connecteurs (noms LaTeX exacts) : `setbfmaths(pour: "connecteurs", …)` les vise tous.
#let noms-connecteurs = ("Si", "Alors", "Donc", "Et", "Mais", "Car", "Puisque", "SSI")

// Clés d'`encadrer` (tcbox de `\encadrer`) ; pour l'ancien `\formuleTable` : `encadrer(couleur: "red")`.
#let _encadrer = (
  couleur: bf-nommee("blue"), colback: auto, colframe: auto, colupper: black, fond: 5, filet: 75,
) + _tcbox(5, 1, 2, 3)

#let _types = (
  acc: (couleur: auto, graisse: "bold", formules-regulieres: true),
  encadrer: _encadrer,
  surligner: (
    couleur: bf-nommee("blue"), colback: auto, colframe: auto, colupper: auto, fond: 10, filet: 10, texte: 75,
  ) + _tcbox(5, 0, 2, 3),
  Si: _connecteur(bf-nommee("red"), "Si", "large"),
  Alors: _connecteur(bf-nommee("blue"), "Alors", "large"),
  Donc: _connecteur(bf-nommee("purple"), "Donc", "large"),
  Et: _connecteur(bf-nommee("green"), "Et", "large"),
  Mais: _connecteur(bf-nommee("red"), "Mais", "large"),
  Car: _connecteur(bf-nommee("green"), "Car", "large"),
  Puisque: _connecteur(bf-nommee("purple"), "Puisque", "large"),
  SSI: _connecteur(bf-nommee("purple"), "si et seulement si", "normalsize"),
  Coordonnees: (
    separateur: pvfr, colback: bf-nommee("gray!15"), colframe: auto,
  ) + _tcbox(2, 1, 1, 1, boxrule: 0.5 * 72.27 / 25.4),
  intervalle: (forme: "ff", separateur: pvfr) + _crochets,
  Crochet: (taille: auto) + _crochets,
  outilcours: (
    etiquette: "Outil du cours", couleur: bf-nommee("gray"), taille: "small", symbole: sym.triangle.stroked.r,
    italique: true, espace-sous: ptl(3),
  ),
  lien: (couleur: bf-nommee("lienInterneColor"), graisse: "bold"),
  affiche: (code: 0),
  pascalc: (libelle: "Calculatrice interdite", graisse: "bold"),
  frquote: (ouvrant: "«", fermant: "»", espace: sym.space.nobreak),
)

#let _controles = (
  couleur: reglages-controles.couleur-ou-nom,
  colback: reglages-controles.couleur-ou-nom,
  colframe: reglages-controles.couleur-ou-nom,
  colupper: reglages-controles.couleur-ou-nom,
  fond: _pourcent,
  filet: _pourcent,
  texte: _pourcent,
  arc: reglages-controles.longueur,
  boxsep: reglages-controles.longueur,
  boxrule: reglages-controles.longueur,
  top: reglages-controles.longueur,
  bottom: reglages-controles.longueur,
  left: reglages-controles.longueur,
  right: reglages-controles.longueur,
  fontupper: _taille,
  taille: reglages-ou(_taille, reglages-choix(auto)),
  mot: _contenu,
  espace-apres: reglages-controles.booleen,
  espace-sous: reglages-controles.longueur,
  graisse: _graisse,
  formules-regulieres: reglages-controles.booleen,
  separateur: _contenu,
  forme: reglages-choix("ff", "oo", "fo", "of"),
  trait: reglages-controles.longueur,
  patte: reglages-controles.longueur,
  marge: reglages-controles.longueur,
  ecart: reglages-controles.longueur,
  approche: reglages-controles.longueur,
  ex: reglages-controles.longueur,
  etiquette: _contenu,
  symbole: _contenu,
  italique: reglages-controles.booleen,
  code: reglages-choix(-1, 0, 1),
  libelle: _contenu,
  ouvrant: _contenu,
  fermant: _contenu,
  espace: _contenu,
)

/// Registre des réglages de mise en valeur, connecteurs, coordonnées, intervalles, crochets.
#let _M = reglages-paquet(
  "maths", (:), controles: _controles, types: _types, commande: "setbfmaths",
  groupes: (connecteurs: noms-connecteurs),
)

// ---------------------------------------------------------------------
// Nombres et unités : clés de siunitx
// ---------------------------------------------------------------------

#let _cles-nombre = (
  output-decimal-marker: ",",
  group-separator: sym.space.thin,
  group-minimum-digits: 4,
  group-digits: "integer",
  round-mode: "none",
  round-precision: none,
  round-pad: true,
  exponent-mode: "input",
  exponent-product: sym.times,
  print-unity-mantissa: true,
  print-zero-exponent: true,
  retain-explicit-plus: false,
  uncertainty-mode: "separate",
  zero: (:),
)
#let _cles-unite = (per-mode: "power", inter-unit-product: sym.space.thin)

#let _controles-nombres = (
  output-decimal-marker: _contenu,
  group-separator: _contenu-ou-none,
  group-minimum-digits: reglages-controles.entier,
  group-digits: reglages-choix("integer", "none"),
  round-mode: reglages-choix("none", "places", "figures"),
  round-precision: (v => v == none or type(v) == int, "none ou un entier"),
  round-pad: reglages-controles.booleen,
  exponent-mode: reglages-choix("input", "scientific", "engineering"),
  exponent-product: _contenu,
  print-unity-mantissa: reglages-controles.booleen,
  print-zero-exponent: reglages-controles.booleen,
  retain-explicit-plus: reglages-controles.booleen,
  uncertainty-mode: reglages-choix("separate", "compact", "compact-marker"),
  zero: (v => type(v) == dictionary, "un dictionnaire de clés de zero (échappatoire)"),
  per-mode: reglages-choix("power", "fraction", "symbol"),
  inter-unit-product: _contenu,
)

/// Registre des réglages de nombres et d'unités (réglage global : `sisetup`).
#let _N = reglages-paquet(
  "nombres",
  (:),
  controles: _controles-nombres,
  types: (num: _cles-nombre, qty: _cles-nombre + _cles-unite, unit: _cles-unite),
  commande: "sisetup",
)

// ---------------------------------------------------------------------
// Du réglage siunitx à celui de zero
// ---------------------------------------------------------------------

/// Traduit les valeurs résolues (clés siunitx) en options de zero : `(nombre: (…), unite: (…))`.
#let vers-zero(r) = {
  let nombre = (:)
  if "output-decimal-marker" in r { nombre.insert("decimal-separator", r.output-decimal-marker) }
  if "group-separator" in r {
    let seuil = if r.group-separator == none or r.group-digits == "none" { 1000 } else { r.group-minimum-digits }
    nombre.insert("group", if r.group-separator == none { (threshold: seuil) } else { (separator: r.group-separator, threshold: seuil) })
  }
  if "round-precision" in r and r.round-precision != none {
    let mode = if r.round-mode == "none" { "places" } else { r.round-mode }
    nombre.insert("round", (mode: mode, precision: r.round-precision, pad: r.round-pad))
  }
  if "exponent-mode" in r and r.exponent-mode != "input" {
    nombre.insert("exponent", if r.exponent-mode == "scientific" { "sci" } else { "eng" })
  }
  if "exponent-product" in r { nombre.insert("product", r.exponent-product) }
  if "print-unity-mantissa" in r and not r.print-unity-mantissa { nombre.insert("omit-unity-mantissa", true) }
  if "print-zero-exponent" in r and not r.print-zero-exponent { nombre.insert("omit-zero-exponent", true) }
  if "retain-explicit-plus" in r and r.retain-explicit-plus { nombre.insert("positive-sign", true) }
  if "uncertainty-mode" in r { nombre.insert("uncertainty-mode", if r.uncertainty-mode == "compact-marker" { "compact-separator" } else { r.uncertainty-mode }) }
  let unite = (:)
  if "per-mode" in r { unite.insert("fraction", if r.per-mode == "symbol" { "inline" } else { r.per-mode }) }
  if "inter-unit-product" in r { unite.insert("unit-separator", r.inter-unit-product) }
  if "zero" in r { nombre += r.zero }
  (nombre: nombre, unite: unite)
}
