// #import "@preview/touying:0.4.2": *

#import "theme.typ": *
#import "lib.typ": *
// #import "./theme.typ" as ustc-theme

#let s = register(aspect-ratio: "16-9")
#let s = (s.methods.numbering)(self: s, section: "1.", "1.1")

#let s = (s.methods.info)(
  self: s,
  title: [Typst template for School of Computer Science and Technology, USTC],
  subtitle: [Continuously Improving...],
  author: [Quaternijkon],
  date: datetime.today(),
  institution: [School of Computer Science and Technology, USTC],
  logo: image("./assets/img/USTC.svg", width: 50%),
  github: []
)

#let (init, slides) = utils.methods(s)

#let (slide, empty-slide, title-slide, outline-slide, new-section-slide, ending-slide, focus-slide,matrix-slide) = utils.slides(s)




