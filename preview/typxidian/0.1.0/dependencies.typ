#import "@preview/cetz:0.4.1" // drawing inspired by tikz
#import "@preview/booktabs:0.0.4": * // booktabs-like tables
#import "@preview/wrap-it:0.1.1": wrap-content, wrap-top-bottom // wrap figures around text
#import "@preview/subpar:0.2.2" // create subfigures
#import "@preview/headcount:0.1.0": *
#import "@preview/glossarium:0.5.9": gls, make-glossary, glspl, print-glossary, register-glossary

#let subfigure(..args) = {
  subpar.grid(
    gutter: 1.5em,
    numbering: n => {
        numbering("1.1", ..counter(heading.where(level: 1)).get(), n)
      },
    numbering-sub-ref: (..n) => {
      numbering("1.1a", ..counter(heading.where(level: 1)).get(), ..n)
    },
    ..args
  )
}
