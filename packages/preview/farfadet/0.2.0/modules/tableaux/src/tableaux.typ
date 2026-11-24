// tableaux.typ (farfadet-tableaux) — façade publique : `tcbtab` (le tableau encadré, sur la `table`
// native de Typst), les aides de filets et de cellules qui se glissent entre ses cellules (hline, cline,
// multicolumn, multirow, cellcolor), les tableaux de récapitulatif de séquence et le setter `setbftableaux`.
//
// Le style par défaut suit celui des tableaux bfcours (tcbtab) : cadre bleu nuit à coins arrondis et ombre
// légère, filets fins, texte rouge sombre, bandeau de titre bleu nuit à texte blanc. Les couleurs sont les
// couleurs nommées de bfcours (`currentTableFrameColor`…), lues au rendu : `couleurs-tabular` et `setbfcolors`
// les changent (paquet farfadet-socle).
//
// Les noms du moteur (interne.typ) ne changent pas : ici on importe le moteur sous alias (`m`) et on
// définit les noms publics par-dessus. Tout ce qui n'est pas un nom public commence par « _ ».
// Variantes du tableau : `align`, `width` + `couleurs` et le style `"CompTab"`. Un tableau nu s'écrit avec
// la `table` native de Typst (le moteur garde `tabular`, `tcbtabcomp` et `tcbtab` pour les autres paquets).

#import "../../socle/lib.typ": interne as _socle
#import _socle: reglages-resoudre, reglages-regler, reglages-definir-style, reglages-reinitialiser
#import _socle: environnements, decouper-items, item-corps
#import "moteur/tableaux.typ" as m

/// Syntaxe environnement des tableaux : `#begin(tcbtab, 3)[cellules fixes] … #end(tcbtab)` appelle la
/// fonction avec les cellules écrites dans `#begin` puis UN corps dont chaque item `-` est une cellule.
/// Cette fonction sépare, parmi les arguments positionnels, un dernier contenu qui est une liste `-`
/// (le corps) : renvoie `(positionnels sans le corps, items du corps)`, ou `(positionnels, none)`.
/// Une cellule qui est elle-même une liste à puces s'écrit `itemize[…]`.
#let _separer-corps(pos) = {
  if pos.len() == 0 or type(pos.last()) != content { return (pos, none) }
  let c = environnements(pos.last())
  let a-items = c.func() == list.item or (c.has("children") and c.children.any(x => x.func() == list.item))
  if not a-items { return (pos, none) }
  (pos.slice(0, -1), decouper-items(c, puce: "-").map(item-corps))
}
#import "moteur/natif.typ": bf-reglages-tableaux as _R, bf-tableau as _tableau

// =====================================================================
// Réglage : un seul setter
// =====================================================================

/// Règle les tableaux pour la suite du document. Sans `pour`, le réglage vaut pour tous les tableaux ;
/// avec `pour`, pour un seul type : `"tcbtab"` (tableau principal) ou `"secondaire"` (tableau à
/// `couleurs: "secondaire"`).
///
/// Priorité : clé locale, puis style nommé, puis réglage du type, puis réglage global, puis défaut. Les
/// couleurs par défaut sont les couleurs nommées de bfcours : `setbfcolors` (ou `couleurs-tabular`) les change
/// pour tout le document ; ce setter les remplace pour les seuls tableaux.
///
/// ```typ
/// #setbftableaux(arraystretch: 1.2, drop-fuzzy-shadow: false)         // global
/// #setbftableaux(pour: "secondaire", arrayrulewidth: 1pt)             // un type
/// #setbftableaux(definir: "compact", arraystretch: 0.8, entete: true) // style nommé
/// #setbftableaux(reinitialiser: true)                                 // retour aux défauts
/// ```
///
/// - pour (str, array, none): type visé : `"tcbtab"` ou `"secondaire"` ; `none` : tous.
/// - reinitialiser (bool, str): `true` repart des réglages d'origine avant d'appliquer les clés (les styles nommés restent) ; `"tout"` ramène aussi les styles aux styles prédéfinis `TableauBox` et `CompTab`.
/// - definir (str, none): nom d'un style à définir (ou à remplacer) avec les clés données ; on l'appelle ensuite par `style: "nom"`. Deux styles existent d'origine : `"TableauBox"` et `"CompTab"` (filets bleu nuit, `arraystretch: 0.2`, tableau compact).
/// - cles (any): clés de `tcbtab` (voir cette fonction), plus `style: "nom"` pour appeler un style nommé.
/// -> content
#let setbftableaux(pour: none, reinitialiser: false, definir: none, ..cles) = {
  if reinitialiser not in (true, false, "tout") {
    panic("setbftableaux : la clé « reinitialiser » attend true, false ou \"tout\" ; reçu : " + repr(reinitialiser) + ".")
  }
  if definir != none { return reglages-definir-style(_R, definir, pour: pour, ..cles) }
  if reinitialiser == "tout" { reglages-reinitialiser(_R, styles: true) }
  reglages-regler(_R, pour: pour, reinitialiser: reinitialiser != false, commande: "setbftableaux", ..cles)
}

/// Retire les clés valant `auto` (« selon les réglages ») d'un dictionnaire de clés locales.
#let _sans-auto(d) = d.pairs().filter(((_, v)) => v != auto).to-dict()

/// Résout les réglages puis dessine le tableau. `couleurs: "secondaire"` bascule sur
/// les défauts du type `secondaire`.
#let _construire(colonnes, cellules, local) = context {
  let local = _sans-auto(local)
  let r = reglages-resoudre(_R, pour: "tcbtab", local: local, commande: "tcbtab")
  let r = if r.couleurs == "secondaire" { reglages-resoudre(_R, pour: "secondaire", local: local, commande: "tcbtab") } else { r }
  _tableau(r, colonnes, cellules, commande: "tcbtab")
}

// =====================================================================
// Tableau encadré
// =====================================================================

/// Tableau encadré à la bfcours. Les cellules
/// se donnent à la suite, rangée après rangée, comme dans la `table` de Typst : on garde tout ce que Typst
/// sait faire (`table.cell(colspan: 2)[…]`, `table.hline()`, `table.vline()`), et on dispose aussi des aides
/// du paquet (`hline()`, `cline("2-3")`, `multicolumn`, `multirow`, `cellcolor`).
///
/// Le premier argument (positionnel) décrit les colonnes de trois façons : la **spécification de colonnes**
/// (`"|c|p{4cm}|c|"` : alignements, filets verticaux `|`, largeurs `p{…}`, colonnes `X`), un **nombre** de
/// colonnes, ou un **tableau de largeurs** Typst `(auto, 1fr, 3cm)`. Avec une spécification de colonnes, les
/// filets la suivent (verticaux aux `|`) et des filets horizontaux séparent toutes les rangées ; `filets: "verticaux"` les supprime, et `hline()` reste utile pour les bordures ou les filets partiels.
///
/// Sans réglage, le tableau a l'allure des tableaux bfcours : cadre bleu nuit à coins arrondis avec une
/// ombre légère, filets fins, texte rouge sombre centré. Chaque détail se règle par une clé ; `cadre: false`
/// donne une grille nue, sans cadre ni titre. Toutes les clés valent `auto` (« selon les réglages ») : on les
/// fixe pour tout le document avec `setbftableaux`.
///
/// Les variantes sont des clés : tableau centré (`\tcbtabc`) = `align: center` (défaut : `left`, comme `\tcbtab`) ; tableau secondaire de
/// largeur imposée = `couleurs: "secondaire"` avec `width:` ; tableau compact en ligne = `style: "CompTab"`
/// avec `align: none`.
///
/// ```typ
/// #tcbtab(3, title: [Valeurs], entete: true,
///   [$x$], [$1$], [$2$],
///   [$f(x)$], [$3$], [$5$],
/// )
/// ```
///
/// - colonnes (str, int, array): spécification de colonnes, nombre de colonnes ou liste de largeurs.
/// - title (content, none): titre, dans un bandeau coloré au-dessus du tableau (défaut : aucun).
/// - style (str, array): nom (ou noms) de style défini par `setbftableaux(definir: …)`.
/// - entete (bool, int): colore la première rangée (les `n` premières si on donne un entier) : fond et texte du titre, texte gras (défaut : `false`).
/// - entete-colonne (bool): met la première colonne en valeur : gras, fond teinté (défaut : `false`).
/// - couleurs (str): jeu de couleurs courantes : `"primaire"` (`couleurs-tabular`) ou `"secondaire"` (`couleurs-secondary-tabular`, avec leurs réglages : filets de `0.5mm`, `arraystretch: 1.4`, titre agrandi) (défaut : `"primaire"`).
/// - colframe (color, str): couleur du cadre (défaut : `currentTableFrameColor`, bleu nuit).
/// - colback (color, str): fond du tableau (défaut : `currentTableColbackColor`, blanc ; sans cadre, aucun fond).
/// - colbacktitle (color, str): fond du bandeau de titre (défaut : `current-table-colback-title-color`, bleu nuit).
/// - coltitle (color, str): couleur du texte du titre (défaut : `current-table-col-title-color`, blanc).
/// - colupper (color, str, none): couleur du texte des cellules (défaut : `currentTableColupperColor`, rouge sombre) ; `none` garde la couleur du texte courant.
/// - entete-fond (color, str): fond de l'en-tête (défaut : celui du titre).
/// - entete-texte (color, str): texte de l'en-tête (défaut : celui du titre).
/// - entete-colonne-fond (color, str): fond de la première colonne mise en valeur (défaut : teinte pâle du cadre).
/// - rowcolors (bool, color, array): rangées alternées : `true` colore une rangée sur deux en teinte pâle du cadre ; une couleur colore une rangée sur deux ; `(c1, c2)` alterne `c1`, `c2` à partir de la première rangée du corps ; `(n, impaires, paires)` : rangées numérotées depuis 1, colorées à partir de la `n`-ième (défaut : `false`).
/// - arrayrulecolor (color, str): couleur des filets (défaut : celle de `couleurs-tabular`, noire).
/// - arrayrulewidth (length): épaisseur des filets (défaut : `0.4pt`).
/// - arraystretch (float): interligne des rangées (défaut : `1.5`, valeur de bfcours).
/// - tabcolsep (length, auto): espace de part et d'autre du contenu d'une cellule (défaut : `6pt`, celui de `marges`).
/// - marges (length, dictionary): marges des cellules `(x: 6pt, y: 5.5pt)`, `y` valant pour `arraystretch: 1.5`.
/// - alignement (alignment, array): alignement du contenu ; un tableau en donne un par colonne. Avec une spécification de colonnes, les lettres `l`, `c`, `r` règlent l'horizontal, `alignement` règle le vertical (défaut : `center + horizon`).
/// - filets (str): `"tous"` (quadrillage), `"horizontaux"`, `"verticaux"`, `"aucun"` ; `auto` : avec une spécification de colonnes, filets verticaux aux `|` et filets horizontaux entre toutes les rangées (comme un `\hline` après chaque rangée) ; sans spécification, quadrillage. `"verticaux"` donne les seuls filets des `|`.
/// - cadre (bool): entoure le tableau du cadre bfcours. Sans cadre, le titre n'est pas affiché (défaut : `true`).
/// - boxrule (length): épaisseur du cadre (défaut : `0.5mm`).
/// - arc (length): rayon des coins du cadre (défaut : `1mm`).
/// - toptitle (length): marge au-dessus du titre (défaut : `0.5mm`).
/// - bottomtitle (length): marge au-dessous du titre (défaut : `0.5mm`).
/// - fonttitle (dictionary): police du titre : arguments de `text`, la taille pouvant être un nom (`"large"`) (défaut : `(weight: "bold")`).
/// - fontupper (dictionary): police du contenu : arguments de `text` (défaut : aucun).
/// - center-title (bool): centre le titre ; sinon à gauche (défaut : `true`).
/// - drop-fuzzy-shadow (bool): ombre floue sous le cadre (défaut : `true`).
/// - left (length): marge intérieure gauche de la boîte, entre le cadre et la grille (défaut : `0mm`, comme `TableauBox`).
/// - right (length): marge intérieure droite (défaut : `0mm`).
/// - top (length): marge intérieure haute (défaut : `0mm`).
/// - bottom (length): marge intérieure basse (défaut : `0mm`).
/// - boxsep (length): marge ajoutée des quatre côtés, en plus de `left`, `right`, `top`, `bottom` (défaut : `0mm`).
/// - width (length, ratio, str): largeur du tableau ; `auto` : celle du contenu. Avec des colonnes en `fr` ou `X`, donner une largeur. Une chaîne est acceptée : `"0.8\\textwidth"` (défaut : `auto`).
/// - align (alignment, none): placement sur la page : `center`, `left`, `right` ; `none` : boîte en ligne, sans saut de ligne (défaut : `left`, comme `\tcbtab` ; `center` = `\tcbtabc`).
/// - cellules (content): les cellules, rangée après rangée.
/// -> content
#let tcbtab(
  colonnes,
  title: auto,
  style: auto,
  entete: auto,
  entete-colonne: auto,
  couleurs: auto,
  colframe: auto,
  colback: auto,
  colbacktitle: auto,
  coltitle: auto,
  colupper: auto,
  entete-fond: auto,
  entete-texte: auto,
  entete-colonne-fond: auto,
  rowcolors: auto,
  arrayrulecolor: auto,
  arrayrulewidth: auto,
  arraystretch: auto,
  tabcolsep: auto,
  marges: auto,
  alignement: auto,
  filets: auto,
  cadre: auto,
  boxrule: auto,
  arc: auto,
  toptitle: auto,
  bottomtitle: auto,
  fonttitle: auto,
  fontupper: auto,
  center-title: auto,
  drop-fuzzy-shadow: auto,
  left: auto,
  right: auto,
  top: auto,
  bottom: auto,
  boxsep: auto,
  width: auto,
  align: auto,
  ..cellules,
) = {
  let local = (
    title: title,
    style: style,
    entete: entete,
    entete-colonne: entete-colonne,
    couleurs: couleurs,
    colframe: colframe,
    colback: colback,
    colbacktitle: colbacktitle,
    coltitle: coltitle,
    colupper: colupper,
    entete-fond: entete-fond,
    entete-texte: entete-texte,
    entete-colonne-fond: entete-colonne-fond,
    rowcolors: rowcolors,
    arrayrulecolor: arrayrulecolor,
    arrayrulewidth: arrayrulewidth,
    arraystretch: arraystretch,
    tabcolsep: tabcolsep,
    marges: marges,
    alignement: alignement,
    filets: filets,
    cadre: cadre,
    boxrule: boxrule,
    arc: arc,
    toptitle: toptitle,
    bottomtitle: bottomtitle,
    fonttitle: fonttitle,
    fontupper: fontupper,
    center-title: center-title,
    drop-fuzzy-shadow: drop-fuzzy-shadow,
    left: left,
    right: right,
    top: top,
    bottom: bottom,
    boxsep: boxsep,
    width: width,
    align: align,
  ) + cellules.named()
  let (pos, corps) = _separer-corps(cellules.pos())
  _construire(colonnes, if corps == none { pos } else { pos + corps }, local)
}

// =====================================================================
// Aides de filets et de cellules à glisser entre les cellules de tcbtab
// =====================================================================

/// Filet horizontal sur toute la largeur. À glisser entre les cellules de `tcbtab`.
///
/// ```typ
/// #tcbtab("|c|c|", hline(), [a], [b], hline())
/// ```
///
/// -> dictionary
#let hline() = m.hline()

/// Filet horizontal sous les colonnes `a` à `b` (numérotées à partir de 1).
///
/// ```typ
/// #tcbtab("|c|c|c|", hline(), [a], [b], [c], cline("2-3"), [d], [e], [f], hline())
/// ```
///
/// - plage (str): « a-b », par exemple `"2-3"`.
/// -> dictionary
#let cline(plage) = {
  let morceaux = str(plage).split("-").map(x => x.trim())
  if morceaux.len() != 2 or morceaux.any(x => x.match(regex("^[0-9]+$")) == none) or int(morceaux.at(0)) < 1 or int(morceaux.at(0)) > int(morceaux.at(1)) {
    panic("cline : plage de colonnes attendue sous la forme « a-b » avec 1 ≤ a ≤ b (par exemple \"2-3\") ; reçu : " + repr(plage) + ".")
  }
  m.cline(plage)
}

/// Une cellule sur `n` colonnes. L'alignement se lit dans la spécification
/// (`l`, `c` ou `r`).
///
/// ```typ
/// #tcbtab("|c|c|c|", hline(), multicolumn(3, "|c|")[Titre sur trois colonnes], hline(), [a], [b], [c], hline())
/// ```
///
/// - n (int): nombre de colonnes couvertes.
/// - spec (str): spécification de la cellule : `"c"`, `"l"`, `"r"`, avec ou sans `|`.
/// - corps (content): contenu de la cellule.
/// -> dictionary
#let multicolumn(n, spec, corps) = m.multicolumn(n, spec, corps)

/// Une cellule sur `n` rangées. La
/// rangée suivante donne une cellule vide (`[]`) à la place couverte. (Une `table.cell(rowspan: n)` native
/// suit au contraire la convention de Typst : pas de cellule de remplacement.)
///
/// ```typ
/// #tcbtab("|c|c|", hline(), multirow(2)[Groupe], [a], cline("2-2"), [], [b], hline())
/// ```
///
/// - n (int): nombre de rangées couvertes.
/// - corps (content): contenu de la cellule.
/// - width (length, auto): largeur du texte ; `auto` : largeur naturelle (défaut : `auto`).
/// - align (alignment, auto): alignement horizontal de la cellule (défaut : celui de la colonne).
/// -> dictionary
#let multirow(n, corps, width: auto, align: auto) = {
  if type(n) != int or n < 1 {
    panic("multirow : le nombre de rangées doit être un entier au moins égal à 1 ; reçu : " + repr(n) + ".")
  }
  if width != auto and type(width) != length {
    panic("multirow : `width` attend auto (comme `*`) ou une longueur ; reçu : " + repr(width) + ".")
  }
  m.cellule(rowspan: n, align: align, if width == auto { corps } else { block(width: width, corps) })
}

/// Cellule colorée.
///
/// ```typ
/// #tcbtab(2, cellcolor("red!30!white")[Rouge pâle], [Normal])
/// ```
///
/// - couleur (color, str): couleur Typst ou expression xcolor (`"red!30!white"`).
/// - corps (content): contenu de la cellule.
/// -> dictionary
#let cellcolor(couleur, corps) = m.cellule(fill: couleur, corps)

// =====================================================================
// Tableaux de récapitulatif de séquence
// =====================================================================

/// Rangée d'en-tête « Contenu de la séquence » avec les quatre colonnes de maîtrise
/// MI, MF, MS, TBM colorées, suivie d'un filet. Renvoie des cellules : à étaler avec `..`.
///
/// ```typ
/// #tableaurecapsequence(hline(), ..entete-contenu(), [Fractions], [], [], [], [], hline())
/// ```
///
/// -> array
#let entete-contenu() = (
  m.cellule(align: center)[*Contenu de la séquence*],
  cellcolor("red!30!white")[*MI*],
  cellcolor("orange!30!white")[*MF*],
  cellcolor("yellow!30!white")[*MS*],
  cellcolor("green!30!white")[*TBM*],
  hline(),
)

/// Tableau de bilan de séquence, une colonne large (0,68 de la largeur du
/// texte) et quatre colonnes étroites (MI, MF, MS, TBM). Les rangées se donnent comme celles de `tcbtab`
/// (utiliser `hline()`, `entete-contenu()`, `competence`…).
///
/// ```typ
/// #tableaurecapsequence(hline(), ..entete-contenu(), [Calculer], [], [], [], [], hline())
/// ```
///
/// Syntaxe environnement : `#begin(tableaurecapsequence)` puis un contenu par item `-`, puis
/// `#end(tableaurecapsequence)`. Le filet du haut, l'en-tête, les quatre cases vides de chaque rangée et
/// les filets sont ajoutés. Les cellules écrites entre crochets dans `#begin(…)` sont ajoutées après l'en-tête.
///
/// - cellules (content): les cellules, rangée après rangée ; les clés nommées sont celles de `tcbtab`. Ou un seul corps d'items `-` (une rangée par item).
/// -> content
#let tableaurecapsequence(..cellules-brutes) = {
  let (pos, corps) = _separer-corps(cellules-brutes.pos())
  let cellules = if corps == none { cellules-brutes } else {
    let rangees = (hline(), ..entete-contenu(), ..pos)
    for it in corps { rangees += (it, [], [], [], [], hline()) }
    arguments(..rangees, ..cellules-brutes.named())
  }
  let spec(large, etroite) = (
    "|>{\\raggedright\\arraybackslash}p{" + large + "}|*{4}{>{\\centering\\arraybackslash}p{" + etroite + "}|}"
  )
  let defaut = spec("0.68\\textwidth", "0.05\\textwidth")
  // Dans un cadre plus étroit que le texte (boîte, colonne, exemple), les colonnes proportionnelles à la
  // largeur du texte, plus les espaces et les filets, débordaient du cadre. Le tableau est alors
  // resserré (mêmes proportions) pour tenir dans la place disponible ; à pleine largeur, rien ne change.
  // Tableau en ligne (`align: none`) : tel quel. Sinon, le bloc extérieur reprend les espaces (1 em)
  // du bloc de `tcbtab`, que la mesure par `layout` ferait perdre.
  if cellules.named().at("align", default: auto) == none { return tcbtab(defaut, ..cellules) }
  block(width: 100%, above: 1em, below: 1em, layout(place => context {
    let mesure = measure(tcbtab(defaut, ..cellules.pos(), ..(cellules.named() + (align: none)))).width
    if mesure <= place.width {
      tcbtab(defaut, ..cellules)
    } else {
      let lt = _socle.bf-largeur-courante()
      let fixe = mesure - 0.88 * lt
      let k = calc.max(0.1, (place.width - fixe) / (0.88 * lt))
      tcbtab(spec(repr(0.68 * k * lt), repr(0.05 * k * lt)), ..cellules)
    }
  }))
}

/// Rangée « Nombre d'heures » suivie du total, sur quatre colonnes, puis d'un filet.
/// Renvoie des cellules : à étaler avec `..`.
///
/// ```typ
/// #tableaurecapsequence(hline(), ..recap-heures(12))
/// ```
///
/// - heures (int, content): nombre d'heures de la séquence.
/// -> array
#let recap-heures(heures) = (
  m.cellule(align: center)[*Nombre d'heures*],
  multicolumn(4, "c")[#heures heures],
  hline(),
)
