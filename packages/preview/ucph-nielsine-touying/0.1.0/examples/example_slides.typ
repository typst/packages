#import "@preview/mitex:0.2.4": mitex
#import "../src/lib.typ" as uc
// #import "@preview/ucph-nielsine-touying" as uc
#import "@preview/touying:0.6.1" as ty
#import "@preview/numbly:0.1.0": numbly
#import "@preview/pinit:0.2.2" as pi

#show: uc.ucph-metropolis-theme.with(
  header-right: align(right, image("../assets/ucph_1_seal.svg", height: 1.1cm)),
  ty.config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
    institution: [University of Copenhagen],
    logo: image("../assets/ucph_1_seal.svg"),
  ),
  /// Uncomment this if you have animations in your slides and only want to keep the last subslide
  // ty.config-common(
  //   handout: true
  // )
)

#uc.title-slide()

// If you want a table of contents
// #uc.components.adaptive-columns(outline(indent: 1em))

= First section

== First slide
Wow, this is a slide.

== Second slide
The music experience has been #pi.pin(1)cancelled#pi.pin(2).

#pi.pinit-highlight(1, 2)

#pi.pinit-point-from(2)[This quote is from the Severance TV-show]

== Animations
#uc.slide[
  Touying equation with pause:

  $
    f(x) & = #ty.pause x^2 + 2x + 1 & = #ty.pause (x + 1)^2
  $

  #ty.meanwhile

  Touying equation is very simple.
]

== Complex Animations
#uc.slide(
  repeat: 3,
  self => [
    #let (uncover, only, alternatives) = ty.utils.methods(self)

    At subslide #self.subslide, we can

    use #uncover("2-")[`#uncover` function] for reserving space,

    use #only("2-")[`#only` function] for not reserving space,

    #alternatives[call `#only` multiple times \u{717}][use `#alternatives` function #sym.checkmark] for choosing one of the alternatives.
  ],
)

== Intermezzo
If you have "animations" in your presentation, you can set "handout" to "true" in the config and only include the last subslide.
```typ
#import "@preview/ucph-nielsine-touying" as uc
#import "@preview/touying:0.6.1" as ty
show: uc.ucph-metropolis-theme.with(
  // ...
  ,
ty.config-common(handout: true)
)
```

== Slide with columns
#uc.slide(align: center + horizon, composer: (1fr, 1fr))[
  First column.
][
  Second column. #cite(<schelling1971dynamic>, form: "prose")#footnote("a footnote")
]

= The OLS estimator
== Derivation of the OLS estimator
For a multiple linear regression model, the equation can be written in matrix form as:

$
  bold(y)=bold(X) bold(beta) + bold(epsilon)
$

where:
- $bold(y)$ is an $n times 1$ vector of observed dependent variables.
- $bold(X)$ is an $k times (k+ 1)$ matrix of independent variables (including a column of ones for the intercept).
- $bold(beta)$ is a vector of unknown coefficients.
- $bold(epsilon)$ is an $n times 1$ vector of error terms.

#pagebreak()


Implying we have a vector of residuals given by:

$
  bold(epsilon) = bold(y)-bold(X) bold(beta)
$

Our objective is to minimize the sum of squared residuals:

$
  min_(beta) bold(epsilon)^T bold(epsilon)&=(bold(y)-bold(X) bold(beta))^T (bold(y)-bold(X) bold(beta)) #sym.arrow.l.r
  \
  &= underbrace(bold(y)^T bold(y), perp bold(beta)) - bold(y)^T bold(X) bold(beta)-bold(beta)^T bold(X)^T bold(y)+ bold(beta)^T bold(X)^T bold(X) bold(beta) arrow.l.r
  \
  &= -2bold(beta)^T
  bold(X)^T bold(y) + bold(beta)^T bold(X)^T bold(X) bold(beta)
$

_Note_: By multiple a vector with itself transposed with just a scalar, or in this case $bold(epsilon)^T bold(epsilon)$ which is the sum of squared error terms.

#pagebreak()

$
  diff/(diff bold(beta))(-2bold(beta)^T
    bold(X)^T bold(y) + bold(beta)^T bold(X)^T bold(X) bold(beta)) & = 0 arrow.l.r                  \
                                    2 bold(X)^T bold(X) bold(beta) & = 2bold(X)^T bold(y) arrow.l.r \
                                       bold(X)^T bold(X)bold(beta) & = bold(X)^T bold(y) arrow.l.r
$
Multiply both sides with $(bold(X)^T bold(X))^(-1)$:

$
  underbrace((bold(X)^T bold(X))^(-1) bold(X)^T bold(X), = bold(I))) bold(beta) &= (bold(X)^T bold(X))^(-1) bold(X)^T bold(y) arrow.l.r
  \
  hat(bold(beta)) &= (bold(X)^T bold(X))^(-1) bold(X)^T bold(y)
$

#uc.slide(align: left)[
  #align(center + top)[
    #uc.framed(title: "The OLS estimator", block-width: 60%)[
      $
        hat(bold(beta)) = (bold(X)^T bold(X))^(-1) bold(X)^T bold(y)
      $
    ]]

  - This is very important.
  - Remember this.
]

= Colors

== Let me show you the colors

#uc.show_color_pallette()

#uc.focus-slide()[
  Wake up!
]


#let my_gradient = gradient.linear(uc.colors.ucph_dark.red, uc.colors.ucph_dark.blue, angle: 45deg)

#uc.focus-slide(fill: my_gradient)[
  Wake up with a gradient!
]


== References
#set text(size: 14pt)
#bibliography("bibliography.bib", style: "harvard-cite-them-right", title: none)

#show: ty.appendix
= Appendix
== Appendix
123

= Page layout
== Page layout
#let container = rect.with(height: 100%, width: 100%, inset: 0pt)
#let innerbox = rect.with(stroke: (dash: "dashed"))

#set text(size: 30pt)
#set page(
  paper: "presentation-16-9",
  header: container[#innerbox[Header]],
  header-ascent: 30%,
  footer: container[#innerbox[Footer]],
  footer-descent: 30%,
)

#place(top + right)[Margin→]
#container[
  #container[
    #innerbox[Content]
  ]
]
