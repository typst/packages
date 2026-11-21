// reglages.typ (farfadet-extras) — description des réglages du paquet, par le mécanisme du socle
// (REGLAGES.md du paquet farfadet-socle).
//
// UN registre « extras » (état « bfr-extras »), réglé par l'unique setter `setbfextras`. Types :
//   Film      : filmbox (mode « image »), filmbox-rogne, filmbox-texte, filmt (groupe « film »)
//   Code Python : BFCodePython (styles prédéfinis « classique » et « sobre »)
//   Compléments : habiller, icone
// Priorité (socle) : clé locale > style nommé > réglage du type > réglage global > défaut.
// Les cotes du film sont celles d'une pellicule de 3,2 cm (perforations de 1,8 × 2,8 mm) ; les couleurs
// du code Python sont des couleurs NOMMÉES de bfcours (`setbfcolors` les change). Le noir, le blanc et le
// gris de la pellicule sont ceux d'un film : ils ne dépendent pas de la palette des cours.

#import "../../socle/lib.typ": interne as _socle
#import _socle: (
  reglages-paquet, reglages-controles, reglages-choix, reglages-ou, reglages-resoudre, ptl, xcouleur,
  taille-latex, bf-metriques, bf-nommee,
)

// ---------------------------------------------------------------------
// Contrôles de valeurs
// ---------------------------------------------------------------------

#let _c = reglages-controles
#let _coul = _c.couleur-ou-nom
#let _coul-auto = reglages-ou(reglages-choix(auto), _c.couleur-ou-nom)
#let _coul-none = reglages-ou(reglages-choix(none), _c.couleur-ou-nom)
#let _long = _c.longueur
#let _long-auto = _c.longueur-ou-auto
#let _contenu-ou-none = (v => v == none or type(v) in (content, str, symbol), "none ou un contenu")
#let _noms-tailles = ("tiny", "scriptsize", "footnotesize", "small", "normalsize", "large", "Large", "LARGE", "huge", "Huge")
#let _taille = reglages-ou(reglages-choix(.._noms-tailles), _c.longueur)
#let _dico = (v => type(v) == dictionary, "un dictionnaire de clés")
#let _police = (v => v == auto or type(v) in (str, array), "auto, un nom de police ou un tableau de noms")
#let _entier-pos = (v => type(v) == int and v >= 1, "un entier d'au moins 1")
#let _numeros = (v => type(v) == bool or (type(v) == int and v >= 1), "false, true ou le numéro (au moins 1) de la première ligne")
#let _liste-entiers = (v => type(v) == array and v.all(x => type(x) == int), "un tableau de numéros de lignes")

// ---------------------------------------------------------------------
// Film (bfcours-Film.sty)
// ---------------------------------------------------------------------

/// Clés communes aux commandes de film : perforations de 1,8 × 2,8 mm, marge de 1 mm, contenu à 4,02 pt de
/// la bande basse.
#let _film-commun = (
  fond: "black",
  perforations: 9,
  perforation-largeur: 1.8mm,
  perforation-hauteur: 2.8mm,
  perforation-couleur: "white",
  ColoredSmallBox: "white",
  marge: 1mm,
  ecart-bas: 4.02pt,
  couleur-texte: auto,
)

// ---------------------------------------------------------------------
// Code Python
// ---------------------------------------------------------------------

/// Défauts de `bf-code-python` = style « classique » : fond vert très pâle, cadre vert forêt, onglet de titre.
#let _python-classique = (
  title: "Code Python",
  titre-position: "onglet",
  numeros: false,
  basicstyle: "footnotesize",
  numberstyle: "scriptsize",
  tabsize: 4,
  police: auto,
  pythonkeyword: bf-nommee("pythonkeyword"),
  pythonstring: bf-nommee("pythonstring"),
  pythoncomment: bf-nommee("pythoncomment"),
  pythonnumber: bf-nommee("pythonnumber"),
  keywordstyle2: "magenta",
  colframe: bf-nommee("CouleurVertForet"),
  colback: bf-nommee("CouleurVertForet!5"),
  colbacktitle: bf-nommee("CouleurVertForet!25"),
  boxrule: ptl(1.25),
  arc: ptl(12),
  sharp-corners: "downhill",
  left: 0.6em + 1mm,
  right: 5mm + 1mm,
  top: auto,
  bottom: 2mm,
  before-skip: auto,
  after-skip: auto,
  fonttitle: (:),
  onglet: (:),
  numeros-fond: none,
  numeros-fond-largeur: 1.6em,
  surligner: (),
  couleur-surlignage: "yellow!40",
)

/// Style « sobre » : cadre fin, bandeau de titre pleine largeur, bande grisée derrière les numéros.
#let _python-sobre = (
  titre-position: "bandeau",
  colframe: "darkgray!50!black",
  colback: "white",
  colbacktitle: "darkgray!50!black",
  boxrule: 0.75pt,
  arc: 0pt,
  sharp-corners: "all",
  left: 0.4em + 1mm,
  right: 5mm + 1mm,
  top: 2mm + 1mm,
  bottom: 2mm + 1mm,
  fonttitle: (style: "normal", weight: "bold", family: auto, fill: "white"),
  numeros-fond: "lightgray!25",
)

// ---------------------------------------------------------------------
// Le registre
// ---------------------------------------------------------------------

#let _E = reglages-paquet(
  "extras",
  (:),
  controles: (
    // film
    fond: _coul, perforations: _entier-pos, perforation-largeur: _long, perforation-hauteur: _long,
    perforation-couleur: _coul, ColoredSmallBox: _coul, marge: _long, ecart-bas: _long, ecart-haut: _long,
    couleur-texte: _coul-auto, largeur: _long-auto, hauteur: _long, image-largeur: _long, image-hauteur: _long,
    // boîtes (filmt, code Python)
    colback: _coul, colbacklower: _coul, colframe: _coul, colbacktitle: _coul, boxrule: _long, arc: _long,
    boxsep: _long, left: _long, right: _long, top: _long-auto, bottom: _long,
    // code Python
    title: _contenu-ou-none, titre-position: reglages-choix("onglet", "bandeau"), numeros: _numeros,
    tabsize: _entier-pos, basicstyle: _taille, numberstyle: _taille,
    police: _police, pythonkeyword: _coul, pythonstring: _coul, pythoncomment: _coul, pythonnumber: _coul,
    keywordstyle2: _coul, before-skip: _long-auto, after-skip: _long-auto,
    sharp-corners: reglages-choix("none", "all", "downhill", "uphill", "north", "south", "east", "west"),
    fonttitle: _dico, onglet: _dico, numeros-fond: _coul-none, numeros-fond-largeur: _long,
    surligner: _liste-entiers, couleur-surlignage: _coul,
    // habillage de figure et icônes
    cote: reglages-choix("droite", "gauche"), haut: _c.booleen, ecart: _long, debord: _long, couleur: _coul-none,
    taille: _long, epaisseur: _c.nombre, decalage: _c.nombre,
  ),
  types: (
    filmbox: _film-commun + (largeur: 3.2cm, image-largeur: 3cm, ecart-haut: 3.83pt),
    filmbox-rogne: _film-commun + (largeur: 3.2cm, image-largeur: 3cm, image-hauteur: 3cm, ecart-haut: 3.83pt),
    filmbox-texte: _film-commun + (largeur: 4.5cm, ecart-haut: 3.83pt),
    filmt: _film-commun + (
      largeur: 4.7cm, hauteur: 6cm, ecart-haut: 3.83pt, colback: "white", colbacklower: "gray!50",
      colframe: "black", boxrule: 0.5mm, arc: 1mm, boxsep: 1mm, left: 4pt, right: 4pt, top: 4pt, bottom: 4pt,
    ),
    BFCodePython: _python-classique,
    habiller: (cote: "droite", haut: true, ecart: 1em, largeur: auto, debord: 0pt),
    icone: (couleur: none, taille: 1em, epaisseur: 2, decalage: 0.2),
  ),
  styles: (
    classique: _python-classique,
    sobre: _python-sobre,
  ),
  groupes: (film: ("filmbox", "filmbox-rogne", "filmbox-texte", "filmt")),
  commande: "setbfextras",
)

// ---------------------------------------------------------------------
// Aides pour les façades
// ---------------------------------------------------------------------

/// Retire les clés valant `auto` (« selon les réglages ») d'un dictionnaire de clés locales.
#let _local(d) = d.pairs().filter(p => p.at(1) != auto).to-dict()

/// Valeurs effectives d'un type, à appeler dans un `context`. `options` : les arguments nommés de l'appel
/// (clés locales, dont `style`) ; `commande` : le nom de la commande pour les messages d'erreur.
#let _resoudre(type, options, commande: auto) = {
  if options.pos().len() > 0 {
    panic((if commande == auto { type } else { commande }) + " : argument positionnel inattendu : " + repr(options.pos().first()) + ".")
  }
  reglages-resoudre(_E, pour: type, local: _local(options.named()), commande: if commande == auto { type } else { commande })
}

/// Couleurs : les clés `cles` de `r` passent de « nom xcolor ou couleur » à couleur Typst (dans un `context`).
#let _couleurs(r, ..cles) = {
  let res = r
  for cle in cles.pos() {
    if cle in res and res.at(cle) != none and res.at(cle) != auto { res.insert(cle, xcouleur(res.at(cle))) }
  }
  res
}
