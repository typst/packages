
// 阿拉伯数字转中文大写年月份
#let to-chinese-date(dt) = {
  let num-map = ("〇", "一", "二", "三", "四", "五", "六", "七", "八", "九")
  let year-str = str(dt.year()).clusters().map(c => num-map.at(int(c))).join()
  let month-map = ("一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "十二")
  let month-str = month-map.at(dt.month() - 1)
  [#(year-str)年#(month-str)月]
}

#let render-cover-page(
  cfg,
) = {
  // 设置封面这一页的纸张状态
  set page(
    header: none,
    footer: none,
    margin: 0pt,
  )

  // 从统一的元数据配置中提取字段
  let title = cfg.meta.title
  let stu_name = cfg.meta.stu-name
  let stu_number = cfg.meta.stu-number
  let tch_name = cfg.meta.tch-name
  let department = cfg.meta.department
  let major = cfg.meta.major
  let grade = cfg.meta.grade

  let font-sans = cfg.fonts.sans
  let font-serif = cfg.fonts.serif

  let cover-content = {
    set text(font: font-serif, lang: cfg.meta.lang)

    v(2fr)
    // --- 顶部校徽 ---
    grid(
      columns: (1fr, auto, 8fr),
      align: (left + horizon, right + horizon),
      [],
      box(height: 2.5cm)[
        #image("../../assets/logo.png", height: 100%)
      ],
      [],
    )

    // --- 中间：学校名 + 院系名称 + 文档大标题 ---
    align(center)[
      #block(width: 55%)[
        #image("../../assets/font_logo.png", width: 100%)
      ]
      #v(1cm)
      #text(size: 20pt, weight: "bold", font: font-sans, tracking: 0.1em)[#department]
      #v(0em)
      #text(size: 25pt, weight: "bold", font: font-sans, tracking: 0.2em)[本科学年论文]
    ]

    v(4fr)

    // --- 中间：论文题目区 ---
    align(center)[
      #block(width: 70%)[
        #set text(size: 16pt, weight: "bold")
        #grid(
          columns: (auto, 1fr),
          column-gutter: 1em,
          row-gutter: 1.2em,
          align: horizon,

          [题#h(2em)目：],
          block(width: 100%, inset: (bottom: 0.3em), stroke: (bottom: 1pt + black))[
            #title
          ],
        )
      ]
    ]

    v(4fr)

    // --- 底部：学生教务信息卡片（去掉了院系行） ---
    align(center)[
      #block(width: 50%)[
        #set text(size: 16pt, weight: "bold")
        #set align(left)

        #let info-field(body) = block(
          width: 100%,
          inset: (bottom: 0.4em),
          stroke: (bottom: 1pt + black),
          align(center, text(weight: "medium", body)),
        )

        #grid(
          columns: (5em, 1fr),
          row-gutter: 1em,
          column-gutter: 0.5em,
          [学生姓名], info-field(stu_name),
          [学#h(2em)号], info-field(stu_number),
          [指导教师], info-field(tch_name),
          [专#h(2em)业], info-field(major),
          [年#h(2em)级], info-field(grade),
        )
      ]
    ]

    v(5fr)

    // --- 底部：中文大写年月 ---
    align(center)[
      #text(size: 16pt, weight: "bold", font: font-sans, tracking: 0.15em)[
        #to-chinese-date(datetime.today())
      ]
    ]

    v(5fr)
  }

  cover-content

  // 强制断页
  pagebreak()
}
