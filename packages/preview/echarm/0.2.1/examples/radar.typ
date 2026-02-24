#set page(width: 200mm, height: 150mm, margin: 0mm)
#import "../typst-package/lib.typ" as echarm
#echarm.render(width: 100%, height: 100%, options: (
  legend: (
    top: "10%",
    data: ("Allocated Budget", "Actual Spending")
  ),
  radar: (
    radius: "45%",
    indicator: (
      (name: "Sales", max: 6500),
      (name: "Administration", max: 16000),
      (name: "Information Technology", max: 30000),
      (name: "Customer Support", max: 38000),
      (name: "Development", max: 52000),
      (name: "Marketing", max: 25000),
    )
  ),
  series: (
    (
      name: "Budget vs spending",
      type: "radar",
      data: (
        (
          name: "Allocated Budget",
          value: (4200, 3000, 20000, 35000, 50000, 18000)
        ),
        (
          name: "Actual Spending",
          value: (5000, 14000, 28000, 26000, 42000, 21000)
        )
      )
    )
  )
))