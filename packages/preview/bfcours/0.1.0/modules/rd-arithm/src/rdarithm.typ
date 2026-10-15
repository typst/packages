// rdarithm.typ (façade) — setrdarithm, ListeFP, DecompFP, ListeDiviseurs, TabDiviseurs, pgcd, ppcm,
// TabPGCD, RowPGCD, DecompFrac, fracirr, dfracirr. `decomp-fp(mise-en-page:)` choisit la présentation de
// la décomposition ; `pgcd()` et `ppcm()` sans argument écrivent l'opérateur seul.
//
// Les commandes graphiques prennent toutes les clés de `setrdarithm` en options (`..options`) : la liste
// complète est dans la doc de `setrdarithm`. Une clé inconnue provoque une erreur qui liste les clés.

#import "../../socle/lib.typ": interne as _socle
#import _socle: reglages-resoudre
#import "moteur/rdarithm.typ" as _m
#import "moteur/commun.typ": rd-local, rd-regler

#let _R = _m.rdarithm-reglages

#let _entier(n, cmd) = {
  if type(n) != int or n < 1 { panic(cmd + " : un entier positif est attendu ; reçu : " + repr(n) + ".") }
  n
}

// Résout les réglages puis appelle le rendu (dans un `context`).
#let _avec(options, cmd, f) = {
  let local = rd-local(options.named())
  context {
    let r = reglages-resoudre(_R, local: local, commande: cmd)
    // longueurs en em résolues dans la police courante (géométrie calculée en absolu)
    f(r.pairs().map(((k, v)) => (k, if type(v) == length { v.to-absolute() } else { v })).to-dict())
  }
}

/// `setrdarithm(clés)` : le réglage de rdarithm, sous ses quatre formes.
///
/// - `setrdarithm(cle: v, …)` : réglage global, pour la suite du document ; les appels s'ajoutent clé par clé.
/// - `setrdarithm(definir: "nom", cle: v, …)` : définit le style nommé « nom »,
///   appelé ensuite par `style: "nom"` ; un style peut en appeler un autre, la clé locale l'emporte.
/// - `setrdarithm(reinitialiser: true)` : oublie les réglages (styles gardés) ; avec des clés, repart des
///   défauts puis les applique. `reinitialiser: "tout"` oublie aussi les styles.
///
/// Clés (option LaTeX → clé Typst, espaces → tirets) :
/// - colors (array, str): couleurs des boîtes, traits et liens, en boucle. Défaut : `("arithmcol1", "arithmcol2")`.
/// - node-opacity (float): opacité des boîtes de la mise en page `"etapes"`. Défaut : `0.25`.
/// - node-style (dictionary): style des restes encadrés de la mise en page `"etapes"` (text, font, inset…). Défaut : `none`.
/// - decorate (bool): boîtes et traits de la mise en page `"etapes"`. Défaut : `true`.
/// - stop (int): nombre d'étapes affichées (0 : toutes). Défaut : `0`.
/// - powers (str, bool): `"none"`, `"right"`, `"bottom"` (`true` = `"bottom"`) : écriture avec exposants. Défaut : `"none"`.
/// - crep (bool): chaque valeur dans une boîte réponse \tccrep (vide en version élève). Défaut : `false`.
/// - crep-width (length): largeur des boîtes réponse. Défaut : `3em`.
/// - crep-style (dictionary): clés de `tccrep`. Défaut : `(seyes: true, boxsep: 1pt, opacityback: 0.6, left: 2pt, right: 2pt)`.
/// - prime-style, prime-append-style (dictionary): style des facteurs premiers. Défaut : fond arithmcol1 à 25 %, contour arithmcol1, gras.
/// - cell-style, cell-append-style (dictionary): style de toutes les cellules. Défaut : `none`.
/// - cell (dictionary): style d'une cellule (`cell 1`, `cell m-n`) : `("1": (fill: blue), "3-2": (fill: green))`. Défaut : `none`.
/// - picture-style (dictionary): `draw` (couleur des traits), `fill`, `radius`, `inset` (fond). Défaut : `none`.
/// - level-distance, sibling-distance (length): distance entre niveaux (ou rangées) ; entre frères. Défaut : `8mm`, `15mm`.
/// - label (str, bool): `"none"`, `"left"`, `"above"` (`true` = `"above"`). Défaut : `"none"`.
/// - label-style (dictionary), prefix-label, suffix-label (content), label-extrasep (length): libellé. Défaut : `none`, `none`, `none`, `0mm`.
/// - overlay (function): `cellules => contenu` posé par-dessus (ancres `center`, `north-west`… des cellules `"cell 1"`, `"cell 2-1"`… ; aide `node`). Défaut : `none`.
/// - column-sep (length), line-width (length): espace entre colonnes ; épaisseur des traits. Défaut : `1mm`, `0.7pt`.
/// - separator (content): séparateur de \ListeFP et \ListeDiviseurs. Défaut : `[,~]`.
/// - cf (int), cf-style, gcd-style (dictionary): diviseurs communs avec `cf` mis en valeur. Défaut : `0`, `(fill: "arithmcol3!50")`, `(fill: "arithmcol3")`.
/// - tab-orientation (str): `"horizontal"` ou `"vertical"` (\TabPGCD). Défaut : `"horizontal"`.
/// - header-style (dictionary), prefix-header, suffix-header (content): entêtes de \TabPGCD. Défaut : fond gris, gras ; `none` ; `[~:]`.
/// - rules (str): `"none"`, `"all"`, `"horizontal"`, `"Horizontal"`, `"vertical"`, `"Vertical"`. Défaut : `"all"`.
/// - rule-color (color, str): couleur des traits de \TabPGCD. Défaut : `"black"`.
/// - forced-width, inner-xsep, header-width (length): largeur imposée de \TabPGCD. Défaut : `0cm`, `3pt`, `0cm`.
/// - frac-mode (str): `"frac"` ou `"dfrac"` (\DecompFrac). Défaut : `"dfrac"`.
/// - link (str): `"none"`, `"line"`, `"bubble"` (\RowPGCD). Défaut : `"bubble"`.
/// - line-style (dictionary): style des liens `line` (shorten…). Défaut : `none`.
/// - to (dictionary): style du lien n° m (`to m`) : `("2": (out: -90, "in": 90))`. Défaut : `none`.
/// - row-sep (length): interligne des décompositions alignées (ajout ; \baselineskip + \jot). Défaut : `1.24em + 3pt`.
/// - decoration-line-width (length): trait des potences de la mise en page `"etapes"` (ajout). Défaut : `0.4pt`.
/// - bubble-width (length): épaisseur de la barre des bulles (ajout ; amplitude=1.25mm). Défaut : `1.25mm`.
/// - bubble-line-width (length): contour des bulles (ajout). Défaut : `0.7pt`.
/// - cell-min-width (length): largeur minimale des cellules (ajout ; minimum width=3em). Défaut : `3em`.
///
/// ```example
/// #setrdarithm(colors: ("red", "green", "blue"))
/// #decomp-fp(mise-en-page: "etapes", 1260)
/// #setrdarithm(definir: "monstyle", cell-append-style: (radius: 2pt), prime-append-style: (fill-opacity: 1))
/// #decomp-fp(mise-en-page: "arbre", style: "monstyle", 126)
/// #setrdarithm(reinitialiser: "tout")
/// ```
///
/// La clé `frac-mode` prend `"frac"` ou `"dfrac"`.
///
/// - pour (none, str): sans effet ici (rdarithm n'a pas de types) ; gardé pour la signature commune des setters. Défaut : `none`.
/// - reinitialiser (bool, str): `true` : oublie les réglages ; `"tout"` : oublie aussi les styles. Défaut : `false`.
/// - definir (none, str): nom du style à définir avec les clés données. Défaut : `none`.
/// - ..cles (any): clés ci-dessus (et `style:`).
/// -> content
#let setrdarithm(pour: none, reinitialiser: false, definir: none, ..cles) = rd-regler(
  _R, "setrdarithm", pour, reinitialiser, definir, cles,
)

/// `\ListeFP[options]{n}` : liste des facteurs premiers de n.
///
/// ```example
/// Facteurs premiers de 210 : #liste-fp(210). Autre séparateur : #liste-fp(separator: [~-~], 210).
/// ```
///
/// - n (int): entier à décomposer.
/// - separator (auto, content): séparateur. Défaut : `[,~]`.
/// - style (auto, str, array): style(s) nommé(s). Défaut : `auto`.
/// -> content
#let liste-fp(separator: auto, style: auto, n) = _avec(arguments(separator: separator, style: style), "ListeFP", r => _m.ra-listefp(r, _entier(n, "ListeFP")))

/// `\DecompFP[options]{n}` : décomposition de n en facteurs premiers, dans la mise en page choisie par la
/// clé `mise-en-page`. Elle remplace `\DecompFP` (produit), `\DecompFPA`, `\DecompFPB` et `\DecompFPC`.
///
/// `"produit"` (défaut, `\DecompFP`) : produit en ligne, `powers` écrit les facteurs égaux en puissances.
/// `"etapes"` (`\DecompFPA`) : étapes alignées, restes encadrés et reliés (clés `decorate`, `colors`,
/// `node-opacity`, `node-style`, `powers`, `stop`, `crep`, `row-sep`, `overlay`). `"arbre"` (`\DecompFPB`) :
/// arbre, facteur premier à gauche et quotient à droite (`level-distance`, `sibling-distance`, `line-width`,
/// `picture-style`, `cell-style`, `prime-style`, `cell`, `stop`, `crep`, `overlay`). `"tableau"`
/// (`\DecompFPC`) : tableau à deux colonnes, quotients puis facteurs (`column-sep`, `label`, `prefix-label`,
/// `suffix-label`, `cell-style`, `prime-style`, `cell`, `stop`, `crep`, `overlay`).
///
/// ```example
/// $126 = #decomp-fp(126) = #decomp-fp(powers: true, 126)$
///
/// #decomp-fp(mise-en-page: "etapes", 1260) #h(5mm) #decomp-fp(mise-en-page: "arbre", 126)
/// #h(5mm) #decomp-fp(mise-en-page: "tableau", label: true, prefix-label: [Décomposition de~], 105)
/// ```
///
/// - n (int): entier à décomposer.
/// - mise-en-page (str): `"produit"`, `"etapes"`, `"arbre"` ou `"tableau"`. Défaut : `"produit"`.
/// - ..options (any): clés de `setrdarithm` (celles qui n'ont pas de sens pour la mise en page choisie sont sans effet).
/// -> content
#let decomp-fp(mise-en-page: "produit", ..options, n) = {
  let cmd = "DecompFP"
  let mises = ("produit", "etapes", "arbre", "tableau")
  if mise-en-page not in mises {
    panic(cmd + " : mise en page inconnue « " + str(mise-en-page) + " ». Mises en page possibles : " + mises.map(m => "« " + m + " »").join(", ") + ".")
  }
  if options.pos().len() > 0 { panic(cmd + " : un seul argument positionnel (n) est attendu ; reçu aussi : " + repr(options.pos().first()) + ".") }
  _avec(options, cmd, r => {
    let n = _entier(n, cmd)
    if mise-en-page == "produit" { _m.ra-decompfp(r, n) }
    else if mise-en-page == "etapes" { _m.ra-decompfpa(r, n, cmd: cmd) }
    else if mise-en-page == "arbre" { _m.ra-decompfpb(r, n, cmd: cmd) }
    else { _m.ra-decompfpc(r, n, cmd: cmd) }
  })
}

/// `\ListeDiviseurs[options]{n}` : liste ordonnée des diviseurs de n.
///
/// ```example
/// Les diviseurs de 40 : #liste-diviseurs(40).
/// ```
///
/// - n (int): entier.
/// - separator (auto, content): séparateur. Défaut : `[,~]`.
/// - style (auto, str, array): style(s) nommé(s). Défaut : `auto`.
/// -> content
#let liste-diviseurs(separator: auto, style: auto, n) = _avec(arguments(separator: separator, style: style), "ListeDiviseurs", r => _m.ra-listediviseurs(r, _entier(n, "ListeDiviseurs")))

/// `\TabDiviseurs[options]{n}` : diviseurs rangés par paires dans un tableau à deux colonnes. Mêmes clés
/// que `decomp-fp(mise-en-page: "tableau")`, plus `cf`, `cf-style` et `gcd-style` (diviseurs communs avec `cf`, PGCD).
///
/// ```example
/// #tab-diviseurs(label: true, prefix-label: [Diviseurs de ], level-distance: 5mm, cf: 75, 60)
/// ```
///
/// - n (int): entier.
/// - ..options (any): clés de `setrdarithm`.
/// -> content
#let tab-diviseurs(..options, n) = _avec(options, "TabDiviseurs", r => _m.ra-tabdiviseurs(r, _entier(n, "TabDiviseurs")))

/// `\pgcd{a}{b}` : écrit PGCD(a ; b) ; `\pgcd*{a}{b}` (`etoile: true`) : renvoie la valeur (entier).
/// Sans argument, `pgcd()` écrit l'opérateur « PGCD » seul.
///
/// ```example
/// Le #pgcd() de 60 et 75. On a : $#pgcd(60, 75) = #pgcd(60, 75, etoile: true)$.
/// ```
///
/// - ..termes (int): les deux entiers a et b, ou aucun argument (opérateur « PGCD » seul).
/// - etoile (bool): renvoie le PGCD calculé. Défaut : `false`.
/// -> content, int
#let pgcd(etoile: false, ..termes) = {
  let t = termes.pos()
  if t.len() == 0 { return $op("PGCD")$ }
  if t.len() != 2 { panic("pgcd : deux entiers (a, b) ou aucun argument sont attendus ; reçu : " + str(t.len()) + " argument(s).") }
  if etoile { calc.gcd(..t) } else { _m.ra-ecrire("PGCD", ..t) }
}

/// `\ppcm{a}{b}` : écrit PPCM(a ; b) ; `\ppcm*{a}{b}` (`etoile: true`) : renvoie la valeur (entier).
/// Sans argument, `ppcm()` écrit l'opérateur « PPCM » seul.
///
/// ```example
/// Le #ppcm() de 60 et de 75 vaut #ppcm(60, 75, etoile: true).
/// ```
///
/// - ..termes (int): les deux entiers a et b, ou aucun argument (opérateur « PPCM » seul).
/// - etoile (bool): renvoie le PPCM calculé. Défaut : `false`.
/// -> content, int
#let ppcm(etoile: false, ..termes) = {
  let t = termes.pos()
  if t.len() == 0 { return $op("PPCM")$ }
  if t.len() != 2 { panic("ppcm : deux entiers (a, b) ou aucun argument sont attendus ; reçu : " + str(t.len()) + " argument(s).") }
  if etoile { calc.lcm(..t) } else { _m.ra-ecrire("PPCM", ..t) }
}

/// `\TabPGCD[options]{a}{b}` : tableau des facteurs premiers de a et b rangés en colonnes ; les facteurs
/// communs (ceux du PGCD) reçoivent `gcd-style`. Clés utiles : `tab-orientation`, `header-style`,
/// `prefix-header`, `suffix-header`, `rules`, `rule-color`, `forced-width`, `inner-xsep`, `header-width`,
/// `line-width`, `level-distance`, `cell-style`, `gcd-style`, `cell`, `picture-style`, `overlay`, `crep`.
///
/// ```example
/// #tab-pgcd(420, 126)
///
/// Ainsi $#pgcd(420, 126) = #decomp-fp(pgcd(420, 126, etoile: true)) = #pgcd(420, 126, etoile: true)$
/// ```
///
/// - a (int): premier entier.
/// - b (int): second entier.
/// - ..options (any): clés de `setrdarithm`.
/// -> content
#let tab-pgcd(..options, a, b) = layout(taille => _avec(options, "TabPGCD", r => {
  // forced-width relatif (100% = \linewidth) : résolu sur la largeur disponible
  let fw = r.forced-width
  if type(fw) == ratio { fw = fw * taille.width } else if type(fw) == relative { fw = fw.ratio * taille.width + fw.length.to-absolute() } else { fw = fw.to-absolute() }
  _m.ra-tabpgcd(r + (forced-width: fw), _entier(a, "TabPGCD"), _entier(b, "TabPGCD"))
}))

/// `\RowPGCD[options]{a}{b}` : décompositions de a et b alignées, facteurs communs reliés (`link` :
/// `"bubble"`, `"line"` ou `"none"`). Dans `cf-style`, la couleur `"arithmcol"` désigne la couleur du
/// couple courant (liste `colors`). Clés utiles : `colors`, `cf-style`, `link`, `line-width`,
/// `line-style`, `to`, `cell` (`"1-k"`, `"2-k"`), `crep`.
///
/// ```example
/// #row-pgcd(cf-style: (inset: 1.5pt), colors: ("arithmcol1!50", "arithmcol2!50", "arithmcol3!50"), 420, 126)
/// #h(1cm)
/// #row-pgcd(cf-style: (inset: 1.5pt, fill: "arithmcol"), link: "line", 420, 126)
/// ```
///
/// - a (int): premier entier.
/// - b (int): second entier.
/// - ..options (any): clés de `setrdarithm`.
/// -> content
#let row-pgcd(..options, a, b) = _avec(options, "RowPGCD", r => _m.ra-rowpgcd(r, _entier(a, "RowPGCD"), _entier(b, "RowPGCD")))

/// `\DecompFrac[options]{a}{b}` : fraction a/b, numérateur et dénominateur décomposés, facteurs communs
/// mis en valeur par `cf-style` (`"arithmcol"` : couleur du couple). `frac-mode: "frac"` : fraction en ligne.
///
/// ```example
/// $105/273 = #decomp-frac(cf-style: (shape: "circle", inset: 1.5pt, fill: "arithmcol"),
///   colors: ("arithmcol1!50", "arithmcol2!50"), 105, 273) = #dfracirr(105, 273)$
/// ```
///
/// - a (int): numérateur.
/// - b (int): dénominateur.
/// - ..options (any): clés de `setrdarithm`.
/// -> content
#let decomp-frac(..options, a, b) = _avec(options, "DecompFrac", r => _m.ra-decompfrac(r, _entier(a, "DecompFrac"), _entier(b, "DecompFrac")))

/// `\fracirr{a}{b}` : fraction irréductible égale à a/b (taille du texte).
///
/// ```example
/// On a $15/45 = #fracirr(15, 45)$.
/// ```
///
/// - a (int): numérateur.
/// - b (int): dénominateur.
/// -> content
#let fracirr(a, b) = {
  let g = calc.gcd(a, b)
  $inline(frac(#str(calc.quo(a, g)), #str(calc.quo(b, g))))$
}

/// `\dfracirr{a}{b}` : fraction irréductible égale à a/b, en taille « display ».
///
/// ```example
/// On a $display(63/96) = #dfracirr(63, 96)$.
/// ```
///
/// - a (int): numérateur.
/// - b (int): dénominateur.
/// -> content
#let dfracirr(a, b) = {
  let g = calc.gcd(a, b)
  $display(frac(#str(calc.quo(a, g)), #str(calc.quo(b, g))))$
}
