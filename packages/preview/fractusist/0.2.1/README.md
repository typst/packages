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
  <td>
    <a href="examples/sierpinski-triangle-n6.typ">
      <img src="examples/sierpinski-triangle-n6.png" width="250px">
    </a>
  </td>
</tr>
<tr>
  <td>Dragon Curve</td>
  <td>Koch Snowflake</td>
  <td>Sierpiński Triangle</td>
</tr>
<tr>
  <td>
    <a href="examples/hypotrochoid-a19-b16-h2.typ">
      <img src="examples/hypotrochoid-a19-b16-h2.png" width="250px">
    </a>
  </td>
  <td>
    <a href="examples/random-fractal-tree-n14.typ">
      <img src="examples/random-fractal-tree-n14.png" width="250px">
    </a>
  </td>
  <td>
    <a href="examples/pythagorean-tree-n12.typ">
      <img src="examples/pythagorean-tree-n12.png" width="250px">
    </a>
  </td>
</tr>
<tr>
  <td>Hypotrochoid</td>
  <td>Random Fractal Tree</td>
  <td>Pythagorean Tree</td>
</tr>
</table>

*Click on the example image to jump to the code.*


## Features

- Generate fractals using [L-system](https://en.wikipedia.org/wiki/L-system). The number of iterations, step size, fill and stroke styles, etc. of generated fractals could be customized.
- Generate spirograph and Lissajous curves with various parameters.
- Generate various parameterized fractal trees.
- Generate Fibonacci word fractals.


## Usage

Import the latest version of this package with:

```typ
#import "@preview/fractusist:0.2.1": *
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


### Tree

- `fractal-tree`: Generate fractal tree (n: integer range **[1, 14]**)

```typ
#let fractal-tree(n, root-color: rgb("#46230A"), leaf-color: rgb("#228B22"), trunk-len: 100, trunk-rad: 3.0, theta: 1/2, angle: 1/4, ratio: 0.8) = {...}
```

- `random-fractal-tree`: Generate random fractal tree (n: integer range **[1, 14]**)

```typ
#let random-fractal-tree(n, seed: 42, root-color: rgb("#46230A"), leaf-color: rgb("#228B22"), trunk-len: 100, trunk-rad: 3.0, theta: 1/2, angle: 1/4, ratio: 0.8) = {...}
```

- `pythagorean-tree`: Generate Pythagorean tree (n: integer range **[1, 14]**)

```typ
#let pythagorean-tree(n, root-color: rgb("#46230A"), leaf-color: rgb("#228B22"), trunk-len: 50, theta: 1/5, filling: true) = {...}
```


### Fibonacci
- `fibonacci-word-fractal`: Generate Fibonacci word fractal (n: integer range **[3, 24]**)

```typ
#let fibonacci-word-fractal(n, skip-last: true, step-size: 10, start-dir: 0, stroke: black + 1pt) = {...}
```
