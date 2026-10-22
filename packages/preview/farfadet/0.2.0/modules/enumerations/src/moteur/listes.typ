// listes.typ — tcbenumerate, \tcbitempoint et listes standard (itemize, enumerate) façon bfcours.
//
// Sources LaTeX : new-bfcours-environments.sty (tcbenumerate refondu, \myboxeditemstyle,
// \tcbitempoint), bfcours-colors.sty (\itemBaseColor), enumitem + babel-french (listes).
// Les dimensions viennent de relevés PyMuPDF sur un PDF bfcours de production ; les longueurs TeX passent par ptl().
//
// Ce module fournit aussi les outils communs de la suite (bf-metriques, bf-quad, tcbitem,
// largeur de ligne) : colonnes.typ, tableaux.typ et exo.typ l'importent.

//
// Les outils communs (métriques, largeur courante, couleur des badges, points) sont dans farfadet-socle.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: *
#import "../reglages.typ": registre-enum

/// Registre de réglages du paquet (pour interne.typ : les autres paquets peuvent le lire ou le régler).
#let bf-registre-enum = registre-enum

/// Couleur d'une option (couleur Typst ou expression xcolor en chaîne), avec les couleurs perso et l'accent
/// courants. À appeler dans un `context`.
#let _couleur-option(v) = {
  if type(v) != str { return v }
  xcolor(v.trim(), perso: bf-lire(bf-couleurs-perso-p) + (bfaccent: bf-lire(bf-couleur-p)))
}

// =====================================================================
// Outils propres aux énumérations
// =====================================================================

/// Séquence de contenus (type des blocs `[…]`).
#let _sequence = [a *b*].func()

/// Première feuille visible d'un contenu (espaces et sauts de paragraphe ignorés).
#let _premiere-feuille(c) = {
  if type(c) != content { return none }
  if c.func() == _sequence {
    for x in c.children {
      if x == [ ] or x.func() == parbreak { continue }
      return _premiere-feuille(x)
    }
    return none
  }
  c
}

/// \tcbitem[options] : cellule d'un tcbenumerate, d'un MultiColonnes ou d'un tcbraster avec options.
///   #tcbitem(tcb: "raster multicolumn=2, halign=center")[contenu]
/// Les options nommées (kebab-case) s'ajoutent à `tcb` : tcbitem(raster-multicolumn: 2, title: [T])[…].
#let tcbitem(tcb: none, ..options, corps) = (
  bf-tcbitem: true,
  options: lire-options(tcb) + options.named(),
  corps: corps,
)

/// (corps, options) d'une cellule : contenu brut ou résultat de tcbitem().
#let bf-lire-item(it) = {
  if type(it) == dictionary and it.at("bf-tcbitem", default: false) { (it.corps, it.options) } else { (it, (:)) }
}

/// Largeurs de colonnes numériques (en points absolus) pour une largeur disponible `largeur` :
/// `colonnes` mêle longueurs, rapports (%), parts (fr) et `auto` (compté comme 1fr).
#let bf-largeurs-colonnes(largeur, colonnes, ecart) = {
  let n = colonnes.len()
  let ecart = ecart.to-absolute()
  let fixe(c) = if type(c) == fraction or c == auto { none } else if type(c) == ratio { c * largeur } else if type(c) == relative {
    c.ratio * largeur + c.length.to-absolute()
  } else { c.to-absolute() }
  let part(c) = if type(c) == fraction { c / 1fr } else { 1.0 }
  let somme-fixes = colonnes.map(c => fixe(c)).filter(v => v != none).fold(0pt, (a, b) => a + b)
  let somme-parts = colonnes.filter(c => fixe(c) == none).map(part).fold(0.0, (a, b) => a + b)
  let reste = calc.max(largeur - (n - 1) * ecart - somme-fixes, 0pt)
  colonnes.map(c => if fixe(c) != none { fixe(c) } else { reste * part(c) / somme-parts })
}

/// Grille dont les cellules d'une même rangée ont la hauteur de la plus haute. `cellules` : tableau de
/// (x, y, etendue, dessin) où `dessin(h)` fabrique la cellule à la hauteur `h` (`auto` : hauteur naturelle).
/// Une cellule peut porter `valign` (top, horizon, bottom) : sans mesure (`egales: false`), c'est la grille
/// elle-même qui égalise la hauteur de la rangée et place le contenu, au lieu de mesurer chaque case puis de la
/// redessiner. Avec `egales: true`, une cellule qui fournit aussi `fond(h)` (cadre, fond, filets à la hauteur
/// `h`), `corps` (contenu à sa hauteur naturelle) et `valign-corps` est égalisée SANS mesure (voir plus bas) ;
/// sinon sa hauteur est MESURÉE (un `height: 100%` dans une rangée « auto » prendrait toute la page).
/// `largeurs` : largeurs numériques des colonnes (bf-largeurs-colonnes). À appeler dans un `layout`.
#let bf-grille-egale(largeurs, ecart-col, ecart-lig, cellules, egales: true) = {
  let largeur-cellule(c) = largeurs.slice(c.x, c.x + c.etendue).fold(0pt, (a, b) => a + b) + (c.etendue - 1) * ecart-col
  let nrangees = cellules.map(c => c.y).fold(0, calc.max) + 1
  if egales and cellules.all(c => "fond" in c and "corps" in c) {
    // Hauteurs égales SANS mesure. Une cellule `breakable: false` rend sa rangée insécable : Typst compose
    // alors la cellule de rendu dans une région dont la hauteur pleine est celle de la rangée (dans une rangée
    // sécable, c'est celle de la page), si bien qu'un `layout` posé dans la cellule lit la hauteur de la rangée.
    // Le fond (cadre, couleur, coins arrondis, filets) y est dessiné à cette hauteur par `place`, qui ne pèse
    // pas sur la hauteur de la rangée ; le contenu garde sa hauteur naturelle, placé par l'alignement de la
    // cellule. `measure` composait chaque case une fois de plus, avec un emplacement de mesure distinct (rien
    // n'était repris du cache) : le coût doublait à chaque niveau d'imbrication de cases encadrées.
    // Rangées insécables comme avant (rangées de hauteur fixe, cases `breakable: false`).
    return grid(
      columns: largeurs,
      column-gutter: ecart-col,
      row-gutter: ecart-lig,
      align: top,
      ..cellules.map(c => grid.cell(
        x: c.x,
        y: c.y,
        colspan: c.etendue,
        breakable: false,
        align: c.at("valign-corps", default: top),
        {
          place(top + left, layout(s => (c.fond)(s.height)))
          c.corps
        },
      )),
    )
  }
  let hauteurs = (0pt,) * nrangees
  if egales {
    for c in cellules {
      let h = measure((c.dessin)(auto), width: largeur-cellule(c)).height
      hauteurs.at(c.y) = calc.max(hauteurs.at(c.y), h)
    }
  }
  grid(
    columns: largeurs,
    rows: if egales { hauteurs } else { auto },
    column-gutter: ecart-col,
    row-gutter: ecart-lig,
    align: top,
    ..cellules.map(c => grid.cell(
      x: c.x,
      y: c.y,
      colspan: c.etendue,
      align: if egales { top } else { c.at("valign", default: top) },
      (c.dessin)(if egales { hauteurs.at(c.y) } else { auto }),
    )),
  )
}

// =====================================================================
// tcbenumerate
// =====================================================================

/// Profondeur d'imbrication des tcbenumerate (0 hors liste). N'est plus tenue (nom gardé pour compatibilité) :
/// la profondeur est portée par la chaîne de styles, lue par `bf-porte("bf-enum-niveau", defaut: 0)`.
#let bf-enum-niveau = state("bf-enum-niveau", 0)

/// Compteurs des tcbenumerate : un couple (numéro, motif) par niveau, mis à jour en tête de chaque item
/// (compteurs bfdEnumCntA/B/C de LaTeX).
#let bf-enum-compteurs = state("bf-enum-compteurs", ())

/// Numéro courant au niveau `k` (1, 2, 3), 0 hors liste ou si le niveau n'est pas ouvert. Dans un `context`.
#let bf-enum-numero(k) = {
  let cs = bf-enum-compteurs.get()
  if bf-porte("bf-enum-niveau", defaut: 0) == 0 or k < 1 or k > cs.len() { 0 } else { cs.at(k - 1).at(0) }
}

/// \bfdEnumLevel : profondeur d'imbrication courante (1, 2, 3… ; 0 hors liste).
#let bfd-enum-level() = context str(bf-porte("bf-enum-niveau", defaut: 0))

/// \bfdEnumNum (et \bfdEnumNumI/II/III : clé `niveau`) : numéro brut de l'item courant, au niveau `niveau`
/// (`auto` : le niveau courant). 0 hors liste ou si le niveau n'est pas ouvert.
#let bfd-enum-num(niveau: auto) = context {
  let k = if niveau == auto { bf-porte("bf-enum-niveau", defaut: 0) } else { niveau }
  str(bf-enum-numero(k))
}

/// \bfdEnumLabel (et \bfdEnumLabelI/II/III : clés `niveau` et `format`) : étiquette de l'item du niveau `niveau`
/// (`auto` : le niveau courant), sans le point. `format: auto` : le format de la liste (forcé ou auto) ;
/// un motif Typst (`"1"`, `"a"`, `"i"`) impose le format, comme \arabic, \alph, \roman.
#let bfd-enum-label(niveau: auto, format: auto) = context {
  let n = if niveau == auto { bf-porte("bf-enum-niveau", defaut: 0) } else { niveau }
  let cs = bf-enum-compteurs.get()
  if n == 0 or n < 1 or n > cs.len() or bf-porte("bf-enum-niveau", defaut: 0) == 0 { "0" } else {
    let noms = (num: "1", arabic: "1", alph: "a", Alph: "A", roman: "i", Roman: "I")
    let motif = if format == auto { cs.at(n - 1).at(1) } else { noms.at(format, default: format) }
    numbering(motif, cs.at(n - 1).at(0))
  }
}

#let _marque-enum = "bf-tcbenumerate"
#let _formats-enum = (
  num: "1", arabic: "1", alph: "a", Alph: "A", roman: "i", Roman: "I",
  // motifs Typst acceptés tels quels
  "1": "1", a: "a", A: "A", i: "i", I: "I",
)
#let _formats-auto = ("1", "a", "i")

/// Badge d'un item (nœud TikZ : \large\bfseries blanc sur \itemBaseColor, inner sep 3pt,
/// minimum 1,5 em × 1,5 em, coins 2pt, texte centré dont la ligne de base est celle de la ligne).
/// À appeler dans un `context`. Renvoie le dessin et ses cotes : asc (au-dessus de la ligne de base),
/// desc (au-dessous), largeur.
#let bf-badge-enum(etiquette, couleur, rayon: auto) = {
  let t = text(fill: white, weight: "bold", size: 1.2em, top-edge: "bounds", bottom-edge: "baseline", overhang: false, etiquette)
  let m = measure(t)
  let mini = (1.5 * bf-quad()).to-absolute()
  let haut = calc.max(m.height + ptl(6), mini)
  let largeur = calc.max(m.width + ptl(6), mini)
  let desc = (haut - m.height) / 2
  (
    dessin: box(width: largeur, height: haut, fill: couleur, radius: if rayon == auto { ptl(2) } else { rayon }, align(center + horizon, t)),
    largeur: largeur,
    asc: haut - desc,
    desc: desc,
  )
}

/// Badge en ligne sans profondeur : il fixe la hauteur de la première ligne (comme la boîte TikZ)
/// mais ne pousse pas la ligne suivante, que TeX place à \baselineskip quoi qu'il arrive.
#let _badge-en-ligne(b) = box(
  width: b.largeur,
  height: b.asc,
  place(top + left, b.dessin),
)

/// Bandeau de titre d'un item (`\tcbitem[title=…]`) : colbacktitle=\itemBaseColor, texte blanc gras, arc 5 pt
/// en haut (sharp corners=south), toptitle 2 pt, bottomtitle 3 pt, lefttitle/righttitle 5 pt.
#let _bandeau-titre(titre) = if titre != none {
  block(
    width: 100%, above: 0pt, below: 0pt, fill: titre.fond, radius: (top: ptl(5)),
    inset: (left: ptl(5), right: ptl(5), top: ptl(2), bottom: ptl(3)),
    text(weight: "bold", fill: titre.couleur, titre.texte),
  )
}

/// Item sans pastille (`tcbitem(numerote: false)`) : une case de transition, qui n'avance pas le compteur.
/// Même boîte que `_item-enum`, sans badge ni retrait pour la pastille.
#let _item-transition(corps, titre: none, halign: "left") = {
  let marge = 1mm - ptl(1)
  _bandeau-titre(titre)
  block(width: 100%, inset: marge, breakable: true, bf-avec-largeur({
    set par(justify: halign == "justify")
    set align(if halign == "center" { center } else if halign == "right" { right } else { left })
    bf-sans-espace-initial(corps)
  }))
}

/// Cellule d'item : boîte du raster (boxsep 1 mm, boxrule −1 pt, marges nulles, alignée à gauche).
/// À appeler dans un `context`. `avant` : contenu invisible posé en tête (mise à jour des compteurs) ;
/// `titre` : bandeau de titre de l'item (`\tcbitem[title=…]`), dict (texte, fond, couleur) ou none.
#let _item-enum(etiquette, couleur, corps, m, ecart-badge: auto, rayon-badge: auto, avant: none, titre: none, halign: "left") = {
  let serre = {
    let f = _premiere-feuille(corps)
    f != none and f.func() == metadata and f.value == _marque-enum
  }
  let b = bf-badge-enum(etiquette, couleur, rayon: rayon-badge)
  let marge = 1mm - ptl(1)
  // le badge déborde sous la dernière ligne de base (profondeur TeX de la ligne)
  let bas = if serre { marge } else { marge + calc.max(b.desc - m.desc, 0pt) }
  _bandeau-titre(titre)
  // La pastille (et la mise à jour des compteurs) passe par `avant:` : hors de la portée de la largeur, elle a
  // la même chaîne de styles d'un item à l'autre et sa composition est mise en cache (une pastille « 2. »
  // n'est composée qu'une fois pour tout le document, au lieu d'une fois par item).
  block(width: 100%, inset: (x: marge, top: marge, bottom: bas), breakable: true, {
    set par(justify: halign == "justify")
    set align(if halign == "center" { center } else if halign == "right" { right } else { left })
    if serre {
      // \tcbitem suivi directement d'un tcbenumerate : la sous-liste démarre sur la ligne du badge.
      // relevé LaTeX : la boîte de la sous-liste commence 1,17 pt AU-DESSUS du badge parent
      bf-avec-largeur(block(inset: (top: -1.17pt), corps), avant: [#avant#place(top + left, b.dessin)])
    } else {
      bf-avec-largeur(
        bf-sans-espace-initial(corps),
        avant: [#avant#_badge-en-ligne(b)#h(if ecart-badge == auto { ptl(3) } else { ecart-badge })],
      )
    }
  })
}

/// \begin{tcbenumerate}[colonnes][départ][format] \tcbitem A \tcbitem B \end{tcbenumerate}
///   #tcbenumerate(colonnes: 2, depart: 1, format: "auto")[A][B]
/// format : "auto" (niveau 1 : 1, 2… ; niveau 2 : a, b… ; niveau 3 : i, ii…), "num", "arabic",
/// "alph", "Alph", "roman", "Roman". Une cellule peut être un tcbitem(raster-multicolumn: 2)[…].
/// Extensions de la façade, absentes de LaTeX : ecart-colonnes (auto = 0,5 quad),
/// ecart-lignes, et des boîtes autour des items : cadre (trait), fond (couleur), rayon, marge. Un item
/// peut avoir ses propres `cadre` et `fond` (tcbitem(cadre: …, fond: …)) ; `auto` reprend ceux de la liste.
#let _tcbenumerate(resoudre, items) = {
  [#metadata(_marque-enum)]
  // profondeur portée par la chaîne de styles (`bf-porter`) : exacte dès le premier tour
  context {
    let niveau = bf-porte("bf-enum-niveau", defaut: 0) + 1
    bf-porter(("bf-enum-niveau": niveau), {
    // réglages effectifs (dictionnaire aux clés internes), calculés dans le contexte
    let r = resoudre()
    let (colonnes, depart, format, ecart-colonnes, ecart-lignes, cadre, fond, rayon, marge) = (
      r.colonnes, r.depart, r.format, r.ecart-colonnes, r.ecart-lignes, r.cadre, r.fond, r.rayon, r.marge,
    )
    let couleur = if r.couleur-badge == auto { bf-lire(bf-couleur-item-p) } else { r.couleur-badge }
    let formats-auto = if r.format-auto == auto { _formats-auto } else { r.format-auto.map(f => _formats-enum.at(f, default: f)) }
    let motif = if format in (auto, none, "auto", "") {
      formats-auto.at(calc.min(niveau, 3) - 1)
    } else { _formats-enum.at(format, default: format) }
    let m = bf-metriques()
    let q = bf-quad()
    let cellules = ()
    let specs = ()
    let col = 0
    let rang = 0
    let en-boites = false
    let k = 0 // nombre de questions numérotées déjà vues (un item `numerote: false` ne compte pas)
    for it in items {
      let (corps, options) = bf-lire-item(it)
      let numerote = options.at("numerote", default: true) != false
      let etendue = calc.min(int(options.at("raster-multicolumn", default: 1)), colonnes)
      // une cellule trop large pour la place restante passe au rang suivant (comme tcbraster)
      if col + etendue > colonnes {
        cellules.push(grid.cell(colspan: colonnes - col, []))
        col = 0
        rang += 1
      }
      let c = options.at("cadre", default: auto)
      let f = options.at("fond", default: auto)
      // clés tcolorbox d'un tcbitem : colframe (+ boxrule) et colback
      if c == auto and "colframe" in options {
        let cf = _couleur-option(options.colframe)
        let ep = if "boxrule" in options { longueur-latex(options.boxrule, defaut: 0.4pt) } else { 0.4pt }
        c = if cf == none { none } else { ep + cf }
      }
      if f == auto and "colback" in options { f = _couleur-option(options.colback) }
      let c = if c == auto { cadre } else { c }
      let f = if f == auto { fond } else { f }
      let numero = depart + k
      if numerote { k += 1 }
      // compteurs lus par \bfdEnumNum, \bfdEnumLabel… : un couple (numéro, motif) par niveau
      let maj = if numerote {
        bf-enum-compteurs.update(cs => {
          let cs = cs.slice(0, calc.min(cs.len(), niveau - 1))
          while cs.len() < niveau - 1 { cs.push((0, "1")) }
          cs.push((numero, motif))
          cs
        })
      }
      let titre = if options.at("title", default: none) == none { none } else {
        (
          texte: options.title,
          fond: if "colbacktitle" in options { _couleur-option(options.colbacktitle) } else { couleur },
          couleur: if "coltitle" in options { _couleur-option(options.coltitle) } else { white },
        )
      }
      let halign-item = options.at("halign", default: r.at("halign", default: "left"))
      let item = if numerote {
        _item-enum(
          numbering(motif, numero) + ".", couleur, corps, m,
          ecart-badge: r.ecart-badge, rayon-badge: r.rayon-badge, avant: maj, titre: titre,
          halign: halign-item,
        )
      } else {
        _item-transition(corps, titre: titre, halign: halign-item)
      }
      let boite = c != none or f != none
      if boite { en-boites = true }
      cellules.push(grid.cell(colspan: etendue, item))
      specs.push((
        x: col,
        y: rang,
        etendue: etendue,
        dessin: h => block(
          width: 100%,
          height: h,
          fill: if boite { f },
          stroke: if boite { c },
          radius: if boite { rayon } else { 0pt },
          inset: if boite { marge } else { 0pt },
          breakable: false,
          above: 0pt,
          below: 0pt,
          item,
        ),
        // même case en deux couches, pour bf-grille-egale sans mesure : fond à la hauteur de la rangée, contenu
        // à sa hauteur naturelle, en haut
        fond: h => block(
          width: 100%, height: h, fill: if boite { f }, stroke: if boite { c }, radius: if boite { rayon } else { 0pt },
          breakable: false, above: 0pt, below: 0pt,
        ),
        corps: block(width: 100%, inset: if boite { marge } else { 0pt }, breakable: false, above: 0pt, below: 0pt, item),
      ))
      col = calc.rem(col + etendue, colonnes)
      if col == 0 { rang += 1 }
    }
    let ecart-col = if ecart-colonnes == auto { 0.5 * q } else { ecart-colonnes }
    // Une seule colonne : les questions s'empilent dans le flot, chacune dans un bloc. Une grille à rangées
    // `auto` compose chaque cellule DEUX fois (mesure de la rangée, puis rendu à sa hauteur) et, comme les
    // régions diffèrent, rien n'est repris du cache : le coût double à chaque niveau d'imbrication (sous-liste
    // dans une question, liste dans une colonne…). Le flot compose chaque question une fois. Une rangée d'une
    // seule case n'a rien à égaliser : une boîte y garde sa hauteur naturelle, sans mesure.
    let g = if colonnes == 1 {
      let blocs = if en-boites { specs.map(s => (s.dessin)(auto)) } else { cellules.map(c => c.body) }
      blocs.map(b => block(width: 100%, above: ecart-lignes, below: ecart-lignes, breakable: not en-boites, b)).join()
    } else if en-boites {
      // boîtes : les questions d'une même rangée prennent la hauteur de la plus haute (hauteur mesurée)
      layout(taille => bf-grille-egale(
        bf-largeurs-colonnes(taille.width, (1fr,) * colonnes, ecart-col),
        ecart-col,
        ecart-lignes,
        specs,
        egales: r.at("egales", default: true),
      ))
    } else {
      grid(
        columns: (1fr,) * colonnes,
        column-gutter: ecart-col,
        row-gutter: ecart-lignes,
        align: top,
        ..cellules,
      )
    }
    // retraits par niveau : \bfdEnumIndentI = 0 em, \bfdEnumIndentII = 1,5 em, \bfdEnumIndentIII = 3 em
    let indent = r.indents.at(calc.min(niveau, 3) - 1)
    let retrait = if indent == auto { (0 * q, 1.5 * q, 3 * q).at(calc.min(niveau, 3) - 1) } else { indent }
    if niveau <= 1 {
      let e = bf-espacement-tcb(m)
      block(width: 100%, above: e.above, below: e.below, breakable: true, if retrait == 0pt { g } else { pad(left: retrait, g) })
    } else {
      block(width: 100%, above: 2mm, below: 0pt, breakable: true, pad(left: retrait, g))
    }
    })
  }
}

/// tcbenumerate à clés LaTeX, réglée par le registre de farfadet-enum (façade `tcbenumerate` de lib.typ).
/// `cles` : clés locales (dictionnaire) ; `items` : tableau de cellules.
#let tcbenumerate-cles(cles, items) = _tcbenumerate(
  () => {
    let r = reglages-resoudre(registre-enum, pour: "tcbenumerate", local: cles, commande: "tcbenumerate")
    let coul(v) = if v == auto { auto } else { _couleur-option(v) }
    let cadre = if r.colframe == none { none } else { r.boxrule + _couleur-option(r.colframe) }
    (
      colonnes: r.raster-columns, depart: r.depart, format: r.format,
      ecart-colonnes: r.raster-column-skip, ecart-lignes: if r.raster-row-skip == auto { 5pt } else { r.raster-row-skip },
      cadre: cadre, fond: if r.colback == none { none } else { _couleur-option(r.colback) },
      rayon: r.arc, marge: r.boxsep,
      couleur-badge: coul(r.couleur-badge), ecart-badge: r.ecart-badge, rayon-badge: r.rayon-badge,
      format-auto: r.format-auto, indents: (r.bfdEnumIndentI, r.bfdEnumIndentII, r.bfdEnumIndentIII),
      egales: r.raster-equal-height == "rows", halign: r.halign,
    )
  },
  items,
)

// =====================================================================
// Listes standard : itemize / enumerate (enumitem + babel-french + bfcours)
// =====================================================================
// Relevés (corps 11 pt, \baselineskip 14,5 pt) :
//   \leftmargini = 27,37 pt, \leftmarginii = 24,09 pt, \leftmarginiii = 20,81 pt, \labelsep = 5,475 pt ;
//   écart entre lignes de base de deux items : \baselineskip + 4,08 pt (niveau 1), + 2,04 pt (niveaux 2+) ;
//   paragraphe → premier item : + 4,08 pt ; dernier item → paragraphe : + 6,12 pt.
// Puces : $\bullet$ à tous les niveaux (\setlist[itemize]{label=$\bullet$}).
// Numéros : boîte \myboxeditemstyle (\bfseries blanc sur \itemBaseColor, filet 1 pt, coins 2 pt,
// marges 2 pt) contenant « 1. », « a. », « i. », « A. » selon le niveau.

#let _marges-listes = (ptl(27.37), ptl(24.09), ptl(20.81), ptl(18.62), ptl(16.43), ptl(10.95))
#let _motifs-enumerate = ("1", "a", "i", "A")

/// Profondeurs courantes (toutes listes, itemize, enumerate). N'est plus tenue (nom gardé pour compatibilité) :
/// lire `bf-porte("bf-liste-niveau", defaut: (total: 0, itemize: 0, enumerate: 0))`.
#let bf-liste-niveau = state("bf-liste-niveau", (total: 0, itemize: 0, enumerate: 0))

/// Étiquette encadrée de enumerate (\myboxeditemstyle), sans hauteur propre dans la ligne
/// (TeX garde \baselineskip entre les items). À appeler dans un `context`.
#let bf-etiquette-enum(texte, couleur) = {
  let t = text(fill: white, weight: "bold", top-edge: "bounds", bottom-edge: "bounds", texte)
  let prof = measure(text(fill: white, weight: "bold", top-edge: "baseline", bottom-edge: "bounds", texte)).height
  let m = measure(t)
  // hauteur explicite : dans une boîte de hauteur nulle, une boîte « auto » perd son fond
  let dessin = box(width: m.width + ptl(6), height: m.height + ptl(6), fill: couleur, radius: ptl(2.5), align(center + horizon, t))
  box(width: m.width + ptl(6), height: 0pt, place(bottom + left, dy: ptl(3) + prof, dessin))
}

/// Rendu d'une liste : `sorte` = "itemize" ou "enumerate" ; `items` = tableau de (corps, numéro) ;
/// options enumitem : leftmargin, labelsep, itemsep, topsep, label (contenu ou fonction n => contenu),
/// start, nosep.
#let _liste(sorte, items, options: (:)) = {
  // profondeurs portées par la chaîne de styles (`bf-porter`) : exactes dès le premier tour
  context {
    let niv0 = bf-porte("bf-liste-niveau", defaut: (total: 0, itemize: 0, enumerate: 0))
    let niv = niv0 + (total: niv0.total + 1, (sorte): niv0.at(sorte) + 1)
    bf-porter(("bf-liste-niveau": niv), {
    let total = niv.total
    let propre = niv.at(sorte)
    let m = bf-metriques()
    // réglages : options de l'appel (clés locales) > styles > type (itemize / enumerate) > global > défauts
    let reg = reglages-resoudre(registre-enum, pour: sorte, local: options, commande: sorte)
    let couleur = if sorte == "enumerate" and reg.couleur-etiquette != auto {
      _couleur-option(reg.couleur-etiquette)
    } else { bf-lire(bf-couleur-item-p) }
    // longueurs en em de enumitem : quads de la police courante
    let options = reg.pairs().map(((k, v)) => (k, if type(v) == dictionary and "bf-quad" in v { v.bf-quad * bf-quad() } else { v })).to-dict()
    let niveau-marge = ("leftmargini", "leftmarginii", "leftmarginiii", "leftmarginiv", "leftmarginv", "leftmarginvi").at(calc.min(total, 6) - 1)
    let marge = if options.leftmargin != auto { options.leftmargin } else if options.at(niveau-marge) != auto {
      options.at(niveau-marge)
    } else { _marges-listes.at(calc.min(total, 6) - 1) }
    let sep = if options.labelsep == auto { ptl(5.475) } else { options.labelsep }
    let nosep = options.nosep
    // \itemsep + \parsep (babel-french réduit les deux à 2,04 pt ; \itemsep = 0 aux niveaux 2+)
    let entre = if nosep { 0pt } else {
      (if options.itemsep == auto { if total <= 1 { ptl(2.04) } else { 0pt } } else { options.itemsep }) + ptl(2.04)
    }
    let avant = if options.topsep != auto { options.topsep } else if nosep { 0pt } else if total <= 1 { ptl(4.08) } else { ptl(4.0) }
    let apres = if nosep { 0pt } else if total <= 1 { avant + ptl(2.04) } else { avant }
    let largeur-etiquette = calc.max(marge - sep, 0pt)
    let depart = if sorte == "enumerate" and options.start != auto { options.start } else { 1 }
    let motifs = if sorte == "enumerate" and options.motifs != auto { options.motifs } else { _motifs-enumerate }
    let etiquette(n) = {
      let e = options.label
      // `label` peut être un tableau : un élément par niveau
      if type(e) == array { e = e.at(calc.min(propre, e.len()) - 1) }
      if e != auto {
        if type(e) == function { e(n) } else if type(e) == str and sorte == "enumerate" { numbering(e, n) } else { e }
      } else if sorte == "itemize" {
        if options.couleur-puce == auto { [•] } else { text(fill: _couleur-option(options.couleur-puce))[•] }
      } else {
        bf-etiquette-enum(numbering(motifs.at(calc.min(propre, motifs.len()) - 1), n) + ".", couleur)
      }
    }
    let rendu = items
      .enumerate()
      .map(((i, (corps, numero))) => {
        let n = if numero == none or numero == auto { depart + i } else { numero }
        let etiq = box(width: largeur-etiquette, align(right, etiquette(n)))
        block(
          width: 100%,
          above: if i == 0 { 0pt } else { m.bs + entre - m.haut - m.desc },
          below: 0pt,
          inset: (left: marge),
          breakable: true,
          [#h(-sep - largeur-etiquette)#etiq#h(sep)#bf-sans-espace-initial(corps)],
        )
      })
    block(
      width: 100%,
      above: m.bs + avant - m.haut - m.desc,
      below: m.bs + apres - m.haut - m.desc,
      breakable: true,
      rendu.join(),
    )
    })
  }
}

/// Options enumitem (« label=$\bullet$, leftmargin=10pt, itemsep=1em ») → dictionnaire pour _liste.
#let _options-enumitem(chaine) = {
  let o = lire-options(chaine)
  let r = (:)
  // les em de enumitem sont ceux d'Utopia (quad = 0,9564 em du corps)
  let longueur(v) = {
    let m = v.replace(" ", "").match(regex("^(-?[0-9]*\.?[0-9]+)em$"))
    if m != none { (bf-quad: float(m.captures.at(0))) } else { longueur-latex(v, defaut: auto) }
  }
  for cle in ("leftmargin", "labelsep", "itemsep", "topsep") {
    if cle in o {
      let v = o.at(cle)
      r.insert(cle, if v == "*" { auto } else { longueur(v) })
    }
  }
  r = r.pairs().filter(((k, v)) => v != auto).to-dict()
  if "nosep" in o { r.insert("nosep", true) }
  if "start" in o { r.insert("start", int(o.start)) }
  r
}

/// \begin{itemize}[options] \item A \item B \end{itemize}
///   #itemize(options: "leftmargin=10pt", label: [--])[A][B]
#let itemize(options: none, label: auto, ..items) = {
  let o = _options-enumitem(options)
  if label != auto { o.insert("label", label) }
  _liste("itemize", items.pos().map(c => (c, none)), options: o + items.named())
}

/// \begin{enumerate}[options] \item A \item B \end{enumerate}
///   #enumerate(options: "itemsep=1em", label: "a)")[A][B]   (label : motif Typst ou fonction n => contenu)
#let enumerate(options: none, label: auto, ..items) = {
  let o = _options-enumitem(options)
  if label != auto { o.insert("label", label) }
  _liste("enumerate", items.pos().map(c => (c, none)), options: o + items.named())
}

/// Liste à plat : chaque item est un paragraphe ordinaire ouvert par la puce, comme quand on
/// écrit « \textbullet\ … » à la main faute de pouvoir mettre un itemize dans un \tcbitem.
/// Pas de retrait, lignes de continuation à la marge (précieux en colonne étroite), espacement
/// de paragraphe entre les puces. Le convertisseur l'emploie pour ces listes-là : le contenu
/// reste une vraie liste Typst, qu'on peut relire et modifier.
///   #puces[- première puce
///          - deuxième puce]
/// Le texte qui suit garde son propre paragraphe : le writer Pandoc écrit les blocs à la ligne,
/// sans ligne vide, et sans cela il se collerait à la dernière puce. (Le texte qui précède est
/// séparé, lui, par la ligne vide que le convertisseur place avant l'appel.)
#let puces(marqueur: [•], corps) = {
  show list: it => it.children.map(item => marqueur + [~] + item.body).join(parbreak())
  corps
  parbreak()
}

/// Règles appliquées par le modèle à tout le document : les listes Typst (`- …`, `+ …`,
/// list(), enum()) prennent la mise en page des itemize/enumerate de bfcours.
/// Un enum() dont `numbering` n'est pas celui par défaut garde son étiquette (non encadrée).
#let regles-listes(doc) = {
  show list: it => {
    let o = (:)
    if it.marker != ([•], [‣], [–]) { o.insert("label", if type(it.marker) == array { it.marker.at(0) } else { it.marker }) }
    _liste("itemize", it.children.map(c => (c.body, none)), options: o)
  }
  show enum: it => {
    let o = (:)
    if it.numbering != "1." { o.insert("label", n => numbering(it.numbering, n)) }
    if type(it.start) == int and it.start != 1 { o.insert("start", it.start) }
    _liste("enumerate", it.children.map(c => (c.body, c.number)), options: o)
  }
  doc
}
