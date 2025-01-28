#import "style.typ": 字体, 字号

#let table-stroke = 0.5pt

#set page(numbering: "1")

#align(center, text(
  font: 字体.黑体,
  size: 字号.三号,
  weight: "bold",
  "深圳大学本科毕业论文（设计）开题报告"
))

#set text(font: 字体.宋体, size: 字号.小四)
// #set underline(offset: 0.1em)

// #align(center)[
//   填表人签名#underline("　　　　　　")填表时间：#underline("　　　　")年#underline("　　")月#underline("　　")日
// ]

#v(-0.7em)

#{
  set text(size: 字号.小四)
  table(
    columns: (96pt, 102pt, 100pt, 1fr),
    stroke: table-stroke,
    align: center + horizon,
    [题目], table.cell(colspan: 3)[],
  
    // [学生姓名], [], [学号], [],
    // [院系专业], [], [手机号], [],
    // [指导教师姓名一 \ （必填）], [], [职称], [],
    // [导师所在院系], [], [是否校内], [],
    // [指导教师姓名二 \ （选填）], [], [职称], [],
    // [导师所在院系], [], [是否校内], [],
    // [毕设类型], table.cell(colspan: 3)[#sym.ballot 毕业论文 #h(1fr) #sym.ballot 毕业设计（含毕业作品） #h(1fr)],
  )
}

#v(-1.21em)

#{
  set text(size: 字号.小四)
  table(
    columns: (96pt, 96pt, 40pt, 96pt, 40pt, 1fr),
    stroke: table-stroke,
    align: center + horizon,
    //[题目], table.cell(colspan: 3)[],
    [学生姓名], [], [学号],[],[专业]
    // [学生姓名], [], [学号], [],
    // [院系专业], [], [手机号], [],
    // [指导教师姓名一 \ （必填）], [], [职称], [],
    // [导师所在院系], [], [是否校内], [],
    // [指导教师姓名二 \ （选填）], [], [职称], [],
    // [导师所在院系], [], [是否校内], [],
    // [毕设类型], table.cell(colspan: 3)[#sym.ballot 毕业论文 #h(1fr) #sym.ballot 毕业设计（含毕业作品） #h(1fr)],
  )
}

#v(-1.21em)

#{
  set text(size: 字号.小四)
  table(
    columns: (96pt, 96pt, 96pt, 1fr),
    stroke: table-stroke,
    align: center + horizon,
    //[题目], table.cell(colspan: 3)[],
    [学院], [], [指导教师],[]
    // [学生姓名], [], [学号], [],
    // [院系专业], [], [手机号], [],
    // [指导教师姓名一 \ （必填）], [], [职称], [],
    // [导师所在院系], [], [是否校内], [],
    // [指导教师姓名二 \ （选填）], [], [职称], [],
    // [导师所在院系], [], [是否校内], [],
    // [毕设类型], table.cell(colspan: 3)[#sym.ballot 毕业论文 #h(1fr) #sym.ballot 毕业设计（含毕业作品） #h(1fr)],
  )
}

#v(-1.21em)

#table(
  columns: 1fr,
  stroke: table-stroke,
  inset: 10pt,
)[
  本选题的意义及国内外发展状况：

  #v(35em)
][
  研究内容：

  #v(12em)
][
  #text[　　　　]
  #v(35em)

][
  研究方法、手段及步骤：

  #v(45em)
][
  #text[　　　　]
  #v(6em)

][
  参考文献：

  #v(24em)
][
  学生签名：
  #v(6em)
  #set align(right)
  #text("　　　　年　　月　　日")#h(2em)

]

  #pagebreak()

#table(
  columns: 1fr,
  stroke: table-stroke,
  inset: 10pt,
)[
  指导教师意见：

  #v(20em)

  #set align(right)

  签名： #h(6em)


  #set align(left)
  院系意见：

  #v(1fr)

  #set align(right)

  院系负责人签名： #h(6em)

  #v(1em)

  #strong("　　　　年　　月　　日")
]