#import "@preview/touying:0.6.1": *
#import "@preview/touying-swufe:0.1.0": *
// #import "../lib.typ": *

#show: swufe-theme.with(
  // Lang and font configuration
  aspect-ratio: "16-9",
  lang: "en",
  font: ("Libertinus Serif",),


  // Basic information
  config-info(
    title: [Typst Slide Theme for Southwest University of Finance and Economics Based on Touying],
    subtitle: [基于Touying的西南财经大学Typst幻灯片模板],
    short-title: [Typst Slide Theme for Southwest University of Finance and Economics Based on Touying],
    authors: [雷超#super("1"), Lei Chao#super("1,2")],
    author: [Presenter: Lei Chao],
    date: datetime.today(),
    institution: ([#super("1")金融学院 西南财经大学], [#super("2")西南财经大学]),
    banner: emoji.school,
  ),

  config-colors(
    primary: rgb(1, 83, 139),
    primary-dark: rgb(0, 42, 70),
    secondary: rgb(255, 255, 255),
    neutral-lightest: rgb(255, 255, 255),
    neutral-darkest: rgb(0, 0, 0),
  ),
)
#title-slide()

#outline-slide()

= The section I

== Slide I / i

- Slide content.
  - content point 1
  - content point 2
- Slide content.

== Slide I / ii

Slide content.

= The section II

== Slide II / i
- Insert figure
```typst
#figure(
  image("fig.png", width: auto, height: 80%),
  caption: [Example Figure],
)
```


== Slide II / ii

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    stroke: none,
    align: center + horizon,
    inset: .5em,
    table.hline(stroke: 2pt),
    [Name], [Age], [Major],
    table.hline(stroke: 1pt),
    [Zhang San], [23], [Finance],
    [Li Si], [22], [Economics],
    [Wang Wu], [24], [Accounting],
    table.hline(stroke: 2pt),
  ),
  caption: "Example Table",
)

= Last Section
==
#ending-slide("Thank You!")
