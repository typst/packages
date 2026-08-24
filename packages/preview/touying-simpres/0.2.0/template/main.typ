#import "@preview/touying:0.7.4": *
#import "@preview/cetz:0.5.2"
#import "@preview/touying-simpres:0.2.0": *

#show raw: set text(size: 12pt)
#show figure.caption: set text(size: 10pt)

#show: touying-simpres.with(
  aspect-ratio: "16-9",
  footer: [#datetime.today().display("[year]-[month]-[day]")], 
  show-level-one: false,
  config-info(
    title: [The "Simpres" slide template],
    subtitle: [Presentation Template for Education and Business],
    author: [thy0s],
    date: datetime.today(),
    institution: [Funk Town State University],
  ),
)

#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))

#title-slide[]

#outline-slide(depth: 2)

= Example Slides

== Bullet Points

- Networks are a collection of interconnected, autonomous computing devices #cite(<tanenbaum-2021>)

- *Also pay attention to this bold text!*

  - _This here is also important..._

== A CeTZ Figure
#figure(
  cetz-canvas({
    import cetz.draw: *

    let darkgray = luma(20%)

    let objects = (
      (pos: (0, 0), name: "n0", fill: black, text: "0", textfill: white),
      (pos: (-3, -3), name: "n1", fill: none, text: "1", textfill: darkgray),
      (pos: (4, -3), name: "n2", fill: none, text: "1", textfill: darkgray),
      (pos: (1, -5), name: "n3", fill: none, text: "2", textfill: darkgray),
      (pos: (5, -8), name: "n4", fill: none, text: "2", textfill: darkgray),
      (pos: (-4.5, -7.5), name: "n5", fill: none, text: "2", textfill: darkgray),
      (pos: (1.5, -9), name: "n6", fill: none, text: "3", textfill: darkgray),
      (pos: (8, -11),  name: "n7", fill: none, text: "3", textfill: darkgray),
    )

    for obj in objects {
      circle(obj.pos, radius: (.75, .75), fill: obj.fill, name: obj.name)
        content(
          obj.pos, 
          text(size: 14pt, fill: obj.textfill)[#obj.text]
        )
    }

    let dag_edge = line.with(
      stroke: (paint: black, thickness: 3pt),
      mark: (end: "triangle", length: 0.2),
    )

    dag_edge("n2", "n0")
    dag_edge("n1", "n0")
    dag_edge("n3", "n1")
    dag_edge("n3", "n2")
    dag_edge("n5", "n1")
    dag_edge("n6", "n3")
    dag_edge("n6", "n4")
    dag_edge("n4", "n2")
    dag_edge("n7", "n4")
  }),
  caption: [Fully built RPL-DODAG #cite(<dodag-figure>)]
)

#focus-slide[WATCH OUT]

#slide(footer: "Override the default footer if necessary.", show-level-one: true, title: "Mixing it Up")[

- Show the section heading for individual slides with `show-level-one: true`

- *Or* you can show it for all slides when configuring the theme...

```typst 
  #show: touying-simprpes.with(
    aspect-ratio: "16-9",
    lang: "en",
    font: "Source Sans 3",
    font-raw: "Source Code Pro"
    text-size: 22pt,
    text-size-raw: 11pt,
    show-level-one: false,
    footer: [#datetime.today().display("[year]-[month]-[day]")], 
    config-info(
      title: [The "Simpres" slide template],
      subtitle: [Presentation Template for Education and Business],
      author: [Computer Science Department],
      date: datetime.today(),
      institution: [Funk Town State University],
    ),
  )'
```
]

#heading(outlined: true, depth: 1)[References]
#slide(show-level-one: false, title: "Literature and Figure", footer: "")[#bibliography("refs.yaml", title: none)]




