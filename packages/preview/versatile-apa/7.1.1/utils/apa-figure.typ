#import "languages.typ": *
#import "to-string.typ": *

#let apa-figure(
  body,
  caption: none,
  gap: 1.5em,
  kind: auto,
  numbering: "1",
  outlined: true,
  placement: none,
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
        #emph(get-terms(text.lang).Note).
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
