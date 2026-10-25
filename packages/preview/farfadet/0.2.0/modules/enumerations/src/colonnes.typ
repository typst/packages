// colonnes.typ (farfadet-enum) — façade publique du colonnage : MultiColonnes, tcbitem, tcbraster.
// Noms et clés = ceux de LaTeX (bfcours, tcolorbox). Réglages : `setbfenum` (reglages.typ).
// Les noms du moteur (interne.typ) : on les appelle par l'alias de module `m` (listes) et `mc` (colonnes).

#import "../../socle/lib.typ": interne as _socle
#import _socle: lire-options, longueur-latex, reglages-resoudre, bf-avec-largeur, garde-marqueur
#import "moteur/listes.typ" as m
#import "moteur/colonnes.typ" as mc
#import "reglages.typ": registre-enum
#import "items.typ": items-boites

// =====================================================================
// tcbitem
// =====================================================================

/// Clés tcolorbox qu'un `tcbitem` (ou une case de raster) comprend.
#let _cles-tcbitem = (
  "raster-multicolumn", "colback", "colframe", "boxrule", "colbacktitle", "coltitle", "colupper", "coltext",
  "halign", "valign", "halign-upper", "valign-upper", "halign-title", "fonttitle", "fontupper", "title", "notitle",
  "size", "blank", "blanker", "blankest", "arc", "boxsep", "left", "right", "top", "bottom", "lefttitle",
  "righttitle", "toptitle", "bottomtitle", "titlerule", "sharp-corners", "frame-hidden", "interior-hidden",
  "opacityback", "center-upper", "center-title", "flushleft-title", "flush-left-title", "title-filled", "width",
  "height", "enhanced", "breakable", "nobeforeafter", "compenser", "numerote", "count",
)

#let _verifier-cles(commande, cles, permises) = {
  for cle in cles {
    if cle not in permises {
      panic(
        commande + " : clé inconnue « " + cle + " ». Clés possibles : "
          + permises.map(c => "« " + c + " »").join(", ") + ".",
      )
    }
  }
}

/// Une case d'un `multi-colonnes`, d'un `tcbenumerate` ou d'un `tcbraster`, avec ses réglages
/// propres : elle peut occuper plusieurs colonnes (`raster-multicolumn`), avoir son fond (`colback`), son cadre
/// (`colframe` et `boxrule`), son alignement, un titre. Une clé absente reprend le réglage de la disposition
/// qui contient la case. Sans réglage propre, un simple contenu `[…]` suffit.
///
/// Un `tcbitem` s'écrit dans le corps de la disposition, à la place du `-` ou du `+` (jamais `+ #tcbitem`).
/// Il renvoie un marqueur de contenu, lu par la disposition qui le contient : hors d'une disposition, la
/// compilation s'arrête.
///
/// Dans un `tcbenumerate`, `numerote: false` (alias `count`) fait une case de transition : pas de pastille,
/// et le compteur n'avance pas. Elle se combine avec `raster-multicolumn` (case sur toute la largeur).
///
/// ```typ
/// #multi-colonnes(3)[
///   #tcbitem(raster-multicolumn: 2)[Énoncé, sur deux colonnes]
///   #tcbitem(colback: yellow.lighten(80%))[Remarque]
/// ]
/// ```
///
/// - tcb (str, none): clés tcolorbox en syntaxe LaTeX, comme dans `\tcbitem[…]` : `"raster multicolumn=2, halign=center"`. Les clés nommées ci-dessous s'y ajoutent et l'emportent.
/// - raster-multicolumn (int): nombre de colonnes occupées par la case (1 par défaut).
/// - colback (color, str, none): fond de la case (couleur Typst ou expression xcolor : `"yellow!20"`).
/// - colframe (color, str, none): couleur du cadre ; `none` supprime le cadre de cette case.
/// - boxrule (length): épaisseur du cadre (0,4 pt par défaut).
/// - halign (str): alignement horizontal du texte : `"justify"`, `"left"`, `"center"`, `"right"`.
/// - valign (str): alignement vertical : `"top"`, `"center"`, `"bottom"`.
/// - title (content): titre de la case, dans un bandeau en tête.
/// - numerote (bool): `false` : pas de pastille et le compteur n'avance pas (`tcbenumerate` seulement ; `true`). Alias : `count`.
/// - corps (content): contenu de la case.
/// -> content
#let tcbitem(tcb: none, ..args) = {
  let pos = args.pos()
  if pos.len() != 1 {
    panic("tcbitem : un seul contenu est attendu (le corps de la case) ; reçu : " + str(pos.len()) + ".")
  }
  let cles = lire-options(tcb) + args.named()
  _verifier-cles("tcbitem", cles.keys().map(c => c.replace(" ", "-")), _cles-tcbitem)
  if "raster-multicolumn" in cles {
    let v = cles.at("raster-multicolumn")
    let n = if type(v) == str { int(v) } else { v }
    if type(n) != int or n < 1 { panic("tcbitem : `raster-multicolumn` doit être un entier à partir de 1 ; reçu : " + repr(v) + ".") }
  }
  if "count" in cles {
    if "numerote" in cles { panic("tcbitem : `count` est l'alias de `numerote` ; ne donner qu'une des deux clés.") }
    cles.insert("numerote", cles.remove("count"))
  }
  if "numerote" in cles {
    let v = cles.numerote
    if v in ("true", "false") { v = v == "true" }
    if type(v) != bool { panic("tcbitem : `numerote` doit valoir true ou false ; reçu : " + repr(cles.numerote) + ".") }
    cles.numerote = v
  }
  // marqueur de contenu, lu par `decouper-items` (la garde signale un tcbitem hors d'une disposition)
  garde-marqueur("tcbitem hors d'une disposition à items : à écrire dans le corps d'un tcbenumerate, d'un MultiColonnes ou d'un tcbraster.")
  metadata((bf-tcbitem: true, options: cles, corps: pos.first()))
}

// =====================================================================
// MultiColonnes
// =====================================================================

/// Une case est un dictionnaire : tcbitem(…) en fabrique, un simple contenu devient une case ordinaire.
/// À appeler dans un `context` (résolution des couleurs).
#let _lire-case(c, boxrule) = {
  let (corps, o) = m.bf-lire-item(c)
  let fond = if "colback" in o { mc.bf-couleur-tcb(o.colback) } else { auto }
  let bordure = auto
  if "colframe" in o {
    let cf = mc.bf-couleur-tcb(o.colframe)
    let ep = if "boxrule" in o { longueur-latex(o.boxrule, defaut: boxrule) } else { boxrule }
    bordure = if cf == none { none } else { ep + cf }
  }
  let n = o.at("raster-multicolumn", default: 1)
  (
    colonnes: if type(n) == str { int(n) } else { n },
    fond: fond,
    bordure: bordure,
    halign: o.at("halign", default: auto),
    valign: o.at("valign", default: auto),
    titre: o.at("title", default: none),
    colbacktitle: if "colbacktitle" in o { mc.bf-couleur-tcb(o.colbacktitle) } else { auto },
    coltitle: if "coltitle" in o { mc.bf-couleur-tcb(o.coltitle) } else { auto },
    corps: corps,
  )
}

/// Alignement vertical d'une case dans sa rangée (celui de la case, sinon celui de la disposition).
#let _valign-case(c, defaut) = {
  let va = if c.valign == auto { defaut } else { c.valign }
  if va in ("center", "centre") { horizon } else if va == "bottom" { bottom } else { top }
}

/// Largeur de colonne : un entier ou un flottant vaut des parts (`3` = `3fr`) ; le reste passe tel quel.
#let _largeur-colonne(l) = if type(l) in (int, float) { l * 1fr } else { l }

/// Dispose des contenus côte à côte, en colonnes : un énoncé et sa figure, trois remarques alignées, des
/// exercices en grille… Le premier argument est le nombre de colonnes (`{n}` de LaTeX) ; chaque contenu
/// `[…]` qui suit devient une case, et quand une rangée est pleine la suivante commence dessous. Les cases
/// d'une même rangée ont la même hauteur (`raster-equal-height`).
///
/// Sans réglage, les colonnes sont invisibles : du texte côte à côte. Avec `colframe` ou `colback`, chaque
/// case devient une boîte. Avec `filets`, un trait sépare les colonnes. Une case qui a besoin d'un réglage
/// propre (largeur de plusieurs colonnes, fond, titre…) se fabrique par `tcbitem(…)`.
///
/// Les réglages se posent trois façons : sur l'appel (clés ci-dessous), par un style nommé
/// (`style: "mon-style"`, défini par `setbfenum(definir: "mon-style", …)`) ou pour tout le document
/// (`setbfenum(pour: "MultiColonnes", …)`, qui remplace le `\setColonnesBaseStyle` de LaTeX). La clé locale
/// l'emporte sur le style nommé, qui l'emporte sur le réglage du type, qui l'emporte sur le réglage global.
///
/// ```typ
/// #multi-colonnes(2)[
///   - Un énoncé.
///   - Sa figure.
/// ]
/// #multi-colonnes(largeurs: (3, 2), filets: 0.5pt + gray)[
///   - Énoncé
///   - Figure
/// ]
/// ```
///
/// Le corps est UN SEUL bloc `[…]` : une case par `-` (ou `#tcbitem(…)[…]`). Du texte écrit après une case
/// lui est rattaché.
///
/// - n (int): nombre de colonnes, en premier argument (ou clé `columns`). Absent : celui de `largeurs`, sinon 2.
/// - largeurs (array, auto): largeur de chaque colonne : longueurs (`4cm`), parts (`2fr`) ou nombres qui valent des parts (`(3, 2)`). `auto` : colonnes égales.
/// - raster-column-skip (length): espace entre deux colonnes (6 pt).
/// - raster-row-skip (length): espace entre deux rangées (6 pt).
/// - raster-equal-height (str): `"rows"` : toutes les cases d'une rangée ont la hauteur de la plus haute ; `"none"` : hauteur naturelle (`"rows"`).
/// - filets (stroke, none): trait vertical entre les colonnes ; sans effet si les cases sont des boîtes (`none`).
/// - filets-lignes (stroke, none): trait horizontal entre les rangées ; sans effet si les cases sont des boîtes (`none`).
/// - colframe (color, str, none): couleur du cadre de chaque case (`none` : pas de cadre).
/// - boxrule (length): épaisseur du cadre (0,4 pt).
/// - colback (color, str, none): fond de chaque case (`none`).
/// - arc (length): rayon des coins des boîtes (3 pt).
/// - boxsep (length, auto): espace entre le bord d'une boîte et son contenu. `auto` : 5 pt pour une boîte, 0 sinon.
/// - halign (str): `"left"` (défaut : plus lisible en colonne étroite), `"justify"`, `"center"`, `"right"`.
/// - valign (str): `"top"`, `"center"`, `"bottom"` : place du contenu dans une case plus haute que lui (`"top"`).
/// - colbacktitle (color, str, none): fond du bandeau de titre d'une case (couleur nommée `rem` à 24 %, un gris clair ; suit `setbfcolors(rem: …)`).
/// - coltitle (color, str, none): couleur du texte du titre (`currentTitleColor` : noir ; suit `setbfcolors`).
/// - before-skip (length): espace avant la disposition (0,9 em).
/// - after-skip (length): espace après la disposition (0,9 em).
/// - style (str, array): style(s) nommé(s) à appliquer (voir `setbfenum(definir: …)`).
/// - cases (content): le corps : une case par `-`, ou `#tcbitem(…)[…]`.
/// -> content
#let multi-colonnes(..args) = {
  let pos = args.pos()
  let cles = args.named()
  let n = auto
  if pos.len() > 0 and type(pos.first()) == int {
    n = pos.first()
    pos = pos.slice(1)
  }
  if "columns" in cles {
    if n != auto { panic("multi-colonnes : le nombre de colonnes est donné deux fois (entier en tête et `columns`).") }
    n = cles.remove("columns")
  }
  let pos = items-boites("MultiColonnes", pos, "-").items
  context {
    let r = reglages-resoudre(registre-enum, pour: "MultiColonnes", local: cles, commande: "MultiColonnes")
    let largeurs = r.largeurs
    if largeurs != auto and type(largeurs) != array {
      panic("multi-colonnes : `largeurs` doit être un tableau, par exemple (3, 2) ou (4cm, 1fr) ; reçu : " + repr(largeurs) + ".")
    }
    let nb = if n != auto { n } else if largeurs != auto { largeurs.len() } else { 2 }
    if type(nb) != int or nb < 1 {
      panic("multi-colonnes : le nombre de colonnes doit être un entier à partir de 1 ; reçu : " + repr(nb) + ".")
    }
    if largeurs != auto and largeurs.len() != nb {
      panic("multi-colonnes : `largeurs` donne " + str(largeurs.len()) + " largeurs pour " + str(nb) + " colonnes.")
    }
    let cols = if largeurs == auto { (1fr,) * nb } else { largeurs.map(_largeur-colonne) }
    let coul(v) = mc.bf-couleur-tcb(v)
    let ecart = r.raster-column-skip
    let ecart-lignes = r.raster-row-skip
    let rayon = r.arc
    let colframe = coul(r.colframe)
    let colback = coul(r.colback)
    let bordure = if colframe == none { none } else { r.boxrule + colframe }
    let fond = colback
    let filets = r.filets
    let filets-lignes = r.filets-lignes

    // placement : une case trop large pour la place restante passe à la rangée suivante
    let placees = ()
    let x = 0
    let y = 0
    for c in pos {
      let c = _lire-case(c, r.boxrule)
      let etendue = calc.min(c.colonnes, nb)
      if x + etendue > nb { y += 1; x = 0 }
      placees.push((c: c, x: x, y: y, etendue: etendue))
      x += etendue
      if x >= nb { y += 1; x = 0 }
    }
    let derniere = if placees.len() == 0 { 0 } else { placees.map(p => p.y).fold(0, calc.max) }

    let en-boites = bordure != none or fond != none or placees.any(p => p.c.fond not in (auto, none) or p.c.bordure not in (auto, none))
    let marge-boite = if r.boxsep == auto { if en-boites { 5pt } else { 0pt } } else { r.boxsep }
    let egales = r.raster-equal-height == "rows"
    // Mesurer les cases n'a d'effet visible que si une case a un cadre ou un fond (coins arrondis), ou si des
    // filets la bordent. Sinon on s'en passe : une mesure ralentit (chaque niveau d'imbrication met le contenu
    // en page deux fois), et un contenu qui lit sa position (points d'un `itempoint`, `bf-avec-largeur`) la
    // fait ne plus converger. Les rangées à hauteur égale et le centrage vertical sont alors faits par la
    // grille elle-même (cellules d'une rangée « auto » alignées par `align`), sans mesure.
    let besoin-hauteur = (egales and en-boites) or filets != none or filets-lignes != none

    // `h` : hauteur de la case, mesurée par bf-grille-egale (`auto` : hauteur naturelle)
    let dessiner(p, h, fond-seul: false) = {
      let c = p.c
      let f = if c.fond == auto { fond } else { c.fond }
      let b = if c.bordure == auto { bordure } else { c.bordure }
      let ha = if c.halign == auto { r.halign } else { c.halign }
      let va = if c.valign == auto { r.valign } else { c.valign }
      let v = if va == "center" { horizon } else if va == "bottom" { bottom } else { top }
      let hh = if ha == "center" { center } else if ha == "right" { right } else { none }
      let alignement = if hh == none { v } else { v + hh }
      let boite = f != none or b != none
      let fond-titre = if c.colbacktitle == auto { coul(r.colbacktitle) } else { c.colbacktitle }
      let texte-titre = if c.coltitle == auto { coul(r.coltitle) } else { c.coltitle }
      let contenu = {
        set par(justify: ha == "justify")
        if c.titre != none {
          // Dans une case encadrée, le bandeau va jusqu'au cadre (comme le titre d'une tcolorbox) au lieu
          // de flotter dans la marge intérieure ; il s'arrête à la moitié intérieure du trait.
          let ep = if b == none { 0pt } else { let t = stroke(b).thickness; if t == auto { 1pt } else { t } }
          let deborde = if boite { calc.max(0pt, marge-boite - ep / 2) } else { 0pt }
          pad(x: -deborde, top: -deborde, block(
            width: 100%, below: 0.4em, fill: fond-titre, inset: (x: if boite { deborde + ep / 2 } else { 5pt }, y: 3pt),
            radius: (top: if boite { calc.max(0pt, rayon - ep / 2) } else { rayon }),
            text(weight: "bold", fill: texte-titre, c.titre),
          ))
        }
        bf-avec-largeur(c.corps)
      }
      // `h == none` : contenu seul, à sa hauteur naturelle (sans fond, ni cadre, ni filets) ; `fond: true` : le
      // fond seul, à la hauteur `h` (bf-grille-egale sans mesure : deux couches dans la cellule)
      let interieur = if h != auto and h != none or hh != none { align(if h == auto or h == none { hh } else { alignement }, contenu) } else { contenu }
      if h == none {
        return block(
          width: 100%, inset: if boite { marge-boite } else { 0pt }, breakable: false, above: 0pt, below: 0pt, interieur,
        )
      }
      let traits = {
        // filets : posés dans l'écart, centrés entre deux colonnes (ou deux rangées)
        if not en-boites {
          if filets != none and p.x + p.etendue < nb {
            let haut = if p.y > 0 { ecart-lignes / 2 } else { 0pt }
            let bas = if p.y < derniere { ecart-lignes / 2 } else { 0pt }
            place(top + right, dx: ecart / 2, dy: -haut, line(start: (0pt, 0pt), end: (0pt, 100% + haut + bas), stroke: filets))
          }
          if filets-lignes != none and p.y < derniere {
            let gauche = if p.x > 0 { ecart / 2 } else { 0pt }
            let droite = if p.x + p.etendue < nb { ecart / 2 } else { 0pt }
            place(bottom + left, dx: -gauche, dy: ecart-lignes / 2, line(length: 100% + gauche + droite, stroke: filets-lignes))
          }
        }
      }
      block(
        width: 100%, height: h, fill: f, stroke: b, radius: if boite { rayon } else { 0pt },
        inset: if boite { marge-boite } else { 0pt }, breakable: false, above: 0pt, below: 0pt,
        { traits; if not fond-seul { interieur } },
      )
    }
    // place verticale du contenu dans une case plus haute que lui (celle que `dessiner` donne dans un bloc de
    // hauteur imposée, que la case ait des hauteurs égales ou seulement des filets)
    let valign-corps(p) = {
      let va = if p.c.valign == auto { r.valign } else { p.c.valign }
      if va == "center" { horizon } else if va == "bottom" { bottom } else { top }
    }

    block(
      width: 100%,
      above: r.before-skip,
      below: r.after-skip,
      layout(taille => m.bf-grille-egale(
        m.bf-largeurs-colonnes(taille.width, cols, ecart),
        ecart,
        ecart-lignes,
        placees.map(p => (
          x: p.x, y: p.y, etendue: p.etendue, valign: if egales { _valign-case(p.c, r.valign) } else { top },
          dessin: h => dessiner(p, h),
          // deux couches pour les hauteurs égales sans mesure (bf-grille-egale)
          fond: h => dessiner(p, h, fond-seul: true),
          corps: dessiner(p, none),
          valign-corps: valign-corps(p),
        )),
        egales: besoin-hauteur,
      )),
    )
  }
}

// =====================================================================
// tcbraster
// =====================================================================

/// Clés de grille que `setbfenum(pour: "tcbraster", …)` règle (les autres clés `raster-*` passent telles quelles).
#let _cles-raster-reglables = (
  "raster-columns", "raster-width", "raster-column-skip", "raster-row-skip", "raster-before-skip",
  "raster-after-skip", "raster-left-skip", "raster-equal-height", "raster-valign",
)

#let _cles-raster = _cles-raster-reglables + ("raster-equal-skip", "style")

/// Valeur d'une clé de grille écrite en syntaxe LaTeX (`tcb: "raster columns=3, raster equal height"`) : entier,
/// longueur, ou clé seule (`raster equal height` = `"rows"`).
#let _raster-latex(cle, v) = {
  if v != true and type(v) != str { return v }
  if cle == "raster-columns" and type(v) == str and v.trim().match(regex("^[0-9]+$")) != none { return int(v) }
  if cle == "raster-columns" { return v }
  if cle == "raster-equal-height" { return if v == true or v == "true" { "rows" } else { v } }
  if cle in ("raster-width", "raster-column-skip", "raster-row-skip", "raster-before-skip", "raster-after-skip", "raster-left-skip") {
    return longueur-latex(v, defaut: v)
  }
  v
}

/// Place des boîtes en grille, comme `tcbraster` de tcolorbox (et `tcbitemize`, qui n'en est que le nom quand
/// chaque argument est un `tcbitem`) : les clés `raster-*` règlent la grille, les autres clés tcolorbox
/// (`colback`, `colframe`, `boxrule`, `arc`…) s'appliquent à toutes les cases. Les cases ont l'aspect d'une
/// `tcolorbox` bfcours (fond gris clair, cadre noir).
///
/// ```typ
/// #tcbraster(raster-columns: 2, raster-equal-height: "rows")[
///   - Case A
///   - Case B, plus longue
/// ]
/// #tcbraster(columns: 3)[
///   #tcbitem(title: [A])[un]
///   #tcbitem(title: [B])[deux]
///   #tcbitem(title: [C])[trois]
/// ]
/// ```
///
/// Le corps est UN SEUL bloc `[…]` : une case par `-` (ou `#tcbitem(…)[…]`).
///
/// - tcb (str, none): clés en syntaxe LaTeX (`"raster columns=3, raster equal height"`).
/// - every-box (str, dictionary, none): clés appliquées à chaque case (`raster every box`).
/// - raster-columns (int): nombre de colonnes (2). Alias : `columns`.
/// - raster-width (length, ratio): largeur de la grille (100 %).
/// - raster-column-skip (length): espace entre colonnes (2 mm).
/// - raster-row-skip (length): espace entre rangées (2 mm).
/// - raster-before-skip (length): espace avant la grille (2 mm).
/// - raster-after-skip (length): espace après la grille (2 mm).
/// - raster-left-skip (length): retrait à gauche (0).
/// - raster-equal-height (str): `"rows"` pour des cases de même hauteur par rangée, `"none"` sinon (`"none"`).
/// - raster-valign (str): `"top"`, `"center"`, `"bottom"` : place d'une case dans sa cellule (`"center"`).
/// - style (str, array): style(s) nommé(s) (voir `setbfenum(definir: …)`).
/// - cases (content): le corps : une case par `-`, ou `#tcbitem(…)[…]`.
/// -> content
#let tcbraster(tcb: none, every-box: none, ..args) = {
  let cles = lire-options(tcb) + args.named()
  let cles = cles.pairs().map(((k, v)) => (k.replace(" ", "-"), v)).to-dict()
  if "columns" in cles {
    if "raster-columns" in cles {
      panic("tcbraster : `columns` est l'alias de `raster-columns` ; ne donner qu'une des deux clés.")
    }
    cles.insert("raster-columns", cles.remove("columns"))
  }
  let cases = items-boites("tcbraster", args.pos(), "-").items
  let permises = _cles-raster + _cles-tcbitem
  _verifier-cles("tcbraster", cles.keys(), permises)
  _verifier-cles("tcbraster (every-box)", lire-options(every-box).keys().map(c => c.replace(" ", "-")), permises)
  let locales = (:)
  let reste = (:)
  for (k, v) in cles {
    if k in _cles-raster-reglables { locales.insert(k, _raster-latex(k, v)) } else if k == "style" { locales.insert(k, v) } else { reste.insert(k, v) }
  }
  context {
    let r = reglages-resoudre(registre-enum, pour: "tcbraster", local: locales, commande: "tcbraster")
    let grille = (:)
    for k in _cles-raster-reglables { grille.insert(k, r.at(k)) }
    mc.tcbraster(tcb: grille + reste, every-box: every-box, ..cases)
  }
}
