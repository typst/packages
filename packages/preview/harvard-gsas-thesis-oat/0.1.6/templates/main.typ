#import "@preview/harvard-gsas-thesis-oat:0.1.6": frontmatter, school-color, appendix

#let ifb = $"fb"^(-1)$
#let total-lumi = [140 #ifb]
#let cme = $sqrt(s) = 13 "TeV"$
#let pT = $p_"T"$

// Every argument below has a default; they are all spelled out here to show
// what can be customized. `completion-date` defaults to the current month and
// year, and `creative-commons: false` drops the CC BY notice from the
// copyright page.
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
  department: "Department of Physics",
  doctor-of: "Philosophy",
  major: "Physics",
  completion-date: datetime.today().display("[month repr:long] [year]"),
  creative-commons: true,
)

= The LHC and the ATLAS <lhc_and_atlas>

#lorem(80)

#figure(
  table(
    columns: 4,
    [t], [1], [2], [3],
    [y], [0.3s], [0.4s], [0.8s],
  ),
  caption: [Timing results],
) <timing_results>

== Calorimeter <calorimeter>
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

== Cross references

Labelled headings are referenced with their supplement: @lhc_and_atlas is a
chapter, while @calorimeter is a section. Figures, tables and equations carry
the chapter number as their first component, so @timing_results and
@LAr_schematic both live in this chapter, and both counters restart in
@analysis_strategy.

== Some equations
#lorem(20)

$
0.002(x + 89.6)^(-1.06log(x))
$

Equations can be labelled and referenced too, such as @fit_function below:

$
f(x) = p_0 dot (1 - x)^(p_1) dot x^(-p_2 - p_3 log(x))
$ <fit_function>

== Citations

The LHC @Evans:2008lhc and the ATLAS detector @ATLAS:2008detector are
described in detail elsewhere; jets are reconstructed with the anti-$k_t$
algorithm @Cacciari:2008antikt. The bibliography that follows the last chapter
picks these up automatically, and gets a chapter opening of its own without a
chapter number.

= Analysis strategy <analysis_strategy>

Each chapter restarts the figure, table, listing and equation counters, so the
first figure here is numbered 2.1 rather than continuing from @LAr_schematic.

#figure(
  rect(fill: school-color),
  caption: [The first figure of the second chapter],
) <second_chapter_figure>

Tables are counted separately from figures, so this is Table 2.1:

#figure(
  table(
    columns: 3,
    align: (left, right, right),
    table.header([Selection], [Data], [Simulation]),
    [Preselection], [1.2M], [1.1M],
    [#pT $> 30$ GeV], [340k], [332k],
    [Signal region], [1.2k], [1.1k],
  ),
  caption: [Event yields after each stage of the selection.],
) <event_yields>

Code listings get their own counter as well:

#figure(
  ```python
  def signal_region(events):
      return events[(events.pt > 30) & (abs(events.eta) < 2.5)]
  ```,
  caption: [Definition of the signal region selection.],
) <selection_listing>

Multi-line equations are numbered as a whole:

$
cal(L)(mu, theta) &= product_(i in "bins") "Pois"(n_i | mu s_i (theta) + b_i (theta)) \
                  &times product_(j in "nuisance") "Gauss"(theta_j)
$ <likelihood>

#lorem(40)

#bibliography("refs.bib")

// everything after this line is numbered as an appendix: chapters become
// A, B, C, ... and their sections, figures and equations follow the letter
#show: appendix.with()

= Appendix <first_appendix>

#lorem(20) @appendix_figure
$
    a^2 + b^2 = c^2
$

== Appendix is hard
$
    a^3 + b^3 = c^3
$

#figure(
  rect(fill: school-color),
  caption: [Here's a figure in Appendix],
) <appendix_figure>

#figure(
  table(
    columns: 2,
    [Parameter], [Value],
    [$p_0$], [0.002],
    [$p_1$], [89.6],
  ),
  caption: [Tables in the appendix are numbered A.1, A.2, ...],
) <appendix_table>

= Supplementary material

Each appendix chapter gets its own letter, so this is Appendix B while the
previous one is @first_appendix, and the counters restart accordingly.

#figure(
  rect(fill: school-color),
  caption: [The first figure of the second appendix],
) <second_appendix_figure>
