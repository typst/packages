#set page(width: 200mm, height: 150mm, margin: 0mm)
#import "../typst-package/lib.typ" as echarm
#echarm.render(width: 100%, height: 100%, options: (
  legend: (
    top: "5%",
    left: "center"
  ),
  series: (
    name: "Access Form",
    type: "pie",
    radius: ("40%", "70%"),
    avoidLabelOverlap: false,
    itemStyle: (
      borderRadius: 10,
      borderColor: "#fff",
      borderWidth: 2,
    ),
    label: (
      "show": false,
    ),
    labelLine: (
      "show": false,
    ),
    data: (
      (value: 1048, name: "Search Engine"),
      (value: 735, name: "Direct"),
      (value: 580, name: "Email"),
      (value: 484, name: "Union Ads"),
      (value: 300, name: "Video Ads"),
    )
  ),
))