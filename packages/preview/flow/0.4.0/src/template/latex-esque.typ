#import "common.typ": *
#import "generic.typ": generic

#let _prelude(body, args) = {
  let (data, title) = _shared(args)

  let title = text(2em, strong(title))

  let extra = data
    .pairs()
    .filter(((key, value)) => key != "title")
    .map(((key, value)) => (
      (upper(key.at(0)) + key.slice(1)).replace(
        "Cw",
        "Content warning",
      ),
      if type(value) in (str, int, float, content) {
        value
      } else if type(value) == array {
        value.join([, ], last: [ and ])
      } else if type(value) == dictionary {
        value.keys().join[, ]
      } else {
        repr(value)
      },
    ).join[: ])
    .join[\ ]

  align(center, {
    title
    [\ ]
    v(0.25em)
    extra
  })

  outline()
}

#let latex-esque(body, ..args) = {
  set text(font: "New Computer Modern", size: 12pt)
  show raw: set text(font: "FiraCode Nerd Font Mono")

  show: generic.with(..args)

  set par(justify: true)
  set outline(title: [Table of contents], fill: repeat[.])

  (_maybe-stub(_prelude))(data, args)
  body
}
