#import "@preview/ctheorems:1.1.3": thmrules

#let quote-box(cite: none, body) = [
  #set text(size: 0.97em)
  #pad(left: 1.5em)[
    #block(
      breakable: true,
      width: 100%,
      fill: gray.lighten(95%),
      radius: (left: 0pt, right: 5pt),
      stroke: (left: 5pt + gray, rest: 1pt + silver.lighten(50%)),
      inset: 1em,
    )[#body]
  ]
]

#let indent(body) = [
  #block(
    width: 90%,
    inset: (left: 1.5em),
    [ #body ],
  )
]

#let smash(body, side: center) = math.display(
  box(
    width: 0pt,
    align(
      side.inv(),
      box(width: float.inf * 1pt, $ script(body) $),
    ),
  ),
)

#let maketitle(title, subtitle: "", position: center) = [
  #align(position)[
    #text(22pt, weight: "bold")[#title]
    #if subtitle != "" [
      \ #text(13pt, style: "italic")[#subtitle]
    ]
  ]
]

#let horizontalrule(color: gray, dashed: false) = {
  line(
    length: 100%,
    stroke: (
      paint: color,
      thickness: 1pt,
      dash: if dashed { ("dot", 2pt, 4pt, 2pt) } else { none },
    ),
  )
}

#let mathbox(content, higher: false) = {
  box(
    stroke: 0.5pt,
    inset: (x: 6pt, y: 3pt),
    outset: (x: 2pt, y: if higher { 8pt } else { 4pt }),
    if higher { $display(#content)$ } else { $#content$ },
  )
}

#let mathnote(content) = align(center)[(#content)]

#let set_min_config(
  title: "",
  subtitle: "",
  text_lang: "en",
  text_font: ("Charter", "XCharter", "Libertinus Serif", "Linux Libertine", "Source Serif 4", "Georgia", "serif"),
  code_font: ("IoskeleyMono Nerd Font", "MonoLisa", "JetBrains Mono", "Fira Code", "Cascadia Code", "monospace"),
  math_font: ("Erewhon Math", "Libertinus Math", "STIX Two Math", "New Computer Modern Math", "Cambria Math", "serif"),
  font_size: 11.5pt,
  list_numbering: "1.a.i.",
  paragraph_indent: 1em,
  body,
) = {
  show: thmrules
  set text(lang: text_lang, size: font_size, font: text_font)
  show math.equation: set text(font: math_font)
  show raw: set text(font: code_font)
  set enum(numbering: list_numbering)
  set par(linebreaks: "optimized", first-line-indent: paragraph_indent)

  if title != "" {
    set document(title: title)
    maketitle(title, subtitle: subtitle)
  }

  body
}

