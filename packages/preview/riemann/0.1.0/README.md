# Riemann sum graphs in Typst with CeTZ

A package to draw Riemann sums (and their plots) of a function with CeTZ.

<https://typst.app/project/rnDsqxCFu3U_vj-qIM_Hsm>

On Typst v0.6.0+ you can import the `riemann` package:

```typst
#import "@preview/riemann:0.1.0": riemann
```

Otherwise, add the `riemann.typ` file to your project and import it as normal:

```typst
#import "riemann.typ": riemann
```

Usage example in `example.typ`

All paramenters:

```js
// Function
fn,
// Start
start: 0,
// End
end: 10,
// Number of bars (please made Delta x = 1)
n: 10,
// Y scale
y-scale: 1,
// X offset
x-offset: 0,
// Y offset
y-offset: 0,
// Hand of graph. Can be left, mid/midpoint, or right
hand: "left",
// Transparency fill of bars
transparency: 40%,
// Radius of dots
dot-radius: 0.055,
// Whether to add plot
plot: true,
// Show grid on plot
plot-grid: false,
// X tick step of plot
plot-x-tick-step: auto,
// Y tick step of plot
plot-y-tick-step: auto,
// Color of positive bars
positive-color: color.green,
// Color of negative bars
negative-color: color.red,
// Color of plotted line
plot-line-color: color.blue
```

![Demo](https://github.com/ThatOneCalculator/riemann-sum-typst-cetz/assets/44733677/30c01ebc-915a-4322-8374-1c674cda0cb1)