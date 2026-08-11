#set page(width: 200mm, height: 150mm, margin: 0mm)
#import "../typst-package/lib.typ" as echarm
#echarm.render(width: 100%, height: 100%, options: (
  series: (
    type: "gauge",
    progress: (
      "show": true
    ),
    data: ((value: 60),)
  )
))