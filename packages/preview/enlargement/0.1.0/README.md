# [Enlargement] (Typst package)

[Enlargement]: https://codeberg.org/Andrew15-5/enlargement

[Enlargement] is a package to enlarge a part of any Typst content, including
images. It was emerged from [here](https://forum.typst.app/t/3717/2).

## Usage

```typ
#import "@preview/enlargement:0.1.0": enlarge-circle, image, source

#set page(width: auto, height: auto, margin: 0pt)

#let image = image(source("tiger.jpg"), width: 20cm)

#enlarge-circle(
  400%,
  image,
  place-pos: (15, 9),
  pos: (8.9, 8.9),
  diameter: 1.8,
  stroke: 3pt + purple,
  line-style: none,
)
```

![Tiger image with one eye enlarged](./assets/example-image.png)

```typ
#import "@preview/enlargement:0.1.0": enlarge-rect
#import "@preview/lilaq:0.2.0" as lq

#set page(width: auto, height: auto, margin: 0pt)

#let weierstrass(x, k: 8) = {
  range(k).map(k => calc.pow(0.5, k) * calc.cos(calc.pow(5, k) * x)).sum()
}

#let xs = lq.linspace(-0.5, .5, num: 1000)
#let xs-fine = lq.linspace(-0.05, 0, num: 1000)

#show: lq.set-grid(stroke: none)

#let diagram = lq.diagram(
  fill: black,
  width: 14cm,
  height: 7cm,
  ylim: (0, 2),
  margin: (x: 2%),
  yaxis: (ticks: none),
  xaxis: (ticks: none),
  lq.plot(xs, mark: none, xs.map(weierstrass)),
)

#enlarge-rect(
  300%,
  diagram,
  place-pos: (5, 1),
  pos: (11.6, 1.1),
  size: (1.5, 1.8),
)
```

![Typst diagram from Lilaq with an enlarged section](./assets/example-content.png)

## API

### `enlarge-circle`

```typ
/// Enlarge content using circle.
///
/// - scale (ratio): enlargement scale
/// - body (content): what to enlarge
/// - place-pos (array): position of the enlarged area (circle center)
/// - pos (array): position on the content where to enlarge (circle center)
/// - diameter (int, float): diameter of the enlarged circle
/// - unit (length): unit to use to convert int/float numbers
/// - stroke (stroke): stroke for circles and connection line
/// - normal-style (dictionary): args for `block()` (original area)
/// - enlarge-style (dictionary): args for `block()` (enlarged area)
/// - line-style (dictionary, none): args for `line()` (connecting line)
#let enlarge-circle(
  scale,
  body,
  place-pos: (0, 0),
  pos: (0, 0),
  diameter: 1,
  unit: 1cm,
  stroke: 1pt,
  normal-style: (:),
  enlarge-style: (:),
  line-style: (:),
)
```

---

### `enlarge-rect`

```typ
/// Enlarge content using rectangle.
///
/// - scale (ratio): enlargement scale
/// - body (content): what to enlarge
/// - place-pos (array): position of the enlarged area (bottom-left corner)
/// - pos (array): position on the content where to enlarge (bottom-left corner)
/// - size (array): width and height of the enlarged rectangle
/// - unit (length): unit to use to convert int/float numbers
/// - stroke (stroke): stroke for circles and connection line
/// - normal-style (dictionary): args for `block()` (original area)
/// - enlarge-style (dictionary): args for `block()` (enlarged area)
/// - line-style (dictionary, none): args for `line()` (connecting line)
#let enlarge-rect(
  scale,
  body,
  place-pos: (0, 0),
  pos: (0, 0),
  size: (1, 1),
  unit: 1cm,
  stroke: 1pt,
  normal-style: (:),
  enlarge-style: (:),
  line-style: (:),
)
```

---

### `source`

```typ
/// Alias for `read(file, encoding: none)`.
#let source
```

---

### `image`

```typ
/// Create an image that can be used with enlargement functions.
/// Must be used with `source()` function.
///
/// Note. You can use standard `image` by providing both width and height.
#let image(source, ..args)
```

## License

This Typst package is licensed under AGPL-3.0-only license. You can view the
license in the LICENSE file in the root of the project or at
<https://www.gnu.org/licenses/agpl-3.0.txt>.
