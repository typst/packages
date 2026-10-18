#import "@preview/mitex:0.2.7": *

#let mitex = (it, ..args) => mitex.with(..args)({
  ```tex
  \newcommand{\f}[2]{#1f(#2)}
  ```.text
  it.text
})

#mitex(```latex
\f\relax{x} = \int_{-\infty}^\infty
  \f\hat\xi\,e^{2 \pi i \xi x}
  \,d\xi
```)
