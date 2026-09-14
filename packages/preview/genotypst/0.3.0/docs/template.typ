#import "../src/constants.typ": (
  _medium-gray, aa-palette-default, dna-palette, rna-palette,
)

#let project(
  title: "",
  author: "",
  body,
) = {
  set document(author: author, title: title)
  set page(
    margin: (y: 2.8cm, x: 2.8cm),
    paper: "us-letter",
  )

  set text(font: "Source Sans 3", size: 10.8pt)
  show raw: set text(font: "Source Code Pro", size: 9pt)
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
    fill: oklch(96.5%, 0.005, 269deg),
    inset: 10pt,
    radius: 4pt,
    width: 100%,
    breakable: false,
  )

  // Title
  align(left)[
    #set par(justify: false)
    #text(size: 19.5pt, title)
  ]

  body
}

#let aa-groups = (
  (
    name: "Hydrophobic",
    symbols: ("A", "H", "I", "L", "M", "V"),
    names: (
      "Alanine",
      "Histidine",
      "Isoleucine",
      "Leucine",
      "Methionine",
      "Valine",
    ),
    abbrevs: ("Ala", "His", "Ile", "Leu", "Met", "Val"),
  ),
  (
    name: "Polar",
    symbols: ("S", "T", "Q", "N"),
    names: ("Serine", "Threonine", "Glutamine", "Asparagine"),
    abbrevs: ("Ser", "Thr", "Gln", "Asn"),
  ),
  (
    name: "Aromatic",
    symbols: ("F", "W", "Y"),
    names: ("Phenylalanine", "Tryptophan", "Tyrosine"),
    abbrevs: ("Phe", "Trp", "Tyr"),
  ),
  (
    name: "Negatively charged",
    symbols: ("D", "E"),
    names: ("Aspartic acid", "Glutamic acid"),
    abbrevs: ("Asp", "Glu"),
  ),
  (
    name: "Positively charged",
    symbols: ("K", "R"),
    names: ("Lysine", "Arginine"),
    abbrevs: ("Lys", "Arg"),
  ),
  (name: "Cysteine", symbols: ("C",), names: ("Cysteine",), abbrevs: ("Cys",)),
  (name: "Glycine", symbols: ("G",), names: ("Glycine",), abbrevs: ("Gly",)),
  (name: "Proline", symbols: ("P",), names: ("Proline",), abbrevs: ("Pro",)),
)

#let dna-rna-groups = (
  (
    name: "DNA palette",
    symbols: ("A", "C", "G", "T"),
    names: ("Adenine", "Cytosine", "Guanine", "Thymine"),
    palette: dna-palette,
  ),
  (
    name: "RNA palette",
    symbols: ("A", "C", "G", "U"),
    names: ("Adenine", "Cytosine", "Guanine", "Uracil"),
    palette: rna-palette,
  ),
)

#let swatch(clr) = box(
  width: 45pt,
  fill: clr,
  radius: 10pt,
  outset: (y: 3.3pt),
  align(center, text(
    font: "Source Code Pro",
    size: 8pt,
    weight: "semibold",
    fill: white.transparentize(30%),
    clr.to-hex(),
  )),
)

#let render-palette-group(group, palette: aa-palette-default) = block(
  breakable: false,
  {
    let has-abbrevs = "abbrevs" in group
    let p = group.at("palette", default: palette)
    let clr = p.at(group.symbols.at(0))
    stack(
      spacing: 5pt,
      context box(text(
        weight: "bold",
        fill: if has-abbrevs { clr } else { text.fill },
        group.name,
      )),
      table(
        columns: if has-abbrevs { (80pt, 35pt, 25pt, 50pt) } else {
          (115pt, 25pt, 50pt)
        },
        column-gutter: 0pt,
        stroke: none,
        inset: (y: 4pt, x: 0pt),
        align: horizon,
        ..range(group.symbols.len())
          .map(i => (
            group.names.at(i),
            ..if has-abbrevs { (group.abbrevs.at(i),) } else { () },
            group.symbols.at(i),
            swatch(p.at(group.symbols.at(i))),
          ))
          .flatten()
      ),
    )
  },
)
