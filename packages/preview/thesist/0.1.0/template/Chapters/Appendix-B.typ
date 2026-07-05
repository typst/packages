#import "@preview/thesist:0.1.0": flex-caption, subfigure-grid
#import "@preview/glossarium:0.4.1": gls, glspl

= Another appendix

#lorem(300)

#figure(
  rect(),
  caption: [An appendix image]
)<example_ref_B>

#subfigure-grid(
  in-appendix: true,
  figure(
    rect(),
    caption: [An image on the left.]
  ), <sub-left-example-2>,
  figure(
    rect(),
    caption: [An image on the right.#v(1em)]
  ), <sub-right-example-2>,
  align: top,
  columns: (1fr, 1fr),
  caption: [An appendix figure with two images],
  label: <subfigure-grid-example-2>,
)
