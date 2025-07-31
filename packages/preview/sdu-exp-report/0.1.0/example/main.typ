#import "@preview/sdu-exp-report:0.1.0" : *
// #import "../templete.typ":*

#show: report.with(
  institute: "计算机科学与技术",
  course: "人工智能引论",
  student-id: "202322114514",
  student-name: "张三",
  date: datetime.today(),
  lab-title: "实验0华为开发者空间-云主机初体验",
  exp-time: "2"
)

#show figure.where(kind: "image"): it => {
  set image(width: 67%)
  it
}

#exp-block(
[
  = 实验过程
  （记录实验过程、遇到的问题和实验结果。可以适当配以关键代码辅助说明，但不要大段贴代码。）
  #v(10em)
]
)

#exp-block(
[
  = 结果分析与体会
  #v(15em)
]
)