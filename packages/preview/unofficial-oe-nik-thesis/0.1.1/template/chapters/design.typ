= Design <design>

#figure(
  grid(
    columns: 5,
    align: horizon,
    column-gutter: 1em,
    ..([Front pages], [Chapters], [Back matter])
      .map(part => box(stroke: 0.5pt, inset: 0.8em, part))
      .intersperse($arrow.r$),
  ),
  caption: [The parts of the thesis],
) <parts>

@parts shows the parts of the thesis, in the order of the guide's appendix 3.

== Front pages

The inside cover is generated from the `degree`, `year`, `author` and `registration-number` parameters.
After it come the signed forms: the worksheet, the student declaration, the consultation log, and the confidentiality document if there is one.

=== Abstracts

The Hungarian and English abstracts come right before the table of contents.

== Back matter

Everything after the chapters is added by the template: the summaries, the bibliography, the lists of figures and tables, the abbreviations, the appendices and the list of AI tools.
