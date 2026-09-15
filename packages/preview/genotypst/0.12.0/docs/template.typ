#import "../src/common/colors.typ": _medium-gray
#import "../src/sequence/residue_palette.typ": residue-palette

#let project(
  title: "",
  author: "",
  body,
) = {
  set document(author: author, title: title, date: none)
  set page(
    margin: (y: 2.6cm, x: 2.55cm),
    paper: "us-letter",
  )

  set text(font: "Source Sans 3", size: 10.8pt)
  show raw: set text(font: "Source Code Pro", size: 9.6pt)
  show link: set text(fill: rgb("4B69BE"))
  set par(
    justify: true,
    justification-limits: (
      tracking: (min: -0.012em, max: 0.012em),
      spacing: (min: 70%, max: 130%),
    ),
    leading: 0.67em,
  )

  show heading.where(level: 1): it => {
    set text(size: 16pt)
    set block(below: 0.8em)
    block(it)
  }

  show heading.where(level: 2): it => {
    set block(below: 0.8em)
    block(it)
  }

  show figure.caption: it => {
    set text(fill: _medium-gray)
    v(0.4em)
    strong(it.supplement)
    if it.numbering != none and it.supplement != none {
      text(weight: "bold")[ #context it.counter.display(it.numbering). ]
    }
    it.body
    v(0.9em)
  }

  show raw.where(block: true): block.with(
    fill: oklch(96.5%, 0.003, 269deg),
    inset: 10pt,
    radius: 4pt,
    width: 100%,
    breakable: false,
  )

  align(left)[
    #set par(justify: false)
    #text(size: 19.5pt, title)
  ]

  body
}

#let aa-residues = (
  "A",
  "C",
  "D",
  "E",
  "F",
  "G",
  "H",
  "I",
  "K",
  "L",
  "M",
  "N",
  "P",
  "Q",
  "R",
  "S",
  "T",
  "V",
  "W",
  "Y",
)
#let nt-residues = ("A", "C", "G", "T", "U")

#let aa-palettes = residue-palette.aa.pairs()
#let nt-palettes = residue-palette.dna.pairs()

#let _ink-on(fill) = if oklab(fill).components(alpha: false).at(0) < 70% {
  fill.lighten(80%)
} else {
  fill.darken(55%)
}

#let _render-group-box(group) = box(
  width: 100%,
  height: 0.48cm,
  fill: group.color,
  radius: 2.5pt,
  grid(
    columns: group.symbols.map(_ => (1fr, auto)).flatten() + (1fr,),
    rows: 100%,
    align: horizon,
    ..group
      .symbols
      .map(symbol => (
        [],
        text(
          font: "Source Code Pro",
          size: 0.85em,
          weight: "semibold",
          fill: _ink-on(group.color),
          symbol,
        ),
      ))
      .flatten()
      + ([],),
  ),
)

#let _render-palette-row(residues, all-colors, palette) = {
  let groups = all-colors
    .map(color => (
      color: color,
      symbols: residues.filter(residue => (
        palette.at(residue).to-hex() == color.to-hex()
      )),
    ))
    .filter(group => group.symbols.len() > 0)

  grid(
    columns: residues.map(_ => 0.48cm),
    column-gutter: 0.13cm,
    align: center + horizon,
    ..groups.map(group => grid.cell(
      colspan: group.symbols.len(),
      _render-group-box(group),
    )),
  )
}

#let render-residue-palettes(residues, palettes) = {
  let all-colors = ()
  for (_, palette) in palettes {
    for residue in residues {
      let color = palette.at(residue)
      if (
        all-colors.position(existing => existing.to-hex() == color.to-hex())
          == none
      ) {
        all-colors.push(color)
      }
    }
  }

  block(
    breakable: false,
    grid(
      columns: (auto, auto),
      align: (right + horizon, left + horizon),
      column-gutter: 0.26cm,
      row-gutter: 0.13cm,
      ..palettes
        .map(((name, palette)) => (
          grid.cell(align: right + horizon, text(size: 0.875em)[#name]),
          grid.cell(_render-palette-row(residues, all-colors, palette)),
        ))
        .flatten(),
    ),
  )
}
