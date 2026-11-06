#set page(width: 200mm, height: 150mm, margin: 0mm)
#import "../typst-package/lib.typ" as echarm
#echarm.render(width: 100%, height: 100%, options: (
  xAxis: (
    data: ("2017-10-24", "2017-10-25", "2017-10-26", "2017-10-27")
  ),
  yAxis: (:),
  series: (
    (
      type: "candlestick",
      data: (
        (20, 34, 10, 38),
        (40, 35, 30, 50),
        (31, 38, 33, 44),
        (38, 15, 5, 42),
      )
    )
  )
))