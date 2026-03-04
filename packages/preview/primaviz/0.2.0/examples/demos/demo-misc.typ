// Miscellaneous: waffle, parliament, radial-bar, sunburst
#import "../../src/lib.typ": *
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  waffle-chart(
    (labels: ("Rust", "C", "Python", "Go", "Other"),
     values: (35, 28, 18, 12, 7)),
    size: 200pt, gap: 1.5pt, title: "waffle-chart (light)", theme: lt,
  ),
  parliament-chart(
    (labels: ("Party A", "Party B", "Party C", "Party D", "Indep"),
     values: (120, 95, 55, 25, 5)),
    size: 210pt, dot-size: 4pt, title: "parliament-chart (dark)", theme: dk,
  ),
  radial-bar-chart(
    (labels: ("Sales", "Marketing", "Eng", "Design", "Support"),
     values: (85, 72, 95, 60, 78)),
    size: 200pt, title: "radial-bar-chart (light)", show-labels: true, theme: lt,
  ),
  sunburst-chart(
    (name: "Total",
     children: (
       (name: "A", value: 40,
        children: (
          (name: "A1", value: 25),
          (name: "A2", value: 15),
        )),
       (name: "B", value: 35,
        children: (
          (name: "B1", value: 20),
          (name: "B2", value: 15),
        )),
       (name: "C", value: 25),
     )),
    size: 200pt, inner-radius: 25pt, ring-width: 40pt, title: "sunburst-chart (dark)", theme: dk,
  ),
))
