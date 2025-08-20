#import "../utils/packages.typ": fakebold
#import "../utils/fonts.typ": 字体, 字号, chineseunderline, justify-words

#let bachelor-cover-conf(
  studentID: "00121001",
  author: "王东南",
  school: "示例学院",
  major: "示例专业",
  advisor: "湖牌桥",
  thesisname: "示例论文标题\n此行空白时下划线自动消失",
  date: "某个起止日期",
) = page(paper: "a4", margin: (top: 2cm+0.7cm, bottom: 2cm+0.5cm, left: 2cm + 0.5cm, right: 2cm))[

  #set text(lang: "zh")

  #set align(center)
  //#hide[#heading(outlined: false, bookmarked: true)[封面]]

  #image("../assets/vi/东南大学校标文字组合.png", width: 10cm)
  #block(height: 2cm, {
    text(font: 字体.黑体, size: 字号.一号, fakebold[本科毕业设计（论文）报告])
  })
  
  #v(40pt)

  #block(height: 2.5cm, {
    set text(font: 字体.黑体, size: 字号.二号, weight: "regular")
    grid(
      columns: (2.85cm, 12.84cm),
      [题 目：], chineseunderline(thesisname)
    )
  })

  #v(40pt)

  #{
    set text(font: 字体.宋体, size: 字号.小二, weight: "regular")
    grid(
      columns: (3.44cm-1em, 1em, 8cm),
      rows: 1.4cm,
      justify-words("学号", width: 4em), "：", chineseunderline(studentID),
      justify-words("姓名", width: 4em), "：", chineseunderline(author),
      justify-words("学院", width: 4em), "：", chineseunderline(school),
      justify-words("专业", width: 4em), "：", chineseunderline(major),
      justify-words("指导教师", width: 4em), "：", chineseunderline(advisor),
      justify-words("起止日期", width: 4em), "：", chineseunderline(date),
    )
  }
]

// 测试部分
#bachelor-cover-conf(
  studentID: "00121001",
  author: "王东南",
  school: "示例学院",
  major: "示例专业",
  advisor: "湖牌桥",
  thesisname: "示例论文标题\n此行空白时下划线自动消失",
  date: "某个起止日期",
)