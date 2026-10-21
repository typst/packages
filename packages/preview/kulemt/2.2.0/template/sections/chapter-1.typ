= The First Chapter

#lorem(50)

== Figures

A figure gets a caption, which is what puts it in the List of Figures.

#figure(
  image("../images/example.png", width: 60%),
  caption: [The logo of the Faculty of Engineering Science.],
)

#lorem(40)

== Tables

#figure(
  table(
    columns: 3,
    stroke: 0.5pt,
    [*Column A*], [*Column B*], [*Column C*],
    [1], [2], [3],
    [4], [5], [6],
  ),
  caption: [A table with the wrong layout.],
)

Booktabs-style rules read better in print: no vertical lines, and only three
horizontal ones.

#figure(
  table(
    columns: 3,
    stroke: none,
    table.hline(stroke: 1pt),
    [*Column A*], [*Column B*], [*Column C*],
    table.hline(stroke: 0.5pt),
    [1], [2], [3],
    [4], [5], [6],
    table.hline(stroke: 1pt),
  ),
  caption: [A table with the correct layout.],
)

== Conclusion

#lorem(40)
