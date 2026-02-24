# Fractusist

Create a variety of wonderful fractals in Typst.


## Examples

The example below creates a dragon curve of the 12th iteration with the `dragon-curve` function.

![The rendered dragon curve](./examples/dragon-curve-n12.png)

<details>
  <summary>Show code</summary>

  ```typ
  #set page(width: auto, height: auto, margin: 0pt)

  #dragon-curve(
    12,
    step-size: 6,
    stroke-style: stroke(
      paint: gradient.linear(..color.map.crest, angle: 45deg),
      thickness: 3pt,
      cap: "square"
    )
  )
  ```
</details>


## Features

- Use SVG backend for image rendering.
- Generate fractals using [L-system](https://en.wikipedia.org/wiki/L-system).
- The number of iterations, step size, fill and stroke styles, etc. of generated fractals could be customized.


## Usage

Import the latest version of this package with:

```typ
#import "@preview/fractusist:0.1.1": *
```

Each function generates a specific fractal. The input and output arguments of all functions have a similar style. Typical input arguments are as follows:

- `n`: the number of iterations (**the valid range of values depends on the specific function**).
- _`step-size`_: step size (in pt).
- _`fill-style`_: fill style, can be `none` or color or gradient (**exists only when the curve is closed**).
- _`stroke-style`_: stroke style, can be `none` or color or gradient or stroke object.
- _`width`_: the width of the image.
- _`height`_: the height of the image.
- _`fit`_: how the image should adjust itself to a given area, "cover" / "contain" / "stretch".

The content returned is the `image` element.

For more codes with these functions see [tests](./tests).


## Reference

### Dragon

- `dragon-curve`: Generate dragon curve (n: range **[0, 16]**).

```typ
#let dragon-curve(n, step-size: 10, stroke-style: black + 1pt, width: auto, height: auto, fit: "cover") = {...}
```


### Hilbert

- `hilbert-curve`: Generate 2D Hilbert curve. (n: range **[1, 8]**).

```typ
#let hilbert-curve(n, step-size: 10, stroke-style: black + 1pt, width: auto, height: auto, fit: "cover") = {...}
```

- `peano-curve`: Generate 2D Peano curve (n: range **[1, 5]**).

```typ
#let peano-curve(n, step-size: 10, stroke-style: black + 1pt, width: auto, height: auto, fit: "cover") = {...}
```


### Koch

- `koch-curve`: Generate Koch curve (n: range **[0, 6]**).

```typ
#let koch-curve(n, step-size: 10, stroke-style: black + 1pt, width: auto, height: auto, fit: "cover") = {...}
```

-  `koch-snowflake`: Generate Koch snowflake (n: range **[0, 6]**).

```typ
#let koch-snowflake(n, step-size: 10, fill-style: none, stroke-style: black + 1pt, width: auto, height: auto, fit: "cover") = {...}
```


### Sierpiński

- `sierpinski-curve`: Generate classic Sierpiński curve (n: range **[0, 7]**).

```typ
#let sierpinski-curve(n, step-size: 10, fill-style: none, stroke-style: black + 1pt, width: auto, height: auto, fit: "cover") = {...}
```

- `sierpinski-square-curve`: Generate Sierpiński square curve (n: range **[0, 7]**).

```typ
#let sierpinski-square-curve(n, step-size: 10, fill-style: none, stroke-style: black + 1pt, width: auto, height: auto, fit: "cover") = {...}
```

- `sierpinski-arrowhead-curve`: Generate Sierpiński arrowhead curve (n: range **[0, 8]**).

```typ
#let sierpinski-arrowhead-curve(n, step-size: 10, stroke-style: black + 1pt, width: auto, height: auto, fit: "cover") = {...}
```

- `sierpinski-triangle`: Generate 2D Sierpiński triangle (n: range **[0, 6]**).

```typ
#let sierpinski-triangle(n, step-size: 10, fill-style: none, stroke-style: black + 1pt, width: auto, height: auto, fit: "cover") = {...}
```
