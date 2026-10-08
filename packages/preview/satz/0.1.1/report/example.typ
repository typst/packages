// Example: Scientific protocol using the report template.
// Shows config overrides, sections, figures, tables, math, citations.
// Compile: typst compile example.typ

#import "@preview/satz:0.1.1": report

#show: report.with(
  config: (
    // Override defaults: different font, tighter margins, blue accent palette
    page: (
      paper: "a4",
      margin: (top: 2cm, bottom: 2cm, left: 2.5cm, right: 2.5cm),
    ),
    typography: (
      font: "EB Garamond",
      size: 11pt,
      leading: 0.65em,
      hyphenate: false,
      justify: true,
    ),
    headings: (
      numbering: "1.1",
      h1-size: 16pt,  h1-below: 0.65em,
      h2-size: 13pt,  h2-below: 0.65em,
      h3-size: 11pt,  h3-below: 0.65em,
      h4-size: 11pt,  h4-below: 0.4em,
    ),
    colors: (
      bg-paper: rgb("#FAFAFA"),
      bg-subtle: rgb("#EFF6FB"),
      brand-primary: rgb("#1B4965"),
      brand-accent: rgb("#468FAF"),
      text-main: rgb("#1E1F24"),
      text-muted: rgb("#5A6B7A"),
    ),
    links: (
      color: rgb("#468FAF"),
    ),
  ),
)

= Isolation and Characterization of Extracellular Vesicles from MSC Cultures

== Introduction

Extracellular vesicles (EVs) are lipid bilayer-enclosed particles naturally
released from cells that mediate intercellular communication by transferring
proteins, lipids, and nucleic acids between donor and recipient cells
@thery2018. Among the various EV subtypes, small EVs ($< 200$ nm in
diameter) have garnered significant interest as potential biomarkers and
therapeutic agents @kalluri2020.

Mesenchymal stem cells (MSCs) are particularly prolific producers of
therapeutically relevant EVs. However, current isolation protocols suffer
from low yield and purity, hampering clinical translation. Here we present
an optimised, reproducible protocol for the isolation and characterisation
of small EVs from MSC-conditioned medium using differential
ultracentrifugation combined with size-exclusion chromatography.

#lorem(15)

== Methods

=== Cell Culture

Bone marrow-derived MSCs (passage 3--6) were cultured in DMEM supplemented
with 10% (v/v) EV-depleted foetal bovine serum, 1%
penicillin-streptomycin, and 2 mM L-glutamine. Cells were maintained at
$37 degree C$ in a humidified atmosphere containing 5% $"CO"_2$. Conditioned
medium was collected after 48 h of incubation at 80--90% confluence.

=== EV Isolation by Differential Ultracentrifugation

All centrifugation steps were carried out at $4 degree C$. The workflow
proceeded as follows:

+ Centrifuge conditioned medium at $300 times g$ for 10 min to pellet
  cells and large debris.
+ Transfer supernatant to fresh tubes; centrifuge at $2000 times g$ for
  20 min to remove apoptotic bodies and microvesicles.
+ Filter supernatant through a 0.22 $mu"m"$ PES filter.
+ Ultracentrifuge at $100\,000 times g$ for 90 min in a Type 70 Ti rotor
  (Beckman Coulter) to pellet small EVs.
+ Resuspend pellet in 200 $mu"L"$ of particle-free PBS.

All steps were performed in triplicate across three independent MSC donors.

=== Nanoparticle Tracking Analysis

EV size distribution and concentration were measured using a NanoSight NS300
(Malvern Panalytical) equipped with a 488 nm laser. Five 60 s videos were
recorded for each sample with a camera level of 13 and analysed with NTA
software version 3.4.

=== Western Blotting

EV lysates (10 $mu"g"$ total protein) were separated on 12% SDS-PAGE gels
and transferred to PVDF membranes. Membranes were probed with antibodies
against the EV markers CD9, CD63, and CD81 (all 1:1000, System Biosciences),
and the negative marker calnexin (1:2000, Abcam). #lorem(8)

== Results

=== Size Distribution and Concentration

NTA measurements revealed a mean particle diameter of
$105.4 ± 8.2$ nm with a mode of $82.1$ nm
(@fig:size-distribution). The mean particle concentration was
$2.8 times 10^11$ particles per mL of conditioned medium.

#figure(
  rect(
    width: 80%,
    height: 4.5cm,
    fill: rgb("#EFF6FB"),
    stroke: 0.5pt + rgb("#468FAF"),
  ),
  caption: [
    Representative particle size distribution of small EVs isolated
    from MSC-conditioned medium, measured by NTA. Error bars denote
    $±$ SEM ($n = 3$).
  ],
) <fig:size-distribution>

=== Protein Marker Validation

Western blotting confirmed the presence of canonical EV markers CD9, CD63,
and CD81 in all three donor preparations. Calnexin, an endoplasmic
reticulum-resident protein absent from EVs, was not detected, confirming
the absence of cellular contamination.

#lorem(12)

=== Yield Comparison

We compared our optimised protocol with a standard ultracentrifugation-only
approach @thery2018. The results are summarised in @tab:yield.

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: center + horizon,
    stroke: 0pt,
    [*Parameter*], [*Standard UC*], [*Optimised*], [*Fold change*],
    [Particles/mL ($times 10^11$)], [$1.52 ± 0.31$], [$2.84 ± 0.22$], [$1.9 times$],
    [Mean size (nm)], [$118.4 ± 6.1$], [$105.4 ± 8.2$], [$0.89 times$],
    [Protein yield ($mu"g"$)], [$42.3 ± 5.7$], [$38.1 ± 4.2$], [$0.90 times$],
    [Purity (part./$mu"g"$ prot.)], [$(3.6 ± 0.8) times 10^9$], [$(7.5 ± 1.1) times 10^9$], [$2.1 times$],
  ),
  caption: [
    Comparison of isolation yield and purity between standard
    ultracentrifugation (UC) and the optimised protocol. Values are
    displayed as mean $±$ SD ($n = 3$).
  ],
) <tab:yield>

The optimised protocol achieved a $2.1 times$ improvement in purity
over standard UC, as measured by particles per microgram of protein.

== Discussion

The protocol described here reliably produces high-quality small EVs from
MSC-conditioned medium. The combination of differential centrifugation,
filtration, and size-exclusion chromatography yields particles within the
canonical small EV size range with high purity @kalluri2020.

#lorem(20)

Several limitations should be acknowledged. First, the protocol remains
labour-intensive, requiring approximately 5 h from start to finish. Second,
batch-to-batch variability in MSC cultures may affect EV yield; we observed
a coefficient of variation of 18--22% across the three donors tested.
Third, the ultracentrifugation step may cause EV aggregation or damage,
as previously reported @linares2017.

#lorem(12)

== Conclusion

We present a robust, well-characterised protocol for small EV isolation
from MSC cultures that outperforms standard methods in purity while
maintaining comparable yield. The protocol is suitable for downstream
applications including proteomics, RNA sequencing, and functional assays.

#lorem(6)

#bibliography("refs.bib")
