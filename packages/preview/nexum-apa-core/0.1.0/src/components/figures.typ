// Accessible, in-flow APA figure and table wrappers.
#let apa-note(body) = block(width: 100%)[
  #set par(first-line-indent: 0pt, leading: 1em, spacing: 0pt)
  #text(size: 10pt)[#emph[Nota.] #body]
]

#let apa-figure(
  body,
  title: none,
  note: none,
  alt: none,
  placement: none,
) = {
  assert(title != none, message: "apa-figure requires a title.")
  figure(
    block(width: 100%)[
      #align(center)[#body]
      #if note != none [#v(0.25em) #apa-note(note)]
    ],
    kind: image,
    caption: title,
    alt: alt,
    placement: placement,
  )
}

#let apa-table(
  body,
  title: none,
  note: none,
  placement: none,
) = {
  assert(title != none, message: "apa-table requires a title.")
  figure(
    block(width: 100%)[
      #body
      #if note != none [#v(0.25em) #apa-note(note)]
    ],
    kind: table,
    caption: title,
    placement: placement,
  )
}
