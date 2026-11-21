// evaluation.typ (farfadet-exo) — cartouches d'évaluation (tableauEval, tableauProjetEval,
// tableauPresenteEvalSixieme), chronomètres (chrono, overlaychrono), niveaux de maîtrise
// (mi, mf, ms, tbm) et tableaux de compétences (competence, tableaucompetence, tableaucompetenceEval
// et l'index). Valeurs réglables par le registre « exo-divers » de `setrdexo` : types `competences`,
// `tableau-eval`, `tableau-projet-eval`, `tableau-presente-eval-sixieme`, `chrono`, `overlaychrono`.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: *
#import "../../../enumerations/lib.typ": interne as _enum
#import _enum: bf-raster, bf-resoudre-tcb, bf-tcb-defaut, bf-boite
#import "../../../zones-reponse/lib.typ": interne as _crep
#import _crep: tcfillcrep, tccrep
#import "../../../tableaux/lib.typ": interne as _tableaux
#import _tableaux: cellule, hline, tcbtab
#import "reglages.typ": bf-divers-registre, bf-exo-registre, bf-exo-couleur

#let _p(type, cles) = reglages-resoudre(bf-divers-registre, pour: type, local: cles, commande: type)

// =====================================================================
// Chronomètres : \overlaychrono, \chrono
// =====================================================================

/// \overlaychrono{minutes} : cadran de 0,8 cm en surimpression (sans largeur), secteur rouge
/// jusqu'aux minutes, repères des quarts d'heure, aiguille, puis « minutes’ » à 0,7 cm du centre.
#let bf-overlaychrono(minutes, ..cles) = context {
  let p = _p("overlaychrono", cles.named())
  let r = p.radius
  let fraction = calc.min(float(minutes) / 60, 1)
  let angle = 90deg - fraction * 360deg
  let em = 1em.to-absolute()
  // centre du cadran : 0,35 em au-dessus de la ligne de base (texte ancré « west » à mi-hauteur)
  let cy = -0.35 * em
  let pt(a, rr) = (rr * calc.cos(a), cy - rr * calc.sin(a))
  let n = calc.max(2, int(fraction * 48) + 1)
  let secteur = ((0pt, cy),) + range(n + 1).map(k => pt(90deg - k / n * fraction * 360deg, r))
  let epais = p.line-width
  let couleur = bf-exo-couleur(p.color)
  let remplissage = if p.opacity >= 1 { couleur } else { rgb(couleur).transparentize((1 - p.opacity) * 100%) }
  box(width: 0pt, height: 0pt, {
    if fraction > 0 { place(top + left, polygon(fill: remplissage, stroke: none, ..secteur)) }
    place(top + left, dx: -r, dy: cy - r, circle(radius: r, stroke: p.circle-width + black))
    for a in (0deg, 90deg, 180deg, 270deg) {
      place(top + left, line(start: pt(a, r - 0.07cm), end: pt(a, r - 0.02cm), stroke: epais + black))
    }
    place(top + left, line(start: (0pt, cy), end: pt(angle, r - 0.02cm), stroke: epais + black))
    // texte posé sur la ligne de base (le bas de la boîte de ligne est `desc` sous la ligne de base)
    place(bottom + left, dx: p.label-sep + 0.3333 * em, dy: bf-metriques().desc, [#minutes’])
  })
}

/// \chrono{minutes} : minipage de 3 cm, \boite{Durée :}{cadran et minutes}.
#let bf-chrono(minutes, ..cles) = context {
  let p = _p("chrono", cles.named())
  let cadre = bf-exo-couleur(p.colframe)
  let s = bf-resoudre-tcb(
    bf-tcb-defaut,
    "halign title=flush left, fonttitle=\\bfseries, coltitle=white, colback=white",
    (colbacktitle: cadre, colframe: cadre, title: p.title, titre-rempli: true),
  )
  box(width: p.width, bf-boite(s, [#v(0.9em)#h(0.4cm)#bf-overlaychrono(minutes)#v(0.5em)]))
}

// =====================================================================
// Cartouches d'évaluation : \tableauEval, \tableauProjetEval, \tableauPresenteEvalSixieme
// =====================================================================

#let _boite-eval(p) = (
  colback: bf-exo-couleur(p.colback),
  colframe: bf-exo-couleur(p.colframe),
  arc: p.arc,
  boxsep: 0pt,
  bottom: 0pt,
  compenser: false,
)

/// \tableauEval{durée} : cartouche « Nom / Prénom » (3/4) et « Durée » avec chronomètre (1/4).
#let bf-tableauEval(duree, ..cles) = context {
  let p = _p("tableauEval", cles.named())
  let bs = bf-lire(bf-interligne-p).baselineskip
  let cases = grid(
    columns: (1fr, 1fr),
    column-gutter: 2mm,
    align: horizon,
    [*#p.nom* #tcfillcrep[]], [*#p.prenom* #tcfillcrep[]],
  )
  let n = p.raster-columns
  let elements = (
    ([#cases], bf-resoudre-tcb(bf-tcb-defaut, _boite-eval(p), (boxrule: p.boxrule, left: ptl(1), right: ptl(1), top: 0pt, raster-multicolumn: n - 1, compenser: false))),
    ([*#p.duree* #h(1fr)#bf-overlaychrono(duree)#h(1fr)#hide[AA]], bf-resoudre-tcb(bf-tcb-defaut, _boite-eval(p), (boxrule: p.boxrule, top: ptl(2), valign: "center"))),
  )
  // cartouche posé comme un tcbraster (raster before/after skip de 0,5 \baselineskip) : espaces faibles,
  // qui se confondent avec celui que `chap-eval` laisse déjà sous son bandeau au lieu de s'y ajouter
  block(width: 100%, above: 0.5 * bs, below: 0.5 * bs, layout(taille => bf-raster(
    elements,
    n,
    taille.width,
    ecart-col: p.raster-column-skip,
    ecart-lig: p.raster-row-skip,
    valign: horizon,
  )))
}

/// \tableauProjetEval{date} : même cartouche, case de droite titrée « Date de rendu : ».
#let bf-tableauProjetEval(date, ..cles) = context {
  let p = _p("tableauProjetEval", cles.named())
  let bs = bf-lire(bf-interligne-p).baselineskip
  let cases = grid(
    columns: (1fr, 1fr),
    column-gutter: 2mm,
    align: horizon,
    [*#p.nom* #tcfillcrep[]], [*#p.prenom* #tcfillcrep[]],
  )
  let n = p.raster-columns
  let elements = (
    ([#cases], bf-resoudre-tcb(bf-tcb-defaut, _boite-eval(p), (boxrule: p.boxrule, left: ptl(1), right: ptl(1), top: 0pt, raster-multicolumn: n - 1))),
    (date, bf-resoudre-tcb(bf-tcb-defaut, _boite-eval(p), "top=2pt, valign=center, halign=center, toptitle=1pt, bottomtitle=1.5pt, fonttitle=\\bfseries", (boxrule: p.boxrule, title: p.date, compenser: true))),
  )
  block(width: 100%, above: 0.8 * bs, below: 0.5 * bs, layout(taille => bf-raster(
    elements,
    n,
    taille.width,
    ecart-col: p.raster-column-skip,
    ecart-lig: p.raster-row-skip,
    valign: horizon,
  )))
}

/// \tableauPresenteEvalSixieme{…}{note max} : « Nom / Prénom » (0,7 \textwidth, filet de 2 pt) et
/// « Bilan : ▢ / note ▢ » (0,295 \textwidth).
#let bf-tableauPresenteEvalSixieme(inutilise, note, ..cles) = context {
  let p = _p("tableauPresenteEvalSixieme", cles.named())
  let fond = bf-exo-couleur(p.colback)
  let cadre = bf-exo-couleur(p.colframe)
  let gauche = block(width: 100%, fill: fond, stroke: p.boxrule + cadre, radius: p.arc, inset: (x: 0pt, top: 0pt, bottom: 0pt),
    grid(columns: (1fr, 1fr, 1fr), column-gutter: 2mm, inset: (x: ptl(6), y: ptl(3)), align: horizon,
      [*#p.nom* #tcfillcrep[]], [*#p.prenom* #tcfillcrep[]], []))
  let droite = block(width: 100%, fill: fond, stroke: ptl(0.4) + cadre, radius: p.arc, inset: ptl(3),
    strong[#p.bilan#tccrep(seyes: false, 1cm)[]/#note#tccrep(seyes: false, 1.5cm)[]])
  let l = if type(p.width) == ratio { p.width } else { 70% }
  block(width: 100%, grid(columns: (l, 1fr), column-gutter: 0.5%, align: horizon, gauche, align(right, droite)))
}

// =====================================================================
// Niveaux de maîtrise : mi, mf, ms, tbm
// =====================================================================

/// Émojis de \mi, \mf, \ms, \tbm (Twemoji, CC-BY 4.0) : hauteur 1,3 em, abaissés de 0,2 em.
/// Clé `emoji` de `setrdexo` : true et "images" = émojis, false = « MI », « MF »… en gras.
#let _emoji(code, texte) = context {
  if reglages-courants(bf-exo-registre).emoji == false { return strong(texte) }
  let q = bf-quad().to-absolute()
  box(baseline: 0.2 * q, image("emoji/" + code + ".pdf", height: 1.3 * q))
}
#let mi() = _emoji("1f643", "MI")
#let mf() = _emoji("1f928", "MF")
#let ms() = _emoji("1f642", "MS")
#let tbm() = _emoji("1f929", "TBM")

// =====================================================================
// Tableaux de compétences
// =====================================================================

/// Fonds des cases MI, MF, MS, TBM (réglables : setrdexo(pour: "competences", colback-mi: …)).
/// À appeler dans un `context`.
#let bf-couleurs-grille() = {
  let p = reglages-courants(bf-divers-registre, pour: "competences")
  (mi: p.colback-mi, mf: p.colback-mf, ms: p.colback-ms, tbm: p.colback-tbm)
}

/// \encadrer[prop]{code} tel que le dessine bfcours-commands.sty (tcbox on line, fbox, boxsep 1 pt,
/// marges 3 pt × 2 pt, cadre c!75!black, fond c!5, coins 5 pt).
#let _encadrer-code(couleur, corps) = context {
  let t = text(fill: black, top-edge: "bounds", bottom-edge: "bounds", corps)
  let m = measure(t)
  let r = ptl(0.4)
  let (fond, cadre) = if type(couleur) == str {
    (bf-exo-couleur(couleur + "!5!white"), bf-exo-couleur(couleur + "!75!black"))
  } else { (xmix(couleur, 5), xmix(couleur, 75, autre: black)) }
  // boîte à contenu textuel : elle s'aligne d'elle-même sur la ligne de base du texte
  box(
    width: m.width + 2 * (r + ptl(4)),
    height: m.height + 2 * (r + ptl(3)),
    fill: fond,
    stroke: r + cadre,
    radius: ptl(5),
    align(center + horizon, t),
  )
}

/// \competence[code]{texte}
#let competence(code: none, corps) = (bf-competence: true, code: code, corps: corps)

#let _spec-competences = ">{\\raggedright\\arraybackslash}p{0.56\\textwidth}|>{\\centering\\arraybackslash}p{0.05\\textwidth}|>{\\centering\\arraybackslash}p{0.06\\textwidth}|>{\\centering\\arraybackslash}p{0.06\\textwidth}|>{\\centering\\arraybackslash}p{0.09\\textwidth}"

#let _tableau-competences(entete, items) = context {
  let p = reglages-courants(bf-divers-registre, pour: "competences")
  let cellules = (
    cellule(align: center, strong(entete)),
    cellule(fill: p.colback-mi, mi()),
    cellule(fill: p.colback-mf, mf()),
    cellule(fill: p.colback-ms, ms()),
    cellule(fill: p.colback-tbm, tbm()),
    hline(),
  )
  let lignes = ()
  for it in items {
    if type(it) == dictionary and it.at("bf-competence", default: false) {
      lignes.push((code: it.code, corps: it.corps))
    } else { lignes.push((code: none, corps: it)) }
  }
  for (code, corps) in lignes {
    cellules += (
      cellule(fill: p.colback-competence, [#text(fill: black, p.puce) #corps#h(1fr)#if code != none { _encadrer-code(p.couleur-code, code) }]),
      [], [], [], [],
      hline(),
    )
  }
  tcbtab(_spec-competences, ..cellules)
}

/// \tableaucompetence{\competence{…} \competence[code]{…}}
///   #tableaucompetence(competence[Reconnaître…], competence(code: "C2")[Compléter…])
#let tableaucompetence(..items) = context _tableau-competences(reglages-courants(bf-divers-registre, pour: "competences").entete-travaillees, items.pos())

/// \tableaucompetenceEval{…}
#let tableaucompetenceeval(..items) = context _tableau-competences(reglages-courants(bf-divers-registre, pour: "competences").entete-evaluees, items.pos())

