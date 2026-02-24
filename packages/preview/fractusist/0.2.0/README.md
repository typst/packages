# Fractusist

Create a variety of wonderful fractals and curves in Typst.


## Examples

<table>
<tr>
  <td>
    <a href="examples/dragon-curve-n12.typ">
      <img src="examples/dragon-curve-n12.png" width="250px">
    </a>
  </td>
  <td>
    <a href="examples/koch-snowflake-n4.typ">
      <img src="examples/koch-snowflake-n4.png" width="250px">
    </a>
  </td>
</tr>
<tr>
  <td>Dragon Curve</td>
  <td>Koch Snowflake</td>
</tr>
<tr>
  <td>
    <a href="examples/sierpinski-triangle-n6.typ">
      <img src="examples/sierpinski-triangle-n6.png" width="250px">
    </a>
  </td>
  <td>
    <a href="examples/hypotrochoid-a19-b16-h2.typ">
      <img src="examples/hypotrochoid-a19-b16-h2.png" width="250px">
    </a>
  </td>
</tr>
<tr>
  <td>Sierpiński Triangle</td>
  <td>Hypotrochoid</td>
</tr>
</table>

*Click on the example image to jump to the code.*


## Features

- Generate fractals using [L-system](https://en.wikipedia.org/wiki/L-system).
- The number of iterations, step size, fill and stroke styles, etc. of generated fractals could be customized.
- Generate spirograph and Lissajous curves with various parameters.


## Usage

Import the latest version of this package with:

```typ
#import "@preview/fractusist:0.2.0": *
```

Each function (see reference) generates a specific curve. The shape and size of it is configurable. And the fill and stroke style arguments are equivalent to those in the `curve` function. The returned graph is contained within the `box` element.

This package comes with some unit tests under the [tests](https://github.com/liuguangxi/fractusist/tree/main/tests) directory.


## Reference

### Dragon

- `dragon-curve`: Generate dragon curve (n: integer range **[0, 16]**).

```typ
#let dragon-curve(n, step-size: 10, stroke: black + 1pt) = {...}
```


### Hilbert

- `hilbert-curve`: Generate 2D Hilbert curve. (n: integer range **[1, 8]**).

```typ
#let hilbert-curve(n, step-size: 10, stroke: black + 1pt) = {...}
```

- `peano-curve`: Generate 2D Peano curve (n: integer range **[1, 5]**).

```typ
#let peano-curve(n, step-size: 10, stroke: black + 1pt) = {...}
```


### Koch

- `koch-curve`: Generate Koch curve (n: integer range **[0, 6]**).

```typ
#let koch-curve(n, step-size: 10, fill: none, stroke: black + 1pt) = {...}
```

-  `koch-snowflake`: Generate Koch snowflake (n: integer range **[0, 6]**).

```typ
#let koch-snowflake(n, step-size: 10, fill: none, stroke: black + 1pt) = {...}
```


### Sierpiński

- `sierpinski-curve`: Generate classic Sierpiński curve (n: integer range **[0, 7]**).

```typ
#let sierpinski-curve(n, step-size: 10, fill: none, stroke: black + 1pt) = {...}
```

- `sierpinski-square-curve`: Generate Sierpiński square curve (n: integer range **[0, 7]**).

```typ
#let sierpinski-square-curve(n, step-size: 10, fill: none, stroke: black + 1pt) = {...}
```

- `sierpinski-arrowhead-curve`: Generate Sierpiński arrowhead curve (n: integer range **[0, 8]**).

```typ
#let sierpinski-arrowhead-curve(n, step-size: 10, stroke: black + 1pt) = {...}
```

- `sierpinski-triangle`: Generate 2D Sierpiński triangle (n: integer range **[0, 6]**).

```typ
#let sierpinski-triangle(n, step-size: 10, fill: none, stroke: black + 1pt) = {...}
```


### Spirograph

- `hypotrochoid`: Generate hypotrochoid (a, b, h: integer range **[1, 100]**).

```typ
#let hypotrochoid(a, b, h, size: 100, fill: none, fill-rule: "non-zero", stroke: black + 1pt) = {...}
```

- `epitrochoid`: Generate epitrochoid (a, b, h: integer range **[1, 100]**).

```typ
#let epitrochoid(a, b, h, size: 100, fill: none, fill-rule: "non-zero", stroke: black + 1pt) = {...}
```


### Lissajous

- `lissajous-curve`: Generate Lissajous curve (a, b: integer range **[1, 100]**, d: float range **[0, 2]**).

```typ
#let lissajous-curve(a, b, d, x-size: 100, y-size: 100, fill: none, fill-rule: "non-zero", stroke: black + 1pt) = {...}
```
