// natif.typ (farfadet-tableaux) — tableaux sur la `table` native de Typst : registre de réglages et
// constructeur de `tcbtab` (types `tcbtab` et `secondaire`).
//
// Le registre décrit TOUTES les clés des tableaux (options tcolorbox, clés de tableau, ajouts) ; le
// constructeur `bf-tableau` reçoit les valeurs effectives déjà résolues (`reglages-resoudre`) et dessine :
// une grille `table` native, éventuellement entourée du cadre bfcours (titre, coins arrondis, ombre
// floue : `_boite-tableau`, moteur de ce paquet).
//
// Noms exportés par interne.typ (générés) : `bf-reglages-tableaux`, `bf-tableau`.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: (
  bf-couleurs-tableaux-p,
  bf-lire,
  reglages-paquet, reglages-controles, reglages-choix, reglages-ou, bf-nommee, bf-couleurs-tableaux, bf-resoudre-couleur,
  bf-largeur-courante, taille-latex, longueur-latex,
)
#import "tableaux.typ": _boite-tableau, bf-analyser-spec

// =====================================================================
// Registre de réglages
// =====================================================================

#let _ctl = reglages-controles
#let _auto = reglages-choix(auto)
#let _couleur-auto = reglages-ou(_ctl.couleur-ou-nom, _auto)

#let _est-alignement(v) = type(v) == alignment
#let _est-colonne(v) = type(v) in (length, relative, ratio, fraction) or v == auto

/// Styles prédéfinis, équivalents des styles tcolorbox `TableauBox` et `CompTab` de bfcours.
#let _styles-predefinis = (
  // new-bfcours-environments.sty:1700 : couleurs courantes des tableaux, titre centré en gras
  "TableauBox": (
    couleurs: "primaire",
    center-title: true,
    toptitle: 0.5mm,
    bottomtitle: 0.5mm,
    fonttitle: (weight: "bold"),
    left: 0mm,
    right: 0mm,
    top: 0mm,
    bottom: 0mm,
    boxsep: 0mm,
  ),
  // new-bfcours-environments.sty:1711 : filets blue!50!black (= cadre courant), \arraystretch = 0,2
  "CompTab": (style: "TableauBox", arrayrulecolor: bf-nommee("currentTableFrameColor"), arraystretch: 0.2),
)

#let _registre = reglages-paquet(
  "tableaux",
  (
    // --- contenu et structure
    title: none,
    entete: false,
    entete-colonne: false,
    // --- couleurs : couleurs nommées de bfcours lues au rendu (\CouleursTabular, setbfcolors)
    couleurs: "primaire",
    colframe: bf-nommee("currentTableFrameColor"),
    colback: auto, // auto : fond courant des tableaux dans le cadre ; transparent sans cadre
    colbacktitle: bf-nommee("currentTableColbackTitleColor"),
    coltitle: bf-nommee("currentTableColTitleColor"),
    colupper: bf-nommee("currentTableColupperColor"),
    entete-fond: auto,
    entete-texte: auto,
    entete-colonne-fond: auto,
    rowcolors: false,
    arrayrulecolor: auto, // auto : filets courants des tableaux (\CouleursTabular), noirs d'origine
    // --- grille
    arrayrulewidth: 0.4pt,
    arraystretch: 1.5,
    tabcolsep: auto,
    marges: (x: 6pt, y: 5.5pt),
    alignement: center + horizon,
    filets: auto,
    // --- cadre tcolorbox
    cadre: true,
    boxrule: 0.5mm,
    arc: 1mm,
    toptitle: 0.5mm,
    bottomtitle: 0.5mm,
    fonttitle: (weight: "bold"),
    fontupper: (:),
    center-title: true,
    drop-fuzzy-shadow: true,
    // marges intérieures de la boîte (TableauBox : left=right=top=bottom=boxsep=0mm)
    left: 0mm,
    right: 0mm,
    top: 0mm,
    bottom: 0mm,
    boxsep: 0mm,
    width: auto,
    align: left, // \tcbtab est une boîte posée en début de ligne ; \tcbtabc centre (align: center)
  ),
  controles: (
    title: reglages-ou(_ctl.contenu-ou-none, _auto),
    entete: reglages-ou(_ctl.booleen, _ctl.entier),
    entete-colonne: _ctl.booleen,
    couleurs: reglages-choix("primaire", "secondaire"),
    colframe: _ctl.couleur-ou-nom,
    colback: _couleur-auto,
    colbacktitle: _ctl.couleur-ou-nom,
    coltitle: _ctl.couleur-ou-nom,
    colupper: reglages-ou(_ctl.couleur-ou-nom, reglages-choix(none)),
    entete-fond: _couleur-auto,
    entete-texte: _couleur-auto,
    entete-colonne-fond: _couleur-auto,
    rowcolors: (
      v => (
        type(v) in (bool, str, color)
          or (type(v) == array and v.len() == 2 and v.all(x => x == none or type(x) in (str, color)))
          or (
            type(v) == array and v.len() == 3 and type(v.at(0)) == int and v.at(0) >= 1
              and v.slice(1).all(x => x == none or type(x) in (str, color))
          )
      ),
      "false, true, une couleur (Typst ou xcolor), un tableau de deux couleurs (rangées impaires, paires) ou, comme \\rowcolors{début}{impaires}{paires}, un tableau (début, impaires, paires)",
    ),
    arrayrulecolor: _couleur-auto,
    arrayrulewidth: _ctl.longueur,
    arraystretch: _ctl.nombre,
    tabcolsep: _ctl.longueur-ou-auto,
    marges: (
      v => (
        type(v) == length
          or (type(v) == dictionary and v.keys().all(k => k in ("x", "y")) and v.values().all(x => type(x) == length))
      ),
      "une longueur (2pt) ou un dictionnaire (x: 6pt, y: 5.5pt)",
    ),
    alignement: (
      v => _est-alignement(v) or (type(v) == array and v.all(_est-alignement)),
      "un alignement (center + horizon) ou un tableau d'alignements, un par colonne",
    ),
    filets: reglages-choix(auto, "tous", "horizontaux", "verticaux", "aucun"),
    cadre: _ctl.booleen,
    boxrule: _ctl.longueur,
    arc: _ctl.longueur,
    toptitle: _ctl.longueur,
    bottomtitle: _ctl.longueur,
    fonttitle: (v => type(v) == dictionary, "un dictionnaire d'arguments de `text` : (weight: \"bold\", size: \"large\")"),
    fontupper: (v => type(v) == dictionary, "un dictionnaire d'arguments de `text` : (size: \"small\")"),
    center-title: _ctl.booleen,
    drop-fuzzy-shadow: _ctl.booleen,
    left: _ctl.longueur,
    right: _ctl.longueur,
    top: _ctl.longueur,
    bottom: _ctl.longueur,
    boxsep: _ctl.longueur,
    width: reglages-ou(_ctl.longueur-ou-auto, _ctl.texte),
    align: reglages-choix(none, left, center, right),
  ),
  types: (
    // tableau principal (`align: left`, défaut, comme \tcbtab ; `align: center` = \tcbtabc) : défauts communs
    tcbtab: (:),
    // `couleurs: "secondaire"` : couleurs secondaires, filets de 0.5mm, arraystretch 1.4, titre en gras
    // agrandi ; texte du tableau en noir (pas de colupper). `tcbtab` bascule sur ce type quand `couleurs` vaut "secondaire".
    secondaire: (
      couleurs: "secondaire",
      colframe: bf-nommee("currentSecondaryTableFrameColor"),
      colbacktitle: bf-nommee("currentSecondaryTableColbackTitleColor"),
      coltitle: bf-nommee("currentSecondaryTableColTitleColor"),
      colupper: none,
      arrayrulewidth: 0.5mm,
      arraystretch: 1.4,
      toptitle: 1mm,
      bottomtitle: 1mm,
      fonttitle: (weight: "bold", size: "large"),
    ),
  ),
  commande: "setbftableaux",
  styles: _styles-predefinis,
)

/// Registre de réglages des tableaux (mécanisme générique du socle). L'état part avec les styles
/// prédéfinis `TableauBox` et `CompTab` (contrôlés par le socle, rétablis par `reglages-reinitialiser`).
#let bf-reglages-tableaux = _registre

/// Styles prédéfinis (pour la réinitialisation complète).
#let bf-styles-tableaux = _styles-predefinis

// =====================================================================
// Constructeur
// =====================================================================

/// Dictionnaire d'arguments de `text` : une taille donnée par son nom LaTeX (« large ») devient une longueur.
/// À appeler dans un `context`.
#let _police(d) = {
  let d = d
  if "size" in d and type(d.size) == str { d.size = taille-latex(d.size) }
  d
}

/// La cellule est-elle (ou commence-t-elle par) une boîte de réponse `tccrep`/`repsim`/`tcfillcrep`/`crepbox` ?
/// Ces fonctions posent un repère invisible (`metadata("bf-crep-cell")`) en tête de leur contenu.
#let _porte-boite-crep(c) = {
  if c.func() == metadata { return c.value == "bf-crep-cell" }
  if c.func() == [*a* *b*].func() { return c.children.any(x => x.func() == metadata and x.value == "bf-crep-cell") }
  false
}

/// Cellule fournie sous forme de marqueur (`hline`, `cline`, `multicolumn`, `cellcolor`, `multirow` de ce
/// paquet) → élément de `table` ; tout autre contenu passe tel quel. À appeler dans un `context`.
#let _convertir-cellule(it, trait, vertical, n) = {
  if type(it) == dictionary and it.at("bf-filet", default: false) {
    if it.de != none and it.a > n {
      panic("cline : la plage « " + str(it.de) + "-" + str(it.a) + " » dépasse les " + str(n) + " colonnes du tableau.")
    }
    if it.de == none { table.hline(stroke: trait) } else { table.hline(start: it.de - 1, end: it.a, stroke: trait) }
  } else if type(it) == dictionary and it.at("bf-cellule", default: false) {
    table.cell(
      colspan: it.colspan,
      rowspan: it.rowspan,
      fill: if it.fill == none { auto } else { bf-resoudre-couleur(it.fill) },
      align: if it.align == auto { auto } else { it.align + vertical },
      it.corps,
    )
  } else if type(it) == content and _porte-boite-crep(it) {
    // une boîte de réponse (tccrep, repsim, tcfillcrep) a ses propres marges : pas de marge verticale en plus
    table.cell(inset: (y: 0pt), it)
  } else { it }
}

/// Rangées alternées (`rowcolors`) → `none` ou `(debut: n | none, couleurs: (impaires, paires))`, couleurs
/// résolues. `debut: none` : alternance à partir de la première rangée du corps (première couleur d'abord) ;
/// `debut: n` : numérotation absolue des rangées comme `\rowcolors{n}{impaires}{paires}` (rangée 1 = la
/// première du tableau). `pale` : teinte de `rowcolors: true`. À appeler dans un `context`.
#let bf-rangees(v, pale) = {
  let res(x) = if x == none { none } else { bf-resoudre-couleur(x) }
  if v == false or v == none { none } else if v == true { (debut: none, couleurs: (none, pale)) } else if (
    type(v) == array and v.len() == 3
  ) {
    (debut: v.at(0), couleurs: (res(v.at(1)), res(v.at(2))))
  } else if type(v) == array { (debut: none, couleurs: v.map(res)) } else { (debut: none, couleurs: (none, res(v))) }
}

/// Couleur de la rangée `y` (0 = première rangée du tableau) pour des rangées alternées `rg` (`bf-rangees`),
/// `nh` rangées d'en-tête ; `auto` : la rangée n'est pas concernée.
#let bf-couleur-rangee(rg, y, nh: 0) = {
  if rg == none { return auto }
  if rg.debut == none {
    if y < nh { auto } else { rg.couleurs.at(calc.rem(y - nh, 2)) }
  } else {
    let n = y + 1
    if n < rg.debut { auto } else { rg.couleurs.at(if calc.odd(n) { 0 } else { 1 }) }
  }
}

/// Convention LaTeX de `\multirow` : sous une cellule `multirow(n)`, la rangée suivante donne une cellule
/// vide à sa place (`[]`). La `table` de Typst, elle, saute d'elle-même les places couvertes : on écarte
/// donc ces cellules de remplacement. Les `table.cell(rowspan: …)` natives suivent la convention de Typst
/// (pas de cellule de remplacement) et sont respectées telles quelles. `n` : nombre de colonnes.
#let _sans-places-multirow(cellules, n) = {
  let couvert-latex = (:)
  let couvert-natif = (:)
  let cle(x, y) = str(x) + "," + str(y)
  let (x, y) = (0, 0)
  let res = ()
  for it in cellules {
    let est-filet = (
      (type(it) == dictionary and it.at("bf-filet", default: false))
        or (type(it) == content and it.func() in (table.hline, table.vline))
    )
    if est-filet { res.push(it); continue }
    // places déjà prises par une cellule native sur plusieurs rangées : Typst les saute
    while cle(x, y) in couvert-natif {
      x += 1
      if x >= n { x = 0; y += 1 }
    }
    let marqueur = type(it) == dictionary and it.at("bf-cellule", default: false)
    let natif = type(it) == content and it.func() == table.cell
    let cs = if marqueur { it.colspan } else if natif and it.has("colspan") { it.colspan } else { 1 }
    let rs = if marqueur { it.rowspan } else if natif and it.has("rowspan") { it.rowspan } else { 1 }
    if cle(x, y) in couvert-latex {
      // cellule de remplacement sous un multirow : écartée, elle n'occupe que sa place
    } else {
      res.push(it)
      for yy in range(y + 1, y + rs) {
        for xx in range(x, calc.min(x + cs, n)) {
          if marqueur { couvert-latex.insert(cle(xx, yy), true) } else { couvert-natif.insert(cle(xx, yy), true) }
        }
      }
    }
    x += cs
    if x >= n { x = 0; y += 1 }
  }
  res
}

/// Colonnes `auto` → `1fr` (la grille s'étire sur une largeur imposée) ; `none` si aucune ne change.
#let _colonnes-etirees(cols) = {
  let liste = if type(cols) == int { (auto,) * cols } else { cols }
  if auto not in liste { none } else { liste.map(c => if c == auto { 1fr } else { c }) }
}

/// Dessine un tableau à partir des réglages effectifs `r` (voir le registre) : grille native, entourée du
/// cadre bfcours si `r.cadre`. À appeler dans un `context`.
///
/// - r (dictionary): valeurs effectives (`reglages-resoudre`).
/// - colonnes (str, int, array): spécification LaTeX (« |c|p{3cm}| »), nombre de colonnes ou largeurs Typst.
/// - cellules (array): cellules (contenus, `table.cell`, marqueurs de ce paquet), rangée après rangée.
/// - commande (str): nom de la commande dans les messages d'erreur.
#let bf-tableau(r, colonnes, cellules, commande: "tcbtab") = {
  let fam = bf-lire(bf-couleurs-tableaux-p).at(r.couleurs)
  let courante(v, defaut) = if v == auto { bf-resoudre-couleur(defaut) } else if v == none { none } else { bf-resoudre-couleur(v) }
  // cadre, titre et texte : couleurs nommées déjà résolues par `reglages-resoudre` (ou chaînes xcolor)
  let c-cadre = bf-resoudre-couleur(r.colframe)
  let c-fond-titre = bf-resoudre-couleur(r.colbacktitle)
  let c-texte-titre = bf-resoudre-couleur(r.coltitle)
  let c-fond-boite = courante(r.colback, fam.fond)
  // sans cadre, la grille n'est colorée que si `colback` est donné
  let c-fond-grille = if r.colback == auto { none } else { bf-resoudre-couleur(r.colback) }
  let c-texte = if r.colupper == none { none } else { bf-resoudre-couleur(r.colupper) }
  let c-filets = if r.arrayrulecolor == auto {
    if r.couleurs == "secondaire" { c-cadre } else { courante(auto, fam.at("filets", default: "black")) }
  } else { bf-resoudre-couleur(r.arrayrulecolor) }
  let c-entete = if r.entete-fond == auto { c-fond-titre } else { bf-resoudre-couleur(r.entete-fond) }
  let c-entete-texte = if r.entete-texte == auto { c-texte-titre } else { bf-resoudre-couleur(r.entete-texte) }
  let c-entete-col = if r.entete-colonne-fond == auto { c-cadre.lighten(80%) } else { bf-resoudre-couleur(r.entete-colonne-fond) }
  let rangees = bf-rangees(r.rowcolors, c-cadre.lighten(88%))

  // --- géométrie
  let mx = if type(r.marges) == length { r.marges } else { r.marges.at("x", default: 6pt) }
  let my = if type(r.marges) == length { r.marges } else { r.marges.at("y", default: 5.5pt) }
  let tcs = if r.tabcolsep == auto { mx } else { r.tabcolsep }
  // `marges.y` est la marge verticale pour \arraystretch = 1,5 (valeur de bfcours) ; elle suit \arraystretch
  let inset = (x: tcs, y: my * r.arraystretch / 1.5)
  let trait = r.arrayrulewidth + c-filets

  // --- colonnes
  let lt = bf-largeur-courante()
  let vertical = if type(r.alignement) == alignment and r.alignement.y != none { r.alignement.y } else { horizon }
  let (cols, aligns, filets-spec) = if type(colonnes) == str {
    let sp = bf-analyser-spec(colonnes, largeur-texte: lt)
    if sp.colonnes.len() == 0 {
      panic(commande + " : la spécification de colonnes « " + colonnes + " » ne contient aucune colonne (c, l, r, p{…}, X).")
    }
    (
      sp.colonnes.map(c => if type(c.largeur) == length { c.largeur + 2 * tcs } else { c.largeur }),
      sp.colonnes.map(c => (if c.align == auto { left } else { c.align }) + vertical),
      sp.filets,
    )
  } else if type(colonnes) == int {
    if colonnes < 1 { panic(commande + " : le nombre de colonnes doit être au moins 1 ; reçu : " + repr(colonnes) + ".") }
    (colonnes, r.alignement, none)
  } else if type(colonnes) == array and colonnes.len() > 0 and colonnes.all(_est-colonne) {
    (colonnes, r.alignement, none)
  } else {
    panic(
      commande + " : le premier argument (colonnes) est une spécification LaTeX (\"|c|c|\"), un nombre de colonnes (3) ou un tableau de largeurs ((auto, 1fr, 3cm)) ; reçu : "
        + repr(colonnes) + ".",
    )
  }

  // --- filets
  let nh = if r.entete == true { 1 } else if r.entete == false { 0 } else { r.entete }
  let stroke = if r.filets == auto {
    // spécification de colonnes : filets verticaux posés plus bas (`verticaux`), filets horizontaux entre toutes
    // les rangées (la bordure extérieure est celle du cadre) ; un `hline()` explicite prend le pas sur celui-ci
    if filets-spec == none { trait } else { (x, y) => if y > 0 { (top: trait) } else { none } }
  } else {
    (tous: trait, horizontaux: (x: none, y: trait), verticaux: (x: trait, y: none), aucun: none).at(r.filets)
  }
  let verticaux = if r.filets == auto and filets-spec != none {
    filets-spec.enumerate().filter(((b, k)) => k > 0).map(((b, k)) => table.vline(x: b, stroke: r.arrayrulewidth * k + c-filets))
  } else { () }

  let remplissage = (x, y) => {
    let alt = bf-couleur-rangee(rangees, y, nh: nh)
    if y < nh { c-entete } else if r.entete-colonne and x == 0 { c-entete-col } else if alt != auto { alt } else { c-fond-grille }
  }

  // nombre de colonnes (spécification, nombre ou liste) : sert à écarter les cellules de remplacement
  // que LaTeX attend sous un \multirow
  let n-col = if type(cols) == int { cols } else { cols.len() }
  let cellules = _sans-places-multirow(cellules, n-col).map(it => _convertir-cellule(it, trait, vertical, n-col))

  let grille(l, cs: cols) = {
    show table.cell: it => {
      if it.y < nh {
        set text(fill: c-entete-texte, weight: "bold")
        it
      } else if r.entete-colonne and it.x == 0 {
        set text(weight: "bold")
        it
      } else { it }
    }
    let t = table(
      columns: cs,
      stroke: stroke,
      fill: remplissage,
      align: aligns,
      inset: inset,
      ..verticaux,
      ..cellules,
    )
    let t = text(.._police(r.fontupper), t)
    if l == auto { t } else { block(width: l, above: 0pt, below: 0pt, t) }
  }

  let habiller(l) = {
    if not r.cadre {
      let g = grille(l)
      if c-texte == none { g } else { text(fill: c-texte, g) }
    } else {
      let c = (cadre: c-cadre, fond-titre: c-fond-titre, texte-titre: c-texte-titre, fond: c-fond-boite, texte: c-texte)
      // marges intérieures de la boîte (left, right, top, bottom, boxsep de tcolorbox ; 0 dans TableauBox)
      let mg = r.left + r.boxsep
      let md = r.right + r.boxsep
      let entourer(g) = pad(left: mg, right: md, top: r.top + r.boxsep, bottom: r.bottom + r.boxsep, g)
      // la grille remplit la largeur intérieure du cadre (2 × boxrule, moins les marges)
      let l = l
      let cs = cols
      // dimensions naturelles de la grille, mesurées une fois et transmises à `_boite-tableau`
      let m-grille = none
      if l == auto and r.title != none {
        // titre plus large que la grille : la boîte prend la largeur du titre et la grille s'étire
        // (colonnes `auto` → `1fr`) au lieu de flotter au milieu de bandes vides
        let l-titre = measure(text(.._police(r.fonttitle), r.title)).width + 2 * r.toptitle
        m-grille = measure(entourer(grille(auto)))
        let l-grille = m-grille.width
        let etirees = _colonnes-etirees(cols)
        if l-titre > l-grille and etirees != none {
          l = l-titre + 2 * r.boxrule
          cs = etirees
          m-grille = none
        }
      }
      let interieur = if l == auto { auto } else { l - 2 * r.boxrule - mg - md }
      _boite-tableau(
        r.title,
        entourer(grille(interieur, cs: cs)),
        c,
        largeur: l,
        mesure-corps: m-grille,
        regle: r.boxrule,
        arc: r.arc,
        marge-titre: r.toptitle,
        marge-titre-bas: r.bottomtitle,
        police-titre: _police(r.fonttitle),
        ombre: r.drop-fuzzy-shadow,
        titre-centre: r.center-title,
      )
    }
  }

  // largeur : longueur, proportion de la ligne, ou chaîne LaTeX (« 0.8\textwidth »)
  let w = if type(r.width) == str { longueur-latex(r.width, defaut: auto) } else { r.width }
  let corps = if type(w) in (ratio, relative) {
    let w = w + 0pt
    layout(taille => context habiller(w.ratio * taille.width + w.length))
  } else { habiller(w) }
  // \tcbtab est une boîte `nobeforeafter` posée comme une ligne de texte : aucun espace ajouté avant ni
  // après, seulement l'interligne. Valeurs mesurées sur le PDF LaTeX (texte en 12 pt) : la ligne qui précède
  // est à un interligne du titre (14,5 pt), la ligne qui suit au pas d'une rangée de la dernière (22,3 pt)
  if r.align == none { corps } else { block(width: 100%, above: 1pt, below: 4.3pt, align(r.align, corps)) }
}
