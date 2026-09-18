#import "@local/sanor:0.3.0": *

// Set up presentation format.
#set page(paper: "presentation-16-9", fill: luma(20))
#set text(size: 25pt, fill: white)

// To create a handout, uncomment the following line.
// The `handout-index` is the index of the frame that will be shown in the handout.
//
// #let (slide,) = set-option(handout: true, handout-index: auto)

#slide(s => (
  [
    #let tag = tag.with(s)
    #set align(center + horizon)
    #title[Sanor Examples]
    \@pacaunt
  ],
  s,
))

#slide(s => (
  [
    #let tag = tag.with(s)
    = Normal Pause
    #set align(horizon)
    #s.push(1)
    #pause(s, [- First Item])
    #s.push(1)

    #pause(s, [- Second Item])
    #s.push(1)

    #pause(s, [- Third Item])
    #s.push(1)
  ],
  s,
))

#slide(s => (
  [
    #let tag = tag.with(s)
    = Tagged Element Examples
    #set align(center + horizon)
    #tag("once")[This will appear _once_.] \
    #tag("apply")[This will appear _all the time_.]

    #tag("trans")[This will transform.]

    #s.push(once("once"))
    #s.push(apply("apply"))
    #s.push(apply("trans"))
    #s.push(apply("trans", text(fill: yellow, "Transformed!")))
  ],
  s,
))

#slide(s => (
  [
    #let tag = tag.with(s)
    = Nested `tag` for styling
    #set align(center + horizon)
    // element in nested tag calls will not hide
    // good for highlighting
    #tag("paragraph", tag => [
      #lorem(10)#tag("h1", lorem(10))
      #lorem(5)#lorem(10)#tag("h2", lorem(5))
    ])
    #s.push("paragraph")
    #s.push(once("h1", highlight))
    #s.push(once("h2", highlight.with(fill: teal.transparentize(70%))))
  ],
  s,
))

#slide(s => (
  [
    #let tag = tag.with(s)
    = Math Example
    Simplify
    $
      (x(x + 1)tag("m", (x + 2)))/(2 tag("m", (x + 2)))
    $
    #s.push(apply("m")) // Show the `m`.
    #s.push(apply("m", text.with(fill: red))) // Make it red.
    #s.push(apply("m", math.cancel)) // Cancel it.
    #s.push(apply("m", it => none)) // Remove it.
    #s.push(-1) // to move the `pause` up
    #pause(s)[End.]
    #s.push(1) // to update the last `pause`.
  ],
  s,
))

#slide(s => (
  [
    #import "@preview/zebraw:0.6.3": zebraw
    #let tag = tag.with(s)
    #let zebraw = zebraw.with(
      background-color: luma(30),
      lang: false,
      highlight-color: white.transparentize(90%),
      comment-color: white.transparentize(90%),
      comment-font-args: (font: "Libertinus serif"),
    )
    = Code Example
    Integration with `zebraw`.
    #set align(horizon)

    #show: zebraw

    #tag("snippet")[```typst
    #slide(s => ([
      #let tag = tag.with(s)
      // Your Content Goes Here
    ],s))
    ```]

    #s.push(apply("snippet"))
    #s.push(apply("snippet", it => {
      zebraw(it, highlight-lines: (
        "2": [
          Don't forget this line!
        ],
      ))
    }))

  ],
  s,
))

#slide(s => (
  [
    #let tag = tag.with(s)
    = Magic Selectors
    `select` can be used to construct a precise selector for styling.
    #s.push(1) // go to the next slide.
    #tag(
      "eq",
      $
        F = (G m_1 m_2)/r^2
      $,
    )
    #s.push(apply(
      "eq",
      scale.with(200%, reflow: true),
      align.with(center + horizon),
    ))
    #s.push(once("eq", it => {
      // select parts of an equation easily
      show select($m_1$): set text(fill: teal)
      show select($m_2$): set text(fill: red)
      show select($r^2$): set text(fill: yellow)
      show select($F$): set text(fill: orange)
      it
    }))

  ],
  s,
))

#slide(s => (
  [
    #let tag = tag.with(s)
    = Simultaneous Animation
    #set align(center + horizon)

    #grid(columns: (1fr,) * 2, align: horizon)[
      #tag("Jack")[Jack]

      #tag("jtext")[Jack was a teacher.]
    ][
      #tag("Julie")[Julie]

      #tag("ltext")[Julie was a student.]
    ]

    #s.push((
      apply("Jack"),
      apply("Julie"),
    ))

    #s.push((
      once("Jack", circle.with(fill: blue)),
      once("jtext"),
    ))

    #s.push((
      once("Julie", circle.with(fill: fuchsia)),
      once("ltext"),
    ))
  ],
  s,
))

#slide(s => (
  [
    #let tag = tag.with(s)
    = Object Manipulation
    Elements defined by `object` declaration can be modified.
    #set align(horizon)
    #let myrect = object(rect.with(stroke: yellow), hidden: hide)

    #tag("base", myrect[Hello])
    #s.push(apply("base", align.with(center)))
    #s.push(apply("base", outset: 1em))
    #s.push(once("base", text.with(fill: yellow)))
    #s.push(apply("base", radius: 2em))
  ],
  s,
))

#slide(s => (
  [
    #let tag = tag.with(s)
    = Predefined Objects: Components
    For markup, `#import mcomps: *`,\  for CeTZ elements, `#import ccomps: *`.
    #s.push(1)

    #set align(center + horizon)
    // import the predefined CeTZ objects
    #import ccomps: *
    #cetz.canvas({
      import cetz.draw: *
      stroke(white)
      // Name of a component can be called directly.
      ccircle(tag, (0, 0), name: "c1")
      s.push("c1")
      crect(tag, "c1.east", (rel: (2, 2)), name: "r1")
      s.push("r1")
      cpolygon(
        tag,
        "r1.south-east",
        3,
        anchor: "west",
        angle: 90deg,
        name: "poly1",
      )
      s.push("poly1")
      s.push(apply("c1", fill: red, stroke: none))
      s.push(apply("r1", fill: blue, stroke: none))
      s.push(apply("poly1", fill: olive, stroke: none))
    })
  ],
  s,
))

#slide(s => (
  [
    #let tag = tag.with(s)
    = Revert Animation
    Example with CeTZ integration. \

    #let tag = tag.with(hidden: it => none)
    #set align(center)
    #tag("normal", "A Normal Circle")
    #tag("red", "Fill it red.")
    #tag("grow", "Make it big.")
    #tag("back", "It is back!")
    #set align(horizon)

    #import "@preview/cetz:0.5.0"
    #cetz.canvas({
      import cetz.draw: *
      set-style(stroke: white)
      // change the hiding method used by the `tag` function.
      let tag = tag.with(hidden: hide.with(bounds: true))

      let c1 = object(circle, hidden: hide)
      tag("c1", c1((0, 0)))

      s.push((apply("c1"), once("normal")))
      s.push((apply("c1", fill: red), once("red")))
      s.push((apply("c1", radius: 3), once("grow")))
      // `revert` can revert the object to the base case without losing the previous animation styles.
      s.push((revert("c1"), once("normal")))
      // This `apply` still shows the circle as if the `revert` hasn't been called.
      s.push((apply("c1"), once("back")))
    })
  ],
  s,
))

#slide(s => (
  [
    #let tag = tag.with(s)
    = Clear animation of an object
    Example with CeTZ integration. \

    #let tag = tag.with(hidden: it => none)
    #set align(center)
    #tag("normal", "A Normal Circle")
    #tag("red", "Fill it red.")
    #tag("grow", "Make it big.")
    #tag("back", "It did not come back...")
    #set align(horizon)

    #import "@preview/cetz:0.5.0"
    #cetz.canvas({
      import cetz.draw: *
      set-style(stroke: white)
      // change the hiding method used by the `tag` function.
      let tag = tag.with(hidden: hide.with(bounds: true))

      let c1 = object(circle, hidden: hide)
      tag("c1", c1((0, 0)))

      s.push((apply("c1"), once("normal")))
      s.push((apply("c1", fill: red), once("red")))
      s.push((apply("c1", radius: 3), once("grow")))
      // `clear` can revert the object to the base case but the previous animation styles are lost.
      s.push((clear("c1"), once("normal")))
      // This `apply` will show as if the previous animation hasn't been applied.
      s.push((apply("c1"), once("back")))
    })
  ],
  s,
))

#slide(s => (
  [
    #let tag = tag.with(s)
    = Custom Defined Cases
    *Cases* are a shorthand for defining actions that will act on an element.

    #let mytext = object(
      text,
      redden: case(fill: red),
      grayed: case(fill: gray),
      rotated: case(rotate.with(30deg)),
    )

    #show: block.with(height: 1fr, width: 100%)
    #tag("elem", mytext[This is a text.])
    #s.push(apply("elem", place.with(center + horizon)))
    #s.push(once("elem", "redden"))
    #s.push(once("elem", "grayed"))
    #s.push(once("elem", "rotated", place.with(center + horizon)))
  ],
  s,
))

#slide(
  defined-cases: (
    "highlighted": case(block.with(outset: 0.5em, stroke: yellow)),
    "alert": case(text.with(fill: yellow)),
  ),
  s => (
    [
      #let tag = tag.with(s)
      = Mixing animations and pause
      #s.push(1)

      #pause(s, [Hello, there!])
      #s.push(1)

      #pause(s, [Here are some switches you can choose.])
      #s.push(1)

      #set align(center + horizon)

      #let myrect = object(rect.with(height: 2cm, width: 2cm))

      #grid(columns: (1fr,) * 2, align: top)[
        #tag("green", myrect(fill: green))
        #tag("gtext", [If you press the green one, nothing will happen.])
      ][
        #tag("red", myrect(fill: red))
        #tag("rtext", [If you press the red one, also nothing...])
      ]

      #s.push((
        apply("green"),
        apply("red"),
      ))
      #s.push((
        once("gtext", "alert"),
        once("green", "highlighted"),
      ))
      #s.push((
        once("rtext", "alert"),
        once("red", "highlighted"),
      ))

      #pause(s, move(dy: -2em)[What did you choose?])
      #s.push(1)
    ],
    s,
  ),
)

#slide(s => (
  [
    #let tag = tag.with(s)
    #set align(center + horizon)
    = Thanks
    \@pacaunt
  ],
  s,
))
