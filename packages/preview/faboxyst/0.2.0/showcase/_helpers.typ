// Shared helpers for the faboxyst parameter showcase.
#import "@preview/faboxyst:0.2.0": *

#let ar-sample = [هذا صندوق تجريبي مع عنوان واضح.]
#let en-sample = [This is a sample box with a short body.]
#let ar-title = [عنوان]
#let en-title = [Title]

#let kbd(s) = box(
  fill: luma(245),
  stroke: 0.4pt + luma(180),
  inset: (x: 4pt, y: 2pt),
  radius: 2pt,
  text(size: 8pt, font: "DejaVu Sans Mono", s),
)

#let cmd-title(name) = {
  set text(font: "DejaVu Sans", weight: "bold", size: 18pt)
  block(below: 6pt)[#name]
}

#let sig(body) = {
  set text(size: 7.2pt, font: "DejaVu Sans Mono")
  block(
    width: 100%,
    fill: rgb("#F6F3EA"),
    stroke: 0.5pt + rgb("#D4C9A8"),
    inset: 8pt,
    radius: 4pt,
    body,
  )
}

#let note-line(body) = text(size: 8.5pt, fill: luma(50), body)

#let snippet(code) = {
  set text(size: 6.6pt, font: "DejaVu Sans Mono")
  block(
    width: 100%,
    fill: rgb("#EEF3FA"),
    stroke: 0.4pt + rgb("#B8C7DC"),
    inset: (x: 6pt, y: 4pt),
    radius: 3pt,
    below: 4pt,
    text(font: "DejaVu Sans Mono", code),
  )
}

#let pair(cap-a, a, cap-b, b) = {
  grid(
    columns: (1fr, 1fr),
    gutter: 10pt,
    {
      note-line(cap-a)
      v(3pt)
      a
    },
    {
      note-line(cap-b)
      v(3pt)
      b
    },
  )
}

#let trio(items) = {
  grid(
    columns: (1fr,) * items.len(),
    gutter: 8pt,
    ..items.map(it => {
      note-line(it.at(0))
      v(3pt)
      it.at(1)
    }),
  )
}

// Western (occidental) digits even in RTL: keep `lang: "en"` so Typst
// does not remap 0–9 to Eastern Arabic-Indic. Direction still RTL.
#let ltr-box(body) = {
  set text(lang: "en", dir: ltr, font: "DejaVu Sans", size: 9pt)
  body
}
#let rtl-box(body) = {
  set text(lang: "en", dir: rtl, font: "DejaVu Sans", size: 9pt)
  body
}

#let dir-pair(ltr, rtl) = pair(
  [LTR  ·  English],
  ltr-box(ltr),
  [RTL  ·  العربية  ·  0123456789],
  rtl-box(rtl),
)

#let param-row(label, ltr, rtl, code: none) = {
  block(below: 10pt)[
    #text(size: 9pt, weight: "bold", fill: rgb("#1F3A68"), label)
    #if code != none { snippet(code) }
    #v(3pt)
    #dir-pair(ltr, rtl)
  ]
}
