#import "../format.typ": showcode

= Drawing
As we are doing math, inevitably we will need to draw some graphs.

Typically, you would not want to commit time and effort to learn drawing in Typst. Have your graphs done in Desmos, GeoGebra, or any other graphing tools, then display images of them.
```typst
#image("/template/assets/madeline-math.jpg", width: 12em) // n'em = length of n m's
```
#image("/template/assets/madeline-math.jpg", width: 12em)

You may have noticed that the path in example starts with "/". It is not your computer's root directory, but the root directory of the project.

If you are working offline, note that Typst cannot reach beyond the root directory, settable in the compiling command.

== Drawing in Typst
So...

Typst has some native drawing abilities, but they are very limited.
There is an ad hoc Typst drawing library, a package actually, called "cetz", with its graphing companion "cetz-plot".
Simply
```typst
#import drawing: *
```
to let the template import them for you.

For general drawing techniques, refer to the #link("https://cetz-package.github.io/docs/")[cetz documentation].
For graphing, download and refer to the #link("https://github.com/cetz-package/cetz-plot/blob/stable/manual.pdf?raw=true")[cetz-plot manual].

There are other drawing packages available, but not imported by this template, here is a brief list:
- #link("https://staging.typst.app/universe/package/fletcher")[fletcher]: nodes & arrows;
- #link("https://staging.typst.app/universe/package/jlyfish")[jlyfish]: Julia integration;
- #link("https://staging.typst.app/universe/package/neoplot")[neoplot]: Gnuplot integration.

Find more visualization packages #link("https://staging.typst.app/universe/search/?category=visualization&kind=packages")[here].
== Template Helpers
Besides importing the drawing packages, the `drawing` module also provides some helper functions.

For example, the `cylinder()` function draws an upright no-perspective cylinder.
#showcode(```typst
#import drawing: *
#cetz.canvas({
  import cetz.draw: *
  group({
    rotate(30deg)
    cylinder(
      (0, 0), // Center
      (1.618, .6), // Radius: (x, y)
      2cm / 1.618, // Height
      fill-top: maroon.lighten(5%), // Top color
      fill-side: blue.transparentize(80%), // Side color
    )
  })
})
```)

== Example//s
#[
  // Import the drawing module for drawing abilities.
  #import "../drawing.typ": * // You should use the next line instead
  // #import drawing: *
  #figure(
    caption: [Adaptive path-position-velocity graph \ (check source code)],
    cetz.canvas({
      import cetz.draw: *
      import cetz-plot: *
      // Function to plot
      let fx = x => -calc.root(x, 3)
      // Derivative of the function
      let fdx = x => -calc.pow(calc.root(x, 3), -2) / 3
      // Linear approximation of the function
      let la-fx = (x, a) => fdx(a) * (x - a) + fx(a)
      // plot → canvas transformation
      let ts = (x, y) => (x + 1, y).map(c => c * 2)

      // Plot the function (object path)
      plot.plot(
        size: (4, 4),
        axis-style: none,
        name: "path",
        {
          plot.add-anchor("left", (-1, 0))
          plot.add(
            domain: (-1, 1),
            fx,
            style: (stroke: (paint: red, dash: "dashed", thickness: 1.2pt)),
          )
        },
      )
      // Canvas origin set to (-1, 0),
      // size is 4 * 4, which is 2 times of plot (domain, range) = (2, 2),
      // hence the transformation is (x + 1, y) * 2
      set-origin("path.left")
      // Draw laying cylinder
      group({
        rotate(90deg)
        cylinder((0, 0), (2, 1), 4cm, fill-side: blue.transparentize(90%), fill-top: blue.transparentize(80%))
      })
      // Draw object position and tangent line
      let x = 0.8 // Try changing this!
      let shift = 0.5
      line(
        ts(x, fx(x)),
        ts(x + shift, la-fx(x + shift, x)),
        stroke: purple,
        mark: (end: "straight"),
      )
      circle(
        ts(x, fx(x)),
        radius: 2pt,
        fill: purple,
        stroke: none,
      )
    }),
  )
]
