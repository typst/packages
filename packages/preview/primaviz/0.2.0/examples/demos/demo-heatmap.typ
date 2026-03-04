// Heatmaps: heatmap light + dark, calendar-heatmap, correlation-matrix
#import "../../src/lib.typ": *
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  heatmap(
    (rows: ("net", "fs", "mm", "drv"),
     cols: ("Mon", "Tue", "Wed", "Thu", "Fri"),
     values: (
       (82, 95, 78, 88, 65),
       (45, 52, 68, 71, 38),
       (33, 41, 55, 48, 29),
       (91, 87, 93, 85, 72),
     )),
    cell-size: 42pt, title: "heatmap (light)", palette: "viridis", theme: lt,
  ),
  heatmap(
    (rows: ("net", "fs", "mm", "drv"),
     cols: ("Mon", "Tue", "Wed", "Thu", "Fri"),
     values: (
       (82, 95, 78, 88, 65),
       (45, 52, 68, 71, 38),
       (33, 41, 55, 48, 29),
       (91, 87, 93, 85, 72),
     )),
    cell-size: 42pt, title: "heatmap (dark)", palette: "viridis", theme: dk,
  ),
  calendar-heatmap(
    (dates: ("2024-03-01", "2024-03-02", "2024-03-03", "2024-03-04", "2024-03-05",
             "2024-03-06", "2024-03-07", "2024-03-08", "2024-03-09", "2024-03-10",
             "2024-03-11", "2024-03-12", "2024-03-13", "2024-03-14", "2024-03-15",
             "2024-03-16", "2024-03-17", "2024-03-18", "2024-03-19", "2024-03-20",
             "2024-03-21", "2024-03-22", "2024-03-23", "2024-03-24", "2024-03-25",
             "2024-03-26", "2024-03-27", "2024-03-28"),
     values: (12, 8, 3, 15, 22, 18, 5, 9, 14, 2, 20, 25, 11, 7, 16, 4, 1, 19, 23, 13, 10, 6, 17, 8, 21, 15, 12, 9)),
    cell-size: 16pt, title: "calendar-heatmap", palette: "heat", theme: lt,
  ),
  correlation-matrix(
    (labels: ("net", "fs", "mm", "drv", "arch"),
     values: (
       (1.0, 0.7, 0.4, 0.8, 0.3),
       (0.7, 1.0, 0.5, 0.6, 0.4),
       (0.4, 0.5, 1.0, 0.3, 0.6),
       (0.8, 0.6, 0.3, 1.0, 0.5),
       (0.3, 0.4, 0.6, 0.5, 1.0),
     )),
    cell-size: 42pt, title: "correlation-matrix", theme: dk,
  ),
))
