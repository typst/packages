#set page(width: 200mm, height: 150mm, margin: 0mm)
#import "../typst-package/lib.typ" as echarm
#echarm.render(width: 100%, height: 100%, options: (
  xAxis: (
    type: "category",
    data: ("Val1", "Val2", "Val3", "Val4", "Val5", "Val6")
  ),
  yAxis: (
    type: "value"
  ),
  series: (
    (
      data: (20, 330, 400, 218, 135, 147),
      type: "line",
      areaStyle: (:),
      smooth: true
    ),
    (
      data: (200, 430,300, 260, 15, 23),
      type: "line"
    ),
    (
      data: (150, 330, 400, 218, 135, 147),
      type: "bar"
    ),
    (
      data: (60, 30, 300, 250, 130, 120),
      type: "bar"
    )
  )
))