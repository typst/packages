#import "@preview/unify:0.8.1": qty, num
#import "@preview/cetz:0.5.3": canvas, draw
#import "@preview/tudelft-thesis-novanext:0.1.0": *
#import "@preview/nomos:0.1.0": *

#show: sub-document
#let sinc = math.op("sinc")
#let uppi = $upright(pi)$

= My Awesome Research<awe>

== Document Outline
We will use this document throughout the entire course.  We will keep improving it until it truly lives up to its title.
This is another sentence, not a new paragraph.

#emph[This], however, _is_ a new paragraph, because we inserted a blank line between this sentence and the previous one.

== Math
=== Numbers and units
Once upon a time, in a country far, far away (#qty("10e3","km")), a union of #num(31300) unicorns was feeling #qty("98.7","%") corny.
The ambient temperature had reached a grueling #qty("40","dC") at an atmospheric pressure of #qty("999", "hPa").
When the average unicorn is kept under such conditions for a time $Delta #ncl($t$) > qty("3600","s")$, they will emit ‘light’ at a wavelength #ncl($λ$) of #qty("1550", "nano meter").
Simultaneously, they will start to grow taller at a rate of #qty("20", "um/s").
#add-ncl-silent($t$, "time", unit: "s", sec: "Latin") 
#add-ncl-silent($lambda$, "wavelength", unit: "m", sec: "Greek") 


=== Inline math and equations
The resonance frequency of a mass–spring system can be calculated using the following equation:
$ #add-ncl($omega_"res"$, "resonance frequency", unit: "rad/s", sec: "Greek") = sqrt(#ncl($k$)/#ncl($m$)) space.thin , $
where $#add-ncl($k$, "stiffness", unit: "N/m", sec: "Latin") = qty("5", "mN/m")$ and $#add-ncl($m$, "mass", unit: "kg", sec: "Latin") = qty("32", "kg")$.
In this case, $omega_"res"$ is #qty("12.5e-3", "rad/s").

==== Basic <sec:basic-math>
#show math.integral: math.limits.with(inline: false)
#let sinc = math.op("sinc")
#add-ncl-silent("sinc", "normalised sinc function", unit: "-", sec: "Functions") 
This is another equation:
#add-ncl-silent($uppi$, [Archimedes' constant ($approx 3.14159$)], unit: "-", sec: "Greek") 
#add-ncl-silent($x$, "coordinate", unit: "m", sec: "Latin")
$ uppi/2 = integral_0^infinity sinc x dif x, $ <eq:int-sinc>
where
$ sinc(x) := cases(
  0 & "at" x = 0,
  (frak(I) upright(e)^(upright(i) x)) / x & "elsewhere"
) $ <eq:def-sinc>
==== Advanced
$ italic(Ψ) = partial / (∂t) (integral_0^(2 uppi) cos(2 uppi f t + phi) dif x) ... #h(5cm) \ #h(2cm)
 - arrow(nabla) F times arrow(v) + integral.double_A arrow(italic(Phi)) dot arrow(n) dif A + "additional terms" $

$ chevron.l ξ chevron.r =  lim_(n -> infinity) sum_(i=1)^n ξ_i \/ n $

$ i eq.not upright(i) in.not RR $

$ i planck partial / (partial t) lr(|psi(t) chevron.r) = hat(H) lr(|psi(t) chevron.r) $

$ integral.surf_(partial italic(Omega)) bold(E) dot dif bold(S) = 1 / epsilon_0 integral.triple_italic(Omega) rho dif V $

== Common elements
=== Figures
Don't worry about the placements of figures for now.
Typst will decide where the figures fit best.
Some of the figures in this section can be downloaded at #link("https://novanext.nl/latex/figures.zip").


#figure(
  placement: auto,
  grid(
    columns: 2,
    align: center + horizon,
    row-gutter: 2mm,
    column-gutter: 10mm,
    canvas({
      import draw: *
      polygon((0, 0), 3, angle: -90deg, radius: 4.5em,
        stroke: (paint: red, thickness: 10pt, cap: "round", join: "round"))
      content((0, 0), box(align(center)[Missing \ Figure]), name: "text")
      content((5em, -1em), box(align(left)[Additional explanation for \ the placeholder can be added]),
        anchor: "text")
    }),
    include("mass-spring.typ"),
    "a: striking graph",
    "b: insightful schematic",
  ),
  caption: [
    These  awesome  results  show  our  hypothesis  is  correct.
    In Typst, figures do not float like in LaTeX. When a figure appears at the end of a page causing an ugly gap on the previous page, you can give `#figure` the argument `placement: top` or `placement: bottom` to move it to the top or bottom of a page.
  ],
)
/*

==== File formats
Figures can be stored in different file formats.
PdfLATEX can handle three formats, described in the following.
Portable document format (pdf) Use for diagrams and figures with not too many data points.
The text is searchable (and selectable) within the document.
It's more straightforward to make the font size match the main document than when using bitmap formats.
Bitmaps can also be encapsulated in pdf, which at times is very convenient.

Normal list.
- Text
 - Math
  - Layout

Automatically numbered:
+ Preparations
 + Analysis
+ Conclusions

Dictionary-like list:
/ Ligature: A merged glyph.
 / Kerning: A spacing adjustment
  between two adjacent letters.

#figure({
  show table: format-table(none, auto, auto)
  table(
    columns: 3,
    align: (left, center, center),
    toprule(),
    $n$, $α$, $β$,
    midrule(),
    [one], [3.45], [-11.1e6.7],
    [twelve], [34.5], [-1.11],
    bottomrule(),
  )},
  placement: auto,
  caption: [Some optimistic numbers]
)

#import fletcher.shapes: diamond
#figure(
  diagram(
    node-stroke: 1pt,
    node((0,0), [Start], corner-radius: 2pt, extrude: (0, 3)),
    edge("-|>"),
    node((0,1), align(center)[
      Hey, wait,\ this flowchart\ is a trap!
    ], shape: diamond),
    edge("d,r,u,l", "-|>", [Yes], label-pos: 0.1)
  ),
  placement: auto,
  caption: [A flow chart, found on https://xkcd.com/1195/
    #footnote[
      Actually: https://github.com/cetz-package/cetz-plot/blob/master/gallery/line.typ
    ]
  ]
) <diagram>

== #outline-alt([Cross-referencing#footnote['Crossrefs' for friends.
    ]],"Crossrefs") 
@diagram on #ref(<diagram>, form: "page") has a footnote.

@eq:int-sinc[Eqs.] and @eq:def-sinc[] are in @sec:basic-math.

== Citing literature
This was already noted by
pirates long ago.
@Einstein1926[§2].

#cite(<Einstein1926>, supplement: "§2", form: "prose") was one of them. @Axis2020

#{
  show "A. Einstein": [*A. Eistein*]
  show bibliography: set heading(level: 2)
  bibliography(
    "typst.bib",
)}
*/