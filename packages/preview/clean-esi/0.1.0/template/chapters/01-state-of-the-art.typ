#import "@preview/clean-esi:0.1.0": info-box, thesis-table

= State of the Art <ch:state-of-the-art>

== Background
Cite sources from `refs.bib` with `@key`, for example @example2024.

#info-box[Tip][
  Label chapters `<ch:...>`, figures `<fig:...>`, and tables `<tab:...>`, then reference them with `@label`.
]

== Comparison of Existing Approaches
@tab:comparison compares existing approaches. Table captions render above the table.

#figure(
  thesis-table(
    columns: 3,
    table.header[Approach][Strength][Limitation],
    [Approach A], [Fast], [Low accuracy],
    [Approach B], [Accurate], [Expensive],
  ),
  caption: [Comparison of existing approaches.],
) <tab:comparison>

== Synthesis
Summarise the gap your work addresses.
