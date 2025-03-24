#import "@preview/harvard-gsas-thesis-oat:0.1.3": frontmatter, school-color

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

== Calorimeter
=== Electromagnetic Calorimetry (ECal)

ATLAS uses Liquid Argon (LAr) calorimeter for electromagnetic energy measurements in both the central region#footnote[ Electromagnetic Barrel
Calorimeter, or EMB ] ($abs(eta) < 1.475$)
and end-caps regions#footnote[Electromagnetic Endcap Calorimeter, or EMEC] ($1.375 < |eta| < 3.2$). Together, they provide three layers of calorimeter cells with varying
granularities. Additionally, in the $abs(eta) < 1.8$ region, a LAr presampler sits in front of the first
layer of the LAr ECal and is used to correct the energy loss in the passive material between LAr ECal and the IP.
@LAr_schematic shows the schematic of the EMB in regions with four layers.

#figure(
  rect(fill: school-color),
  caption: [Schematic of the EM Barrel Calorimeter, showing four layers including the presampler (PS) layer],
) <LAr_schematic>


== Some equations
#lorem(20)

$
0.002(x + 89.6)^(-1.06log(x))
$


