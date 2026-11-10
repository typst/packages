#set page(width: 200mm, height: 150mm, margin: 0mm)
#import "@preview/echarm:0.4.0"
#let themes = dictionary(echarm.theme)
#grid(
  columns: 6,
  ..themes
    .values()
    .map(theme => echarm.render(
      width: 100%,
      height: 100% / 6,
      zoom: 0.2,
      options: (
        title: (
          text: theme,
        ),
        xAxis: (
          type: "category",
          data: ("1", "2", "3"),
        ),
        yAxis: (
          type: "value",
        ),
        series: (
          (
            data: (5, 6, 7),
            type: "bar",
          )
        ),
      ),
      theme: theme,
    )),
)

