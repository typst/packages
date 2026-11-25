# visage-metric

Typst package for computing 2D facial landmark geometry metrics (canthal tilt, facial thirds balance, golden ratio deviation, and bilateral mirror symmetry) and formatting them as clean summary tables in reports and notes.

## Usage

```typst
#import "@preview/visage-metric:0.1.0": *

#let tilt = canthal-tilt-deg((x: 100, y: 200), (x: 140, y: 193))
#let thirds = compute-facial-thirds(100, 200, 300, 400)
#let gr = golden-ratio-delta(161.8, 100)
#let sym = bilateral-symmetry(
  (
    (left: (x: 160, y: 200), right: (x: 240, y: 200)),
    (left: (x: 170, y: 260), right: (x: 230, y: 260)),
  ),
  200,
  160,
)

#proportion-summary-table(
  canthal-tilt: tilt,
  thirds: thirds,
  golden: gr,
  symmetry: sym,
)
```

## Notes on Coordinates

- Coordinates use top-down image space (`x` increases right, `y` increases downward).
- `calc.atan2(dx, dy)` in Typst takes `(x, y)` order; `canthal-tilt-deg` accounts for this convention and returns positive degrees for an upward lateral tilt.

## Online Tool

Companion web calculator and landmark diagrams: [Looksmax Scale](https://looksmaxscale.com/).

## License

MIT
