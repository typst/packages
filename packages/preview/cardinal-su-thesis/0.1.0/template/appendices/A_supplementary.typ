#import "@preview/cardinal-su-thesis:0.1.0": *

#chapter-title[Appendix A]
= Supplementary material

Appendices are optional. Once `#show: appendix` is applied in main.typ, headings
switch to letter numbering, running heads say "Appendix A" instead of
"Chapter 4", and the figure, note, table, and methods counters all restart with
a letter prefix. Single spacing is acceptable throughout an appendix.

== Supplementary figures

Supplementary figures use the same `figure` and `fig-legend` pattern as the main
text, but pick up an appendix prefix automatically.

#figure(
  image("../figures/supp-figure-1.jpg", width: 95%),
  caption: [Supporting measurements for the example analysis],
) <fig-supp-one>
#fig-legend[
  *(a)* Group means across the six example conditions. *(b)* Observation-level
  scatter for the same data. This is @fig-supp-one — note the letter prefix,
  which the template derives from the appendix heading rather than from a manual
  counter.
]

== Supplementary notes

`supp-note` produces a numbered, titled callout for supporting discussion that
is too long for a figure legend but does not warrant its own section.

#supp-note[Naming conventions][
  Notes are numbered independently of figures and tables, and can run to several
  paragraphs or contain lists:

  + Label every float you intend to reference.
  + Prefix labels by kind, so that `<fig-...>`, `<tab-...>`, and `<supp-note-...>`
    stay easy to tell apart.
  + Keep labels stable once you start citing them from the main text.

  A note is breakable, so a long one will flow across a page boundary rather
  than overflowing.
] <supp-note-conventions>

#supp-note[Interpreting the example data][
  All values in this document are synthetic. They exist to populate the figures
  and tables so that spacing, numbering, and cross-referencing can be checked
  against a realistic-looking manuscript.
] <supp-note-synthetic>

== Supplementary tables

Large data tables are normally submitted as separate supplemental files rather
than typeset in the PDF. `supp-table` records the title, a description, and the
filename, and produces a numbered, referenceable stub.

#supp-table(
  [Model parameters],
  [One row per parameter, giving its symbol, prior, and fitted value.],
  filename: "TableA1_parameters.tsv",
) <supp-tab-parameters>

#supp-table(
  [Per-condition observations],
  [The full observation-level dataset underlying @fig-supp-one.],
  filename: "TableA2_observations.tsv",
) <supp-tab-observations>

Reference them as @supp-tab-parameters and @supp-tab-observations.

== Methods

`method-heading` numbers each methods subsection and makes it referenceable, so
that the main text can point at a specific procedure.

#method-heading[Sample preparation] <method-preparation>

Describe the procedure here. This subsection is @method-preparation when
referenced from elsewhere in the document.

#method-heading[Data processing] <method-processing>

Each `method-heading` increments its own counter, independent of the figure,
note, and table counters, and does not appear in the table of contents.

#method-heading[Statistical analysis] <method-statistics>

Equations work here exactly as in the main text:

$ "SE"(hat(mu)) = sigma / sqrt(n) $

Cross-references from the main text into these subsections resolve to
@method-processing and @method-statistics.
