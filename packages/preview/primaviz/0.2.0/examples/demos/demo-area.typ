// Area charts: single + stacked, light + dark
#import "../../src/lib.typ": *
#set page(margin: 0.5cm, paper: "a4")
#set text(size: 8pt)

#let lt = themes.default
#let dk = themes.dark
#let W = 250pt
#let H = 280pt

#page-grid(cols: 2, rows: 2, col-gutter: 16pt, row-gutter: 24pt, (
  area-chart(
    (labels: ("5.0", "5.5", "5.10", "5.15", "6.0", "6.5", "6.9"),
     values: (26.1, 27.8, 29.2, 30.5, 31.4, 33.1, 35.2)),
    width: W, height: H, title: "area-chart (light)", fill-opacity: 40%, y-label: "M LoC", theme: lt,
  ),
  area-chart(
    (labels: ("5.0", "5.5", "5.10", "5.15", "6.0", "6.5", "6.9"),
     values: (26.1, 27.8, 29.2, 30.5, 31.4, 33.1, 35.2)),
    width: W, height: H, title: "area-chart (dark)", fill-opacity: 40%, y-label: "M LoC", theme: dk,
  ),
  stacked-area-chart(
    (labels: ("2020", "2021", "2022", "2023", "2024"),
     series: (
       (name: "Corporate", values: (1850, 1920, 2050, 2180, 2310)),
       (name: "Independent", values: (620, 580, 550, 510, 480)),
       (name: "Academic", values: (180, 195, 210, 230, 250)),
     )),
    width: W, height: H, title: "stacked-area-chart (light)", theme: lt,
  ),
  stacked-area-chart(
    (labels: ("2020", "2021", "2022", "2023", "2024"),
     series: (
       (name: "Corporate", values: (1850, 1920, 2050, 2180, 2310)),
       (name: "Independent", values: (620, 580, 550, 510, 480)),
       (name: "Academic", values: (180, 195, 210, 230, 250)),
     )),
    width: W, height: H, title: "stacked-area-chart (dark)", theme: dk,
  ),
))
