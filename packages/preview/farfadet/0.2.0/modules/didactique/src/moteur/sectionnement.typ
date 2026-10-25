// sectionnement.typ — titres de section et de sous-section en bandeau (bfcours-sectionning.sty),
// jeux de titres prédéfinis et table des matières (\tableofcontents).
// Phase 2 : cotes des bandeaux réglables (registre `_RS`, types « SectionBox » et « SubSectionBox »,
// noms des styles tcolorbox de bfcours-sectionning) ; BaseColor lue dans les couleurs définies
// par l'utilisateur (`definecolor("BaseColor", …)`), comme \definecolor{BaseColor} en LaTeX.
// Jeux de titres — `bfcours` (défaut : les bandeaux
// SectionBox / SubSectionBox de l'utilisateur), `sobre`, `classique`, `documentation`, `rd` — réglables par
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
#let bf-couleur-titres() = xmix(bf-lire(bf-couleurs-perso-p).at("BaseColor", default: rgb(51, 51, 51)), 80, autre: black)

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

#let _noms-jeux = ("bfcours", "sobre", "classique", "documentation", "rd")

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
  // label « ■ Partie X » de rdboites (`rd.partieDNB`) au niveau 1 ; niveaux 2 à 4 en gras, compacts :
  // `couleur` colore le fond du badge (niveau 1) ou le carré (niveau 2) et le numéro (niveaux 3 et 4)
  rd: (
    (hauteur: auto, fonttitle: "large", before-skip: 14pt, after-skip: 8pt, couleur: bf-nommee("black"), coltitle: bf-nommee("black")),
    (hauteur: auto, fonttitle: "large", before-skip: 11pt, after-skip: 6pt, couleur: bf-nommee("black"), coltitle: bf-nommee("black")),
    (hauteur: auto, fonttitle: "normalsize", before-skip: 9pt, after-skip: 4pt, couleur: bf-nommee("black"), coltitle: bf-nommee("black")),
    (hauteur: auto, fonttitle: "normalsize", before-skip: 8pt, after-skip: 3pt, couleur: bf-nommee("black"), coltitle: bf-nommee("black")),
  ),
)

// =====================================================================
// Réglages des titres (setbfsections)
// =====================================================================

#let _tailles-titre = ("tiny", "scriptsize", "footnotesize", "small", "normalsize", "large", "Large", "LARGE", "huge", "Huge")

// Style de numérotation des titres (clé `numeros`).
//   "arabe"  (défaut) : 1 / 1.1 / 1.1.1, numéro cumulé.
//   "romain"          : I, II, III… pour les sections.
//   "lettres"         : A, B, C… pour les sections.
// Dans les deux derniers modes, une sous-section porte « 1. », « 2. » seul et le niveau 3 « a) », « b) » :
// le titre de la section est affiché juste au-dessus, donc « I.1 » répéterait le numéro de la section, et
// « 1.1 » au niveau 3 se confondrait avec le style arabe. Un tableau de motifs Typst, un par niveau
// (`("I", "1.", "a)")`), règle chaque niveau ; chaque motif s'applique au seul compteur de son niveau.
// Les renvois (`@étiquette`) affichent le chemin complet (« II.1 », « II.1.a ») : « 1 » seul y serait ambigu.
#let _noms-numeros = ("arabe", "romain", "lettres")
#let _motifs-numeros = (romain: ("I", "1.", "a)"), lettres: ("A", "1.", "a)"))
#let _controle-numeros = (
  v => v in _noms-numeros or (type(v) == array and v.len() > 0 and v.all(m => type(m) == str)),
  "\"arabe\", \"romain\", \"lettres\" ou un tableau de motifs Typst, un par niveau (par exemple (\"I\", \"1.\", \"a)\"))",
)

#let _RS = reglages-paquet(
  "sectionnement",
  (
    jeu: "bfcours",
    numeros: "arabe",
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
    numeros: _controle-numeros,
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
/// Renvoie le contenu (mise à jour d'état) à placer dans le document : le modèle `farfadet` l'appelle
/// depuis sa clé `titres:`. Noms : `"bfcours"` (défaut), `"sobre"`, `"classique"`, `"documentation"`, `"rd"`.
/// `numeros` (`auto` : réglage inchangé) règle en même temps le style de numérotation (clé `numeros`).
#let bf-appliquer-jeu-titres(nom, numeros: auto) = reglages-regler(
  _RS,
  commande: "bf-appliquer-jeu-titres",
  jeu: nom,
  ..if numeros == auto { (:) } else { (numeros: numeros) },
)

// ---------- Style de numérotation : formats ----------

/// Motifs Typst par niveau pour une valeur de `numeros` autre que `"arabe"`.
#let _motifs(valeur) = if type(valeur) == array { valeur } else { _motifs-numeros.at(valeur) }

/// Motif du niveau `niveau` (le dernier motif sert aux niveaux suivants).
#let _motif(valeur, niveau) = {
  let m = _motifs(valeur)
  m.at(calc.min(niveau, m.len()) - 1)
}

/// Numéro court d'un titre (celui de son seul niveau) pour un style autre que `"arabe"` : « II », « 1. », « a) ».
/// `nums` : valeurs du compteur de titres.
#let _numero-court(nums, niveau, valeur) = numbering(_motif(valeur, niveau), nums.at(niveau - 1, default: 0))

/// Chemin complet d'un titre pour un style autre que `"arabe"` : « II », « II.1 », « II.1.a » (les points et
/// parenthèses finales de chaque motif sont retirés avant l'assemblage).
#let _chemin-numero(nums, valeur) = nums.enumerate().map(((i, n)) => {
  numbering(_motif(valeur, i + 1), n).trim(regex("[.)]+"), at: std.end)
}).join(".")

/// Numérotation des titres du document (`set heading(numbering: …)`), utilisée par les renvois :
/// « 1.1 » en style arabe, le chemin complet sinon. Le style est lu à l'endroit du renvoi.
#let _numerotation-titres(..n) = context {
  let valeur = reglages-courants(_RS).numeros
  if valeur == "arabe" { numbering("1.1", ..n) } else { _chemin-numero(n.pos(), valeur) }
}

/// Numéro de section tel qu'il apparaît dans le numéro d'un environnement (« 2.3 » devient « II.3 »).
/// À appeler dans un `context`.
#let bf-numero-section(s) = {
  let valeur = reglages-courants(_RS).numeros
  if valeur == "arabe" { str(s) } else { _chemin-numero((s,), valeur) }
}

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

/// Numéro affiché d'un titre de niveau `niveau`, selon le style de numérotation `valeur` (clé `numeros`).
#let _afficher-numero(niveau, valeur) = if valeur == "arabe" {
  counter(heading).display(_format-numero(niveau))
} else {
  counter(heading).display((..n) => _numero-court(n.pos(), niveau, valeur))
}

/// Numéro d'un titre (vide quand le titre n'est pas numéroté ou la numérotation coupée).
#let _numero(it, r) = if it.numbering != none and r.numerotation { _afficher-numero(it.level, r.numeros) }

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
    if it.level == 3 and it.numbering != none and r.numerotation { _afficher-numero(3, r.numeros) + h(1em) }
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

/// Jeu `rd` : niveau 1 en badge « ■ Titre » de rdboites (`rd.partieDNB`, fond gris clair et ombre légère) ;
/// niveau 2 en gras avec un petit carré (même repère visuel que le badge), niveaux 3 et 4 en gras simple
/// (le 4 en italique, non numéroté), sans bandeau ni filet : compact, dans l'esprit de `sobre`.
/// rdboites n'est importé qu'ici, au premier titre rendu avec ce jeu.
#let _titre-rd(it, r) = {
  let c = bf-resoudre-couleur(r.couleur)
  let n = _numero(it, r)
  let taille = _taille(r.fonttitle)
  let fond = bf-resoudre-couleur(r.coltitle)
  if it.level == 1 {
    import "../../../rd-boites/lib.typ": rd as _rd
    let corps = { if n != none { n; [. ] }; it.body }
    block(above: r.before-skip, below: r.after-skip, sticky: true, breakable: false, text(
      size: taille,
      fill: fond,
      _rd.partieDNB(corps, label: [], colback: xmix(c, 15, autre: white)),
    ))
  } else {
    let marque = if it.level == 2 { box(width: 0.55em, height: 0.55em, fill: c) + h(0.5em) }
    let numero = if n != none and it.level <= 3 { text(fill: if it.level == 3 { c } else { fond }, n) + h(if it.level == 2 { 0.5em } else { 0.6em }) }
    block(above: r.before-skip, below: r.after-skip, sticky: true, text(
      size: taille,
      weight: "bold",
      style: if it.level == 4 { "italic" } else { "normal" },
      fill: fond,
      { marque; numero; it.body },
    ))
  }
}

/// Règles de titres du document (`#show: bf-regles-titres`) : numérotation, rendu des niveaux 1 à 4
/// selon le jeu actif (`setbfsections(jeu: …)`, `bf-appliquer-jeu-titres`). Le jeu est lu au rendu :
/// on peut en changer en cours de document.
#let _regles-titres(doc) = {
  set heading(numbering: _numerotation-titres)
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
            bf-bandeau-section(if numerote [#_afficher-numero(1, r.numeros). #it.body] else { it.body }, r: r),
          )
        } else if it.level == 2 {
          block(
            width: 100%,
            above: r.before-skip,
            below: r.after-skip,
            sticky: true,
            breakable: false,
            bf-bandeau-sous-section(
              if it.numbering == none or not r.numerotation [] else { _afficher-numero(2, r.numeros) },
              it.body,
              r: r,
            ),
          )
        } else { _titre-bfcours-bas(it, r) }
      } else if jeu == "sobre" { _titre-sobre(it, r) } else if jeu == "classique" { _titre-classique(it, r) } else if jeu == "rd" {
        _titre-rd(it, r)
      } else {
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
  retrait-large: 28pt, // numéros de section en chiffres romains ou en lettres (« VIII »)
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

/// Copie de mesure de `_fin-toc` (voir `_entree-toc-m`) : même code, autre position dans le source.
#let _fin-toc-m(points: true) = {
  let ecart = _T.rmarg - _T.pnum
  if points { box(width: 1fr, pad(left: 2.63pt, repeat(gap: 5.26pt, justify: false)[.])) } else { h(1fr) }
  h(-ecart - 1pt)
  box(width: 0pt, height: 0pt, place(bottom + left, dx: ecart + 1pt, box(width: _T.pnum, align(right, text(
    bottom-edge: "baseline",
    "0",
  )))))
}


/// Données d'une entrée (à calculer dans un `context`), sans emplacement : numéro de titre en texte,
/// corps du titre ou de l'environnement. Elles fixent la hauteur de l'entrée.
#let _donnee-toc(e) = if e.func() == heading {
  let nums = counter(heading).at(e.location())
  let valeur = reglages-courants(_RS).numeros
  let arabe = valeur == "arabe"
  let num = if e.level == 1 {
    if e.numbering == none { none } else if arabe { str(nums.first()) } else { _numero-court(nums, 1, valeur) }
  } else if arabe { nums.slice(0, calc.min(nums.len(), e.level)).map(str).join(".") } else {
    _numero-court(nums, e.level, valeur)
  }
  (type: if e.level == 1 { "section" } else { "titre" }, num: num, corps: e.body, section: e.level == 1, large: not arabe)
} else if e.value.simple {
  (type: "simple", corps: e.value.nom, section: false)
} else {
  // numéroté par un compteur (exercices) : numéro lu à l'emplacement de l'entrée, juste dès le tour 2
  let nom = if "compteur" in e.value [#e.value.libelle #e.value.compteur.at(e.location()).first()] else { e.value.nom }
  (type: "env", nom: nom, titre: e.value.titre, section: false)
}

/// Espace au-dessus d'une entrée de sommaire (\addvspace{1em} avant une section).
#let _espace-d(d) = if d.section { _T.sep-section + 14.45pt - 11pt } else { 14.45pt - 11pt }

/// Entrée posée : `n` numéro de page, `dest` position de l'élément (lien sans calcul de texte
/// alternatif, qui interrogerait les compteurs à chaque tour).
#let _entree-toc(d, premiere, n, dest) = {
  let leading = 14.45pt - 11pt
  set par(justify: false, leading: leading, hanging-indent: 0pt)
  set text(hyphenate: true)
  let (retrait, suspendu, corps, points, gras) = if d.type == "section" {
    let l = if d.large { _T.retrait-large } else { _T.retrait }
    (0pt, l, [#box(width: l, d.num)#d.corps], false, true)
  } else if d.type == "titre" {
    (_T.retrait, _T.num-sub, [#box(width: _T.num-sub, d.num)#d.corps], true, false)
  } else if d.type == "simple" {
    (_T.retrait, _T.num-sub, [#h(_T.num-sub)#d.corps], true, false)
  } else {
    // sans titre : le type seul, sans tiret
    let libelle = if bf-vide(d.titre) { strong(d.nom) } else { [#strong(d.nom) - #text(fill: _T.bleu, d.titre)] }
    (_T.retrait, _T.num-sub, [#h(_T.num-sub)#libelle], true, false)
  }
  block(
    width: 100%,
    above: if premiere { 0pt } else { _espace-d(d) },
    below: 0pt,
    link(dest, text(weight: if gras { "bold" } else { "regular" }, pad(
      left: retrait,
      block(inset: (right: _T.rmarg), par(hanging-indent: suspendu)[#corps#_fin-toc(n, points: points)]),
    ))),
  )
}

#let _seq-toc = [*a* *b*].func()
#let _styled-toc = text(red)[a].func()

/// Copie d'un contenu du document : formules, gras et italique reconstruits ici (même rendu, autre
/// empreinte), pour qu'aucun élément mesuré n'ait de jumeau posé (voir `_entree-toc-m`).
#let _copie-toc(c) = {
  if type(c) != content { return c }
  let f = c.func()
  if f == math.equation or f == strong or f == emph {
    let ch = c.fields()
    let corps = ch.remove("body")
    let _ = ch.remove("label", default: none)
    return f(..ch, if f == math.equation { corps } else { _copie-toc(corps) })
  }
  if f == _seq-toc { return c.children.map(_copie-toc).join() }
  if f == _styled-toc { return f(_copie-toc(c.child), c.styles) }
  c
}

/// Copie de mesure de `_entree-toc`, écrite à part EXPRÈS. `measure` donne à chaque élément repérable
/// l'emplacement de l'élément posé de même empreinte (contenu et position dans le source), s'il y en a un
/// (voir `_entree-toc`). Le sommaire est vide au tour 1 : une copie identique aux entrées posées trouverait
/// ses jumeaux au tour 3 seulement, et toute la mesure serait refaite. Ici, tout élément est construit à
/// une autre position du source, sans lien, avec le numéro de page 0 (boîte de taille nulle : même
/// hauteur), et le contenu venu du document est reconstruit (`_copie-toc`). À garder identique à
/// `_entree-toc` pour la géométrie.
#let _entree-toc-m(d, premiere) = {
  let leading = 14.45pt - 11pt
  set par(justify: false, leading: leading, hanging-indent: 0pt)
  set text(hyphenate: true)
  let (retrait, suspendu, corps, points, gras) = if d.type == "section" {
    let l = if d.large { _T.retrait-large } else { _T.retrait }
    (0pt, l, [#box(width: l, d.num)#_copie-toc(d.corps)], false, true)
  } else if d.type == "titre" {
    (_T.retrait, _T.num-sub, [#box(width: _T.num-sub, d.num)#_copie-toc(d.corps)], true, false)
  } else if d.type == "simple" {
    (_T.retrait, _T.num-sub, [#h(_T.num-sub)#_copie-toc(d.corps)], true, false)
  } else {
    let libelle = if bf-vide(d.titre) { strong(_copie-toc(d.nom)) } else {
      [#strong(_copie-toc(d.nom)) - #text(fill: _T.bleu, _copie-toc(d.titre))]
    }
    (_T.retrait, _T.num-sub, [#h(_T.num-sub)#libelle], true, false)
  }
  block(
    width: 100%,
    above: if premiere { 0pt } else { _espace-d(d) },
    below: 0pt,
    text(weight: if gras { "bold" } else { "regular" }, pad(
      left: retrait,
      block(inset: (right: _T.rmarg), par(hanging-indent: suspendu)[#corps#_fin-toc-m(points: points)]),
    )),
  )
}

/// Titres et entrées d'environnements du sommaire, dans l'ordre du document. À appeler dans un `context`.
#let _elements-toc(profondeur) = query(selector(heading.where(outlined: true)).or(<bf-toc>)).filter(e => (
  e.func() != heading or e.level <= profondeur
))

/// Hauteur d'une entrée, pour l'équilibrage des colonnes. Ses arguments n'ont ni emplacement ni numéro de
/// page : l'appel reste en cache d'un tour à l'autre et du prof à l'élève, entrée par entrée.
#let _hauteur-toc(d, premiere, largeur) = (
  measure(block(width: largeur, _entree-toc-m(d, premiere))).height + if premiere { 0pt } else { _espace-d(d) }
)

/// \tableofcontents de bfcours : titre de section non numéroté, entrées sur deux colonnes équilibrées.
/// Les environnements didactiques titrés y figurent (« **Définition** - sous-titre »).
#let tableofcontents(titre: [Table des matières], colonnes: 2, profondeur: 2) = {
  heading(level: 1, numbering: none, outlined: false, titre)
  // 19,32 pt du bas du bandeau à la première ligne de base ; les 7,57 pt faibles
  // du titre se cumulent avec cet espace fort.
  context v(calc.max(0pt, 11.07pt - bf-reglages-titre(1).after-skip))
  context {
    if _elements-toc(profondeur).len() == 0 { return }
    // La fonction passée à `layout` ne capture aucune valeur qui change d'un tour à l'autre ou du prof à
    // l'élève : son empreinte fixe l'emplacement de `layout`, base des mesures. Les entrées et leurs
    // positions sont lues à l'intérieur.
    layout(s => {
      let elements = _elements-toc(profondeur)
      let ds = elements.map(_donnee-toc)
      let pos = elements.map(e => e.location().position())
      let largeur = (s.width - (colonnes - 1) * _T.gouttiere) / colonnes
      let rendus = ds.enumerate().map(((i, d)) => _entree-toc(d, i == 0, pos.at(i).page, pos.at(i)))
      let hauteurs = ds.enumerate().map(((i, d)) => _hauteur-toc(d, i == 0, largeur))
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
          rendu = _entree-toc(ds.at(i), true, pos.at(i).page, pos.at(i))
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
