#import "@preview/thesist:1.0.2": flex-caption, subfigure-grid
#import "@preview/glossarium:0.5.6": gls, glspl

= Another appendix

@appendix-figure and @appendix-subfigure-grid (composed of subfigures @appendix-subfigure-left[] and @appendix-subfigure-right[]) are example appendix figures.

#figure(
  rect(),
  caption: [An appendix image]
) <appendix-figure>

#subfigure-grid(
  figure(
    rect(),
    caption: [An image on the left.]
  ), <appendix-subfigure-left>,

  figure(
    rect(),
    caption: [An image on the right.]
  ), <appendix-subfigure-right>,

  kind: image,
  align: top,
  columns: (1fr, 1fr),
  rows: (auto),
  caption: [An appendix figure with two images],
  label: <appendix-subfigure-grid>
)
