#import "../utils/packages.typ": fakebold
#import "../utils/fonts.typ": 字体, 字号, chineseunderline, justify-words

#let bachelor-cover-conf(
  student_id: "00121001",
  author: "王东南",
  school: "示例学院",
  major: "示例专业",
  advisor: "湖牌桥",
  thesis-name: "示例论文标题\n此行空白时下划线自动消失",
  date: "某个起止日期",
  cover_date: datetime.today()
) = page(
  paper: "a4",
  margin: (
    top: 2cm + 0.7cm,
    bottom: 2cm + 0.5cm,
    left: 2cm + 0.5cm,
    right: 2cm,
  ),
  // 原模板中调整了图片亮度和对比度，因此直接导出了调整后的版本
  // 原始图片在本仓库的 ref 目录中
  background: image("../assets/bachelor_cover_adjusted.png")
)[

  #set text(lang: "zh", region: "cn")

  #set align(center)
  //#hide[#heading(outlined: false, bookmarked: true)[封面]]

  #v(1.2cm)

  #image("../assets/vi/东南大学校标文字组合-彩色.png", width: 8.57cm)

  #v(13pt)

  #block(
    height: 2cm,
    {
      // 字号/字距调节太麻烦，并且需要另行安装思源宋体，故使用 svg 代替
      // text(font: 字体.思源宋体, size: 36pt, weight: 900, tracking: 0pt, "本科毕业设计（论文）报告")
      image("../assets/bachelor_title.svg", width: 16.48cm)
    },
  )

  #v(47pt)

  #block(
    height: 2.5cm,
    {
      set text(font: 字体.黑体, size: 字号.二号, weight: "regular")
      set par(spacing: 0.9cm)
      block(
        width: 12.84cm,
        chineseunderline(thesis-name)
      )
    },
  )

  #v(23pt)

  #{
    set text(font: 字体.思源黑体, size: 字号.小二, weight: "medium")
    let label(s) = align(left, pad(top: 5pt, text(font: 字体.思源黑体, size: 字号.四号, weight: "medium", justify-words(s, width: 4em) + "：")))
    // 模板中直接使用宋体，无 Times New Roman 回退
    let value(s) = text(font: "SimSun", size: 字号.小二, chineseunderline(s, bottom: 8pt))
    grid(
      columns: (3.44cm, 7.99cm),
      rows: 1.21cm,
      gutter: 0pt,
      label("学号"),
      value(student_id),
      label("姓名"),
      value(author),
      label("学院"),
      value(school),
      label("专业"),
      value(major),
      label("指导教师"),
      value(advisor),
      label("起止日期"),
      value(date),
    )
  }

  #v(20pt)

  // 模板中直接使用楷体，无 Times New Roman 回退
  #text(font: "KaiTi", size: 字号.四号, cover_date.display("[year]年[month padding:none]月[day padding:none]日"),)
]

// 测试部分
#bachelor-cover-conf(
  student_id: "00121001",
  author: "王东南",
  school: "示例学院",
  major: "示例专业",
  advisor: "湖牌桥",
  thesis-name: "示例论文标题\n此行空白时下划线自动消失",
  date: "某个起止日期",
)