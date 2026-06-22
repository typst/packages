// ============================================================
//  Template : cours de révision illustré  —  VARIANTE ATELIER
//  Usage : voir main.typ
//  Différences avec l'original :
//    1. La case à cocher de #qcm-q est dessinée (plus de glyphe ☐
//       → zéro substitution de police, zéro avertissement sur typst.app)
//    2. Ajout d'un encart #atelier[...] pour baliser les zones
//       « à construire pendant l'atelier »
// ============================================================

// ─── PALETTE PAR DÉFAUT ─────────────────────────────────────
// Réutilisable par l'utilisateur via `import "template.typ": *`
#let c-blue         = rgb("#1e40af")
#let c-blue-light   = rgb("#dbe4ff")
#let c-blue-dark    = rgb("#1e3a8a")
#let c-blue-accent  = rgb("#4a9eed")
#let c-amber        = rgb("#a16207")
#let c-amber-bg     = rgb("#fff3bf")
#let c-amber-strong = rgb("#f59e0b")
#let c-red          = rgb("#991b1b")
#let c-red-bg       = rgb("#fecaca")
#let c-red-strong   = rgb("#dc2626")
#let c-green        = rgb("#166534")
#let c-green-bg     = rgb("#d3f9d8")
#let c-green-strong = rgb("#22c55e")
#let c-pink         = rgb("#9d174d")
#let c-pink-bg      = rgb("#fce7f3")
#let c-pink-strong  = rgb("#ec4899")
#let c-orange       = rgb("#92400e")
#let c-orange-bg    = rgb("#ffd8a8")
#let c-purple       = rgb("#4338ca")
#let c-purple-bg    = rgb("#e9d5ff")
#let c-gray         = rgb("#475569")
#let c-gray-light   = rgb("#cbd5e1")
#let c-teal         = rgb("#0f766e")  // NOUVEAU — pour l'encart atelier
#let c-teal-bg      = rgb("#ccfbf1")  // NOUVEAU

// ─── ENCARTS COLORÉS ────────────────────────────────────────
#let callout(color, bg, label, body) = block(
  fill: bg,
  stroke: (left: 4pt + color),
  inset: (x: 12pt, y: 9pt),
  radius: 3pt,
  width: 100%,
  spacing: 1.1em,
)[
  #if label != none [
    #text(font: "DejaVu Sans", size: 9pt, fill: color, weight: "bold")[#upper(label)]
    #linebreak()
  ]
  #body
]

#let def(body)     = callout(c-blue,         c-blue-light, "Définition", body)
#let key(body)     = callout(c-amber-strong, c-amber-bg,   "À retenir",  body)
#let warn(body)    = callout(c-red-strong,   c-red-bg,     "Attention",  body)
#let ex(body)      = callout(c-green-strong, c-green-bg,   "Exemple concret", body)
#let analogy(body) = callout(c-pink-strong,  c-pink-bg,    "Analogie",   text(style: "italic", body))
#let keyhint(body) = callout(c-purple,       c-purple-bg,  "Clé de compréhension", body)
// NOUVEAU — balise les parties à compléter avec l'IA pendant l'atelier
#let atelier(body) = callout(c-teal,         c-teal-bg,    "À construire en atelier", body)

// ─── SCHÉMA AVEC LÉGENDE ────────────────────────────────────
// `img` est un contenu image déjà construit (#image(...)).
// On NE prend plus un chemin : un package ne peut pas résoudre
// les chemins relatifs à l'appelant.
#let schema(img, caption, breakpage: true) = {
  if breakpage { pagebreak(weak: true) }
  block(width: 100%)[
    #align(center)[#img]
    #v(4pt)
    #align(center)[
      #text(size: 9pt, fill: c-gray, style: "italic")[#caption]
    ]
  ]
}


// ─── En-tête de tableau coloré ──────────────────────────────
#let head(..cells) = table.header(
  ..cells.pos().map(c => table.cell(
    fill: c-blue,
  )[#text(fill: white, weight: "bold", font: "DejaVu Sans")[#c]])
)

// ─── CELLULE DE CATÉGORIE POUR TABLEAUX ─────────────────────
#let cat-cell(body) = table.cell(
  fill: c-orange-bg,
)[#text(font: "DejaVu Sans", weight: "bold", fill: c-orange)[#body]]

// ─── BLOC DE QUESTION POUR AUTO-TEST ────────────────────────
// La case à cocher est DESSINÉE (et non le glyphe ☐) pour éviter
// toute substitution de police sur typst.app.
#let checkbox = box(width: 0.75em, height: 0.75em, radius: 1pt,
  stroke: 0.7pt + c-gray, baseline: 0.05em)

#let qcm-q(num, question, options: none, lines: 0) = block(
  fill: rgb("#f8fafc"),
  stroke: (left: 4pt + c-purple),
  inset: (x: 12pt, y: 8pt),
  radius: 3pt,
  width: 100%,
  spacing: 1em,
)[
  *#text(fill: c-purple, font: "DejaVu Sans")[Q#num.]* #question
  #if options != none {
    list(..options.map(o => [#checkbox #o]))
  }
  #if lines > 0 {
    for _ in range(lines) [
      #v(2pt)
      #line(length: 100%, stroke: (paint: rgb("#94a3b8"), thickness: 0.5pt, dash: "dotted"))
    ]
  }
]

// ─── PAGE DE COUVERTURE ─────────────────────────────────────
#let cover-page(
  eyebrow: none,
  title: none,
  subtitle: none,
  metadata: none,
  background: none,     // contenu image déjà construit (#image(...)), ou none
  eyebrow-color: none,
  title-color: none,
  subtitle-color: none,
  metadata-color: none,
) = {
  let _eyebrow-color  = if eyebrow-color  != none { eyebrow-color }  else { c-amber-strong }
  let _title-color    = if title-color    != none { title-color }    else { c-blue-dark }
  let _subtitle-color = if subtitle-color != none { subtitle-color } else { c-blue-dark }
  let _metadata-color = if metadata-color != none { metadata-color } else { c-gray }

  set page(margin: 0pt, numbering: none)

  if background != none {
    place(top + left)[
      #background
    ]
  }

  // Dégradé blanc en haut pour la lisibilité du titre
  place(top + left)[
    #rect(
      width: 100%,
      height: 150pt,
      fill: gradient.linear(
        white,
        white.transparentize(25%),
        white.transparentize(100%),
        angle: 180deg,
      ),
      stroke: none,
    )
  ]

  if eyebrow != none {
    place(top + center, dy: 35pt)[
      #text(
        font: "DejaVu Sans",
        size: 13pt,
        fill: _eyebrow-color,
        tracking: 4pt,
        weight: "bold",
      )[#eyebrow]
    ]
  }

  if title != none {
    place(top + center, dy: 62pt)[
      #block(width: 85%)[
        #align(center)[
          #text(
            font: "DejaVu Sans",
            size: 30pt,
            fill: _title-color,
            weight: "bold",
          )[#title]
        ]
      ]
    ]
  }

  // Dégradé blanc en bas
  place(bottom + left)[
    #rect(
      width: 100%,
      height: 110pt,
      fill: gradient.linear(
        white.transparentize(100%),
        white.transparentize(25%),
        white,
        angle: 180deg,
      ),
      stroke: none,
    )
  ]

  if subtitle != none {
    place(bottom + center, dy: -55pt)[
      #text(
        font: "DejaVu Sans",
        size: 13pt,
        fill: _subtitle-color,
        style: "italic",
      )[#subtitle]
    ]
  }

  if metadata != none {
    place(bottom + center, dy: -28pt)[
      #text(
        font: "DejaVu Sans",
        size: 9pt,
        fill: _metadata-color,
      )[#metadata]
    ]
  }
}

// ─── PAGE DE SOMMAIRE ───────────────────────────────────────
#let toc-page(title: "Sommaire", title-color: none) = {
  let _color = if title-color != none { title-color } else { c-blue-dark }

  set page(
    paper: "a4",
    margin: (top: 25mm, bottom: 22mm, left: 18mm, right: 18mm),
    numbering: none,
  )

  v(15pt)
  align(center)[
    #text(font: "DejaVu Sans", size: 28pt, fill: _color, weight: "bold")[#title]
  ]
  v(6pt)
  align(center)[
    #line(length: 60pt, stroke: 2pt + c-blue-accent)
  ]
  v(30pt)

  show outline.entry: it => block(below: 14pt)[
    #set text(font: "DejaVu Sans", size: 12pt)
    #it
  ]

  outline(
    title: none,
    indent: 0pt,
    depth: 1,
  )
}

// ─── Petit helper local pour montrer code + rendu ───────────
// (uniquement utilisé dans le tutoriel)
#let code-example(code, body) = {
  v(4pt)
  grid(
    columns: (1fr, 1fr),
    gutter: 10pt,
    block(
      fill: rgb("#f1f5f9"),
      stroke: 0.5pt + c-gray-light,
      inset: 8pt,
      radius: 3pt,
      width: 100%,
    )[
      #set text(font: "DejaVu Sans Mono", size: 8.5pt)
      #code
    ],
    block(
      fill: white,
      stroke: 0.5pt + c-gray-light,
      inset: 8pt,
      radius: 3pt,
      width: 100%,
    )[#body],
  )
  v(4pt)
}

// ─── TEMPLATE PRINCIPAL ─────────────────────────────────────
#let course-template(
  // Métadonnées du document
  title: "Document",
  author: "",

  // Couverture
  eyebrow: none,
  cover-title: none,
  cover-subtitle: none,
  cover-metadata: none,
  cover-background: none,

  // Sommaire
  show-toc: true,
  toc-title: "Sommaire",

  // Mise en page du corps
  body-font: "DejaVu Serif",
  body-size: 11pt,
  heading-font: "DejaVu Sans",
  lang: "fr",
  margin: (top: 18mm, bottom: 22mm, left: 18mm, right: 18mm),

  body,
) = {
  // ── Métadonnées du document ──
  set document(title: title, author: author)

  // ── Réglages globaux ──
  set page(
    paper: "a4",
    margin: margin,
    numbering: "1 / 1",
    number-align: center,
  )

  set text(
    font: body-font,
    size: body-size,
    lang: lang,
    hyphenate: true,
  )

  set par(
    justify: true,
    leading: 0.7em,
    first-line-indent: 0pt,
  )

  set heading(numbering: (..nums) => {
    let n = nums.pos()
    if n.len() == 1 {
      [#numbering("I", n.at(0))]
    } else {
      numbering("1.1", ..n.slice(1))
    }
  })

  // ── Styles des titres ──
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    set text(font: heading-font, size: 20pt, fill: c-blue-dark, weight: "bold")
    block(below: 8pt)[#it]
    line(length: 100%, stroke: 2.5pt + c-blue-accent)
    v(8pt)
  }

  show heading.where(level: 2): it => {
    set text(font: heading-font, size: 14pt, fill: c-blue, weight: "bold")
    v(10pt)
    block(
      inset: (left: 10pt),
      stroke: (left: 4pt + c-blue-accent),
    )[#it]
    v(4pt)
  }

  show heading.where(level: 3): it => {
    set text(font: heading-font, size: 12pt, fill: rgb("#2563eb"), weight: "bold")
    v(6pt)
    block[#it]
  }

  // ── Couverture ──
  if cover-title != none or cover-background != none {
    cover-page(
      eyebrow: eyebrow,
      title: cover-title,
      subtitle: cover-subtitle,
      metadata: cover-metadata,
      background: cover-background,
    )
  }

  // ── Sommaire ──
  if show-toc {
    toc-page(title: toc-title)
  }

  // ── Corps du document ──
  set page(numbering: "1 / 1")
  counter(page).update(1)

  body
}
