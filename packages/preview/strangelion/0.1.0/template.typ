#set text(lang: "zh", region: "cn")

// 定义一个辅助函数：将字符串拆分并插入 1fr 间距实现两端对齐
#let justify-text(body) = {
  if type(body) != str { return body }
  let chars = body.clusters()
  let n = chars.len()
  if n < 2 { return body }
  for (i, char) in chars.enumerate() {
    char
    if i < n - 1 { h(1fr) }
  }
}

#let template(
  doc,
  head: (name: none, value: none, visible: none, depth: none),
  title: (name: none, value: none, visible: none, depth: none),
  title-en: (name: none, value: none, visible: none, depth: none),
  school-semester: (name: none, value: none, visible: none, depth: none),
  school: (name: none, value: none, visible: none, depth: none),
  course-id: (name: none, value: none, visible: none, depth: none),
  course-name: (name: none, value: none, visible: none, depth: none),
  college: (name: none, value: none, visible: none, depth: none),
  author: (name: none, value: none, visible: none, depth: none),
  student-id: (name: none, value: none, visible: none, depth: none),
  class: (name: none, value: none, visible: none, depth: none),
  major: (name: none, value: none, visible: none, depth: none),
  supervisor: (name: none, value: none, visible: none, depth: none),
  date: (name: none, value: datetime.today().display("[year]年[month]月[day]日"), visible: none, depth: none),
  info-order: none,
) = {
  // 1. 页面设置
  set page(
    paper: "a4",
    margin: (top: 3cm, bottom: 3cm, left: 2.5cm, right: 2.5cm),
  )

  // 2. 基础字体和段落设置
  set text(font: ("Times New Roman", "simsun"), size: 12pt)
  set par(leading: 1em, first-line-indent: 2em, justify: true)

  // 3. 封面生成
  align(center)[
    #v(1.2cm)
    #image("resources/logo.png", width: 80%)
    #v(0.6cm)
    #if head.visible {
      text(size: 26pt, weight: "bold")[#head.value]
      v(1cm)
    }
    #if title.visible {
      text(size: 22pt, weight: "bold")[#title.value]
      v(0.6cm)
    }
    #if title-en.visible {
      text(size: 18pt)[#title-en.value]
      v(0.6cm)
    }
    #v(1fr)

    #context {
      // 1. 定义所有可能的字段映射，Key 为 depth 值 [cite: 1, 2]
      let all-fields = (
        "4": (justify-text(school-semester.name) + "：", school-semester),
        "5": (justify-text(school.name) + "：", school),
        "6": (justify-text(course-id.name) + "：", course-id),
        "7": (justify-text(course-name.name) + "：", course-name),
        "8": (justify-text(college.name) + "：", college),
        "9": (justify-text(author.name) + "：", author),
        "10": (justify-text(student-id.name) + "：", student-id),
        "11": (justify-text(class.name) + "：", class),
        "12": (justify-text(major.name) + "：", major),
        "13": (justify-text(supervisor.name) + "：", supervisor),
      )
      // 2. 筛选出当前可见的字段用于计算最大宽度 [cite: 8]
      let visible-items = all-fields.values().filter(it => it.at(1).visible)
      let max-width = if visible-items.len() > 0 {
        let widths = visible-items.map(it => measure(block(width: auto, text(size: 14pt)[#it.at(1).value])).width)
        calc.max(..widths) + 20pt
      } else {
        0pt
      }

      // 3. 定义行渲染函数 [cite: 9, 10]
      let info-row(label, value) = {
        grid(
          columns: (80pt, max-width),
          column-gutter: 0pt,
          align: (right + horizon, center + horizon),
          text(weight: "bold", size: 14pt)[#label],
          block(width: 100%, stroke: (bottom: 1pt), inset: (bottom: 4pt))[
            #set text(size: 14pt)
            #justify-text(value)
          ],
        )
      }

      // 4. 根据 info_order 的顺序循环渲染
      for d in info-order {
        let key = str(d)
        if key in all-fields {
          let (label, data) = all-fields.at(key)
          if data.visible {
            info-row(label, data.value)
            v(1.2em)
          } else {
            if data.value != none {
              // 如果字段不可见但有值，仍占位但不显示内容
              grid(
                columns: (80pt, max-width),
                column-gutter: 0pt,
                align: (right + horizon, center + horizon),
                text(weight: "bold", size: 14pt)[#label],
                block(width: 100%, stroke: (bottom: 1pt), inset: (bottom: 4pt))[
                  #set text(size: 14pt)
                  #v(1.2em) // 占位符，保持行高一致
                ],
              )
            }
          }
        }
      }
    }

    #v(1fr)
    #if date.visible {
      text(size: 14pt)[#date.value]
    }

  ]

  pagebreak()

  // 4. 章节标题格式设置 (等同于 ctexset)
  set heading(numbering: "1.1")

  show heading: it => {
    set text(weight: "bold")
    if it.level == 1 {
      // 一级标题：第X章，居中，三号字(16pt)
      let num = if it.numbering != none {
        numbering("1", ..counter(heading).at(it.location()))
      }
      pagebreak(weak: true)
      v(15pt)
      align(center)[
        #text(size: 16pt)[
          #(if num != none { "第" + num + "章　" })
          #it.body
        ]
      ]
      v(20pt)
    } else if it.level == 2 {
      // 二级标题：四号字(14pt)
      text(size: 14pt)[#it]
    } else if it.level == 3 {
      // 三级标题：小四号(12pt)
      text(size: 12pt)[#it]
    } else {
      it
    }
  }

  // 设置图表自动按章节编号：(一级章节号)-(图表序号)
  set figure(numbering: n => {
    let h1 = counter(heading).at(here()).at(0)
    numbering("1-1", h1, n)
  })

  // 每一级标题（第X章）出现时，重置图表计数器
  show heading.where(level: 1): it => {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    it
  }

  // 设置图表名称的样式
  show figure.where(kind: image): set figure(supplement: [图])
  show figure.where(kind: table): set figure(supplement: [表])

  // 设置图表标题的间隔符，例如“图 1-1：标题”
  show figure.caption: it => [
    #set text(
      size: 10.5pt,
      font: ("Times New Roman", "SimSun", "Source Han Serif", "Songti SC", "Noto Serif CJK SC"),
      weight: "regular",
    )
    #it.supplement #context it.counter.display(it.numbering) ：#it.body
  ]

  // --- 跨页续表处理方案 ---
  // 1. 定义一个状态变量来记录表格开始的页码
  let table-start-page = state("table-start-page", 0)

  // 2. 拦截 table，记录它开始渲染时的页码
  show table: it => {
    context {
      table-start-page.update(here().page())
    }
    it
  }

  // 3. 拦截 table.header，判断当前页码是否大于开始页码
  show table.header: it => {
    context {
      let start = table-start-page.at(here())
      if here().page() > start {
        align(right)[
          #set text(size: 10.5pt, weight: "regular")
          续表
        ]
      }
    }
    it
  }

  // 目录样式修正
  show outline.entry.where(level: 1): it => {
    v(12pt, weak: true)
    strong(it)
  }

  doc
}
