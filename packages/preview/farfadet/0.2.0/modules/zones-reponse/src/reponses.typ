// reponses.typ (farfadet-crep) — façade publique : zones de réponse sensibles au mode correctif.
// Noms LaTeX exacts (crep, tccrep, tcfillcrep…), clés = options LaTeX (espaces → tirets).
// Chaque fonction liste ses clés (autocomplétion) ; `auto` = « selon les réglages » (setrdcrep, styles).
//
// Principe commun : dans la version professeur, la réponse s'affiche dans la police de correction (rose,
// grande, grasse) ; dans la version élève, la zone garde exactement la même place mais reste vide (fond gris
// ou lignes Seyès). La version vient de `--input correction=true|false` ou de setrdcrep(correction: …).

#import "moteur/crep.typ" as m
#import "../../socle/lib.typ": interne as _socle
#import _socle: environnements

// Retire les clés laissées à `auto` (« selon les réglages »).
#let _n(..a) = a.named().pairs().filter(((k, v)) => v != auto).to-dict()

// =====================================================================
// Réglages : \setrdcrep
// =====================================================================

/// Règle les zones de réponse, les cases à cocher et les boîtes du paquet à partir de cet endroit du
/// document (`\setrdcrep{…}`) : c'est le seul réglage du paquet. Les clés absentes gardent leur valeur ;
/// une clé inconnue ou une valeur invalide arrête la compilation avec la liste des possibilités.
///
/// ```example
/// #setrdcrep(seyes: false, correction-color: blue)
/// Réponse : #tccrep(2cm)[$42$]
/// ```
///
/// - pour (str, array, none): type réglé : `"crep"`, `"tccrep"`, `"frac"`, `"dembox"`, `"seyesfig"`, `"seyestab"`, `"tccheckbox"`, `"tccheckboxlist"`, `"crepbox"`, `"checkbox"`, `"tcbcheckbox"`, ou un tableau de types. Défaut : `none` (réglage global).
/// - reinitialiser (bool, str): `true` : oublie les réglages global et par type (les styles nommés restent) ; avec des clés, repart des défauts puis les applique ; `"tout"` : ramène aussi les styles aux styles prédéfinis. Défaut : `false`.
/// - definir (str, none): définit le style nommé de ce nom (appelé ensuite par `style:` sur n'importe quelle boîte) avec les clés données ; `pour:` contrôle alors ces clés contre un type. Les styles prédéfinis de rdcrep se redéfinissent de la même façon : `"crep default style"`, `"tccrep default style"`, `"crep default seyes"`, `"crep opaq"`, `"seyesrep style"`, `"assosbox common style"`, `"seyes upper"`, `"seyes lower"`, `"seyes left"`, `"seyes right"`. Défaut : `none`.
/// - correction (bool, auto): version professeur (`true`) ou élève (`false`) à partir d'ici ; `--input correction=…` l'emporte. Défaut : `auto` (inchangée).
/// - correction-color (auto, color, str): couleur des réponses en version professeur ; la valeur donnée est aussi recopiée dans le socle (objets rd). Défaut : `auto`, la couleur réglée par `setbfsocle(correction-color: …)`, elle-même par défaut la couleur nommée `monrose` (suit `setbfcolors` ; rdcrep : `red`).
/// - correction-font (auto, dictionary, str, function): police des réponses : `(size: "large", weight: "bold")`, ou commandes LaTeX `"\large\bfseries"`. Défaut : `auto`, la police réglée par `setbfsocle(correction-font: …)` (grand et gras).
/// - show-crep (bool): `false` supprime les boîtes crep et vide les boîtes en ligne (simple énoncé). Défaut : `true`.
/// - seyes (bool): lignes Seyès dans les boîtes. Défaut bfcours : `true` (rdcrep : `false`).
/// - seyes-colors (color, array): couleurs (lignes épaisses, lignes fines). Défaut : la couleur nommée `seyescol` pour les deux.
/// - dotfill-command (content, none): remplissage des boîtes `dotfill` côté élève ; `none` : pointillés. Défaut : `none`.
/// - auto-factor (int, float): largeur d'une `tccrep(auto)` = facteur × largeur de la réponse. Défaut : `2`.
/// - seyes-unit (length): interligne Seyès (ajout). Défaut : `8mm`.
/// - seyes-thick (length): épaisseur des lignes épaisses (ajout). Défaut : `1.128pt` TeX.
/// - seyes-thin (length): épaisseur des lignes fines (ajout). Défaut : `0.564pt` TeX.
/// - seyes-shift (length): décalage des lignes sous la ligne de base (ajout). Défaut : `0.564pt` TeX.
/// - seyes-subdivisions (int): intervalles par ligne Seyès (ajout). Défaut : `4`.
/// - sans-font (str, array): police sans empattement des pastilles et des dembox (ajout).
/// - every-crep (dictionary): clés appliquées à toutes les boîtes `crep` (`every crep`).
/// - every-tccrep (dictionary): clés appliquées à toutes les boîtes en ligne (`every tccrep`).
/// - every-box (dictionary): clés appliquées aux deux (`every box`).
/// - reset-crep-counter (bool): remet à zéro le compteur des crep. Défaut : `false`.
/// - reset-tccrep-counter (bool): remet à zéro le compteur des boîtes en ligne. Défaut : `false`.
/// - set-crep-counter (int, none): fixe le compteur des crep. Défaut : `none`.
/// - set-tccrep-counter (int, none): fixe le compteur des boîtes en ligne. Défaut : `none`.
/// - default (bool): `true` : défauts d'origine de rdcrep (préréglage « rd » : rouge, gras, sans Seyès, version élève). Défaut : `false`.
/// - style (str, array): style(s) nommé(s) appliqué(s) au niveau réglé.
/// - ..cles: les clés du type visé par `pour:` (celles de `checkbox`, `tcbcheckbox`, `crepbox`, `seyestab`… ; voir leurs fiches).
/// -> content
#let setrdcrep(
  pour: none,
  reinitialiser: false,
  definir: none,
  correction: auto,
  correction-color: auto,
  correction-font: auto,
  show-crep: auto,
  seyes: auto,
  seyes-colors: auto,
  dotfill-command: auto,
  auto-factor: auto,
  seyes-unit: auto,
  seyes-thick: auto,
  seyes-thin: auto,
  seyes-shift: auto,
  seyes-subdivisions: auto,
  sans-font: auto,
  every-crep: none,
  every-tccrep: none,
  every-box: none,
  reset-crep-counter: false,
  reset-tccrep-counter: false,
  set-crep-counter: none,
  set-tccrep-counter: none,
  default: false,
  style: auto,
  ..cles,
) = m.setrdcrep(
  pour: pour,
  reinitialiser: reinitialiser,
  definir: definir,
  correction: correction,
  every-crep: every-crep,
  every-tccrep: every-tccrep,
  every-box: every-box,
  reset-crep-counter: reset-crep-counter,
  reset-tccrep-counter: reset-tccrep-counter,
  set-crep-counter: set-crep-counter,
  set-tccrep-counter: set-tccrep-counter,
  default: default,
  .._n(
    correction-color: correction-color,
    correction-font: correction-font,
    show-crep: show-crep,
    seyes: seyes,
    seyes-colors: seyes-colors,
    dotfill-command: dotfill-command,
    auto-factor: auto-factor,
    seyes-unit: seyes-unit,
    seyes-thick: seyes-thick,
    seyes-thin: seyes-thin,
    seyes-shift: seyes-shift,
    seyes-subdivisions: seyes-subdivisions,
    sans-font: sans-font,
    style: style,
  ),
  ..cles,
)

// =====================================================================
// Texte de correction : CorrectionBox, crepcorrectionfont
// =====================================================================

/// Texte de correction (`\CorrectionBox{x}`) : en version professeur, `x` dans la couleur et
/// la police de correction ; en version élève, la même place, invisible (`\phantom`). C'est la façon
/// d'écrire une réponse « en rose » au milieu d'un énoncé sans zone de réponse.
///
/// ```example
/// Le périmètre vaut #correction-box[12 cm] et l'aire #correction-box[$9 "cm"^2$].
/// ```
///
/// - corps (content): le texte (ou la formule) de correction.
/// -> content
#let correction-box(corps) = m.correction-box(corps)

/// La police de correction seule, sans sa couleur (`\crepcorrectionfont`), dans les deux
/// versions : pour écrire un texte comme une réponse (grand, gras par défaut) sans la colorer.
///
/// ```example
/// Réponse attendue : #crepcorrectionfont[Pythagore].
/// ```
///
/// - corps (content): le texte.
/// -> content
#let crepcorrectionfont(corps) = m.crep-correction-font(corps)

// =====================================================================
// Boîte en bloc : crep
// =====================================================================

/// Zone de réponse en bloc (`\begin{crep}[options] … \end{crep}`) : un cadre gris (ou des lignes Seyès)
/// sous la question. Version professeur : la réponse en couleur ; version élève : la même place, vide.
/// Deux contenus (ou `tcblower:`) donnent deux parties : l'une visible, l'autre réponse (`crep-mode`).
///
/// ```example
/// #crep(extra-lines: 1)[Le triangle est rectangle en $A$.]
/// #crep(seyes: false, crep-mode: "lower")[Énoncé visible.][Réponse.]
/// ```
///
/// - style (str, array): style(s) nommé(s) (`setrdcrep(definir: …)`, `"crep opaq"`, `"seyes lower"`…).
/// - lines (int, float): nombre de lignes Seyès vides ajoutées sous la réponse (= `\repline[n]`) ; remplace `extra-lines`. Défaut : `auto` (`extra-lines`).
/// - extra-lines (int, float): lignes Seyès vides ajoutées sous la réponse. Défaut : `0`.
/// - seyes (bool): lignes Seyès. Défaut : réglage de `setrdcrep` (vrai dans bfcours).
/// - seyes-colors (color, array): couleurs (épaisses, fines) des lignes Seyès.
/// - dotfill (bool): côté élève, affiche le contenu normalement (sans le masquer). Défaut : `false`.
/// - normal-crep (bool): contenu affiché normalement, quelle que soit la version. Défaut : `false`.
/// - show-crep-num (bool): voile et numéro de la boîte. Défaut : `false`.
/// - crep-mode (str): `"regular"`, `"upper"`, `"lower"`, `"left"`, `"right"` : partie qui reçoit la réponse. Défaut : `"regular"`.
/// - forced-height (bool): ancrage des lignes sur la première ligne (hauteur imposée). Défaut : `false`.
/// - crep-opaq (bool): boîte opaque grise, sans Seyès (`crep opaq`). Défaut : `false`.
/// - bbox (array, none): `(bas, haut)` : agrandit la boîte en bas et en haut. Défaut : `none`.
/// - crep-box (dictionary): style par numéro de boîte : `("11": (colback: yellow))`. Défaut : `(:)`.
/// - title (content, none): titre en bandeau. Défaut : `none`.
/// - tcblower (content, none): partie basse (`\tcblower`). Défaut : `none`.
/// - colback (color, str): fond. Défaut : `gray!10` (blanc transparent avec Seyès).
/// - colframe (color, str): cadre. Défaut : `black`.
/// - opacityback (float): opacité du fond. Défaut : `1` (`0` avec Seyès).
/// - boxrule (length): épaisseur du cadre. Défaut : `0.6pt` (`0pt` avec Seyès).
/// - arc (length): rayon des coins. Défaut : `1mm`.
/// - sharp-corners (bool): coins vifs.
/// - boxsep (length): marge intérieure. Défaut : `7pt`.
/// - top (length): marge haute en plus. Défaut : `0pt` (`1mm` avec Seyès).
/// - bottom (length): marge basse en plus. Défaut : `0pt`.
/// - left (length): marge gauche en plus. Défaut : `0pt`.
/// - right (length): marge droite en plus. Défaut : `0pt`.
/// - middle (length): demi-écart entre les deux parties. Défaut : `0pt`.
/// - frame-hidden (bool): cadre caché. Défaut : `false` (`true` avec Seyès).
/// - colbacklower (color, str, none): fond de la partie basse.
/// - opacitybacklower (float): opacité du fond de la partie basse.
/// - colbacktitle (color, str): fond du titre. Défaut : `gray!30`.
/// - coltitle (color, str): couleur du titre. Défaut : `black`.
/// - fonttitle (dictionary, str, function): police du titre. Défaut : grand et gras.
/// - width (length, ratio): largeur. Défaut : `100%`.
/// - height (length): hauteur imposée. Défaut : `auto`.
/// - halign (str): `"justify"`, `"left"`, `"center"`, `"right"` (partie haute). Défaut : `"justify"`.
/// - halign-lower (str): alignement de la partie basse. Défaut : `"justify"`.
/// - valign (str): `"top"`, `"center"`, `"bottom"`. Défaut : `"top"`.
/// - lefthand-width (length): largeur de la partie gauche (modes left/right).
/// - righthand-width (length): largeur de la partie droite (modes left/right).
/// - sidebyside-gap (length): écart entre les parties côte à côte. Défaut : `0pt`.
/// - bicolor (bool): fond seulement sous la partie haute.
/// - before-skip (int, float, length): espace avant (nombre = fois l'interligne). Défaut : `0.25`.
/// - after-skip (int, float, length): espace après. Défaut : `0.5`.
/// - crep-num-veil (color): voile de `show-crep-num` (ajout). Défaut : blanc à 80 %.
/// - crep-num-fill (color): fond de la pastille (ajout). Défaut : `black!70`.
/// - crep-num-color (color): couleur du numéro (ajout). Défaut : `white`.
/// - crep-num-size (str, length): taille du numéro (ajout). Défaut : `"tiny"`.
/// - seyes-unit (length): interligne Seyès (ajout). Défaut : `8mm`.
/// - seyes-thick (length): épaisseur des lignes épaisses (ajout).
/// - seyes-thin (length): épaisseur des lignes fines (ajout).
/// - seyes-shift (length): décalage des lignes (ajout).
/// - seyes-subdivisions (int): intervalles par ligne (ajout). Défaut : `4`.
/// - ..parties (content): la réponse ; avec deux contenus : partie haute puis partie basse.
/// -> content
#let crep(
  style: auto,
  lines: auto,
  extra-lines: auto,
  seyes: auto,
  seyes-colors: auto,
  dotfill: auto,
  normal-crep: auto,
  show-crep-num: auto,
  crep-mode: auto,
  forced-height: auto,
  crep-opaq: auto,
  bbox: auto,
  crep-box: auto,
  title: auto,
  tcblower: auto,
  colback: auto,
  colframe: auto,
  opacityback: auto,
  boxrule: auto,
  arc: auto,
  sharp-corners: auto,
  boxsep: auto,
  top: auto,
  bottom: auto,
  left: auto,
  right: auto,
  middle: auto,
  frame-hidden: auto,
  colbacklower: auto,
  opacitybacklower: auto,
  colbacktitle: auto,
  coltitle: auto,
  fonttitle: auto,
  width: auto,
  height: auto,
  halign: auto,
  halign-lower: auto,
  valign: auto,
  lefthand-width: auto,
  righthand-width: auto,
  sidebyside-gap: auto,
  bicolor: auto,
  before-skip: auto,
  after-skip: auto,
  crep-num-veil: auto,
  crep-num-fill: auto,
  crep-num-color: auto,
  crep-num-size: auto,
  seyes-unit: auto,
  seyes-thick: auto,
  seyes-thin: auto,
  seyes-shift: auto,
  seyes-subdivisions: auto,
  ..parties,
) = m.crep(
  .._n(
    style: style,
    lines: lines,
    extra-lines: extra-lines,
    seyes: seyes,
    seyes-colors: seyes-colors,
    dotfill: dotfill,
    normal-crep: normal-crep,
    show-crep-num: show-crep-num,
    crep-mode: crep-mode,
    forced-height: forced-height,
    crep-opaq: crep-opaq,
    bbox: bbox,
    crep-box: crep-box,
    title: title,
    tcblower: tcblower,
    colback: colback,
    colframe: colframe,
    opacityback: opacityback,
    boxrule: boxrule,
    arc: arc,
    sharp-corners: sharp-corners,
    boxsep: boxsep,
    top: top,
    bottom: bottom,
    left: left,
    right: right,
    middle: middle,
    frame-hidden: frame-hidden,
    colbacklower: colbacklower,
    opacitybacklower: opacitybacklower,
    colbacktitle: colbacktitle,
    coltitle: coltitle,
    fonttitle: fonttitle,
    width: width,
    height: height,
    halign: halign,
    halign-lower: halign-lower,
    valign: valign,
    lefthand-width: lefthand-width,
    righthand-width: righthand-width,
    sidebyside-gap: sidebyside-gap,
    bicolor: bicolor,
    before-skip: before-skip,
    after-skip: after-skip,
    crep-num-veil: crep-num-veil,
    crep-num-fill: crep-num-fill,
    crep-num-color: crep-num-color,
    crep-num-size: crep-num-size,
    seyes-unit: seyes-unit,
    seyes-thick: seyes-thick,
    seyes-thin: seyes-thin,
    seyes-shift: seyes-shift,
    seyes-subdivisions: seyes-subdivisions,
  ),
  ..parties.named(),
  // chaque partie passe par `environnements` : `#begin(crep) … #end(crep)` et begin/end dans la réponse
  ..parties.pos().map(environnements),
)

// =====================================================================
// Boîtes en ligne : tccrep, tcfillcrep, repsim
// =====================================================================

// Clés communes des boîtes en ligne (passées telles quelles au moteur).
#let _cles-ligne(..a) = _n(..a)

/// Boîte réponse en ligne de largeur fixe (`\tccrep[options]{largeur}{réponse}`), contenu centré.
/// Avec `auto` à la place de la largeur, la largeur est automatique (`\tcautocrep`) : `auto-factor` ×
/// largeur naturelle de la réponse (la même en version élève).
///
/// ```example
/// Le carré de $3$ vaut #tccrep(1.5cm)[$9$].
/// Des #tccrep(auto)[boîtes] dont la #tccrep(auto, auto-factor: 1)[largeur] est automatique.
/// ```
///
/// - largeur (length, ratio, auto): largeur de la boîte (premier argument LaTeX) ; `auto` : largeur automatique.
/// - style (str, array): style(s) nommé(s).
/// - auto-factor (int, float): facteur de la largeur automatique (`largeur: auto`). Défaut : réglage de `setrdcrep` (`2`).
/// - seyes (bool): lignes Seyès. Défaut : réglage de `setrdcrep`.
/// - seyes-colors (color, array): couleurs des lignes Seyès.
/// - dotfill (bool): côté élève, remplit la boîte avec `dotfill-command` (pointillés). Défaut : `false`.
/// - normal-crep (bool): contenu affiché normalement. Défaut : `false`.
/// - show-crep-num (bool): voile et numéro. Défaut : `false`.
/// - crep-align (str): `"default"`, `"center"`, `"left"`, `"right"`. Défaut : `"default"` (centré).
/// - crep-opaq (bool): boîte opaque. Défaut : `false`.
/// - bbox (array, none): `(bas, haut)` : agrandit la boîte.
/// - tccrep-box (dictionary): style par numéro : `("42": (colback: yellow))`.
/// - maths (bool): la réponse est une formule (sans `$`). Défaut : `false`.
/// - width (length): remplace la largeur.
/// - colback (color, str): fond. Défaut : `gray!10`.
/// - colframe (color, str): couleur du cadre (si `frame-hidden: false`).
/// - opacityback (float): opacité du fond.
/// - boxrule (length): épaisseur du cadre. Défaut : `0pt`.
/// - arc (length): coins. Défaut : `0pt`.
/// - sharp-corners (bool): coins vifs.
/// - boxsep (length): marge intérieure. Défaut : `5pt`.
/// - top (length): marge haute. Défaut : `0pt` (`1mm` avec Seyès).
/// - bottom (length): marge basse. Défaut : `0pt`.
/// - left (length): marge gauche. Défaut : `0pt`.
/// - right (length): marge droite. Défaut : `0pt`.
/// - frame-hidden (bool): cadre caché. Défaut : `true`.
/// - crep-num-veil (color): voile du numéro (ajout).
/// - crep-num-fill (color): fond de la pastille (ajout).
/// - crep-num-color (color): couleur du numéro (ajout).
/// - crep-num-size (str, length): taille du numéro (ajout).
/// - seyes-unit (length): interligne Seyès (ajout).
/// - seyes-thick (length): lignes épaisses (ajout).
/// - seyes-thin (length): lignes fines (ajout).
/// - seyes-shift (length): décalage des lignes (ajout).
/// - seyes-subdivisions (int): intervalles par ligne (ajout).
/// - corps (content): la réponse.
/// -> content
#let tccrep(
  style: auto,
  auto-factor: auto,
  seyes: auto,
  seyes-colors: auto,
  dotfill: auto,
  normal-crep: auto,
  show-crep-num: auto,
  crep-align: auto,
  crep-opaq: auto,
  bbox: auto,
  tccrep-box: auto,
  maths: auto,
  width: auto,
  colback: auto,
  colframe: auto,
  opacityback: auto,
  boxrule: auto,
  arc: auto,
  sharp-corners: auto,
  boxsep: auto,
  top: auto,
  bottom: auto,
  left: auto,
  right: auto,
  frame-hidden: auto,
  crep-num-veil: auto,
  crep-num-fill: auto,
  crep-num-color: auto,
  crep-num-size: auto,
  seyes-unit: auto,
  seyes-thick: auto,
  seyes-thin: auto,
  seyes-shift: auto,
  seyes-subdivisions: auto,
  largeur,
  corps,
) = m.tccrep(
  .._cles-ligne(
    style: style,
    auto-factor: auto-factor,
    seyes: seyes,
    seyes-colors: seyes-colors,
    dotfill: dotfill,
    normal-crep: normal-crep,
    show-crep-num: show-crep-num,
    crep-align: crep-align,
    crep-opaq: crep-opaq,
    bbox: bbox,
    tccrep-box: tccrep-box,
    maths: maths,
    width: width,
    colback: colback,
    colframe: colframe,
    opacityback: opacityback,
    boxrule: boxrule,
    arc: arc,
    sharp-corners: sharp-corners,
    boxsep: boxsep,
    top: top,
    bottom: bottom,
    left: left,
    right: right,
    frame-hidden: frame-hidden,
    crep-num-veil: crep-num-veil,
    crep-num-fill: crep-num-fill,
    crep-num-color: crep-num-color,
    crep-num-size: crep-num-size,
    seyes-unit: seyes-unit,
    seyes-thick: seyes-thick,
    seyes-thin: seyes-thin,
    seyes-shift: seyes-shift,
    seyes-subdivisions: seyes-subdivisions,
  ),
  largeur,
  corps,
)

/// Boîte réponse qui occupe le reste de la ligne (`\tcfillcrep[options]{réponse}`), contenu à gauche.
/// Vide, c'est le trait pointillé de `\dotfills` : `#tcfillcrep[]`.
///
/// ```example
/// Nom : #tcfillcrep[] \
/// Le périmètre vaut #tcfillcrep[12 cm].
/// ```
///
/// - style (str, array): style(s) nommé(s).
/// - seyes (bool): lignes Seyès.
/// - seyes-colors (color, array): couleurs des lignes Seyès.
/// - dotfill (bool): pointillés côté élève.
/// - normal-crep (bool): contenu affiché normalement.
/// - show-crep-num (bool): voile et numéro.
/// - crep-align (str): alignement (`"default"` = gauche).
/// - crep-opaq (bool): boîte opaque.
/// - bbox (array, none): `(bas, haut)`.
/// - tccrep-box (dictionary): style par numéro.
/// - maths (bool): la réponse est une formule.
/// - colback (color, str): fond.
/// - colframe (color, str): cadre.
/// - opacityback (float): opacité du fond.
/// - boxrule (length): épaisseur du cadre.
/// - arc (length): coins.
/// - boxsep (length): marge intérieure.
/// - top (length): marge haute.
/// - bottom (length): marge basse.
/// - left (length): marge gauche.
/// - right (length): marge droite.
/// - frame-hidden (bool): cadre caché.
/// - corps (content): la réponse.
/// -> content
#let tcfillcrep(
  style: auto,
  seyes: auto,
  seyes-colors: auto,
  dotfill: auto,
  normal-crep: auto,
  show-crep-num: auto,
  crep-align: auto,
  crep-opaq: auto,
  bbox: auto,
  tccrep-box: auto,
  maths: auto,
  colback: auto,
  colframe: auto,
  opacityback: auto,
  boxrule: auto,
  arc: auto,
  boxsep: auto,
  top: auto,
  bottom: auto,
  left: auto,
  right: auto,
  frame-hidden: auto,
  corps,
) = m.tcfillcrep(
  .._cles-ligne(
    style: style,
    seyes: seyes,
    seyes-colors: seyes-colors,
    dotfill: dotfill,
    normal-crep: normal-crep,
    show-crep-num: show-crep-num,
    crep-align: crep-align,
    crep-opaq: crep-opaq,
    bbox: bbox,
    tccrep-box: tccrep-box,
    maths: maths,
    colback: colback,
    colframe: colframe,
    opacityback: opacityback,
    boxrule: boxrule,
    arc: arc,
    boxsep: boxsep,
    top: top,
    bottom: bottom,
    left: left,
    right: right,
    frame-hidden: frame-hidden,
  ),
  corps,
)

/// Petite boîte en ligne (`\repsim[largeur]{réponse}`) : une tccrep.
///
/// ```example
/// $x = #repsim[$3$]$
/// ```
///
/// - largeur (length): largeur. Défaut : `1.5cm`.
/// - ..options: clés de `tccrep`.
/// - corps (content): la réponse.
/// -> content
#let repsim(largeur: 1.5cm, ..options, corps) = m.repsim(largeur: largeur, .._n(..options), corps)

/// Fraction à trous (`\tcfraccrep[options]{num}{den}`) : deux boîtes en ligne dans une fraction.
///
/// ```example
/// $1/2 = #tcfraccrep[2][4]$ et $3/4 = #tcfraccrep(crep-for: "den")[3][4]$
/// ```
///
/// - width (length): largeur de chaque boîte. Défaut : `0.7cm`.
/// - crep-for (str): `"both"`, `"num"` ou `"den"` : boîtes au numérateur, au dénominateur ou aux deux. Défaut : `"both"`.
/// - crep-style (dictionary): clés de tccrep pour les deux boîtes. Défaut : `(:)`.
/// - crep-num-style (dictionary): clés de tccrep pour la boîte du numérateur.
/// - crep-den-style (dictionary): clés de tccrep pour la boîte du dénominateur.
/// - num (content): numérateur.
/// - den (content): dénominateur.
/// -> content
#let tcfraccrep(width: auto, crep-for: auto, crep-style: auto, crep-num-style: auto, crep-den-style: auto, num, den) = m.tcfraccrep(
  .._n(width: width, crep-for: crep-for, crep-style: crep-style, crep-num-style: crep-num-style, crep-den-style: crep-den-style),
  num,
  den,
)

// =====================================================================
// Boîtes dérivées : seyesrep, assosbox, seyesfig, dembox, crepbox
// =====================================================================

/// Énoncé en haut, réponse sur lignes Seyès en bas, dans un cadre arrondi
/// (`\begin{seyesrep}[options]{réponse} énoncé \end{seyesrep}`, style `"seyesrep style"`).
///
/// ```example
/// #seyesrep[$1/4$][Écrire $0,25$ sous forme de fraction.]
/// ```
///
/// - ..options: toutes les clés de `crep` (elles l'emportent sur le style « seyesrep style »).
/// - reponse (content): la réponse (premier argument LaTeX).
/// - enonce (content): l'énoncé (corps de l'environnement).
/// -> content
#let seyesrep(..options, reponse, enonce) = m.seyesrep(.._n(..options), reponse, enonce)

/// Énoncé accompagné d'une case réponse accolée, à droite (défaut) ou à gauche
/// (`\begin{assosbox}[options]{réponse} énoncé \end{assosbox}`).
///
/// ```example
/// #assosbox[$25$][Quel est le carré de $5$ ?]
/// #assosbox(box-left: 2cm)[$14$][Quel est le double de $7$ ?]
/// ```
///
/// - box-right (length, bool, auto): case à droite, de cette largeur. Défaut : `1.5cm`.
/// - box-left (length, bool, none): case à gauche, de cette largeur (`true` : `1.5cm`). Défaut : `none`.
/// - ..options: toutes les clés de `crep`.
/// - reponse (content): la réponse (premier argument LaTeX).
/// - enonce (content): l'énoncé.
/// -> content
#let assosbox(box-right: auto, box-left: none, ..options, reponse, enonce) = m.assosbox(
  box-right: box-right,
  box-left: box-left,
  .._n(..options),
  reponse,
  enonce,
)

/// Figure encadrée aux couleurs Seyès (style `seyesfig` de rdcrep).
///
/// ```example
/// #seyesfig(title: [Figure])[Un schéma à compléter.]
/// ```
///
/// - title (content, none): titre en gras. Défaut : `none`.
/// - boxrule (length): épaisseur du cadre. Défaut : `1.128pt` TeX.
/// - colframe (color, str): cadre. Défaut : `seyescolA!90!black`.
/// - colback (color, str): fond. Défaut : `seyescolB!10`.
/// - arc (length): coins. Défaut : `1mm`.
/// - halign (str): alignement horizontal. Défaut : `"center"`.
/// - valign (str): alignement vertical. Défaut : `"center"`.
/// - boxsep (length): marge. Défaut : `2pt` TeX.
/// - top (length): marge haute en plus. Défaut : `4pt` TeX.
/// - bottom (length): marge basse en plus. Défaut : `4pt` TeX.
/// - left (length): marge gauche en plus. Défaut : `0pt`.
/// - right (length): marge droite en plus. Défaut : `0pt`.
/// - lefttitle (length): retrait du titre. Défaut : `0pt`.
/// - fonttitle (dictionary, str, function): police du titre. Défaut : gras.
/// - width (length, ratio): largeur. Défaut : `100%`.
/// - height (length, auto): hauteur. Défaut : `auto`.
/// - corps (content): contenu.
/// -> content
#let seyesfig(
  title: auto,
  boxrule: auto,
  colframe: auto,
  colback: auto,
  arc: auto,
  halign: auto,
  valign: auto,
  boxsep: auto,
  top: auto,
  bottom: auto,
  left: auto,
  right: auto,
  lefttitle: auto,
  fonttitle: auto,
  width: auto,
  height: auto,
  corps,
) = m.seyesfig(
  .._n(
    title: title,
    boxrule: boxrule,
    colframe: colframe,
    colback: colback,
    arc: arc,
    halign: halign,
    valign: valign,
    boxsep: boxsep,
    top: top,
    bottom: bottom,
    left: left,
    right: right,
    lefttitle: lefttitle,
    fonttitle: fonttitle,
    width: width,
    height: height,
  ),
  corps,
)

/// Étiquette de démonstration (`\dembox[options]{titre}{contenu}`) : « Ce que je sais », « Propriété »,
/// « Conclusion »… à la couleur de correction (noire avec `normal-crep` ou `normal-dembox`).
///
/// ```example
/// #dembox(width: 6cm)[Propriété :][Deux droites perpendiculaires à une même troisième sont parallèles.]
/// #dembox(demskin: "compact")[Conclusion :][$(A T) parallel (H S)$]
/// #dembox(demskin: "fiche", width: 8cm)[À retenir][Le carré d'un nombre est toujours positif.]
/// ```
///
/// - demskin (str): `"regular"` (titre au-dessus), `"compact"` (titre à gauche) ou `"fiche"` (titre arrondi à cheval sur le bord haut, équerre en haut à gauche ). Défaut : `"regular"`.
/// - normal-dembox (bool): en noir, quelle que soit la version, sans dépendre de `normal-crep`. Défaut : `false`.
/// - normal-crep (bool): en noir, hors mode correctif. Défaut : `false`.
/// - width (length, ratio): largeur. Défaut : `100%`.
/// - halign (str): alignement du contenu. Défaut : `"center"`.
/// - colback (color, str): fond (à `opacityback`). Défaut : `black`.
/// - opacityback (float): opacité du fond. Défaut : `0.05`.
/// - colframe (color, str): traits et étiquette. Défaut : couleur de correction.
/// - coltext (color, str): texte. Défaut : couleur de correction.
/// - coltitle (color, str): texte de l'étiquette. Défaut : `white`.
/// - fonttitle (dictionary, str, function): police de l'étiquette. Défaut : sans, `scriptsize`, gras (`tiny` avec `"fiche"`).
/// - boxrule (length): épaisseur des traits. Défaut : `1pt` TeX.
/// - top (length): marge haute. Défaut : `8pt` TeX.
/// - bottom (length): marge basse. Défaut : `4pt` TeX.
/// - left (length): marge gauche. Défaut : `6pt` TeX.
/// - right (length): marge droite. Défaut : `6pt` TeX.
/// - title-boxsep (length): marge de l'étiquette (ajout). Défaut : `2pt` TeX.
/// - tick-length (length): trait vertical en haut à gauche (ajout) ; avec `"fiche"`, aussi le trait horizontal et le décalage de l'étiquette. Défaut : `4mm` (`6mm` en compact).
/// - corner-length (length): équerre en bas à droite (ajout). Défaut : `4mm`.
/// - titre (content): titre de l'étiquette.
/// - corps (content): contenu.
/// -> content
#let dembox(
  demskin: auto,
  normal-dembox: auto,
  normal-crep: auto,
  width: auto,
  halign: auto,
  colback: auto,
  opacityback: auto,
  colframe: auto,
  coltext: auto,
  coltitle: auto,
  fonttitle: auto,
  boxrule: auto,
  top: auto,
  bottom: auto,
  left: auto,
  right: auto,
  title-boxsep: auto,
  tick-length: auto,
  corner-length: auto,
  titre,
  corps,
) = m.dembox(
  .._n(
    demskin: demskin,
    normal-dembox: normal-dembox,
    normal-crep: normal-crep,
    width: width,
    halign: halign,
    colback: colback,
    opacityback: opacityback,
    colframe: colframe,
    coltext: coltext,
    coltitle: coltitle,
    fonttitle: fonttitle,
    boxrule: boxrule,
    top: top,
    bottom: bottom,
    left: left,
    right: right,
    title-boxsep: title-boxsep,
    tick-length: tick-length,
    corner-length: corner-length,
  ),
  titre,
  corps,
)

/// Boîte réponse Seyès précédée d'une étiquette (`\crepbox[options]{largeur}{étiquette}{réponse}`) : une `tccrep` Seyès de la largeur donnée, dans un cadre dont la partie gauche porte
/// l'étiquette (« Réponse : », « x = »…). Elle se pose sur la ligne de base de la réponse.
///
/// ```example
/// Le périmètre : #crepbox(3cm)[Réponse][12 cm] et l'aire : #crepbox(2cm, colback: yellow.lighten(60%))[$A =$][$9$].
/// ```
///
/// - largeur (length): largeur de la boîte réponse (et non de la boîte finale).
/// - etiquette (content): texte de la zone gauche.
/// - corps (content): la réponse.
/// - lw (length): largeur de la zone d'étiquette ; `0pt` : celle de l'étiquette entourée de `inner-left-sep`. Défaut : `0pt`.
/// - inner-left-sep (length): marge de part et d'autre de l'étiquette. Défaut : `1em`.
/// - left-align (str): `"center"`, `"left"`, `"right"` : alignement de l'étiquette. Défaut : `"center"`.
/// - crep-style (dictionary): clés de `tccrep` pour la boîte réponse (la boîte est `seyes: true`). Défaut : `(:)`.
/// - colback (color, str): fond de l'étiquette. Défaut : `white`.
/// - colframe (color, str): cadre. Défaut : `black!75`.
/// - coltext (color, str): couleur de l'étiquette. Défaut : `black`.
/// - fontupper (dictionary, str, function, none): police de l'étiquette. Défaut : `none`.
/// - boxrule (length): épaisseur du cadre. Défaut : `0.7pt` TeX.
/// - boxsep (length): marge entre le cadre et la boîte réponse. Défaut : `2pt` TeX.
/// - arc (length): coins. Défaut : `1mm`.
/// - opacityback (float): opacité du fond de l'étiquette. Défaut : `1`.
/// - opacityframe (float): opacité du cadre. Défaut : `1`.
/// -> content
#let crepbox(
  lw: auto,
  inner-left-sep: auto,
  left-align: auto,
  crep-style: auto,
  colback: auto,
  colframe: auto,
  coltext: auto,
  fontupper: auto,
  boxrule: auto,
  boxsep: auto,
  arc: auto,
  opacityback: auto,
  opacityframe: auto,
  largeur,
  etiquette,
  corps,
) = m.crepbox(
  .._n(
    lw: lw,
    inner-left-sep: inner-left-sep,
    left-align: left-align,
    crep-style: crep-style,
    colback: colback,
    colframe: colframe,
    coltext: coltext,
    fontupper: fontupper,
    boxrule: boxrule,
    boxsep: boxsep,
    arc: arc,
    opacityback: opacityback,
    opacityframe: opacityframe,
  ),
  largeur,
  etiquette,
  corps,
)
