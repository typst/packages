# The `drawmatrix` Package

Visually represent matrices: rectangular, triangular(, soon: banded).
Inspired by the LaTeX package [of the same name][drawmatrix].

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./thumbnail-dark.svg">
  <img src="./thumbnail-light.svg" alt="Sylvester equation in Schur form">
</picture>

```typ
#import "@preview/drawmatrix:0.1.0": drawmatrix

#let dm = drawmatrix.with(color: black.lighten(50%))
#let dmbig = dm.with(scale: 2, upper: true)
#let dmtall = dm.with(height: 2)
#let dmsmall = dm.with(upper: true)

$
  #dmbig[$A$]
  #dmtall[$X$]
  +
  #dmtall[$X$]
  #dmsmall[$B$]
  =
  #dmtall[$C$]
$
```

## Limitations / Differences to the OG

- Must "repeat" math environment for matrix label
- No banded matrices (yet)
- No control of bounding box (yet)
- No replacement to accumulating `scale`s as in `\dramatrix[scale=2, scale=3]`
  (yet; planned replacement: `#drawmatrix(common-scale)`)

## Additional Documentation and Acknowledgments

* OG: [drawmatrix]
* Typst package template: https://github.com/typst-community/typst-package-template

[drawmatrix]: https://github.com/elmar-peise/drawmatrix
