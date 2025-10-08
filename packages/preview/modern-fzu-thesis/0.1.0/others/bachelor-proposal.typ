#import "style.typ": 字体, 字号

#let table-stroke = 0.5pt

#set page(numbering: "1")

#align(center, text(
  font: 字体.黑体,
  size: 字号.三号,
  weight: "bold",
  "南京大学本科毕业论文（设计）开题报告"
))

#set text(font: 字体.宋体, size: 字号.五号)
#set underline(offset: 0.1em)

#align(center)[
  填表人签名#underline("　　　　　　")填表时间：#underline("　　　　")年#underline("　　")月#underline("　　")日
]

#v(-0.7em)

#{
  set text(size: 字号.小四)
  table(
    columns: (100pt, 1fr, 100pt, 1fr),
    stroke: table-stroke,
    align: center + horizon,
    [学生姓名], [], [学号], [],
    [院系专业], [], [手机号], [],
    [指导教师姓名一 \ （必填）], [], [职称], [],
    [导师所在院系], [], [是否校内], [],
    [指导教师姓名二 \ （选填）], [], [职称], [],
    [导师所在院系], [], [是否校内], [],
    [毕设类型], table.cell(colspan: 3)[#sym.ballot.x 毕业论文 #h(1fr) #sym.ballot 毕业设计（含毕业作品） #h(1fr)],
    [论文题目], table.cell(colspan: 3)[],
  )
}

#v(-1.37em)

#table(
  columns: 1fr,
  stroke: table-stroke,
  inset: 10pt,
)[
  *一、研究背景及意义*（附参考文献）

  #v(45em)
][
  *二、国内外研究现状*（文献综述，附参考文献，不少于800字）

  #v(45em)
][
  *三、主要研究或解决的问题和拟采用的方法*

  #v(45em)
][
  *四、工作进度计划*（每两周为一个单位）

  #v(20em)
][
  *指导教师意见*（不少于50个字）

  #v(20em)

  #set align(right)

  *签名：* #h(6em)

  #v(1em)

  #strong("　　　　年　　月　　日")
][
  *院系意见：*

  *（自动写同意）*

  #v(1fr)

  #set align(right)

  *院系负责人签名：* #h(6em)

  #v(1em)

  #strong("　　　　年　　月　　日")
]