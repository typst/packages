// sectionnement.typ — titres de section et de sous-section en bandeau (bfcours-sectionning.sty),
// jeux de titres prédéfinis et table des matières (\tableofcontents).
// Phase 2 : cotes des bandeaux réglables (registre `_RS`, types « SectionBox » et « SubSectionBox »,
// noms des styles tcolorbox de bfcours-sectionning) ; BaseColor lue dans les couleurs définies
// par l'utilisateur (`definecolor("BaseColor", …)`), comme \definecolor{BaseColor} en LaTeX.
// Épurage (08/10/2026) : QUATRE JEUX DE TITRES (décision D7) — `bfcours` (défaut : les bandeaux
// SectionBox / SubSectionBox de l'utilisateur), `sobre`, `classique`, `documentation` — réglables par
// `setbfsections` (clés `couleur`, `hauteur`, `numerotation`…) et activés par `bf-appliquer-jeu-titres`
// (appelée par la clé `titres:` du modèle) ; niveau 4 non numéroté.
// Contrat avec les environnements : métadonnées <bf-toc> posées par bf-entree-sommaire (moteur/didactique.typ).

#import "../../../socle/lib.typ": interne as _socle
#import _socle: *

// =====================================================================
// Constantes
// =====================================================================

/// Couleur des titres de section : BaseColor!80!black (BaseColor = rgb 0.2, 0.2, 0.2).
/// Valeur d'origine ; la couleur effective suit `definecolor("BaseColor", …)` (voir `bf-couleur-titres`).
#let couleur-titres = xmix(rgb(51, 51, 51), 80, autre: black)

/// BaseColor!80!black avec la BaseColor courante. À appeler dans un `context`.
#let bf-couleur-titres() = xmix(bf-couleurs-perso.get().at("BaseColor", default: rgb(51, 51, 51)), 80, autre: black)

#let _S = (
  hauteur: 0.9cm, // SectionBox : height=0.9cm
  base: 17.07pt, // ligne de base du titre sous le haut du bandeau
  marge: 3mm,
  avant: 1.65pt, // espaces faibles autour d'une section
  apres: 7.57pt,
  ss-hauteur: 24.75pt, // SubSectionBox
  ss-avant: 0pt,
  ss-apres: 7.37pt,
  ss-regle: 0.5mm,
  ss-numero: 1cm, // lefthand width
  ss-ecart: 5mm, // sidebyside gap
  ss-droite: 20pt * 72 / 72.27,
  ss-base-numero: 16.84pt,
  ss-base-titre: 17.31pt,
  ss-trait: 2pt * 72 / 72.27,
  ss-arc: 10pt * 72 / 72.27,
)

// =====================================================================
// Jeux de titres : ce que signifie `auto` pour chaque jeu et chaque niveau
// =====================================================================
// Les clés `couleur`, `hauteur`, `numerotation`, `coltitle`, `fonttitle`, `before-skip` et `after-skip`
// valent `auto` par défaut dans le registre : chaque jeu dit ce que `auto` devient, niveau par niveau.
// Les couleurs sont des couleurs NOMMÉES de bfcours, lues au rendu (`setbfcolors` les change).

#let _noms-jeux = ("bfcours", "sobre", "classique", "documentation")

#let _base = bf-nommee("BaseColor!80!black")
#let _sombre = bf-nommee("BaseColor!80!black")
#let _jeux = (
  // les bandeaux de l'utilisateur (bfcours-sectionning.sty) : niveaux 1 et 2 ; 3 et 4 en gras sans bandeau
  bfcours: (
    (hauteur: _S.hauteur, fonttitle: "Large", before-skip: _S.avant, after-skip: _S.apres, couleur: _base, coltitle: white),
    (hauteur: _S.ss-hauteur, fonttitle: "large", before-skip: _S.ss-avant, after-skip: _S.ss-apres, couleur: _base, coltitle: white),
    (hauteur: auto, fonttitle: "normalsize", before-skip: 11.2pt, after-skip: 7.5pt, couleur: _base, coltitle: black),
    (hauteur: auto, fonttitle: "normalsize", before-skip: 9.5pt, after-skip: 3pt, couleur: _base, coltitle: black),
  ),
  // numéro coloré et filet fin sous le titre, sans grande taille (fiches, activités)
  sobre: (
    (hauteur: auto, fonttitle: "Large", before-skip: 14pt, after-skip: 8pt, couleur: bf-nommee("prop"), coltitle: _sombre),
    (hauteur: auto, fonttitle: "large", before-skip: 11pt, after-skip: 6pt, couleur: bf-nommee("prop"), coltitle: _sombre),
    (hauteur: auto, fonttitle: "normalsize", before-skip: 9pt, after-skip: 4pt, couleur: bf-nommee("prop"), coltitle: _sombre),
    (hauteur: auto, fonttitle: "normalsize", before-skip: 8pt, after-skip: 3pt, couleur: bf-nommee("prop"), coltitle: _sombre),
  ),
  // titres gras d'article, sans bandeau (documents denses, copies)
  classique: (
    (hauteur: auto, fonttitle: "Large", before-skip: 14pt, after-skip: 8pt, couleur: bf-nommee("black"), coltitle: bf-nommee("black")),
    (hauteur: auto, fonttitle: "large", before-skip: 11pt, after-skip: 6pt, couleur: bf-nommee("black"), coltitle: bf-nommee("black")),
    (hauteur: auto, fonttitle: "normalsize", before-skip: 9pt, after-skip: 4pt, couleur: bf-nommee("black"), coltitle: bf-nommee("black")),
    (hauteur: auto, fonttitle: "normalsize", before-skip: 8pt, after-skip: 3pt, couleur: bf-nommee("black"), coltitle: bf-nommee("black")),
  ),
  // rendu des documentations : gros numéro coloré, filet pâle sous le titre de niveau 1
  documentation: (
    (hauteur: auto, fonttitle: 17pt, before-skip: 1.2em, after-skip: 0.9em, couleur: bf-nommee("myblue"), coltitle: _sombre),
    (hauteur: auto, fonttitle: 12pt, before-skip: 1.5em, after-skip: 1em, couleur: bf-nommee("myblue"), coltitle: bf-nommee("myblue!70!black")),
    (hauteur: auto, fonttitle: 10.5pt, before-skip: 1em, after-skip: 0.6em, couleur: bf-nommee("myblue"), coltitle: _sombre),
    (hauteur: auto, fonttitle: 10pt, before-skip: 0.8em, after-skip: 0.4em, couleur: bf-nommee("myblue"), coltitle: _sombre),
  ),
)

// =====================================================================
// Réglages des titres (setbfsections)
// =====================================================================

#let _tailles-titre = ("tiny", "scriptsize", "footnotesize", "small", "normalsize", "large", "Large", "LARGE", "huge", "Huge")

#let _RS = reglages-paquet(
  "sectionnement",
  (
    jeu: "bfcours",
    couleur: auto,
    hauteur: auto,
    numerotation: auto,
    coltitle: auto,
    fonttitle: auto,
    before-skip: auto,
    after-skip: auto,
  ),
  controles: (
    jeu: reglages-choix(.._noms-jeux),
    couleur: reglages-controles.couleur-ou-nom,
    hauteur: reglages-controles.longueur,
    numerotation: reglages-controles.booleen,
    coltitle: reglages-controles.couleur-ou-nom,
    fonttitle: reglages-ou(reglages-choix(.._tailles-titre), reglages-controles.longueur),
    before-skip: reglages-controles.longueur,
    after-skip: reglages-controles.longueur,
  ),
  types: (
    SectionBox: (left: _S.marge, arc: 1mm),
    SubSectionBox: (
      lefthand-width: _S.ss-numero,
      sidebyside-gap: _S.ss-ecart,
      left-skip: 1cm,
      right: _S.ss-droite,
      line-width: _S.ss-trait,
      arc: _S.ss-arc,
      width-extra: 3cm,
      width-max: 80%,
    ),
  ),
  commande: "setbfsections",
)

/// Active un jeu de titres pour la suite du document (même effet que `setbfsections(jeu: nom)`).
/// Renvoie le contenu (mise à jour d'état) à placer dans le document : le modèle `bfcours` l'appelle
/// depuis sa clé `titres:`. Noms : `"bfcours"` (défaut), `"sobre"`, `"classique"`, `"documentation"`.
#let bf-appliquer-jeu-titres(nom) = reglages-regler(_RS, commande: "bf-appliquer-jeu-titres", jeu: nom)

#let _taille(f) = if type(f) == str { taille-latex(f) } else { f }

/// Réglages effectifs d'un niveau de titre (1 à 4) : les clés réglées par `setbfsections`, les `auto`
/// remplacés par les valeurs du jeu actif, les couleurs nommées résolues. À appeler dans un `context`.
/// `niveau` 1 et 2 : types « SectionBox » et « SubSectionBox » ; 3 et 4 : réglages globaux seuls.
#let bf-reglages-titre(niveau, jeu: auto) = {
  let pour = if niveau == 1 { "SectionBox" } else if niveau == 2 { "SubSectionBox" } else { none }
  let r = reglages-courants(_RS, pour: pour)
  let jeu = if jeu == auto { r.jeu } else { jeu }
  for (cle, valeur) in _jeux.at(jeu).at(niveau - 1) {
    if r.at(cle) == auto { r.insert(cle, if bf-est-nommee(valeur) { bf-couleur-nommee(valeur) } else { valeur }) }
  }
  if r.numerotation == auto { r.numerotation = true }
  r
}

// =====================================================================
// Titres : \section et \subsection (bfcours-sectionning.sty)
// =====================================================================

/// Bandeau de \section : onglet foncé à coin arrondi et filet qui court jusqu'au bord droit.
/// `r` : réglages résolus du niveau 1 (`none` : réglages courants).
#let bf-bandeau-section(corps, r: none) = context {
  let r = if r == none { bf-reglages-titre(1) } else { r }
  let h = r.hauteur
  let base = _S.base + (h - _S.hauteur) / 2
  let t = text(
    size: _taille(r.fonttitle),
    weight: "bold",
    fill: bf-resoudre-couleur(r.coltitle),
    top-edge: base,
    bottom-edge: base - h,
    corps,
  )
  let w = measure(t).width + 2 * r.left
  let rr = r.arc
  let c = bf-resoudre-couleur(r.couleur)
  layout(s => {
    let L = s.width
    box(width: L, height: h, {
      // underlay : courbe (to[out=0,in=180]) puis filet jusqu'au bord droit, coins arrondis
      let d = 0.3915 * calc.sqrt(calc.pow(5mm / 1pt, 2) + calc.pow(h / 2pt, 2)) * 1pt
      place(curve(
        fill: c,
        curve.move((0pt, h)),
        curve.line((w, h)),
        curve.cubic((w + d, h), (w + 5mm - d, h / 2), (w + 5mm, h / 2)),
        curve.line((L - rr, h / 2)),
        curve.quad((L, h / 2), (L, h / 2 - rr)),
        curve.line((L, rr)),
        curve.quad((L, 0pt), (L - rr, 0pt)),
        curve.line((0pt, 0pt)),
        curve.close(),
      ))
      place(box(width: w, height: h, fill: c, radius: (top-left: rr), inset: (x: r.left), t))
    })
  })
}

/// Bandeau de \subsection : numéro blanc sur fond foncé, titre dans un cadre ouvert à droite arrondi.
/// `r` : réglages résolus du niveau 2 (`none` : réglages courants).
#let bf-bandeau-sous-section(numero, corps, r: none) = context {
  let r = if r == none { bf-reglages-titre(2) } else { r }
  let taille = _taille(r.fonttitle)
  let c = bf-resoudre-couleur(r.couleur)
  let e = _S.ss-regle
  let xt = e + r.lefthand-width + r.sidebyside-gap
  layout(s => {
    let tw = measure(text(size: taille, weight: "bold", corps)).width
    let W = calc.min(tw + r.width-extra, r.width-max * s.width)
    let lt = W - xt - e - r.right
    // boîte de texte ajustée aux glyphes (TeX : hauteur + profondeur naturelles), au moins 9,95 pt
    let titre = block(width: lt, {
      set par(justify: false, leading: 7pt)
      text(size: taille, weight: "bold", top-edge: "bounds", bottom-edge: "bounds", corps)
    })
    let asc = measure(text(size: taille, weight: "bold", top-edge: "bounds", bottom-edge: "baseline", corps)).height
    let dy-titre = e + 5.98pt + calc.max(0pt, 9.91pt - asc)
    let H = calc.max(r.hauteur, measure(titre).height + dy-titre + e + 5.98pt)
    let rr = r.arc
    pad(left: r.left-skip, box(width: W, height: H, {
      place(dx: e, dy: e, rect(width: r.lefthand-width + r.sidebyside-gap / 2, height: H - 2 * e, fill: c))
      place(dx: e + r.lefthand-width + r.sidebyside-gap / 2, dy: e, rect(
        width: W - 2 * e - r.lefthand-width - r.sidebyside-gap / 2,
        height: H - 2 * e,
        fill: white,
        radius: (right: 1mm - e),
      ))
      place(curve(
        stroke: r.line-width + c,
        curve.move((e, e)),
        curve.line((W - e - rr, e)),
        curve.quad((W - e, e), (W - e, e + rr)),
        curve.line((W - e, H - e - rr)),
        curve.quad((W - e, H - e), (W - e - rr, H - e)),
        curve.line((e, H - e)),
      ))
      place(dx: e, dy: dy-titre + calc.max(asc, 9.91pt) - 0.47pt, box(width: r.lefthand-width, align(center, text(
        size: taille,
        weight: "bold",
        fill: bf-resoudre-couleur(r.coltitle),
        top-edge: "baseline",
        bottom-edge: "baseline",
        numero,
      ))))
      place(dx: xt, dy: dy-titre, titre)
    }))
  })
}

// ---------- Rendus des jeux « bfcours », « sobre », « classique », « documentation » ----------

/// Format du numéro d'un niveau : « 1 », « 1.1 », « 1.1.1 ».
#let _format-numero(niveau) = ("1", "1.1", "1.1.1").at(calc.min(niveau, 3) - 1)

/// Numéro d'un titre (vide quand le titre n'est pas numéroté ou la numérotation coupée).
#let _numero(it, r) = if it.numbering != none and r.numerotation { counter(heading).display(_format-numero(it.level)) }

/// Zone d'un titre : `hauteur` fixe la hauteur minimale (contenu au bas de la zone), `filet` un
/// trait sous la zone.
#let _zone(r, contenu, filet: none) = block(
  width: 100%,
  above: r.before-skip,
  below: r.after-skip,
  sticky: true,
  breakable: false,
  {
    if r.hauteur == auto { contenu } else { block(width: 100%, height: r.hauteur, align(bottom + left, contenu)) }
    if filet != none { v(-0.35em); line(length: 100%, stroke: filet) }
  },
)

/// Niveau 3 et 4 du jeu `bfcours` : gras sans bandeau ; le niveau 4 n'est pas numéroté (en LaTeX
/// `\paragraph` ne l'est pas non plus).
#let _titre-bfcours-bas(it, r) = block(above: r.before-skip, below: r.after-skip, sticky: true, text(
  weight: "bold",
  ..if r.fonttitle == "normalsize" { (:) } else { (size: _taille(r.fonttitle)) },
  {
    if it.level == 3 and it.numbering != none and r.numerotation { counter(heading).display("1.1.1") + h(1em) }
    it.body
  },
))

/// Jeu `sobre` : numéro coloré, titre gras, filet fin sous les niveaux 1 et 2.
#let _titre-sobre(it, r) = {
  let c = bf-resoudre-couleur(r.couleur)
  let n = _numero(it, r)
  let taille = _taille(r.fonttitle)
  let ligne = {
    if n != none and it.level <= 3 { text(size: taille, weight: "bold", fill: c, n); h(0.5em) }
    text(size: taille, weight: "bold", style: if it.level == 4 { "italic" } else { "normal" }, fill: bf-resoudre-couleur(r.coltitle), it.body)
  }
  let filet = if it.level == 1 { 0.8pt + c } else if it.level == 2 { 0.4pt + c.lighten(45%) } else { none }
  if filet == none { block(above: r.before-skip, below: r.after-skip, sticky: true, ligne) } else {
    _zone(r, block(width: 100%, inset: (bottom: 3pt), stroke: (bottom: filet), ligne))
  }
}

/// Jeu `classique` : titres gras d'article, sans bandeau ni filet ; numéro suivi d'un espace.
#let _titre-classique(it, r) = {
  let n = _numero(it, r)
  let taille = _taille(r.fonttitle)
  let ligne = text(size: taille, weight: "bold", style: if it.level == 4 { "italic" } else { "normal" }, fill: bf-resoudre-couleur(r.coltitle), {
    if n != none and it.level <= 3 { n; h(1em) }
    it.body
  })
  if r.hauteur == auto { block(above: r.before-skip, below: r.after-skip, sticky: true, ligne) } else { _zone(r, ligne) }
}

/// Jeu `documentation` (rendu des documentations) : gros numéro coloré à gauche du titre, filet pâle sous le niveau 1.
#let _titre-documentation(it, r) = {
  let c = bf-resoudre-couleur(r.couleur)
  let n = _numero(it, r)
  let taille = _taille(r.fonttitle)
  let titre = text(size: taille, weight: "bold", fill: bf-resoudre-couleur(r.coltitle), it.body)
  if it.level == 1 {
    let ligne = {
      if n != none { text(size: taille * 20 / 17, weight: "bold", fill: c, n); h(10pt) }
      titre
    }
    _zone(r, ligne, filet: 0.6pt + c.lighten(75%))
  } else if it.level == 2 {
    block(above: r.before-skip, below: r.after-skip, sticky: true, {
      if n != none { text(size: taille, fill: c, n); h(8pt) }
      titre
    })
  } else {
    block(above: r.before-skip, below: r.after-skip, sticky: true, {
      if n != none and it.level == 3 { text(size: taille, fill: c, n); h(6pt) }
      text(size: taille, weight: "bold", style: if it.level == 4 { "italic" } else { "normal" }, fill: bf-resoudre-couleur(r.coltitle), it.body)
    })
  }
}

/// Règles de titres du document (`#show: bf-regles-titres`) : numérotation, rendu des niveaux 1 à 4
/// selon le jeu actif (`setbfsections(jeu: …)`, `bf-appliquer-jeu-titres`). Le jeu est lu au rendu :
/// on peut en changer en cours de document.
#let _regles-titres(doc) = {
  set heading(numbering: "1.1")
  show heading: it => if it.level > 4 { it } else {
    context {
      let r = bf-reglages-titre(it.level)
      let jeu = r.jeu
      if jeu == "bfcours" {
        if it.level == 1 {
          let numerote = it.numbering != none and r.numerotation
          block(
            width: 100%,
            above: r.before-skip,
            below: r.after-skip,
            sticky: true,
            breakable: false,
            bf-bandeau-section(if numerote [#counter(heading).display("1"). #it.body] else { it.body }, r: r),
          )
        } else if it.level == 2 {
          block(
            width: 100%,
            above: r.before-skip,
            below: r.after-skip,
            sticky: true,
            breakable: false,
            bf-bandeau-sous-section(
              if it.numbering == none or not r.numerotation [] else { counter(heading).display("1.1") },
              it.body,
              r: r,
            ),
          )
        } else { _titre-bfcours-bas(it, r) }
      } else if jeu == "sobre" { _titre-sobre(it, r) } else if jeu == "classique" { _titre-classique(it, r) } else {
        _titre-documentation(it, r)
      }
    }
  }
  doc
}

// =====================================================================
// Table des matières (\tableofcontents de bfcours : \section* + deux colonnes)
// =====================================================================

#let _T = (
  retrait: 15.78pt, // 1,5 em
  num-sub: 24.19pt, // 2,3 em
  rmarg: 26.83pt, // \@tocrmarg
  pnum: 16.31pt, // \@pnumwidth
  sep-section: 10.52pt, // \addvspace{1em}
  gouttiere: 10pt * 72 / 72.27, // \columnsep
  bleu: xmix(xc.blue, 90, autre: black),
)

/// Numéro de page d'une entrée : le texte peut empiéter sur la marge droite (\@tocrmarg)
/// jusqu'à la boîte du numéro (\@pnumwidth), comme la dernière ligne d'une entrée LaTeX.
#let _fin-toc(n, points: true) = {
  let ecart = _T.rmarg - _T.pnum
  // 4,5 mu avant le premier point ; 1 pt de tolérance pour les lignes qui tiennent tout juste
  if points { box(width: 1fr, pad(left: 2.63pt, repeat(gap: 5.26pt, justify: false)[.])) } else { h(1fr) }
  h(-ecart - 1pt)
  box(width: 0pt, height: 0pt, place(bottom + left, dx: ecart + 1pt, box(width: _T.pnum, align(right, text(
    bottom-edge: "baseline",
    str(n),
  )))))
}

/// Espace au-dessus d'une entrée de sommaire (\addvspace{1em} avant une section).
#let _espace-toc(e) = if e.func() == heading and e.level == 1 { _T.sep-section + 14.45pt - 11pt } else { 14.45pt - 11pt }

#let _entree-toc(e, premiere) = {
  let leading = 14.45pt - 11pt
  set par(justify: false, leading: leading, hanging-indent: 0pt)
  set text(hyphenate: true)
  let page-n = e.location().page()
  let lien(c) = link(e.location(), c)
  let (retrait, suspendu, corps, points, gras) = if e.func() == heading and e.level == 1 {
    let num = if e.numbering == none { [] } else { str(counter(heading).at(e.location()).first()) }
    (0pt, _T.retrait, [#box(width: _T.retrait, num)#e.body], false, true)
  } else if e.func() == heading {
    let nums = counter(heading).at(e.location())
    let num = nums.slice(0, calc.min(nums.len(), e.level)).map(str).join(".")
    (_T.retrait, _T.num-sub, [#box(width: _T.num-sub, num)#e.body], true, false)
  } else if e.value.simple {
    (_T.retrait, _T.num-sub, [#h(_T.num-sub)#e.value.nom], true, false)
  } else {
    // sans titre : le type seul, sans tiret
    let t = e.value.titre
    let libelle = if bf-vide(t) { strong(e.value.nom) } else { [#strong(e.value.nom) - #text(fill: _T.bleu, t)] }
    (_T.retrait, _T.num-sub, [#h(_T.num-sub)#libelle], true, false)
  }
  block(
    width: 100%,
    above: if premiere { 0pt } else { _espace-toc(e) },
    below: 0pt,
    lien(text(weight: if gras { "bold" } else { "regular" }, pad(
      left: retrait,
      block(inset: (right: _T.rmarg), par(hanging-indent: suspendu)[#corps#_fin-toc(page-n, points: points)]),
    ))),
  )
}

/// \tableofcontents de bfcours : titre de section non numéroté, entrées sur deux colonnes équilibrées.
/// Les environnements didactiques titrés y figurent (« **Définition** - sous-titre »).
#let tableofcontents(titre: [Table des matières], colonnes: 2, profondeur: 2) = {
  heading(level: 1, numbering: none, outlined: false, titre)
  // 19,32 pt du bas du bandeau à la première ligne de base ; les 7,57 pt faibles
  // du titre se cumulent avec cet espace fort.
  context v(calc.max(0pt, 11.07pt - bf-reglages-titre(1).after-skip))
  context {
    let elements = query(selector(heading.where(outlined: true)).or(<bf-toc>)).filter(e => (
      e.func() != heading or e.level <= profondeur
    ))
    if elements.len() == 0 { return }
    layout(s => {
      let largeur = (s.width - (colonnes - 1) * _T.gouttiere) / colonnes
      let rendus = elements.enumerate().map(((i, e)) => _entree-toc(e, i == 0))
      let hauteurs = elements.enumerate().map(((i, e)) => (
        measure(block(width: largeur, rendus.at(i))).height + if i == 0 { 0pt } else { _espace-toc(e) }
      ))
      let total = hauteurs.sum()
      // équilibrage façon multicols : on change de colonne dès que la part total / colonnes est atteinte
      let groupes = ()
      let courant = ()
      let cumul = 0pt
      let k = 1
      for i in range(rendus.len()) {
        let rendu = rendus.at(i)
        if cumul + hauteurs.at(i) / 2 > k * total / colonnes and courant.len() > 0 and k < colonnes {
          groupes.push(courant)
          courant = ()
          k += 1
          // la première entrée d'une colonne perd son espace au-dessus
          rendu = _entree-toc(elements.at(i), true)
        }
        courant.push(rendu)
        cumul += hauteurs.at(i)
      }
      groupes.push(courant)
      block(above: 0pt, below: 0pt, grid(
        columns: (1fr,) * colonnes,
        column-gutter: _T.gouttiere,
        ..groupes.map(g => g.join()),
      ))
    })
  }
}
#let sommaire = tableofcontents
