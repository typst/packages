#import "@preview/classic-thesis-uct:0.1.0": *

#let content = [
Use this chapter to position the proposal within the existing body of knowledge. The aim is not to summarise everything, but to show command of the area and isolate the specific opening for the proposed contribution.

== Foundational Concepts

Define the core ideas, terminology, and frameworks needed to understand the project. Keep definitions concise and introduce only the concepts required to make the later research design legible.

== Prior Work

Summarise the most relevant literature thematically rather than paper-by-paper. A short proposal usually benefits from grouping sources by method, theory, dataset, or application area. For example, an overview source can be cited directly [@example2026template], while supporting claims can be cited parenthetically elsewhere.

#side-caption-figure([Example subfigure layout. Use this pattern when comparing prior systems, datasets, instruments, study sites, or design alternatives.])[
  #grid(
    columns: 2,
    column-gutter: 8mm,
    [
      #image("../graphics/simb.png", width: 100%)
      #v(2mm)
      #align(center)[#text(size: 8.5pt)[(a) Example image panel A]]
    ],
    [
      #image("../graphics/wave_glider.png", width: 100%)
      #v(2mm)
      #align(center)[#text(size: 8.5pt)[(b) Example image panel B]]
    ],
  )
]

== Gap Analysis

Conclude with the specific gap your research will address. This should connect directly to the research questions in the next chapter. A strong gap statement is specific, bounded, and matched to a feasible method rather than framed as an open-ended ambition.
]
