#import "@preview/slydekit:0.4.0": *
#import "@preview/cetz:0.5.2"
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#show: slydekit.with(
  title: "Slydekit",
  subtitle: "An example of a presentation template using Typst",
  author: "John Doe",
  date: "2024-06-01",
  institution: "Typst university",
  contact: "john.doe@univ.typst.fr",
  // theme: metropolis,
  // theme: fancy,
  // theme: simple,
  // theme: cambfurt,
  // theme: chalkboard,
  // fonts: (body: "New Computer Modern"),
  // colors: chalkboard-colors-variant,
  lang: "en",
  // navigation-style: "minislide",
  title-logo: (image("images/slydekit-full.svg", height: 2.5cm),),
  slide-logo: image("images/slydekit-mini.svg", height: 1.25cm),
  // handout: true
  // section-numbering: true,
  // numbering-pattern: (section: "I.1.", appendix: "A.1."),
  // slide-level: 2,
  // slide-align: horizon,
)

// #show: hide-new-section-slide

#title-slide

#tableofcontents

= Animations

== Pause, uncover and only

Introduction, #pause always visible.

#uncover(from: 3, to: 4)[A point that is only visible on slides 3 and 4.]

#only(5)[A final note that appears, without reserving space, only at the very end.]

$
  y = f(x) #uncover(from: 3, $= x^2 + 2x + 1$)
$

$
  #boxeq($E = m c^2$)
$

== Item-by-item

#item-by-item[
  - First argument
  - Second argument
  - Third argument
]

== Meanwhile

First

#pause

Second

#meanwhile

Third

#pause

Fourth

== Track

#grid(
  columns: (1fr, 1fr),
  align: top,
  column-gutter: 1em,
  track[
    First point #pause

    Second point #pause

    Third point
  ],
  track[
    First parallel #pause

    Second parallel
  ]
)

== Alternatives

#alternatives[Ann][Bob][Christopher]
likes
#alternatives[chocolate][strawberry][vanilla]
ice cream.

== Code animation

#code-reveal(
  highlight-lines: ("2": 2, "4": 3),
  hide-lines: ("3": 2, "4": 3),
)[
  ```python
  def fib(n):
      if n <= 1:
          return n
      return fib(n-1) + fib(n-2)
  ```
]

= CeTZ/Fletcher integration

#slide("CeTZ integration", steps: 5)[
  #context {
    align(center)[
      #cetz.canvas({
        import cetz.draw: *
        let reveal-cetz = draw-reveal.with(hide-fn: cetz.draw.hide.with(bounds: true))

        // Toujours visible
        circle((0, 0))

        // Visible uniquement à l'étape 2
        reveal-cetz(2, line((0, 0), (2, 1)))

        // Visible à partir de l'étape 3, simule uncover(from: 3)
        reveal-cetz(from: 3, rect((3, 0), (4, 1)))

        // Visible entre les étapes 3 et 5 inclus, simule uncover(from: 3, to: 5)
        reveal-cetz(from: 3, to: 5, {
          circle((5, 0), radius: 0.5, fill: blue)
          circle((6.5, 0), radius: 0.5, fill: green)
          }
        )

        // Visible seulement aux étapes 2 et 4, simule uncover(2, 4)
        reveal-cetz(2, 4, line((0, 2), (2, 3)))
      })
    ]
  }
]

#slide("Fletcher integration", steps: 2)[
  #context {
    let reveal-fletcher = draw-reveal.with(hide-fn: fletcher.hide.with(bounds: true))
    diagram(
      node-stroke: .1em,
      node-fill: gradient.radial(blue.lighten(80%), blue, center: (30%, 20%), radius: 80%),
      spacing: 4em,
      edge((-1,0), "r", "-|>", `open(path)`, label-pos: 0, label-side: center),
      node((0,0), `reading`, radius: 2em),
      edge((0,0), (0,0), `read()`, "--|>", bend: 130deg),

      reveal-fletcher(from: 2, edge(`read()`, "-|>")),

      node((1,0), `eof`, radius: 2em),
      reveal-fletcher(from: 2, edge(`close()`, "-|>")),
      node((2,0), `closed`, radius: 2em, extrude: (-2.5, 0)),
      edge((0,0), (2,0), `close()`, "-|>", bend: -40deg),
    )
  }
]

= Links and references

== Animated slide labels

Pause the animation at this point #anim-label(<my-label>, step: 1) #pause and assign a label to the current sub-slide.

#pagebreak()

Come back to the labeled sub-slide `#anim-label(<my-label>, step: 1)` using this #link(<my-label>, "link").

== References -- Root slide <s:root>

#lorem(10)@knuth

- First point
  - A nested point
    - A deeply nested point

+ First point
+ Second point

Slide @s:root, slide @s:target

#lorem(10)

#place(bottom + right, dy: 1em, link-box(<s:target>, "Go to target slide"))

== References -- Target slide <s:target>

#lorem(25)

#place(right + bottom,link-box(<s:root>, "Go to root slide"))

= Callout boxes

== Information, tip and warning boxes

#info-box[
  #lorem(10)
]

#tip-box[
  #lorem(10)
]

#warning-box[
  #lorem(10)
]

== Important and proof boxes

#important-box[
  #lorem(10)
]

#proof-box[
  #lorem(10)
]

== Question and code boxes

#question-box[
  #lorem(10)
]

#code-box[
  #lorem(10)
]

== Bibliography <hide-toc>

#bibliography("ref.bib")

#focus-slide[This is a focus slide!]

#show: appendix

#tableofcontents

= Appendix

== Table <s:table>

#align(center)[
  #table(
    columns: 3,
    table.header(
      [Substance],
      [Subcritical °C],
      [Supercritical °C],
    ),
    [Hydrochloric Acid],
    [12.0], [92.1],
    [Sodium Myreth Sulfate],
    [16.6], [104],
    [Potassium Hydroxide],
    table.cell(colspan: 2)[24.7],
  )
]

#lorem(25)

== Second appendix

#lorem(25)

= Another appendix

== #lorem(2)
#lorem(25)

#title-slide
