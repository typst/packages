#let codetion(
  mono-font: "Cascadia Code",
  bg-color: rgb("#F1F1EF"),
  text-color: rgb("#373530"),
  doc,
) = {
  show raw: set text(font: mono-font)

  // Block code
  show raw.where(block: true): code-content => block(
    width: 100%,
    fill: bg-color,
    radius: 0.6em,
    inset: (x: 1.85em, top: 1.8em, bottom: 1.8em),
  )[
    #text(fill: text-color)[
      #code-content
    ]
  ]

  // Inline code
  show raw.where(block: false): code-inline => box(
    inset: (x: 0.4em, y: 0.1em),
    outset: (y: 0.4em),
    fill: bg-color,
    radius: 0.2em,
  )[
    #text(fill: text-color)[
      #code-inline
    ]
  ]

  doc
}
