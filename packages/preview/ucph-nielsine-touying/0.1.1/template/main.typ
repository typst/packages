#import "@preview/ucph-nielsine-touying:0.1.1" as uc
#import "@preview/touying:0.6.1" as ty
#import "@preview/theorion:0.3.3" as th
#import th.cosmos.clouds as thc

// Font settings
#set text(font: "Fira Sans", weight: "light")
#show math.equation: set text(font: "Fira Math")

// Settings for theorion package
#show: th.show-theorion
#th.set-inherited-levels(0)

#show: uc.ucph-metropolis-theme.with(
  language: "en", // or "dk"
  ty.config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [University of Copenhagen],
    logo: uc.logos.seal,
  ),
)

#uc.title-slide()

// If you want a table of contents
// #uc.components.adaptive-columns(outline(indent: 1em))

= First section
== First slide
Wow, this is a slide.

= Examples
== Example with `theorion`: OLS estimator
#pagebreak()
#thc.definition()[
  The OLS estimator
  $
    hat(bold(beta)) = (bold(X)^T bold(X))^(-1) bold(X)^T bold(y)
  $
]
#th.important-box(fill: uc.colors.ucph-dark.red)[
  - This is very important.
  - Remember this.
]
== Third slide
#uc.slide(align: center + horizon, composer: (1fr, 1fr))[
  First column.
][
  Second column. #cite(<schelling1971dynamic>, form: "prose")#footnote("a footnote")
]

// A "focus" slide that is colored according to the primary color
#uc.focus-slide([
  Wake up!
])

// You can change the coloring to be gradient of UCPH colors instead

#let my-gradient = gradient.linear(uc.colors.ucph-dark.red, uc.colors.ucph-dark.blue, angle: 45deg)
#uc.focus-slide(
  [
    Wake up with a gradient!
  ],
  fill: my-gradient,
)

= Colors
== Color scheme
Colors of the University of Copenhagen can be retrieved by specifying:
```typ
#import "@preview/ucph-nielsine-touying:0.1.1" as uc
// Darks
uc.colors.ucph-dark.red // the default dark red color of UCPH
// Medium
uc.colors.ucph-medium // ...
// Light
uc.colors.ucph-light // ...

```
#pagebreak()

#align(center, uc.show-color-pallette())


== References
#set text(size: 14pt)
#bibliography("bibliography.bib", style: "harvard-cite-them-right", title: none)
