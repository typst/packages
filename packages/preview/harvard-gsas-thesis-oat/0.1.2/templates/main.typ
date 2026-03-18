#import "@preview/harvard-gsas-thesis-oat:0.1.2": frontmatter, school-color

#let ifb = $"fb"^(-1)$
#let total-lumi = [140 #ifb]
#let cme = $sqrt(s) = 13 "TeV"$
#let pT = $p_"T"$

#show: frontmatter.with(
  title: "Dissertation Title",
  abstract: [
      While the search for ever heavier Beyond the Standard Model (BSM) particles is a popular excercise at the
      energy frontier, the search for XXX has been less explored. This thesis presents a
      search for YYY in a novel #total-lumi dataset collected by the ATLAS experiment during Run 2 at the
      Large Hadron Collider (LHC) at #cme. The dataset is unique in that it is collected at the
  ],
  author: "John Harvard",
  advisor: "Melissa Franklin",
  doctor-of: "Physics",
  major: "Physics",
)

= The LHC and the ATLAS

#lorem(80)

#figure(
  table(
    columns: 4,
    [t], [1], [2], [3],
    [y], [0.3s], [0.4s], [0.8s],
  ),
  caption: [Timing results],
)

== Some equations
#lorem(20)

$
0.002(x + 89.6)^(-1.06log(x))
$
