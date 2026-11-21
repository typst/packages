// rdtabnum.typ (façade) — le tableau `rdtabnum`, ses éléments (`rdtnplace`, `rdtnconvert`, `rdtnemptyline`,
// `rdtn-arrow`, `rdtnsurcouche`) et le réglage `setrdtabnum`.

#import "moteur/rdtabnum.typ" as _m

/// Compose un tableau de numération (classes, rangs décimaux) et y place les nombres décrits par ses
/// éléments.
///
/// Les ÉLÉMENTS sont les arguments positionnels : `rdtnplace` (un nombre), `rdtnconvert` (une
/// conversion d'unité), `rdtnemptyline` (lignes vides), `rdtn-arrow` (une flèche latérale) et
/// `rdtnsurcouche` (un tracé libre). Les lignes de données se numérotent à partir de 1, dans l'ordre
/// d'écriture. Les options sont les clés nommées ; chacune se règle aussi globalement par `setrdtabnum`.
///
/// Les STYLES (clés `*-style` et `*-tikz`) sont des dictionnaires
/// `(text: red, font: (weight: "bold"), fill: "red!5", draw: blue, line-width: 1pt…)`, une fonction
/// `c => …` ou un tableau de styles. Un dégradé s'écrit `(top-color: …, bottom-color: …)`.
///
/// ```example
/// #rdtabnum(width: 7.5cm, rdtnplace(1500), rdtnplace(42), rdtnplace("3,14"))
/// ```
///
/// - start (auto, int, str): borne de gauche : puissance de dix de la colonne des centaines de la classe visée (2, 5, 8, 11) ou nom (`"milliards"`, `"millions"`, `"milliers"`, `"unites"`). Défaut : `"milliers"`.
/// - stop (auto, int, str): borne de droite : puissance de dix de la dernière colonne (0 à -11) ou nom (`"unites"`, `"dixiemes"`, `"centiemes"`, `"milliemes"`, `"dix-milliemes"`…). `"unites"` désigne ici la colonne des unités simples. Défaut : `"milliemes"`.
/// - width (auto, length, ratio): largeur du tableau ; les colonnes ont la même largeur, sauf si une cellule fusionnée (libellé de classe, « Partie décimale ») est plus large que les colonnes qu'elle recouvre : celles-ci s'élargissent alors. Défaut : `100%`.
/// - show-parts (auto, bool): ajoute en haut la rangée « Partie entière » et « Partie décimale ». Défaut : `false`.
/// - show-initial-comma (auto, bool): une conversion garde la virgule de départ, barrée. Défaut : `false`.
/// - correction (auto, bool): le tableau suit la version du document : `rdtnplace(etoile: true)`, `rdtnconvert` et `rdtn-arrow(etoile: true)` n'apparaissent qu'en version professeur (la place reste réservée) et, dans ce cas, prennent la couleur et la police des corrections. `auto` et `true` suivent la version choisie par `--input correction` (comme `ifcorrection`) ; `false` : le tableau ne dépend pas de la version, tout reste visible. Défaut : `auto`.
/// - tblr-options (auto, dictionary, none): réglages de la grille : `rowsep` (marge verticale des cellules), `cells` (style de toutes les cellules) ; `colsep` (marge horizontale, 6pt) fixe la largeur minimale des cellules fusionnées. Défaut : `none`.
/// - classes-style (auto, dictionary, function, array, none): style des cellules « Classe des … ». Défaut : `none`.
/// - cdu-style (auto, dictionary, function, array, none): style des cellules « c », « d », « u ». Défaut : `none`.
/// - decimals-style (auto, dictionary, function, array, none): style des en-têtes décimaux pivotés (« dixièmes »…). Défaut : `none`.
/// - data-style (auto, dictionary, function, array, none): style de toutes les lignes de données (`fill`, `font`, `text`, `row-sep`). Défaut : `none`.
/// - int-part-style (auto, dictionary, function, array, none): style de la cellule « Partie entière » ; `border: false` retire la bordure extérieure autour de cette cellule. Défaut : `none`.
/// - dec-part-style (auto, dictionary, function, array, none): style de la cellule « Partie décimale » (`border` aussi). Défaut : `none`.
/// - part-style (auto, dictionary, function, array, none): raccourci : le même style pour `int-part-style` et `dec-part-style`. Défaut : `none`.
/// - header-tikz (auto, dictionary, function, array, none): fond de tout l'en-tête (dégradé, couleur, opacité, contour). Défaut : `none`.
/// - int-part-tikz (auto, dictionary, function, array, none): fond de la cellule « Partie entière ». Défaut : `none`.
/// - dec-part-tikz (auto, dictionary, function, array, none): fond de la cellule « Partie décimale ». Défaut : `none`.
/// - part-tikz (auto, dictionary, function, array, none): raccourci : le même fond pour `int-part-tikz` et `dec-part-tikz`. Défaut : `none`.
/// - classes-tikz (auto, dictionary, function, array, none): fond de chaque cellule de classe. Défaut : `none`.
/// - cdu-tikz (auto, dictionary, function, array, none): fond de chaque cellule « c », « d », « u ». Défaut : `none`.
/// - decimals-tikz (auto, dictionary, function, array, none): fond de chaque colonne décimale de l'en-tête. Défaut : `none`.
/// - grid-outer-style (auto, none, str, length, color, stroke, dictionary): trait du cadre extérieur. Défaut : `1pt + black`.
/// - grid-h-style (auto, none, str, length, color, stroke, dictionary): traits horizontaux intérieurs. Défaut : `1pt + black`.
/// - grid-v-style (auto, none, str, length, color, stroke, dictionary): traits verticaux intérieurs. Défaut : `1pt + black`.
/// - grid-style (auto, none, str, length, color, stroke, dictionary): raccourci : le même trait pour les trois clés précédentes ; `none` supprime la grille. Défaut : `none`.
/// - digit-style (auto, dictionary, function, array, none): style des chiffres placés. Défaut : `none`.
/// - added-style (auto, dictionary, function, array, none): style des zéros ajoutés par une conversion (en plus du rouge, ou de la couleur des corrections). Défaut : `none`.
/// - cross-style (auto, dictionary, function, array, none): style du trait qui barre les zéros inutiles (en plus de `draw: red, line-width: 1pt`). Défaut : `none`.
/// - cross-path (auto, function, none): tracé d'un zéro inutile : une fonction qui reçoit `(w:, h:, asc:, trait:)` (taille de la cellule, distance du haut à la ligne de base, trait résolu) et renvoie du contenu placé dans la cellule ; `none` : la diagonale. Défaut : `none`.
/// - comma-style (auto, dictionary, function, array, none): style de la virgule (cercle, fond, police…). Défaut : `none`.
/// - initial-comma-style (auto, dictionary, function, array, none): style de la virgule de départ barrée (en plus de `shape: "strike-out", draw: red`). Défaut : `none`.
/// - cell-base-style (auto, dictionary, function, array, none): style de base de chaque cellule de données (`text-height`, `text-depth`, `min-width`, `seyes`…), appliqué après `inset: 0pt, min-width: 1em`. Défaut : `none`.
/// - row-cell-style (auto, dictionary, array, none): styles ciblés par ligne de données : un dictionnaire dont les clés sont des sélecteurs (`"1"`, `"1-3"`, `"2-"`, `"-2"`, `"1, 3"`, `"odd"`, `"even"`) et les valeurs des styles, appliqués dans l'ordre après `cell-base-style`. Défaut : `none`.
/// - style (auto, str, array): style(s) nommé(s) défini(s) par `setrdtabnum(definir: …)`. Défaut : `auto`.
/// - ..elements (any): les éléments du tableau, dans l'ordre : `rdtnplace`, `rdtnconvert`, `rdtnemptyline`, `rdtn-arrow`, `rdtnsurcouche` (ou des tableaux de ces éléments).
/// -> content
#let rdtabnum(
  start: auto,
  stop: auto,
  width: auto,
  show-parts: auto,
  show-initial-comma: auto,
  correction: auto,
  tblr-options: auto,
  classes-style: auto,
  cdu-style: auto,
  decimals-style: auto,
  data-style: auto,
  int-part-style: auto,
  dec-part-style: auto,
  part-style: auto,
  header-tikz: auto,
  int-part-tikz: auto,
  dec-part-tikz: auto,
  part-tikz: auto,
  classes-tikz: auto,
  cdu-tikz: auto,
  decimals-tikz: auto,
  grid-outer-style: auto,
  grid-h-style: auto,
  grid-v-style: auto,
  grid-style: auto,
  digit-style: auto,
  added-style: auto,
  cross-style: auto,
  cross-path: auto,
  comma-style: auto,
  initial-comma-style: auto,
  cell-base-style: auto,
  row-cell-style: auto,
  style: auto,
  ..elements,
) = {
  let local = (
    start: start, stop: stop, width: width, show-parts: show-parts, show-initial-comma: show-initial-comma,
    correction: correction, tblr-options: tblr-options, classes-style: classes-style, cdu-style: cdu-style,
    decimals-style: decimals-style, data-style: data-style, int-part-style: int-part-style,
    dec-part-style: dec-part-style, part-style: part-style, header-tikz: header-tikz,
    int-part-tikz: int-part-tikz, dec-part-tikz: dec-part-tikz, part-tikz: part-tikz,
    classes-tikz: classes-tikz, cdu-tikz: cdu-tikz, decimals-tikz: decimals-tikz,
    grid-outer-style: grid-outer-style, grid-h-style: grid-h-style, grid-v-style: grid-v-style,
    grid-style: grid-style, digit-style: digit-style, added-style: added-style, cross-style: cross-style,
    cross-path: cross-path, comma-style: comma-style, initial-comma-style: initial-comma-style,
    cell-base-style: cell-base-style, row-cell-style: row-cell-style, style: style,
  )
  _m.rdtabnum-construire(local + elements.named(), _m.rdtabnum-aplatir(elements.pos()))
}

/// Place un nombre entier ou décimal dans une nouvelle ligne de données.
///
/// Chaque chiffre est rangé dans la colonne de son ordre de grandeur ; la virgule est tracée sur le
/// filet qui sépare les colonnes des unités et des dixièmes, à hauteur de la ligne de base. Le nombre
/// s'écrit avec une virgule ou un point, de préférence en chaîne (`"3,14"`, `"0,75"`).
///
/// La variante étoilée (`etoile: true`) est la réponse de l'élève : dans un tableau
/// `correction: true`, elle reste vide en version élève (la place est gardée) et s'écrit dans la
/// couleur et la police des corrections en version professeur. Sans `correction: true`, elle se
/// comporte comme `rdtnplace`.
///
/// ```example
/// #rdtabnum(width: 8cm, stop: "centiemes",
///   rdtnplace(42), rdtnplace(1500), rdtnplace("3,14"), rdtnplace("0.75"))
/// ```
///
/// - nombre (str, int, float): le nombre à placer.
/// - etoile (bool): variante étoilée : réponse de l'élève, visible en version professeur seulement. Défaut : `false`.
/// - unite (int): puissance de dix du chiffre des unités du nombre donné (`3` : le nombre est en milliers, `-1` : en dixièmes). Défaut : `0`.
/// -> dictionary
#let rdtnplace(nombre, etoile: false, unite: 0) = {
  if type(etoile) != bool { panic("rdtnplace : la clé « etoile » attend true ou false ; reçu : " + repr(etoile) + ".") }
  if type(unite) != int { panic("rdtnplace : la clé « unite » attend un entier ; reçu : " + repr(unite) + ".") }
  (rdtn: "place", nombre: _m.rdtabnum-lire-nombre(nombre, commande: "rdtnplace"), etoile: etoile, unite: unite)
}

/// Montre la conversion d'un nombre d'une unité à une autre dans une nouvelle ligne.
///
/// Les chiffres du nombre sont rangés selon l'unité source, les zéros nécessaires sont ajoutés
/// (en rouge, clé `added-style`), la virgule est posée sur l'unité cible, et les zéros devenus inutiles
/// sont barrés. Dans un tableau `correction: true`, la ligne est vide en version élève et prend la
/// couleur des corrections en version professeur.
///
/// ```example
/// #rdtabnum(width: 8cm,
///   rdtnconvert("7,2", 1, -2),
///   rdtnconvert(480, -3, 0),
///   rdtnconvert("0,57", 0, -3))
/// ```
///
/// - nombre (str, int, float): le nombre à convertir.
/// - depart (int): puissance de dix de l'unité de départ (0 : unités, 1 : dizaines, 3 : milliers, -1 : dixièmes).
/// - cible (int): puissance de dix de l'unité visée.
/// -> dictionary
#let rdtnconvert(nombre, depart, cible) = {
  if type(depart) != int or type(cible) != int {
    panic("rdtnconvert : les unités de départ et d'arrivée sont des entiers (puissances de dix) ; reçu : " + repr(depart) + " et " + repr(cible) + ".")
  }
  (rdtn: "convert", nombre: _m.rdtabnum-lire-nombre(nombre, commande: "rdtnconvert"), depart: depart, cible: cible)
}

/// Insère `n` lignes de données vides (une par défaut), prêtes à recevoir l'écriture de l'élève ; elles
/// comptent dans la numérotation des lignes.
///
/// ```example
/// #rdtabnum(width: 8cm, stop: "centiemes",
///   rdtnplace(425), rdtnemptyline(2), rdtnplace("18,3"))
/// ```
///
/// - n (int): nombre de lignes. Défaut : `1`.
/// -> dictionary
#let rdtnemptyline(..args) = {
  let n = args.pos().at(0, default: args.named().at("n", default: 1))
  if type(n) != int or n < 1 { panic("rdtnemptyline : le nombre de lignes est un entier positif ; reçu : " + repr(n) + ".") }
  (rdtn: "vide", n: n)
}

/// Flèche d'opération en baïonnette sur un bord du tableau (× 10, ÷ 1000…), de la ligne de départ à la
/// ligne d'arrivée (numéros de lignes de données, à partir de 1), avec son libellé. À placer parmi les
/// éléments de `rdtabnum`.
///
/// La variante étoilée (`etoile: true`) n'apparaît qu'en version professeur quand le tableau est
/// `correction: true` ; la clé `correction` règle ce comportement flèche par flèche (`true` : comme une
/// correction, `false` : toujours visible, `"auto"` : selon l'étoile).
///
/// ```example
/// #rdtabnum(width: 6.5cm, stop: "dixiemes",
///   rdtnplace("3,5"), rdtnplace(350), rdtnplace(3500),
///   rdtn-arrow(1, 2, $times 100$),
///   rdtn-arrow(3, 2, $div 10$, left: true))
/// ```
///
/// - depart (int): ligne de départ.
/// - arrivee (int): ligne d'arrivée (la pointe est de ce côté ; la flèche monte si elle précède le départ).
/// - libelle (content): texte ou formule posé le long du segment vertical.
/// - etoile (bool): variante étoilée : visible en version professeur seulement (si le tableau est `correction: true`). Défaut : `false`.
/// - pos (auto, str): côté du tableau : `"right"` ou `"left"`. Défaut : `"right"`.
/// - left (auto, bool): raccourci de `pos: "left"`. Défaut : `false`.
/// - right (auto, bool): raccourci de `pos: "right"`. Défaut : `false`.
/// - shift-start (auto, length): décalage vertical du point de départ (positif : vers le haut). Défaut : `0pt`.
/// - shift-end (auto, length): décalage vertical du point d'arrivée. Défaut : `0pt`.
/// - shift (auto, length): raccourci : `shift-start` à cette valeur et `shift-end` à son opposé. Défaut : `0pt`.
/// - arm (auto, length): longueur du bras horizontal ; des bras de longueurs différentes permettent d'imbriquer plusieurs flèches. Défaut : `0.3cm`.
/// - arrow-style (auto, dictionary, function, array, none): style du tracé (`draw`, `line-width`, `dash`…), ajouté à `draw: rdtabnumarrowcol, line-width: 1pt`. Défaut : `none`.
/// - color (auto, color, str, none): raccourci : couleur du tracé. Défaut : `none`.
/// - tip (auto, str, dictionary, none): pointe : `"Stealth"`, `"Latex"`, `"Triangle"`, avec options (`"Latex[length=3mm]"`) ou dictionnaire `(type: "Latex", length: 3mm)` ; `none` : sans pointe. Défaut : `"Stealth[length=2mm, inset=1pt]"`.
/// - node-sep (auto, length): écart horizontal entre le segment vertical et le libellé. Défaut : `2mm`.
/// - node-pos (auto, float): position du libellé le long du segment vertical, de 0 (coude de départ) à 1 (coude d'arrivée). Défaut : `0.5`.
/// - node-style (auto, dictionary, function, array, none): style du libellé (fond, cadre, couleur, police). Défaut : `none`.
/// - correction (auto, bool, str): `"auto"`, `true` ou `false` (voir ci-dessus). Défaut : `"auto"`.
/// - style (auto, str, array): style(s) nommé(s) défini(s) par `setrdtabnum(pour: "rdtnArrow", definir: …)`. Défaut : `auto`.
/// -> dictionary
#let rdtn-arrow(
  depart,
  arrivee,
  libelle,
  etoile: false,
  pos: auto,
  left: auto,
  right: auto,
  shift-start: auto,
  shift-end: auto,
  shift: auto,
  arm: auto,
  arrow-style: auto,
  color: auto,
  tip: auto,
  node-sep: auto,
  node-pos: auto,
  node-style: auto,
  correction: auto,
  style: auto,
  ..autres,
) = {
  if autres.named().len() > 0 {
    panic(
      "rdtnArrow : clé inconnue « " + autres.named().keys().first() + " ». Clés possibles : « etoile », « pos », « left », « right », « shift-start », « shift-end », « shift », « arm », « arrow-style », « color », « tip », « node-sep », « node-pos », « node-style », « correction », « style ».",
    )
  }
  if autres.pos().len() > 0 {
    panic("rdtn-arrow : trois arguments positionnels (ligne de départ, ligne d'arrivée, libellé) ; reçu en plus : " + repr(autres.pos().first()) + ".")
  }
  if type(etoile) != bool { panic("rdtn-arrow : la clé « etoile » attend true ou false ; reçu : " + repr(etoile) + ".") }
  if type(depart) != int or type(arrivee) != int {
    panic("rdtn-arrow : les lignes de départ et d'arrivée sont des entiers ; reçu : " + repr(depart) + " et " + repr(arrivee) + ".")
  }
  let cles = (
    pos: pos, left: left, right: right, shift-start: shift-start, shift-end: shift-end, shift: shift, arm: arm,
    arrow-style: arrow-style, color: color, tip: tip, node-sep: node-sep, node-pos: node-pos,
    node-style: node-style, correction: correction, style: style,
  )
  (
    rdtn: "fleche", depart: depart, arrivee: arrivee, libelle: libelle, etoile: etoile,
    cles: _m.rdtabnum-developper-fleche(_m.rd-local(cles)),
  )
}

/// Tracé libre superposé au tableau (accolade, courbe, encadrés), à placer parmi les éléments de
/// `rdtabnum`.
///
/// `f` reçoit un dictionnaire `g` de coordonnées et renvoie du contenu, posé avec l'origine au coin
/// supérieur gauche du tableau. `g.largeur` et `g.hauteur` sont les dimensions du tableau, `g.lignes` et
/// `g.colonnes` le nombre de lignes de données et de colonnes. `(g.gauche)(k)` et `(g.droite)(k)` donnent
/// le point `(x:, y:)` du bord gauche, ou droit, au centre de la ligne de données `k` ; les parenthèses
/// sont nécessaires, `g` étant un dictionnaire. `(g.cellule)(k, c)`
/// donne `(x:, y:, w:, h:, base:)` pour la cellule de la ligne `k` et de la colonne `c` (à partir de 1),
/// `(g.colonne)(c)` donne `(x:, w:)`, `g.separation` est l'abscisse de la frontière entre parties entière
/// et décimale, `g.entete` donne `(y:, h:)` pour les rangées `parties` (ou `none`), `classes` et `cdu`.
///
/// ```example
/// #rdtabnum(width: 5.5cm, stop: "unites",
///   rdtnplace("5,4"), rdtnplace(5400),
///   rdtnsurcouche(g => {
///     let a = (g.droite)(1)
///     let b = (g.droite)(2)
///     place(top + left, dx: a.x, dy: a.y,
///       curve(stroke: teal + 1pt,
///         curve.move((0pt, 0pt)),
///         curve.cubic((1.4cm, 0pt), (1.4cm, b.y - a.y), (0pt, b.y - a.y))))
///   }))
/// ```
///
/// - f (function): fonction `g => contenu`.
/// - dessous (bool): trace sous le tableau (sous les fonds et le texte) au lieu de dessus. Défaut : `false`.
/// -> dictionary
#let rdtnsurcouche(f, dessous: false) = {
  if type(f) != function { panic("rdtnsurcouche : le premier argument est une fonction g => contenu ; reçu : " + repr(f) + ".") }
  (rdtn: "surcouche", f: f, dessous: dessous)
}

/// Le réglage de `rdtabnum`, sous ses quatre formes (mêmes clés que `rdtabnum`).
///
/// - `setrdtabnum(cle: v, …)` : réglage global, pour la suite du document ; les appels s'ajoutent clé par clé.
/// - `setrdtabnum(pour: "rdtnArrow", cle: v, …)` : réglage des flèches (clés de `rdtn-arrow`).
/// - `setrdtabnum(definir: "nom", cle: v, …)` : définit le style nommé « nom », appelé ensuite par `style: "nom"` (avec `pour: "rdtnArrow"` : style de flèche).
/// - `setrdtabnum(reinitialiser: true)` : oublie les réglages (styles gardés) ; avec des clés, repart des défauts puis les applique. `reinitialiser: "tout"` oublie aussi les styles.
///
/// ```example
/// #setrdtabnum(width: 7cm, stop: "dixiemes", grid-style: (thickness: 0.8pt, paint: teal))
/// #rdtabnum(rdtnplace("4250,7"), rdtnplace(18))
/// #setrdtabnum(reinitialiser: "tout")
/// ```
///
/// - pour (none, str): `none` (le tableau) ou `"rdtnArrow"` (les flèches). Défaut : `none`.
/// - reinitialiser (bool, str): `true` : oublie les réglages ; `"tout"` : oublie aussi les styles. Défaut : `false`.
/// - definir (none, str): nom du style à définir avec les clés données. Défaut : `none`.
/// - ..cles (any): clés de `rdtabnum` (ou de `rdtn-arrow`) et `style:`.
/// -> content
#let setrdtabnum(pour: none, reinitialiser: false, definir: none, ..cles) = {
  if cles.pos().len() > 0 {
    panic("setrdtabnum : seuls des arguments nommés sont acceptés ; reçu : " + repr(cles.pos().first()) + ".")
  }
  if pour not in (none, "rdtnArrow") {
    panic("setrdtabnum : valeur invalide pour la clé « pour » : " + repr(pour) + ". Valeurs possibles : none (le tableau) ou \"rdtnArrow\" (les flèches).")
  }
  if pour == "rdtnArrow" {
    _m.rd-regler(_m.rdtnarrow-reglages, "setrdtabnum", none, reinitialiser, definir, arguments(.._m.rdtabnum-developper-fleche(cles.named())))
  } else {
    _m.rd-regler(_m.rdtabnum-reglages, "setrdtabnum", none, reinitialiser, definir, arguments(.._m.rdtabnum-developper(cles.named())))
    if reinitialiser != false and definir == none {
      _m.rd-regler(_m.rdtnarrow-reglages, "setrdtabnum", none, reinitialiser, none, arguments())
    }
  }
}
