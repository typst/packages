#import "languages.typ": *
#import "to-string.typ": *

#let apa-figure-numbering(n) = {
  let header-counter = counter(heading).get().first()
  let queried-heading = query(selector(heading).before(here())).last().numbering
  if queried-heading == none {
    queried-heading = "A"
  }
  if header-counter == 0 {
    numbering("1", n)
  } else {
    numbering(queried-heading + "1", header-counter, n)
  }
}

#let apa-figure(
  body,
  caption: none,
  gap: 1.5em,
  kind: auto,
  numbering: n => apa-figure-numbering(n),
  outlined: true,
  placement: auto,
  scope: "column",
  supplement: auto,
  note: none,
  specific-note: none,
  probability-note: none,
  label: "",
) = context [
  #figure(
    [
      #set par(first-line-indent: 0em)
      #body
      #set align(left)
      #if note != none [
        _#get-terms(text.lang).Note._
        #note
      ]
      #parbreak()
      #specific-note
      #parbreak()
      #probability-note
    ],
    caption: caption,
    gap: gap,
    kind: kind,
    numbering: numbering,
    outlined: outlined,
    placement: placement,
    scope: scope,
    supplement: supplement,
  ) #std.label(label)
]
