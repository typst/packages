#import "@preview/magic-isprs:0.1.0": isprs-heading
#show: isprs-heading

= Part 1

== Subpart 1

#lorem(20)

=== Subsubpart 1

#lorem(50)

#figure(
  rect(width: 70%, height: 20mm, fill: gradient.linear(..color.map.turbo, angle: 10deg)),
  caption: "Example of a fancy figure.",
  kind: image,
)

#lorem(80)

=== Subsubpart 2

#lorem(80)

#figure(
  table(
    columns: 3,
    stroke: (x, y) => {
      let res = (bottom: 1pt, top: 0pt)
      if (y < 2) {
        res.top = 1pt
      }
      res
    },
    table.header([Column 1], [Column 2], [Column 3]),
    [Row 1, Cell 1], [Row 1, Cell 2], [Row 1, Cell 3],
    [Row 2, Cell 1], [Row 2, Cell 2], [Row 2, Cell 3],
    [Row 3, Cell 1], [Row 3, Cell 2], [Row 3, Cell 3],
  ),
  caption: "Example of a fancy table.",
)

#lorem(30)

== Subpart 2

#lorem(50)

= Part 2

== Subpart 1

=== Subsubpart 1

#lorem(50)

=== Subsubpart 2

#lorem(70)

== Subpart 2

#lorem(20)

= Citing everyone

Citing all the entries in the bibliography:

- @doe2020book
- @miller2021article
- @nguyen2019conf
- @chen2018chapter
- @garcia2022thesis
- @kim2021thesis
- @smith2017report
- @somewebcompany2024misc
- @website2023online
- @white2025unpub
- @brown2020short
- @editor2023edited
- @multi2024many
- @special2021chars
- @string2015volume
- @missingfields2026
