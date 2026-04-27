# Meander

`meander` provides a core function `reflow` to segment pages and wrap content around images.

<!-- @scrybe(not version; panic Please specify a version number) -->
<!-- @scrybe(if publish; grep https; grep {{version}}) -->
See the [documentation](https://github.com/Vanille-N/meander.typ/releases/download/v0.4.1/docs.pdf).

## Quick start

The function `meander.reflow` takes a sequence of
- obstacles: use `placed` to put content at specific positions of the page,
- containers: use `container` to specify where text can be laid out,
- flowing content: provide text with `content`.
- optionally `pagebreak`, `colbreak`, `colfill` can be used to produce multi-page
  layouts and fine-tune which text goes into which container.

<!-- @scrybe(not publish; jump import; grep local; grep {{version}}) -->
<!-- @scrybe(if publish; jump import; grep preview; grep {{version}}) -->
<!-- @scrybe(jump let; until ```; diff tests/gallery/multi-obstacles/test.typ) -->
```typ
#let my-img-1 = box(width: 7cm, height: 7cm, fill: orange)
#let my-img-2 = box(width: 5cm, height: 3cm, fill: blue)
#let my-img-3 = box(width: 8cm, height: 4cm, fill: green)
#let my-img-4 = box(width: 5cm, height: 5cm, fill: red)
#let my-img-5 = box(width: 4cm, height: 3cm, fill: yellow)

#import "@preview/meander:0.4.1"

#meander.reflow({
  import meander: *

  // As many obstacles as you want
  placed(top + left, my-img-1)
  placed(top + right, my-img-2)
  placed(horizon + right, my-img-3)
  placed(bottom + left, my-img-4)
  placed(bottom + left, dx: 32%, my-img-5)

  // The container wraps around all
  container()
  content[
    #set par(justify: true)
    #lorem(430)
  ]
})
```
![a page where text flows between 5 rectangular obstacles](tests/gallery/multi-obstacles/ref/1.png)

-----

Use multiple `container`s to produce layouts in columns.

<!-- @scrybe(not publish; jump import; grep local; grep {{version}}) -->
<!-- @scrybe(if publish; jump import; grep preview; grep {{version}}) -->
<!-- @scrybe(jump let; until ```; diff tests/gallery/two-columns/test.typ) -->
```typ
#let my-img-1 = box(width: 7cm, height: 7cm, fill: orange)
#let my-img-2 = box(width: 5cm, height: 3cm, fill: blue)
#let my-img-3 = box(width: 8cm, height: 4cm, fill: green)

#import "@preview/meander:0.4.1"

#meander.reflow({
  import meander: *

  placed(bottom + right, my-img-1)
  placed(center + horizon, my-img-2)
  placed(top + right, my-img-3)

  // With two containers we can
  // emulate two columns.

  // The first container takes 60%
  // of the page width.
  container(width: 60%, margin: 5mm)
  // The second container automatically
  // fills the remaining space.
  container()

  content[#lorem(470)]
})
```
![a two-column page with 3 obstacles](tests/gallery/two-columns/ref/1.png)

------

If your Meander environment shares page(s) with other content,
use the option `placement: box`.
The `overflow` parameter determines what happens to text that doesn't
fit inside the provided containers.

You can see this in effect in the example below:
- the text in red is outside of the Meander environment
- the text in blue is the Meander environment itself
- the text in black is the overflow handled by Meander
<!-- @scrybe(not publish; jump import; grep local; grep {{version}}) -->
<!-- @scrybe(not publish; jump import; grep local; grep {{version}}) -->
<!-- @scrybe(jump import; until ```; diff tests/gallery/placement/test.typ) -->
```typ
#import "@preview/meander:0.4.1"
#set par(justify: true)

#text(fill: red)[#lorem(200)]

#meander.reflow({
  import meander: *
  // Gets rid of the paragraph break between
  // the columns and the overflow.
  opt.placement.spacing(below: 0.65em)

  // This turns on some debugging information,
  // specifically showing the boundaries
  // of the boxes in green.
  opt.debug.post-thread()

  container(
    width: 48%,height: 50%,
    style: (text-fill: blue),
  )
  container(
    width: 48%, height: 50%, align: right,
    style: (text-fill: blue),
  )

  content[#lorem(700)]

  // This applies a style to the text
  // that overflows the layout.
  opt.overflow.custom(data => {
    set text(fill: orange)
    data.styled
  })
})

#text(fill: red)[#lorem(200)]
```
![Content that overflows the environment (page 1/2)](tests/gallery/placement/ref/1.png)
![Content that overflows the environment (page 2/2)](tests/gallery/placement/ref/2.png)

------

Meander allows precise control over the boundaries of obstacles, to draw complex paragraph shapes.

<!-- @scrybe(not publish; jump import; grep local; grep {{version}}) -->
<!-- @scrybe(if publish; jump import; grep preview; grep {{version}}) -->
<!-- @scrybe(jump import; until ```; diff tests/gallery/circle-hole/test.typ) -->
```typ
#import "@preview/meander:0.4.1"

#meander.reflow({
  import meander: *

  placed(
    center + horizon,
    boundary:
      // Override the default margin
      contour.margin(1cm) +
      // Then redraw the shape as a grid
      contour.grid(
        // 25 vertical and horizontal subdivisions.
        // Just pick a number that looks good.
        // A good rule of thumb is to start with obstacles
        // about as high as one line of text.
        div: 25,
        // Equation for a circle of center (0.5, 0.5) and radius 0.5
        (x, y) => calc.pow(2 * x - 1, 2) + calc.pow(2 * y - 1, 2) <= 1
      ),
    // Underlying object
    circle(radius: 3cm, fill: yellow),
  )

  container(width: 48%)
  container(align: right, width: 48%)
  content[
    #set par(justify: true)
    #lorem(570)
  ]
})
```
![text with a circular cutout](tests/gallery/circle-hole/ref/1.png)

------

For a more in-depth introduction, including
- alternative recontouring techniques,
- styling options,
- advanced multi-page layouts,
- control over content that overflows,
- tips to get better segmentation,
<!-- @scrybe(if publish; grep https; grep {{version}}) -->
please consult the [documentation](https://github.com/Vanille-N/meander.typ/releases/download/v0.4.1/docs.pdf).

