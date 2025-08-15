#import "@submit/presentate:0.2.0" as p: *
#import themes.simple: *
#import "@preview/codly:1.3.0": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "@preview/cetz:0.4.1" as cetz: canvas, draw
#import "@preview/pinit:0.2.2": *
#import "@preview/gentle-clues:1.2.0" as gtc
#import "@preview/mantys:1.0.2" as mnt
#import "@preview/layout-ltd:0.1.0": layout-limiter
#import "@preview/alchemist:0.1.7": single, fragment, skeletize, branch
#let (single,) = animation.animate(
  single,
  modifier: (func, ..args) => func(stroke: 0pt, ..args),
)

#let slide = slide.with(align: horizon)
#let animate-items(..args) = {
  let kwargs = args.named() 
  let args = args.pos() 
  args = args.map(it => [ 

  ] + it + [ 

  ])
  fragments(hider: utils.hide-enum-list, ..kwargs, ..args)
} 
#let show-results(output, title: []) = {
  [Output: ] + title
  rect(width: 100%, output, radius: 0.3cm)
}

#let footlink(url, body) = {
  link(url, body)
  footnote(link(url))
}

#let itemize(..args, body) = {
  show list.item: pause.with(hider: utils.hide-enum-list)
  show enum.item: pause.with(hider: utils.hide-enum-list)
  body
}

#let config(body) = {
  show: template.with(
    author: [\@pacaunt],
    title: [Welcome To Presentate!],
    subtitle: [Tools for creating integrated dynamic slides.],
  )
  set raw(lang: "typst")
  show raw: set text(font: "Noto Sans Mono")
  show: codly-init
  codly(
    display-icon: false,
    display-name: false,
    highlighted-default-color: eastern.transparentize(80%),
  )

  set heading(numbering: "1.1")
  set page(numbering: "1")
  show heading.where(level: 3): set heading(numbering: none)
  show link: set text(fill: blue)

  body
}
