#import "../utils/datetime-display.typ": datetime-display-without-day
#import "../utils/style.typ": font-family, font-size

/// 渲染本科生封面
/// -> content
#let bachelor-cover(
  /// 是否匿名，由 @@thesis() 传入
  anonymous: false,
  /// 是否启用双面打印, 由 @@thesis() 传入
  twoside: false,
  /// 自定义字体，由 @@thesis() 传入
  fonts: (:),
  /// 论文与作者信息，由 @@thesis() 传入
  info: (:),
  /// 下划线宽度
  stoke-width: 0.5pt,
  /// 标题的最少行数
  min-title-lines: 1,
  /// 作者信息值（张三，李四等）与下划线的距离偏移量
  info-inset: (x: 0pt, bottom: 1pt),
  /// 作者信息键（学生姓名，指导教师等）占的宽度
  info-key-width: 72pt,
  /// 作者信息键所用字体
  info-key-font: "宋体",
  /// 作者信息值所用字体
  info-value-font: "宋体",
  /// 作者信息键值对之间的间隔大小
  column-gutter: -3pt,
  /// 作者信息中行之间的间隔大小
  row-gutter: 11.5pt,
  /// 日期表示形式
  /// 自定义写法可参考 @@datetime-display() 系列函数
  datetime-display: datetime-display-without-day,
) = {
  fonts = font-family + fonts
  info = (
    (
      title: "基于 Typst 的毕业论文中文题目",
      title-en: "My Title in English",
      grade: "20XX",
      student-id: "1234567890",
      author: "张三",
      department: "某学院",
      major: "某专业",
      supervisor: ("李四", "教授"),
      submit-date: datetime.today(),
    )
      + info
  )

  //* 2.  对参数进行处理
  //* 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }
  //* 2.2 根据 min-title-lines 填充标题
  info.title = info.title + range(min-title-lines - info.title.len()).map(it => "　")
  //* 2.3 处理提交日期
  if type(info.submit-date) == datetime {
    info.submit-date = datetime-display(info.submit-date)
  }

  //* 3.  内置辅助函数
  let info-key(body) = {
    rect(
      width: 100%,
      inset: info-inset,
      stroke: none,
      text(
        font: fonts.at(info-key-font, default: "宋体"),
        size: font-size.三号,
        body,
      ),
    )
  }

  let info-value(key, body) = {
    set align(center)
    rect(
      width: 100%,
      inset: info-inset,
      stroke: (bottom: stoke-width + black),
      text(
        font: fonts.at(info-value-font, default: "宋体"),
        size: font-size.三号,
        weight: "regular",
        bottom-edge: "descender",
        body,
      ),
    )
  }

  let info-long-value(key, body) = {
    grid.cell(colspan: 2, info-value(
      key,
      if anonymous and (key in anonymous-info-keys) {
        "██████████"
      } else {
        body
      },
    ))
  }

  //* 4.  正式渲染

  pagebreak(weak: true, to: if twoside { "odd" })

  pad(left: 2em)[
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 9em,
      text(size: font-size.小四, font: fonts.宋体)[
        *学校代码：#info.school-code*
      ],
      text(size: font-size.小四, font: fonts.宋体)[
        *学号：#info.student-id*
      ],
    )
  ]


  v(22pt)

  set align(center)

  //* 校徽 & 校名 & 类型
  image("../assets/nenu-logo-blue.svg", width: 90pt, format: "svg")

  pad(image("../assets/nenu-title.svg", width: 126pt), top: 0cm, bottom: -0.8cm)


  text(size: font-size.小一, font: fonts.黑体, weight: "medium")[本科毕业论文]

  v(30pt)

  //* 标题
  text(size: font-size.二号, font: fonts.隶书, weight: "bold")[
    #for line in info.title {
      line
    }
  ]

  v(3pt)

  text(size: font-size.三号, font: fonts.宋体)[
    #info.title-en
  ]

  v(40pt)

  //* 作者信息
  pad(
    left: 20pt,
    block(width: 318pt, grid(
      columns: (info-key-width, info-key-width, 1fr),
      rows: 4,
      column-gutter: column-gutter,
      row-gutter: row-gutter,
      info-key("学生姓名："), info-long-value("author", info.author), info-key("指导教师："),
      info-long-value("supervisor", info.supervisor.at(0)),

      info-key("所在学院："), info-long-value("department", info.department), info-key("所学专业："),
      info-long-value("major", info.major),
    )),
  )

  v(70pt)

  grid(
    rows: 2,
    row-gutter: 10pt,
    text(size: font-size.小三, font: fonts.宋体)[
      东北师范大学
    ],
    text(size: font-size.小三, font: fonts.宋体)[
      #info.submit-date
    ],
  )
}
