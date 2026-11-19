#import "@preview/unify:0.8.1": qty
#import "@preview/cetz:0.5.3": canvas, draw
#import "@preview/cetz-plot:0.1.4": chart
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "@preview/tudelft-presentation-novanext:0.1.0": tud-presentation, tud-presentation-classic, tud-logo, flame, toolbox, tud-blue, tud-turquoise, tud-royal-blue, tud-orange, tud-green, tud-red, set-footer-fill, show-heading, list-marker, slide, AR, if-classic-else

#import "clip-image.typ": clip-image, aspect-ratio
#import "gantt.typ": project, blockheight, vline

#show: tud-presentation
// #show: tud-presentation-classic

#set document(
  author: ("Phobos, A. B.", "Deimos, C. D. E."),
  title: [Placeholer Title],
  date: datetime.today(),
)


#{
  set page(
    fill: tud-blue,
    background: {context place(
      center,
      dx: 0.2 * page.width,
      image(
        "tud-bieb.jpg",
        width: 0.6 * page.width,
        height: 1 * page.height,
      ),
    )}
  )
  
  set-footer-fill(white, none)

  slide({
    set text(fill:white)
    set align(horizon)
    context(toolbox.side-by-side(
      columns: (
        .4 * page.width - 4cm,
        .6 * page.width - 4cm,
      ),
      gutter: 4cm,
      context({
        v(2fr)
        title()
        document.author.join(", ", last: " and ")
        line(length: 4em, stroke: white)
        v(1fr)
      }),
      [],
      ))
  })
}

#set-footer-fill(auto)

// optionally get rid of top-level headers too:
// #show heading.where(level:1): it => [] 

#[
  #set page(
    background: {
      context(image(
        "tud-bieb.jpg",
        width: page.width,
        height: page.height,
      ))
    },
    margin: 2cm,
  )
  = Introduction
]


#slide[
  #import "@preview/cades:0.3.1": qr-code


This template
- follows the #link("https://www.tudelft.nl/en/tu-delft-corporate-design")[TU Delft corporate design]
- uses the #link("https://polylux.dev/book/polylux.html")[Polylux] package for Typst.

The version history is tracked on \ https://gitlab.com/novanext

Here is a QR Code for the TU Delft corporate design site: 

#v(1fr)
#h(1fr) #box(
  qr-code("https://www.tudelft.nl/en/tu-delft-corporate-design", width: 4cm)
)
]

== Fonts

#slide[
  #show-heading()

To follow the TU Delft corporate design and use the font family
#link("https://fonts.google.com/specimen/Roboto+Slab")[Roboto Slab] and
#link("https://en.wikipedia.org/wiki/Arial")[Arial], use the following show rule:

`#show: tud-presentation`

For a more classic look, use the Typst default font Libertinus Serif#footnote[https://github.com/alerque/libertinus/blob/master/documentation/Opentype-Features.pdf]

`#show: tud-presentation-classic`


// https://typst.app/docs/reference/text/text/#parameters-font
// https://fonts.google.com/specimen/Libertinus+Serif
]

== Logo

#slide[
  #show-heading()

  The TU Delft logo and the flame can be inserted and customized using the commands `#tud-logo` and `#flame`, respectively.

  The colours of the TU Delft corporate style are defined.

  #text(size: 40pt, {
    box(stroke: tud-red, tud-logo(full: false))
    box(fill: tud-blue, tud-logo(fill: white, U: none)) // `U: none` to use `fill` color for the U
    box(stroke: tud-red, flame(fill: tud-blue, width: 4cm))
  })
]


== Lists

#slide[
  #show-heading()
  #toolbox.side-by-side(
    gutter: 3em, [
      - Unnumbered
      - List
        - With
        - Subitems
      
    ], [
    + One
    + Two
      + Three
      + Four
        + Five
        + Six
    ]
  )
]

#[
  #set page(
    background: {
      context(image(
        "tud-bieb.jpg",
        width: page.width,
        height: page.height,
      ))
    },
    margin: 2cm,
  )
  = Sectioning
]
#heading(
  level: 2,
  outlined: false,
  numbering: none,
)[Outline]

#slide[
  #show outline.entry: it => link(
    it.element.location(),
    it.indented(it.prefix(), it.body())
  )
  #show-heading(numbering: none)
  #outline(title: none)
]

== Headings

#slide[
  #show-heading()

  A level-one heading, e.g., `= Sectioning` inserts a title slide for the section, as you have seen before.
  
  A level-two or level-three heading, e.g., `== Subsection` is not shown by itself, but can be shown inserts a title slide for the subsection. The command `#show-heading()` can be used to show the current section and subsection on the slide.

  This way, the heading can be repeated on all slides in the (sub)section, if desired.
]

#[
  #set page(
    background: {
      context(image(
        "tud-bieb.jpg",
        width: page.width,
        height: page.height,
      ))
    },
    margin: 2cm,
  )
  = One more section
]

#slide({
  set par(justify: false)
  table(
    columns: (0.6fr, 1fr, 1fr, 1fr),
    table.vline(x: 1, start: 1),
    table.header[Month][Title][Author][Genre],
    [January], [The Great Gatsby], [F. Scott Fitzgerald], [Classic],
    [February], [To Kill a Mockingbird], [Harper Lee], [Drama],
    [March], [1984], [George Orwell], [Dystopian],
    [April], [The Catcher in the Rye], [J.D. Salinger], [Coming-of-Age],
  )
})

#let data = (
    ("Gnu" ,36),
    ("Gnat", 18),
    ("Fly", 23),
    ("Foo", 14),
    ("Bar", 9),
  )
#let slice-style = (
  (fill: rgb("#00a7d6"), stroke: none),
  (fill: rgb("#047288"), stroke: none),
  (fill: rgb("#eb7146"), stroke: none),
  (fill: rgb("#00a390"), stroke: none),
  (fill: rgb("#f0bd3e"), stroke: none),
  (fill: rgb("#c23130"), stroke: none),
)


#slide[
  https://typst.app/universe/package/cetz-plot/


  #toolbox.side-by-side(
    gutter: 1cm,
    columns: (1fr, .5fr),
    [
    #canvas({
      import draw: *
      chart.piechart(
        data,
        value-key: 1,
        label-key: 0,
        radius: 5,
        slice-style: slice-style,
        inner-radius: 1,
        inner-label: (content: (value, label) => [#text(white, str(value) + " %")], radius: 110%),
        outer-label: (content: none),
        legend: (label: none),
      )
  })
], [#align(horizon,
 for (i, (label, value)) in data.enumerate() {
  [
    #list-marker(color: slice-style.at(i).fill, width: .7em, dy: 0em) #label (#str(value) %) \
  ]
 })
])
]

#slide[
#import "@preview/lilaq:0.6.0" as lq
https://lilaq.org/docs/reference/bar


#show: lq.cond-set(
  lq.grid.with(kind: "x"),
  stroke: none
)

#show: lq.cond-set(
  lq.grid.with(kind: "y"),
  stroke: 1pt
)

#show: lq.set-tick(inset: 0pt)

#context(lq.diagram(
  width: 0.8 * page.width,
  height: 0.5 * page.height,
  xaxis: (
    ticks: data.map(x => x.at(0))
      .map(rotate.with(-45deg, reflow: true))
      .map(align.with(right))
      .enumerate(),
    subticks: none,
    position: bottom,
  ),
  yaxis: (
    position: left,
    stroke: none,
    subticks: none,
  ),
  lq.bar(
    range(5),
    data.map(x => x.at(1)),
    fill: slice-style.map(x => x.fill).slice(0, data.len())

  )
)
)
]

#slide[
  Clipping an image; orginal aspect ratio is #context(aspect-ratio(image("tud-bieb.jpg")))
  @tud-bieb

  #clip-image("tud-bieb.jpg", height: 4cm, width: 4cm, img-height: 4cm, img-width: 6cm, radius: 2cm, dx: -1cm, fit: "contain")
//
#box(
  stroke: red,
//  clip: true,
  width: 4cm, height: 4cm,
  {move(dx: -1cm,
    image(
      "tud-bieb.jpg", fit: "cover",
      height: 4cm, width:auto
    ),
  )},
)
//
#box(
  stroke: red,
  clip: true,
  width: 4cm, height: 4cm,
  {move(dx: -2cm,
    image(
      "tud-bieb.jpg", fit: "cover",
      height: 4cm, width:6cm
    ),
  )},
)

#let img = image("tud-bieb.jpg")
// Get dimensions of the source image
#let AR = context({
  let dims = measure(img)
  dims.at("width") / dims.at("height")
})


// right-aligned with the correct aspect ratio
#box(
  stroke: red,
  clip: true,
  width: 4cm, height: 4cm,
  // inset: (left:-0cm, right: 0cm),
  context({
    
    align(right, image("tud-bieb.jpg", height: 4cm,
    width: aspect-ratio(img) * 4cm))
  }),
)
// remove 1 cm from the right
#box(
  stroke: red,
  clip: true,
  width: 4cm, height: 4cm,
  inset: (left:0cm, right:-1cm),
  context({
    let img = image("tud-bieb.jpg", height:4cm)
    let dims = measure(img)
    align(right, image("tud-bieb.jpg", height: 4cm,
    width: dims.at("width") / dims.at("height") * 4cm))
  }),
)
//
#clip-image("tud-bieb.jpg",
  width: 4cm, height: 4cm, img-height: 4cm, alignment: right)

]

#set-footer-fill(none)

#slide({
  align(horizon + center,
  text(size: 100pt, tud-logo(full:false)))
})

#set-footer-fill(white, none)

#{
  set page(fill: tud-blue)
  slide(align(horizon + center,
      text(size: 4em, fill: white, [$ AR = S / b^2 $])
  ))
}

#slide[
#import "@preview/merman:0.5.0": analyze-mermaid, mermaid, mermaid-result, mermaid-svg

#scale(125%, origin:left,
mermaid(
"
%%{init: {'theme': 'base', 'themeVariables': {
    'fontSize': '20px',
    'sectionBkgColor': '"+tud-blue.to-hex()+"',
    'altSectionBkgColor': '#ffffff',
    'taskBkgColor': '"+tud-blue.to-hex()+"',
    'taskBorderColor': '"+tud-blue.to-hex()+"',
    'activeTaskBorderColor': '"+tud-orange.to-hex()+"',
    'taskTextColor': '#ffffff',
    'activeTaskTextColor': '#ffffff',
    'doneTaskTextColor': '#ffffff',
    'activeTaskBkgColor': '"+tud-orange.to-hex()+"',
    'doneTaskBkgColor': '"+tud-green.to-hex()+"'
}}}%%
  gantt
    title A Gantt Diagram
    dateFormat YYYY-MM-DD
    section Section
        A task          :done, a1, 2014-01-01, 30d
        Another task    :active, after a1, 20d
    section Another
        Task in Another :2014-01-12, 12d
        another task    :24d
"))


- https://mermaid.ai/open-source/syntax/gantt.html
- https://mermaid.ai/open-source/config/theming.html#theme-variables
]

== A simple Gantt chart

#slide[
  #show-heading()
  #v(-16mm)

#align(center + horizon,
diagram(
  node-outset: 0pt,
  node-inset: 0pt,
  for year in range(26, 30) {
    vline((-1, 8), [#sym.quote.single.r#year], (year))
  },
  vline((-1, 8), [], (30)),
  for year in range(26 * 4, 30 * 4) {
    vline((-0.25, 7.5), text(size:0.7em, [Q#calc.rem(year, 4)]), (year / 4), "dotted")
  },  
  project(y: (1, blockheight), [Lit. A], (26 + 0/12, 6/12), red),
  project(y: (2, blockheight), [Lit. B], (26 + 4/12, 7/12), red),
  project(y: (3, blockheight), [Method I], (27 + 4/12, -4/6), red),
  project(y: (4, blockheight), [Method II], (27 + 0/12, 14/12), blue),
  project(y: (5, blockheight), [Method III], (28 + 3/12, -10/12), blue),
  project(y: (6, blockheight), [Results 1], (29 + 3/12, -18/12), green),
  project(y: (7, blockheight), [Results 2], (30, -18/12), green),
))
]

#{
  set page(
    fill: tud-blue,
    background: {
      context place(
        center,
        dx: -0.05 * page.width,
        dy: -0.05 * page.width,
        flame(fill: tud-royal-blue,
          width: 3 * page.height,
          height: 2 * page.height,
        ),
      )
    },
    margin: 2cm,
  )

  set-footer-fill(white)

  slide({
    align(right + bottom, {
      ({
        text(
          size: 1.6em,
          weight: "regular",
          fill: white,
          if-classic-else(
            text(
              size: 1.15em,
              font: "Libertinus Serif",
              "Thank you for your attention!"
            ),
            text(
              font: "Roboto Slab",
              "Thank you for your attention!"
            )
          )
        )
        v(-.5em)
        text(
          fill: white, size: 1.25em,
          "Einstein & Lorentz"
        )
      })
      v(2em)
    })
  })
}

#heading(
    level: 2,
    outlined: false,
    numbering: none,
  )[References]
#slide({
  show-heading(numbering: none)
  bibliography("typst.bib", title: none)
})
