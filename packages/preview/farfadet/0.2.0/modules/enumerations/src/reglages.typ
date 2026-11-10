// reglages.typ (farfadet-enum) — registre de réglages du paquet et setter unique `setbfenum`, bâtis sur le
// mécanisme du socle.
//
// Cinq types : tcbenumerate, MultiColonnes, tcbraster, itemize, enumerate.
// Les clés reprennent les options LaTeX (espaces → tirets) ; les valeurs « auto » veulent dire « valeur
// intégrée de bfcours » (celle de LaTeX, relevée sur un PDF de production).
// Couleurs par défaut : des couleurs NOMMÉES de bfcours (`bf-nommee`), lues au rendu : `setbfcolors` les change.
// Priorité : clé locale > style nommé > réglage du type > réglage global > défaut.

#import "../../socle/lib.typ": interne as _socle
#import _socle: (
  reglages-paquet, reglages-regler, reglages-definir-style, reglages-reinitialiser, reglages-controles,
  reglages-choix, reglages-ou, bf-nommee,
)

#let _c = reglages-controles
#let _coul = reglages-ou(_c.couleur, _c.texte, (v => v == none or v == auto, "none ou auto"))
#let _long = reglages-ou(_c.longueur, (v => v == auto, "auto"))
// longueur d'enumitem : longueur Typst, auto, ou « n em » interne (dictionnaire bf-quad)
#let _long-liste = reglages-ou(_long, (v => type(v) == dictionary and "bf-quad" in v, "une longueur"))
#let _entier-ou-auto = reglages-ou(_c.entier, (v => v == auto, "auto"))

#let _formats = ("auto", "num", "arabic", "alph", "Alph", "roman", "Roman", "1", "a", "A", "i", "I")

#let _defauts-boites = (
  colframe: none,
  boxrule: 0.4pt,
  colback: none,
  arc: 3pt,
  boxsep: 3pt,
)

#let _defauts-liste = (
  leftmargin: auto,
  labelsep: auto,
  itemsep: auto,
  topsep: auto,
  nosep: false,
  label: auto,
  leftmargini: auto,
  leftmarginii: auto,
  leftmarginiii: auto,
  leftmarginiv: auto,
  leftmarginv: auto,
  leftmarginvi: auto,
)

/// Registre de farfadet-enum (un seul pour tout le paquet : état « bfr-enum »).
#let registre-enum = reglages-paquet(
  "enum",
  (:),
  commande: "setbfenum",
  controles: (
    raster-columns: _c.entier,
    depart: _c.entier,
    format: reglages-choix(.._formats),
    raster-column-skip: _long,
    raster-row-skip: _long,
    colframe: _coul,
    boxrule: _long,
    colback: _coul,
    arc: _long,
    boxsep: _long,
    couleur-badge: _coul,
    ecart-badge: _long,
    rayon-badge: _long,
    format-auto: (v => type(v) == array and v.len() == 3 and v.all(x => x in _formats), "un tableau de trois motifs, par exemple (\"1\", \"a\", \"i\")"),
    bfdEnumIndentI: _long,
    bfdEnumIndentII: _long,
    bfdEnumIndentIII: _long,
    // MultiColonnes
    largeurs: reglages-ou(_c.tout),
    filets: reglages-ou(_c.tout),
    filets-lignes: reglages-ou(_c.tout),
    raster-equal-height: reglages-choix("rows", "none"),
    halign: reglages-choix("justify", "left", "center", "right"),
    valign: reglages-choix("top", "center", "bottom"),
    colbacktitle: _coul,
    coltitle: _coul,
    before-skip: _long,
    after-skip: _long,
    // tcbraster
    raster-width: _long,
    raster-before-skip: _long,
    raster-after-skip: _long,
    raster-left-skip: _long,
    raster-valign: reglages-choix("top", "center", "bottom"),
    // listes
    leftmargin: _long-liste,
    labelsep: _long-liste,
    itemsep: _long-liste,
    topsep: _long-liste,
    nosep: _c.booleen,
    label: _c.tout,
    leftmargini: _long-liste,
    leftmarginii: _long-liste,
    leftmarginiii: _long-liste,
    leftmarginiv: _long-liste,
    leftmarginv: _long-liste,
    leftmarginvi: _long-liste,
    ecart: _long,
    couleur-puce: _coul,
    couleur-etiquette: _coul,
    start: _entier-ou-auto,
    motifs: (v => v == auto or (type(v) == array and v.all(x => type(x) == str)), "auto ou un tableau de motifs de numérotation"),
  ),
  types: (
    tcbenumerate: (
      raster-columns: 1,
      depart: 1,
      format: "auto",
      raster-column-skip: auto,
      raster-row-skip: auto,
      couleur-badge: bf-nommee("itemBaseColor"),
      ecart-badge: auto,
      rayon-badge: auto,
      format-auto: auto,
      bfdEnumIndentI: auto,
      bfdEnumIndentII: auto,
      bfdEnumIndentIII: auto,
      raster-equal-height: "rows",
      halign: "left",
    ) + _defauts-boites,
    MultiColonnes: (
      largeurs: auto,
      raster-column-skip: 6pt,
      raster-row-skip: 6pt,
      filets: none,
      filets-lignes: none,
      raster-equal-height: "rows",
      halign: "left",
      valign: "top",
      colbacktitle: bf-nommee("rem!24"),
      coltitle: bf-nommee("currentTitleColor"),
      before-skip: 0.9em,
      after-skip: 0.9em,
      boxsep: auto,
    ) + (colframe: none, boxrule: 0.4pt, colback: none, arc: 3pt),
    tcbraster: (
      raster-columns: 2,
      raster-width: 100%,
      raster-column-skip: 2mm,
      raster-row-skip: 2mm,
      raster-before-skip: 2mm,
      raster-after-skip: 2mm,
      raster-left-skip: 0pt,
      raster-equal-height: "none",
      raster-valign: "center",
    ),
    itemize: _defauts-liste + (couleur-puce: auto),
    enumerate: _defauts-liste + (couleur-etiquette: bf-nommee("itemBaseColor"), start: auto, motifs: auto),
  ),
)

/// Règle les énumérations et le colonnage de bfcours : UN setter, comme tous les paquets farfadet-*. Sans `pour` :
/// réglage global (chaque type qui connaît la clé la reçoit) ; avec `pour: "<type>"` (ou un tableau de types) :
/// réglage d'un seul type : `"tcbenumerate"`, `"MultiColonnes"`, `"tcbraster"`, `"itemize"`, `"enumerate"`.
/// La clé locale d'un appel l'emporte sur un style nommé, qui l'emporte sur le réglage du type, qui
/// l'emporte sur le réglage global.
///
/// ```typ
/// #setbfenum(pour: "enumerate", couleur-etiquette: "red!70!black", labelsep: 8pt)
/// #setbfenum(pour: "MultiColonnes", colframe: gray, colback: luma(248))
/// #setbfenum(definir: "cartes", colframe: gray, arc: 4pt)
/// #setbfenum(reinitialiser: true)
/// ```
///
/// - pour (str, array, none): type (ou types) à régler ; `none` : réglage global.
/// - reinitialiser (bool, str): `true` oublie les réglages global et par type (les styles nommés restent) ; avec des clés, repart des défauts puis les applique ; `"tout"` oublie aussi les styles nommés.
/// - definir (str, none): définit le style nommé de ce nom (appelé ensuite par `style: "nom"`) ; `pour` contrôle alors les clés contre un type.
/// - cles (any): clés du type (voir la fiche de chaque fonction et la matrice du guide).
/// -> content
#let setbfenum(pour: none, reinitialiser: false, definir: none, ..cles) = {
  if reinitialiser not in (true, false, "tout") {
    panic("setbfenum : la clé « reinitialiser » attend true, false ou \"tout\" ; reçu : " + repr(reinitialiser) + ".")
  }
  if definir != none { return reglages-definir-style(registre-enum, definir, pour: pour, ..cles) }
  if reinitialiser == "tout" { reglages-reinitialiser(registre-enum, styles: true) }
  reglages-regler(registre-enum, pour: pour, reinitialiser: reinitialiser != false, ..cles)
}
