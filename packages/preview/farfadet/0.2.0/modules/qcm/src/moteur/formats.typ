// formats.typ (farfadet-qcm, moteur) — les formats (thèmes) de rdmcq : default, Troyes, Tokyo, Boston,
// Miami, Reims, Millau, Melun, Paris (rdmcq.<ville>.format.tex) et BFCours (rdmcq.bfcours.format.sty).
//
// Un format se décompose comme en LaTeX en deux formats partiels, rangés dans l'état `bf-mcq-formats` :
//   question : (zone: style de la zone externe, box: style de la boîte interne)        \newQuestionFormat
//   answer   : (horizontal: (zone, box, correction), vertical: (zone, box, correction))  \newAnswerFormat
// et un format GLOBAL (\newMcqFormat) = un style nommé du registre de \setrdmcq (les deux formats
// partiels + les réglages row sep, column sep… + boxrule) : voir mcq.typ, `mcq-formats-globaux`.
//
// Les décors TikZ des formats (formes de Miami, encoches de Paris…) sont redessinés en Typst par des
// fonctions `overlay` / `underlay` : rendu proche, pas identique au point près.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: xmix
#import "boite.typ": mcq-sans, mcq-tailles
#import "cases.typ": mcq-cb, mcq-rb

// ---------------------------------------------------------------------
// Pièces communes
// ---------------------------------------------------------------------

/// \rdmcqCounterFormat : pastille noire du numéro de question (format default), posée en débord à
/// gauche du texte (0,4 em), police sans grasse \footnotesize, coins arrondis 4 pt, largeur min. 1,8 em.
#let rdmcqCounterFormat(n) = context {
  let t = text(font: mcq-sans, weight: "bold", size: mcq-tailles.footnotesize, fill: white, str(n))
  let l = calc.max(measure(t).width + 0.6667 * mcq-tailles.footnotesize.to-absolute(), 1.8em.to-absolute())
  // `outset` : la pastille déborde verticalement sans changer l'interligne (TikZ `overlay`)
  let p = box(fill: black, radius: 4pt, outset: (y: 0.3333 * mcq-tailles.footnotesize.to-absolute()), box(width: l, align(center, t)))
  [#h(-(l + 0.4em))#p#h(0.4em)]
}

/// Pastille ronde numérotée (formats Troyes, Tokyo, Boston, Reims, BFCours).
#let _pastille(contenu, fond: white, texte: black, taille: mcq-tailles.tiny, diametre: 1.2em, opacite: 1) = {
  let f = if opacite < 1 { fond.transparentize((1 - opacite) * 100%) } else { fond }
  box(baseline: 25%, circle(
    radius: diametre / 2,
    fill: f,
    stroke: none,
    inset: 0pt,
    align(center + horizon, text(font: mcq-sans, weight: "bold", size: taille, fill: texte, contenu)),
  ))
}

/// Petit carré blanc des réponses verticales (Troyes, Tokyo, Reims, Melun), barré si la réponse est juste.
#let _carre(m, fond: white, contour: none, marque: "✘") = box(baseline: 15%, rect(
  width: 0.8em,
  height: 0.8em,
  fill: fond,
  stroke: contour,
  inset: 0pt,
  if m.br { align(center + horizon, text(fill: red, size: 0.9em, marque)) },
))

#let _lettre(k) = numbering("A", k)

// ---------------------------------------------------------------------
// default (rdmcq.sty, l. 854-918)
// ---------------------------------------------------------------------

#let _default = (
  question: (
    zone: (opacityback: 0, colframe: black, colback: white),
    box: (
      left: 2.4em,
      right: 5pt,
      top: 3pt,
      bottom: 3pt,
      valign: "top",
      halign: "justify",
      before-upper: m => (m.counter-format)(m.question),
    ),
  ),
  answer: (
    horizontal: (
      zone: (:),
      box: (boxsep: 3pt, valign: "center", halign: "center", colframe: black, opacityback: 0, boxrule: m => m.boxrule),
      // bonne réponse : fond de la couleur nommée `prop` et case cochée en rouge (comme le format BFCours),
      // en plus du gras, qui ne se voit pas sur une formule
      correction: (
        colback: "prop!10",
        // la boîte des réponses est transparente (`opacityback: 0`) : sans ceci le fond restait invisible
        opacityback: 1,
        fontupper: (weight: "bold"),
        before-upper: m => [#mcq-cb(local: (check-color: "red", checked: true))#h(0.5em)],
      ),
    ),
    vertical: (
      zone: (boxsep: 3pt, colframe: black, colback: white, opacityback: 0, boxrule: m => m.boxrule),
      box: (boxsep: 3pt, valign: "center", halign: "left", before-upper: m => [#mcq-cb(local: (checked: m.br))#h(0.5em)]),
      correction: (colback: "prop!10", fontupper: (weight: "bold")),
    ),
  ),
)

// ---------------------------------------------------------------------
// Troyes et Tokyo (rdmcq.troyes.format.tex, rdmcq.tokyo.format.tex)
// ---------------------------------------------------------------------

#let _bleu-troyes = rgb("#4A85A1")

/// Zone question bleue coupée d'un filet blanc de 1,5 pt entre le numéro et l'énoncé.
#let _zone-troyes(gauche) = (
  opacityback: 1,
  colback: xmix(_bleu-troyes, 60),
  colframe: black,
  underlay: m => place(top + left, dx: 3pt + gauche + 3pt, rect(width: 1.5pt, height: m.hauteur, fill: white, stroke: none)),
)

#let _troyes(nom, couleur-numero, largeur-gauche) = (
  question: (
    zone: _zone-troyes(largeur-gauche),
    box: (
      boxsep: 3pt,
      sidebyside-gap: 7.5pt,
      lefthand-width: largeur-gauche,
      lefthand: m => _pastille(str(m.question), texte: couleur-numero),
      halign: "center",
      halign-lower: "justify",
    ),
  ),
  answer: (
    horizontal: if nom == "Troyes" {
      (
        zone: (:),
        box: (boxsep: 3pt, valign: "center", halign: "center", colback: xmix(_bleu-troyes, 60)),
        correction: (
          fontupper: (weight: "bold"),
          coltext: white,
          underlay: m => place(top + left, dx: 2.5pt, dy: 2.5pt, rect(
            width: m.largeur - 5pt,
            height: m.hauteur - 5pt,
            radius: 4pt,
            fill: red.transparentize(70%),
            stroke: none,
          )),
        ),
      )
    } else {
      // Tokyo : cases à cocher de rdcheckbox (tcbcheckbox, couleur automatique)
      (
        zone: (:),
        box: (
          boxsep: 3pt,
          valign: "center",
          halign: "center",
          colback: xmix(_bleu-troyes, 60),
          before-upper: m => [#box(baseline: 15%, rect(
              width: 0.85em,
              height: 0.85em,
              fill: white,
              stroke: 0.7pt + black,
              inset: 0pt,
              if m.br { align(center + horizon, text(fill: red, size: 0.9em, "✘")) },
            ))#h(0.5em)],
        ),
        correction: (colback: red, opacityback: 0.15),
      )
    },
    vertical: (
      zone: (colback: xmix(_bleu-troyes, 60)),
      box: (
        sidebyside-gap: 6pt,
        lefthand-width: 2em,
        lefthand: m => _carre(m),
        halign: "center",
        halign-lower: "justify",
        boxsep: 3pt,
      ),
      correction: (colback: "black!2.5", opacityback: 1),
    ),
  ),
)

// ---------------------------------------------------------------------
// Boston, Millau et BFCours (même famille)
// ---------------------------------------------------------------------

#let _boston = (
  b1: rgb("#e5e5e5"),
  b2: rgb("#fca311"),
)

#let _reponses-boston(zone, box, correction) = (
  horizontal: (zone: zone, box: box, correction: correction),
  vertical: (zone: zone, box: box, correction: correction),
)

#let _boston-format = (
  question: (
    zone: (colback: _boston.b1, opacityback: 1, arc: 3mm, rounded-corners: "north"),
    box: (
      boxsep: 4pt,
      sidebyside-gap: 4pt,
      lefthand-width: 2em,
      lefthand: m => _pastille(str(m.question), opacite: 0.75),
      halign: "center",
      halign-lower: "justify",
    ),
  ),
  answer: _reponses-boston(
    (boxsep: 3pt, opacityback: 1, colback: _boston.b1, arc: 3mm, rounded-corners: "south"),
    (
      colframe: _boston.b2,
      colback: white,
      opacityback: 0.75,
      arc: 3mm,
      boxrule: 0.8pt,
      boxsep: 3pt,
      valign: "center",
      halign: "left",
      before-upper: m => [#mcq-rb(local: (check-color: _boston.b2, checked: m.br))#h(0.5em)],
    ),
    (colback: _boston.b2, opacityback: 0.25),
  ),
)

#let _millau = (m1: rgb("#607D8B"), m2: rgb("#6a8494"), m3: rgb("#2096F3"), m4: rgb("#FF9801"))

#let _millau-format = (
  question: (
    zone: (
      colframe: _millau.m1,
      boxrule: 1pt,
      bottomrule: 0pt,
      colback: _boston.b1,
      opacityback: 0,
      title: m => [Question #m.question],
      toptitle: 2pt,
      bottomtitle: 2pt,
      lefttitle: 2em,
      fonttitle: (font: mcq-sans, weight: "bold"),
      arc: 3mm,
      rounded-corners: "north",
    ),
    box: (boxsep: 5pt, fontupper: (font: mcq-sans)),
  ),
  answer: _reponses-boston(
    (colframe: _millau.m1, boxrule: 1pt, toprule: 0pt, boxsep: 3pt, opacityback: 0, arc: 3mm, rounded-corners: "south"),
    (
      frame-hidden: true,
      colback: _millau.m2,
      opacityback: 0.7,
      coltext: white,
      fontupper: (font: mcq-sans),
      arc: 3mm,
      boxsep: 3pt,
      valign: "center",
      halign: "left",
      before-upper: m => [#mcq-rb(local: (color: white, check-color: _millau.m4, checked: m.br))#h(0.5em)],
    ),
    (colback: _millau.m3, opacityback: 1),
  ),
)

#let _bfcours-format = (
  question: (
    zone: (frame-hidden: true, colback: white, opacityback: 1, boxsep: 0pt, arc: 1.5mm, rounded-corners: "north"),
    box: (
      boxsep: 0pt,
      sidebyside-gap: 3pt,
      lefthand-width: 2em,
      lefthand: m => _pastille(str(m.question), fond: black, texte: white, taille: 1em, diametre: 1.5em),
      halign: "center",
      halign-lower: "justify",
    ),
  ),
  answer: (
    vertical: (
      zone: (
        colframe: black,
        boxrule: 0.4pt,
        toprule: 0pt,
        boxsep: 0pt,
        bottom: 6pt,
        top: 3pt,
        opacityback: 1,
        colback: white,
        arc: 1.5mm,
        rounded-corners: "south",
      ),
      box: (
        colframe: black,
        colback: white,
        opacityback: 0.9,
        arc: 1.5mm,
        boxrule: 0.8pt,
        boxsep: 3pt,
        valign: "center",
        halign: "left",
        before-upper: m => [#mcq-cb(local: (check-color: "red", checked: m.br))#h(0.5em)],
      ),
      correction: (colback: "prop!10", opacityback: 0.2),
    ),
    horizontal: (
      zone: (
        colframe: black,
        boxrule: 0pt,
        bottomrule: 0.4pt,
        boxsep: 0pt,
        bottom: 6pt,
        top: 3pt,
        opacityback: 1,
        colback: white,
        arc: 1.5mm,
        rounded-corners: "south",
      ),
      box: (
        colframe: black,
        colback: white,
        opacityback: 0.9,
        arc: 1.5mm,
        boxrule: 0.8pt,
        boxsep: 3pt,
        valign: "center",
        halign: "center",
        before-upper: m => [#mcq-cb(local: (check-color: "red", checked: m.br))#h(0.5em)],
      ),
      correction: (colback: "prop!10"),
    ),
  ),
)

// ---------------------------------------------------------------------
// Miami (rdmcq.miami.format.tex)
// ---------------------------------------------------------------------

#let _miami = (
  m1: rgb("#2d254f"),
  m4: rgb("#DC8E44"),
  m8: rgb("#FF8F00"),
  m9: rgb("#FFBE00"),
)

/// Forme « miami shape » : bandeau aux extrémités en pointes arrondies (0,9 cm), dégradé vertical.
#let _forme-miami(remplissage, retrait: 0pt) = m => {
  let (l, h) = (m.largeur, m.hauteur)
  let p = 0.9cm
  let k = 0.35cm
  place(top + left, curve(
    fill: remplissage,
    stroke: none,
    curve.move((p, h)),
    curve.cubic((p - k, h), (retrait + k, h / 2), (retrait, h / 2)),
    curve.cubic((retrait + k, h / 2), (p - k, 0pt), (p, 0pt)),
    curve.line((l - p, 0pt)),
    curve.cubic((l - p + k, 0pt), (l - retrait - k, h / 2), (l - retrait, h / 2)),
    curve.cubic((l - retrait - k, h / 2), (l - p + k, h), (l - p, h)),
    curve.close(),
  ))
}

#let _degrade-miami(c) = gradient.linear(c, xmix(c, 70), angle: 90deg)

#let _miami-reponse = (
  left: 0.6cm,
  right: 0.6cm,
  boxsep: 3pt,
  top: 1pt,
  fontupper: (font: mcq-sans),
  coltext: m => if m.br { black } else { white },
  halign: "left",
  valign: "center",
  before-upper: m => text(weight: "bold", fill: if m.br { black } else { _miami.m4 })[#_lettre(m.answer) : ],
  underlay: m => {
    (_forme-miami(_degrade-miami(_miami.m1)))(m)
    place(top + left, dx: 0.55cm - 4pt, dy: m.hauteur / 2 - 1.25pt, polygon(
      fill: white,
      stroke: none,
      (0pt, 1.25pt),
      (2pt, 0pt),
      (4pt, 1.25pt),
      (2pt, 2.5pt),
    ))
  },
)

#let _miami-correction = (
  underlay: m => {
    (_forme-miami(gradient.linear(xmix(_miami.m8, 80, autre: black), _miami.m9, xmix(_miami.m8, 80, autre: black), angle: 90deg), retrait: 2pt))(m)
    place(top + left, dx: 0.55cm - 4pt, dy: m.hauteur / 2 - 1.25pt, polygon(
      fill: white,
      stroke: none,
      (0pt, 1.25pt),
      (2pt, 0pt),
      (4pt, 1.25pt),
      (2pt, 2.5pt),
    ))
  },
)

#let _miami-format = (
  question: (
    zone: (opacityback: 1, frame-hidden: true, underlay: _forme-miami(_degrade-miami(_miami.m1))),
    box: (boxsep: 3pt, left: 0.9cm, right: 0.9cm, top: 1pt, fontupper: (font: mcq-sans), coltext: white, halign: "center"),
  ),
  answer: (
    vertical: (zone: (:), box: _miami-reponse, correction: _miami-correction),
    horizontal: (zone: (:), box: _miami-reponse, correction: _miami-correction),
  ),
)

// ---------------------------------------------------------------------
// Reims (rdmcq.reims.format.tex)
// ---------------------------------------------------------------------

#let _reims = (r1: rgb("#DDCFCF"), r2: rgb("#D0F03C"), r3: rgb("#FCF5EF"), r4: rgb("#BABFC0"))
#let _ombre-reims = (dx: 0pt, dy: 0.5mm, color: xmix(black, 70))

#let _reims-format = (
  answer: (
    vertical: (
      zone: (:),
      box: (
        sidebyside-gap: 6pt,
        lefthand-width: 2em,
        lefthand: m => _carre(m, fond: none, contour: 1pt + white, marque: "✖"),
        halign: "center",
        halign-lower: "justify",
        colback: _reims.r1,
        shadow: _ombre-reims,
        boxsep: 3pt,
      ),
      correction: (colback: _reims.r2),
    ),
    horizontal: (
      zone: (:),
      box: (
        halign: "center",
        valign: "center",
        colback: _reims.r1,
        shadow: _ombre-reims,
        boxsep: 3pt,
        overlay: m => place(top + left, dx: -0.6em, dy: -0.6em, circle(
          radius: 0.6em,
          fill: white,
          stroke: none,
          align(center + horizon, text(
            font: mcq-sans,
            weight: "bold",
            size: mcq-tailles.scriptsize,
            fill: if m.br { _reims.r2 } else { _reims.r1 },
            _lettre(m.answer),
          )),
        )),
      ),
      correction: (colback: _reims.r2),
    ),
  ),
  question: (
    zone: (
      opacityback: 1,
      boxrule: 0pt,
      leftrule: 3pt,
      colframe: _reims.r1,
      colback: _reims.r3,
      shadow: _ombre-reims,
    ),
    box: (
      boxsep: 3pt,
      sidebyside-gap: 7.5pt,
      lefthand-width: 2em,
      lefthand: m => _pastille(str(m.question), fond: _reims.r1, texte: white),
      halign: "center",
      halign-lower: "justify",
    ),
  ),
)

// ---------------------------------------------------------------------
// Melun (rdmcq.melun.format.tex)
// ---------------------------------------------------------------------

#let _melun = (
  me1: rgb("#b5dcd6"),
  me2: rgb("#00ad98"),
  me3: rgb("#007A6C"),
  me4: rgb("#EFDCD2"),
  me5: rgb("#C17752"),
)

#let _titre-melun = (fonttitle: (weight: "bold", size: mcq-tailles.footnotesize), lefttitle: 1em, toptitle: -1pt, bottomtitle: -1pt)

#let _carre-melun(m) = [#box(baseline: 15%, rect(width: 1em, height: 1em, fill: white, stroke: none, inset: 0pt, if m.br {
      align(center + horizon, text(fill: red, "✗"))
    }))#h(0.5em)]

#let _melun-format = (
  question: (
    zone: (
      colback: _melun.me1,
      opacityback: 1,
      colframe: _melun.me2,
      leftrule: 2pt,
      boxsep: 5pt,
      title: m => [Question #m.question],
    )
      + _titre-melun,
    box: (valign: "top", halign: "justify"),
  ),
  answer: (
    horizontal: (
      zone: (:),
      box: (
        boxsep: 3pt,
        valign: "center",
        halign: "center",
        colback: xmix(_melun.me1, 50),
        colframe: _melun.me3,
        title: m => [#_carre-melun(m)Réponse #_lettre(m.answer)],
        fonttitle: (weight: "bold", size: mcq-tailles.footnotesize),
        toptitle: -1pt,
        bottomtitle: -1pt,
      ),
      correction: (colback: _melun.me4, colframe: _melun.me5),
    ),
    vertical: (
      zone: (colback: _melun.me1, boxsep: 5pt),
      box: (
        lefthand-width: 1.5em,
        boxsep: 3pt,
        sidebyside-gap: 6pt,
        colback: _melun.me3,
        colbacklower: xmix(_melun.me1, 50),
        lefthand: m => _carre-melun(m),
        halign: "center",
      ),
      correction: (colbacklower: _melun.me4, colback: _melun.me5),
    ),
  ),
)

// ---------------------------------------------------------------------
// Paris (rdmcq.paris.format.tex)
// ---------------------------------------------------------------------

#let _paris = (
  p1: rgb("#D9D9D9"),
  p2: rgb("#D75436"),
  p3: rgb("#C30005"),
  p4: rgb("#83B5B4"),
  p5: rgb("#F2F2F2"),
  p6: rgb("#0B7492"),
)

#let _tirets-blancs = (paint: white, thickness: 0.7pt, dash: (1.5pt, 1pt))

/// Étiquette « Question n » de Paris, posée en haut à gauche et débordant de 1,5 mm.
#let _etiquette-paris = m => {
  let t = text(font: mcq-sans, weight: "bold", size: mcq-tailles.scriptsize, fill: white)[Question #m.question]
  place(top + left, dx: 0.35cm - 1mm, dy: -1.5mm, polygon(fill: _paris.p3, stroke: none, (0pt, 1mm), (1mm, 0pt), (1mm, 2.5mm)))
  place(top + left, dx: 0.35cm, dy: -1.5mm, box(fill: _paris.p2, radius: (right: 1mm, bottom-left: 1mm), inset: (x: 4pt, y: 2pt), t))
}

/// Partie gauche des réponses de Paris : fond de cadre, encoche (arc) et liseré en tirets.
#let _gauche-paris(largeur-gauche) = m => {
  let x = 3pt + largeur-gauche + 3pt
  let r = 0.2886 * m.hauteur
  place(top + left, rect(width: x, height: m.hauteur, fill: if m.br { _paris.p6 } else { _paris.p4 }, stroke: none))
  place(top + left, dx: x - r / 2, dy: m.hauteur / 2 - r, circle(radius: r, fill: _paris.p5, stroke: none))
  place(top + left, dx: 2pt, dy: 2pt, rect(
    width: x - 2pt,
    height: m.hauteur - 4pt,
    radius: (left: 2mm - 1pt),
    stroke: (left: _tirets-blancs, top: _tirets-blancs, bottom: _tirets-blancs),
  ))
}

#let _reponse-paris = (
  lefthand-width: 2cm,
  sidebyside-gap: 6pt,
  boxsep: 3pt,
  valign: "center",
  halign: "center",
  halign-lower: "left",
  colback: _paris.p5,
  arc: 2mm - 1pt,
  rounded-corners: "west",
  boxrule: 0pt,
  leftrule: 2pt,
  rightrule: 2pt,
  colframe: _paris.p4,
  collower: black,
  lefthand: m => text(font: mcq-sans, weight: "bold", size: mcq-tailles.scriptsize, fill: white)[Réponse #_lettre(m.answer)],
  fontlower: (font: mcq-sans),
  underlay: _gauche-paris(2cm),
)

#let _paris-format = (
  question: (
    zone: (colback: _paris.p1, frame-hidden: true, opacityback: 1, boxsep: 5pt, top: 1mm, overlay: _etiquette-paris),
    box: (valign: "top", halign: "justify", fontupper: (font: mcq-sans), before-upper: h(2.5cm)),
  ),
  answer: (
    horizontal: (zone: (:), box: _reponse-paris, correction: (colframe: _paris.p6)),
    vertical: (zone: (:), box: _reponse-paris, correction: (colframe: _paris.p6)),
  ),
)

// ---------------------------------------------------------------------
// Registre des formats partiels
// ---------------------------------------------------------------------

#let _troyes-format = _troyes("Troyes", black, 2em)
#let _tokyo-format = _troyes("Tokyo", _bleu-troyes, 1.2em)

#let _tous = (
  default: _default,
  Troyes: _troyes-format,
  Tokyo: _tokyo-format,
  Boston: _boston-format,
  Miami: _miami-format,
  Reims: _reims-format,
  Millau: _millau-format,
  Melun: _melun-format,
  Paris: _paris-format,
  BFCours: _bfcours-format,
)

/// Formats partiels prédéfinis (question, answer), par nom. Une partie absente d'un format reprend celle
/// de `default`.
#let mcq-formats-predefinis = {
  let res = (question: (:), answer: (:))
  for (nom, f) in _tous {
    for partie in res.keys() {
      let v = f.at(partie, default: none)
      if v == none {
        v = _default.at(partie)
      }
      res.at(partie).insert(nom, v)
    }
  }
  res
}

/// État des formats partiels : prédéfinis + ceux créés par \newQuestionFormat, \newAnswerFormat…
#let bf-mcq-formats = state("bf-mcq-formats", mcq-formats-predefinis)

/// Formats globaux prédéfinis (\newMcqFormat[…]{nom}{boxrule}) : réglages \setrdmcq de chaque format.
/// Chacun devient un style nommé du registre de \setrdmcq, appelé par `style: "Boston"`.
#let mcq-formats-globaux = {
  let gather(n) = (
    question-format: n,
    answer-format: n,
  )
  (
    default: gather("default") + (column-sep: 0pt, row-sep: 0pt, boxrule: 0.6pt),
    Troyes: gather("Troyes") + (every-odd-question-zone: (colback: "tcbcolback!60"), every-odd-answer-zone: (colback: "tcbcolback!60"), every-odd-answer: (colback: "tcbcolback!60"), column-sep: 1.5pt, row-sep: 1.5pt, boxrule: 0pt),
    Tokyo: gather("Tokyo") + (every-odd-question-zone: (colback: "tcbcolback!60"), every-odd-answer-zone: (colback: "tcbcolback!60"), every-odd-answer: (colback: "tcbcolback!60"), column-sep: 1.5pt, row-sep: 1.5pt, boxrule: 0pt),
    Boston: gather("Boston") + (same-width: true, row-sep: 1em, question-answer-sep: -0.1pt, answer-columns: 2, answer-column-sep: 1em, answer-row-sep: 0.5em, boxrule: 0pt),
    Miami: gather("Miami") + (row-sep: 0.5em, answer-columns: 2, answer-row-sep: 0.5em, same-width: true, orientation: "vertical", boxrule: 1pt),
    Reims: gather("Reims") + (column-sep: 1em, row-sep: 1em, answer-row-sep: 0.5em, boxrule: 0pt),
    Millau: gather("Millau") + (same-width: true, row-sep: 1em, question-answer-sep: -0.1pt, answer-columns: 2, answer-column-sep: 1em, answer-row-sep: 0.5em, boxrule: 0pt),
    Melun: gather("Melun") + (column-sep: 4pt, answer-column-sep: 4pt, row-sep: 4pt, answer-row-sep: 4pt, boxrule: 0pt),
    Paris: gather("Paris") + (same-width: true, column-sep: 4pt, answer-columns: 2, answer-column-sep: 4pt, row-sep: 4pt, answer-row-sep: 4pt, boxrule: 0pt),
    BFCours: gather("BFCours") + (same-width: true, row-sep: 1em, question-answer-sep: -0.1pt, answer-columns: 2, answer-column-sep: 1em, answer-row-sep: 0.3em, boxrule: 0pt),
  )
}
