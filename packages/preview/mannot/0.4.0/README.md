# Mannot
<a href="https://typst.app/universe/package/mannot">
    <img alt="Typst Universe badge" src="https://img.shields.io/badge/dynamic/xml?url=https%3A%2F%2Ftypst.app%2Funiverse%2Fpackage%2Fmannot&query=%2Fhtml%2Fbody%2Fdiv%2Fmain%2Fdiv%5B2%5D%2Faside%2Fsection%5B2%5D%2Fdl%2Fdd%5B3%5D&logo=typst&label=Universe&color=%23239DAE" />
</a>

A [Typst](https://typst.app/) package for marking and annotating elements within math blocks.

For comprehensive documentation, please refer to the [manual](docs/doc.pdf).


## Features
* Visually marks content within math blocks without affecting the layout.
* Enables subsequent annotation of marked content.
* Supports annotations using CeTZ canvas for advanced graphical annotations.


## Examples
### Simple Example
```typst
$
  markhl(x) + markhl(y, #blue, #<tag1>)

  #annot(<tag1>)[Annotation]
$
```

![Simple example showing a highlighted math equation with an annotation.](examples/sample1.svg)

### More Complex Example
![Complex example showing a equation where multiple parts are marked,
highlighted, and connected to text annotations.](examples/showcase1.svg)

<details> <summary> Source code </summary>

```typst
#set page(width: auto, height: auto, margin: (left: 4cm, top: 2cm, rest: 1cm), fill: white)
#set text(24pt)

$
  markul(p_i, #<p>)
  = markrect(
    exp(- mark(beta, #<beta>, #red) mark(E_i, #<E>, #green)),
    #<fac>, #blue,
  ) / markhl(sum_j exp(- beta E_j), #<Z>)
  //
  #annot(<p>, pos: bottom + left)[Probability of \ state $i$]
  #annot(<beta>, pos: top + left, dy: -1.5em, leader-connect: "elbow")[Inverse temperature]
  #annot(<E>, pos: top + right, dy: -1em)[Energy]
  #annot(<fac>, pos: top + left)[Boltzmann factor]
  #annot(<Z>)[Partition function]
$
```

</details>


### Customized Markings and Annotations
![Example showing a scientific notation number with customized annotations,
including a highlighted box, modified leader lines, and a curly brace.](examples/showcase2.svg)

<details> <summary> Source code </summary>

```typst
#import "@preview/cetz:0.5.2"

#set page(width: auto, height: auto, margin: (x: 4cm, top: 2cm, bottom: 2cm), fill: white)
#set text(24pt)

#let markhl = markhl.with(stroke: 1pt)

$
  markhl(1 mark(., #<sep>) 23, #<mantissa>, #red)
  markub(
    mark(times, #<prd>)
    mark(10, #<base>)^mark(4, #<exp>),
    #<pow>, #blue, bracket: brace.b,
  )
  #{
    annot(<pow>, dy: 0em, annot-text-props: (size: .9em))[power]
    let annot = annot.with(leader-tip: tiptoe.triangle, leader-toe: none)
    annot(<mantissa>, pos: left, dx: -.5em, dy: -1em, annot-text-props: (size: .9em))[mantissa]

    let annot = annot.with(leader-stroke: .03em, leader-tip: none, leader-toe: none)
    annot(<sep>, pos: bottom + left, dx: -.5em)[decimal \ separator]
    annot(<prd>, pos: top, dx: -1em, dy: -1.2em)[product]
    annot(<base>, pos: top, dy: -1em)[base]
    annot(<exp>, pos: top + right, dx: 1em)[exponent]
  }
$
```

</details>


### Annotations using CeTZ
![Example showing a polynomial expansion with curved,
colored arrows drawn between terms using CeTZ.](examples/showcase3.svg)

<details> <summary> Source code </summary>

```typst
#import "@preview/cetz:0.5.2"

#set page(width: auto, height: auto, margin: (y: 2cm, bottom: 1cm), fill: white)
#set text(24pt)

#let rmark = mark.with(color: red)
#let bmark = mark.with(color: blue)
#let pmark = mark.with(color: purple)

$
  ( rmark(a x, #<ax>) + bmark(b, #<b>) )
  ( rmark(c x, #<cx>) + bmark(d, #<d>) )
  = rmark(a c x^2) + pmark((a d + b c) x) bmark(b d)
$

#annot-cetz(
  (<ax>, <b>, <cx>, <d>),
  cetz,
  {
    import cetz.draw: *

    set-style(mark: (end: "straight"))
    bezier-through("ax.south", (rel: (x: 1, y: -.5)), "cx.south", stroke: red)
    bezier-through("ax.south", (rel: (x: 1, y: -1)), "d.south", stroke: purple)
    bezier-through("b.north", (rel: (x: .6, y: .5)), "cx.north", stroke: purple)
    bezier-through("b.north", (rel: (x: .6, y: 1)), "d.north", stroke: blue)
  },
)
```

</details>


## Usage
Import the package `mannot` at the top of your document:
```typst
#import "@preview/mannot:0.4.0": *
```

### Marking
To decorate content within math blocks, use the following marking functions:
- `mark`: Changes the text color.
- `markhl`: Highlights the content.
- `markrect`: Draws a rectangle around the content.
- `markul`: Underlines the content.
- `markuw`: Draws a wavy line under the content.
- `markub`: Draws a bracket under the content.

![Example showing an equation with four different marking styles:
colored text, highlighting, a rectangle, and an underline.](examples/usage1.svg)

You can customize the marking color and other styles:
![Example showing an equation with customized marking styles,
including specific colors, strokes, and fills.](examples/usage2.svg)

### Annotations
After marking content with a tag (`label`),
you can later annotate it using the `annot` function:
```typst
$
  mark(x, #<tag>) + markhl(f(x), #<0>)
  //
  #annot(<tag>)[Annotation]
  #annot(<0>, pos: top, dy: -1em)[Another Annotation]
$
```
![Example showing an equation with various marking styles and text annotations attached to specific elements.](examples/usage3.svg)

> **CAUTION**\
> The `annot` function must be called within the same math block as the marked content.
> Using it outside the math block triggers unnecessary layout updates,
> which may result in a layout non-convergence error.

Markings and annotations do not affect the layout,
so you might sometimes need to manually insert spacing before and after the equations to achieve the desired visual appearance:
```typst
You need to insert spacing
#v(1em)  // <- Manual spacing.
$
  mark(x, #<1>, #green)
  #annot(<1>, pos: top + right)[Annotation]
  #annot(<1>, dy: 1em)[Annotation]
$
#v(2em)  // <- Manual spacing.
before/after the equations.
```
![Example showing manual vertical spacing added around an annotated equation to prevent overlap with surrounding text.](examples/usage4.svg)

#### Annotation Positioning
The `annot` function offers the following arguments to control annotation placement:
* `pos`: Where to place the annotation relative to the marked content.
  This can be:
  - A single alignment for simple relative positioning.
  - A pair of alignments, where the first defines the anchor point on the marked content,
    and the second defines the anchor point on the annotation.

  ![Example demonstrating various annotation positions around a marked equation using different `pos` values.](examples/usage-pos.svg)

* `dx`, `dy`: The horizontal and vertical displacement of the annotation's anchor
  from the marked content's anchor.

  ![Example demonstrating how to adjust an annotation's position using horizontal (`dx`) and vertical (`dy`) offsets.](examples/usage-dxdy.svg)


#### Annotation Leader Line
When the annotation is far from the marked content, a leader line is drawn by default.
You can customize its appearance using the following `annot` arguments:
* `leader`: Whether to draw a leader line. Set to `auto` to enable automatic drawing based on distance.
* `leader-stroke`: How to stroke the leader line e.g., `1pt + red`.
* `leader-tip`, `leader-toe`: Define the end and start markers of the leader line.
  Leader lines are drawn by the [tiptoe](https://typst.app/universe/package/tiptoe) package.
  You can specify markers or `none`:
  ```typst
  $
    markhl(x, #<1>)

    #annot(
      <1>, pos: bottom + right, dy: 1em,
      leader-tip: tiptoe.circle,
      leader-toe: tiptoe.stealth.with(length: 1000%),
    )[annotation]
  $
  ```

  ![Example demonstrating an annotation connected by a customized leader line with a circle at the start and an arrow at the tip.](examples/usage-leader-tiptoe.svg)

  For more options, see the [tiptoe page](https://typst.app/universe/package/tiptoe).

* `leader-connect`: How the leader line connects to the marked content and the annotation.
  This can be:
  - A pair of alignments defining the connection points on the marked content and the annotation.
  - "elbow" to create an elbow-shaped leader line.

  ![Example demonstrating different leader line connection styles, including specific anchor points and an elbow shape.](examples/usage-leader-connect.svg)

* `anchor-inset`: How much to pad the marked content's boundary (anchor boundary) for this annotation.
  This can be specified as a single `length` or a dictionary. It is primarily useful for adjusting the gap between the marked content (including its borders/decorations) and the leader line.

  ```typst
  $
    markhl(x, #<1>)

    #annot(<1>, dy: 1em, anchor-inset: 5pt)[annotation]
  $
  ```
  ![Example demonstrating how to adjust the spacing between the marked content and the leader line using `anchor-inset`.](examples/usage-anchor-inset.svg)


### Annotating Multiple Elements
You can also annotate multiple marked elements simultaneously
by passing an array of their tags to the `annot` function.
```typst
$
  mark(x, #<1>, #green)
  + markhl(f(x), #<2>, #purple, stroke: #1pt, radius: #10%)
  + markrect(e^x, #<3>, #red, outset: #.2em)
  + markul(x + 1, #<4>, #gray, stroke: #2pt)
  //
  #annot((<1>, <2>), dy: 1em)[Annotation]
  #annot((<3>, <2>, <4>), pos: top, dy: -1em, leader-connect: "elbow")[Another annotation]
$
```
![Example showing single text annotations pointing to multiple marked elements simultaneously.](examples/usage5.svg)

### Annotations using CeTZ
To create annotations using the CeTZ canvas, use the `annot-cetz` function.
This allows you to embed a CeTZ canvas directly onto previously marked content.
Within the CeTZ canvas code block,
you can reference the position and dimensions of the marked content using an anchor with the same name as its tag.
For elements marked with multiple tags, corresponding anchors will be available.
```typst
#import "@preview/cetz:0.5.2"

$
  mark(x, #<x>) + mark(y, #<y>)

  #annot-cetz((<x>, <y>), cetz, {
    import cetz.draw: *
    content((0, -1), [CeTZ], anchor: "north-west", name: "a")
    line("x", "a") // You can refer the marked content.
    line("y", "a")
  })
$
```
![Example showing marked elements in an equation connected to a text label using a custom CeTZ canvas.](examples/usage-annot-cetz.svg)


## Tips
### Q. How to override default options?
Use the `with` function to create new functions with modified default arguments.
For example, to always use elbow-shaped leader lines for annotations:
```typst
#let annot = annot.with(leader-connect: "elbow")
```


## Changelog
* v0.4.0:
  - Added `markuw` and `markub` functions.
  - Allowed passing `color` and `tag` as positional arguments in marking functions without explicit parameter names (e.g., `mark(x, red, <tag>)`).
  - Added `anchor-inset` parameter to `annot` to adjust the spacing between the marked content and the leader line (Issue #11).
  - Fixed an issue where the align-point (`&`) did not work inside the `mark` function (Issue #9).
  - Fixed a layout calculation bug in `core-mark` where nested marks inside fractions caused shifted bounding boxes (Issue #10).
* v0.3.3:
  - Fixed layout issues when marking contents starting with unary operators.
* v0.3.2:
  - Fixed layout issues in marking inline math content.
* v0.3.1:
  - Added support for Typst v0.14.
* v0.3.0:
  - Renamed some marking functions for clarity:
    - `mark` is now `markhl` (for highlighting).
    - `marktc` is now `mark` (for changing text color).
  - Added direct leader line functionality to the `annot` function.
  - Added support for multi-element annotations.
  - Introduced support for annotations using CeTZ canvas.
* v0.2.3:
  - Added support for RTL documents.
  - Replaced deprecated `path` functions with `curve`.
* v0.2.2:
  - Improved performance by removing counters.
* v0.2.1:
  - Fixed layout issues with underlays/overlays in marking functions when custom math fonts are used.
* v0.2.0:
  - Removed the `mannot-init` function.
  - Introduced support for placing underlays beneath math content during marking.
  - Added new marking functions: `markrect`, `markul` and `marktc`.
* v0.1.0: Initial release.
