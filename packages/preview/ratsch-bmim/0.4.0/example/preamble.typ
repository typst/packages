#import "@preview/ratsch-bmim:0.4.0" as bmim: task, enum-label, wrapped-enum-numbering, backmatter, abstract, poster-box, translatedMonth

// own titleblock
#let tb(args) = context {
  let course = if type(args.course) == array { args.course.at(0) } else { args.course }
  set align(center)
  rect(
    width: 100%,
    inset: (top: 0.2em, bottom: 0.2em, left: 0.2em, right: 0.2em),
    stroke: 1pt,
    rect(
      width: 100%,
      inset: (top: 1em, bottom: 1em),
      stroke: (paint: black.lighten(20%), thickness: 1.3pt),
      strong[
        Labor \
        #sym.hyph \
        #course \
        #line(length: 95%)
        #if type(args.title) == array {
          args.title.at(0)
          linebreak()
          args.title.at(1)
        } else {
          args.title
        }
      ]
    )
  )
  grid(
    columns: 2,
    gutter: 0.75em,
    align: (right, left),
    [
      #if args.show-solution != none {
        set text(bmim.color.red)
        strong[
          #args.spell.with #args.spell.sol,
        ]
      }
      #args.spell.ho:
    ],
    grid(
      row-gutter: 0.5em,
      ..args.authors.map(author => text(author)),
    ),
    [
      #args.spell.lc:
    ],
    [
      #args.date.day(). #translatedMonth(args.date, args.lang) #args.date.year()
    ],
  )
}

// various environments
#import "@preview/touying:0.7.4": *
#import "@preview/theorion:0.6.0": *
#import cosmos.clouds: *

// own admonition block
#let adm-render(
  border: bmim.color-cd2026.blue,
  prefix: none,
  title: "",
  full-title: auto,
  ..args,
  body,
) = context {
  block(width: 100%, ..args)[
    #box(
      width: 100%,
      fill: white,
      stroke: (
        left: 2pt+border,
        bottom: 2pt+border,
      ),
      radius: 1pt,
      inset: (top: 0em, x: 0.5em, bottom: 0.5em),
    )[
      #box(
        fill: border,
        outset: (x: 0.59em, y: 0.3em),
      )[#text(fill: white, strong(full-title))]
      #sym.space
      #indent-repairer[#body]
    ]
  ]
}

#let (example-counter, example-box, example, show-example) = make-frame(
  "example",
  theorion-i18n-map.at("example"),
  counter: none,
  render: adm-render,
)

#let (important-counter, important-box, important, show-important) = make-frame(
  "important",
  theorion-i18n-map.at("important"),
  counter: none,
  render: adm-render,
)

#let (tip-counter, tip-block, tip, show-tip) = make-frame(
  "tip",
  theorion-i18n-map.at("tip"),
  counter: none,
  render: adm-render,
)

#let (hint-counter, hint-box, hint, show-hint) = make-frame(
  "tip",
  "Tip",
  counter: none,
  render: adm-render,
)

#let example = example.with(numbering: none, border: bmim.color.yellow)
#let important = important.with(numbering: none, border: bmim.color.red)
#let tip = tip.with(numbering: none, border: bmim.color.blue)
#let hint = hint.with(numbering: none, border: bmim.color.green)

