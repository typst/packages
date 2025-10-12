#import "@preview/touying:0.6.1": *
#import "@preview/cetz:0.4.2"
#import "@preview/touying-criterion:0.1.0": *

#show raw: set text(size: 12pt)
#show figure.caption: set text(size: 10pt)

#show: touying-criterion.with(
  aspect-ratio: "16-9",
  footer: [#datetime.today().display("[year]-[month]-[day]")], 
  show-level-one: false,
  config-info(
    title: [The "Criterion" slide template],
    subtitle: [Straightforward Presentations],
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

    let mark = (end: "triangle", length: 0.2)
    let textfill = rgb("#333333")

    let objects = (
      (type: "circle", x: 0, y: 0, fill: rgb("000000"), text: "0", textfill: rgb("ffffff")),
      (type: "circle", x: -3, y: -3, fill: none, text: "1", textfill: textfill),
      (type: "circle", x: 4, y: -3, fill: none, text: "1", textfill: textfill),
      (type: "circle", x: 1, y: -5, fill: none, text: "2", textfill: textfill),
      (type: "circle", x: 5, y: -8, fill: none, text: "2", textfill: textfill),
      (type: "circle", x: -4.5, y: -7.5, fill: none, text: "2", textfill: textfill),
      (type: "circle", x: 1.5, y: -9, fill: none, text: "3", textfill: textfill),
      (type: "circle", x: 8, y: -11,  fill: none, text: "3", textfill: textfill),
    )

    for obj in objects {
      circle((obj.x,obj.y), radius: (.75, .75), fill: obj.fill)
        content(
          (obj.x, obj.y), 
          box(
            width: 2em,
            height: 1em,
            align(center + horizon)[
              #par(
                leading: 0.4em,
                text(
                  size: 14pt,
                  weight: "medium",
                  fill: obj.textfill,
                )[#obj.text]
              )
            ]
          ),
          anchor: "center"
        )
    }

    line((4, -2.25),(0.75, 0), stroke: (paint: black, thickness: 3pt), mark: mark)
    line((-3, -2.25),(-0.75, 0), stroke: (paint: black, thickness: 3pt), mark: mark)
    line((0.25, -5),(-2.25, -3), stroke: (paint: black, thickness: 3pt), mark: mark)
    line((1.75, -5),(3.25, -3), stroke: (paint: black, thickness: 3pt), mark: mark)
    line((-4.5, -6.75),(-3, -3.75), stroke: (paint: black, thickness: 3pt), mark: mark)
    line((1.5, -8.25),(1, -5.75), stroke: (paint: black, thickness: 3pt), mark: mark)
    line((2.25, -9),(4.25, -8), stroke: (paint: black, thickness: 3pt), mark: mark)
    line((5, -7.25),(4, -3.75), stroke: (paint: black, thickness: 3pt), mark: mark)
    line((8, -10.25),(5.75, -8), stroke: (paint: black, thickness: 3pt), mark: mark)
  }),
  caption: [Fully built RPL-DODAG #cite(<dodag-figure>)]
)

#focus-slide[WATCH OUT]

#slide(footer: "Override the default footer if necessary.", show-level-one: true, title: "Mixing it Up")[

- Show the section heading for individual slides with `show-level-one: true`

- *Or* you can show it for all slides when configuring the theme...

```typst 
  #show: touying-criterion.with(
    aspect-ratio: "16-9",
    lang: "en",
    font: "Source Sans 3",
    text-size: 22pt,
    show-level-one: false,
    footer: [#datetime.today().display("[year]-[month]-[day]")], 
    config-info(
      title: [The "Criterion" slide template],
      subtitle: [Clean slides],
      author: [Computer Science Department],
      date: datetime.today(),
      institution: [Funk Town State University],
    ),
  )'
```
]

#heading(outlined: true, depth: 1)[References]
#slide(show-level-one: false, title: "Literature and Figure", footer: "")[#bibliography("refs.yaml", title: none)]




