#import "@preview/numbly:0.1.0": numbly
#import "@preview/cuti:0.2.1": fakebold
#import "@preview/i-figured:0.2.4"
#import "@preview/lovelace:0.3.0": *
#import "@preview/codly:1.1.1": *
#import "@preview/codly-languages:0.1.1": *

#let empty-par = par[#box()]
#let fake-par = context empty-par + v(-measure(empty-par + empty-par).height)
#let unpack(pairs) = {
  let dict = (:)
  for (key, value) in pairs {
    dict[key] = value
  }
  dict
}


#let font-size = (
  初号: 42pt,
  小初: 36pt,
  一号: 26pt,
  小一: 24pt,
  二号: 22pt,
  小二: 18pt,
  三号: 16pt,
  小三: 15pt,
  四号: 14pt,
  中四: 13pt,
  小四: 12pt,
  五号: 10.5pt,
  小五: 9pt,
  六号: 7.5pt,
  小六: 6.5pt,
  七号: 5.5pt,
  小七: 5pt,
)

#let font-family = (
  // 宋体，属于「有衬线字体」，一般可以等同于英文中的 Serif Font
  // 这一行分别是「新罗马体（有衬线英文字体）」、「思源宋体（简体）」、「思源宋体」、「宋体（Windows）」、「宋体（MacOS）」
  宋体: (
    "Times New Roman",
    "Source Han Serif SC",
    "Source Han Serif",
    "Noto Serif CJK SC",
    "SimSun",
    "Songti SC",
    "STSongti",
  ),
  // 黑体，属于「无衬线字体」，一般可以等同于英文中的 Sans Serif Font
  // 这一行分别是「Arial（无衬线英文字体）」、「思源黑体（简体）」、「思源黑体」、「黑体（Windows）」、「黑体（MacOS）」
  黑体: ("Arial", "Source Han Sans SC", "Source Han Sans", "Noto Sans CJK SC", "SimHei", "Heiti SC", "STHeiti"),
  // 楷体
  楷体: ("Times New Roman", "KaiTi", "Kaiti SC", "STKaiti", "FZKai-Z03S"),
  // 仿宋
  仿宋: ("Times New Roman", "FangSong", "FangSong SC", "STFangSong", "FZFangSong-Z02S"),
  // 等宽字体，用于代码块环境，一般可以等同于英文中的 Monospaced Font
  // 这一行分别是「Courier New（Windows 等宽英文字体）」、「思源等宽黑体（简体）」、「思源等宽黑体」、「黑体（Windows）」、「黑体（MacOS）」
  等宽: (
    "Courier New",
    "Menlo",
    "IBM Plex Mono",
    "Source Han Sans HW SC",
    "Source Han Sans HW",
    "Noto Sans Mono CJK SC",
    "SimHei",
    "Heiti SC",
    "STHeiti",
  ),
)

#let colorize(svg, color) = {
  let blk = black.to-hex()
  // You might improve this prototypical detection.
  if svg.contains(blk) {
    // Just replace
    svg.replace(blk, color.to-hex())
  } else {
    // Explicitly state color
    svg.replace("<svg ", "<svg fill=\"" + color.to-hex() + "\" ")
  }
}

#let datetime-display-cn-cover(date) = {
  date.display("[year]    年   [month]  月")
}

#let report-cover(
  fonts: (:),
  info: (:),
  stoke-width: 0.5pt,
  info-inset: (x: 0pt, bottom: 1pt),
  info-key-width: 72pt,
  info-key-font: "宋体",
  info-value-font: "宋体",
  info-col-gutter: -3pt,
  info-row-gutter: 5pt,
) = {
  fonts = fonts + font-family
  info = (
    (
      year: "2024",
      season: "春",
      lesson: "人工智能导论",
      teacher: "李四",
      author: "张三",
      student-id: "123456",
      grade: "2024",
      submit-date: datetime.today(),
    )
      + info
  )


  if type(info.submit-date) == datetime {
    info.submit-date = datetime-display-cn-cover(info.submit-date)
  }

  let info-key(body) = {
    rect(
      width: 100%,
      inset: info-inset,
      stroke: none,
      text(
        font: fonts.at(info-key-font, default: "宋体"),
        size: font-size.小三,
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
        bottom-edge: "descender",
        body,
      ),
    )
  }

  let info-long-value(key, body) = {
    grid.cell(
      colspan: 2,
      info-value(
        key,
        body,
      ),
    )
  }


  pagebreak(weak: true)

  v(50pt)

  set align(center)

  let nenu-logo = read("../assets/nenu-logo.svg")

  pad(image("../assets/nenu-title-blue.svg", width: 6.14cm), top: 0cm, bottom: 0cm)

  text(
    font: fonts.黑体,
    size: font-size.小二,
    "信  息  科  学  与  技  术  学  院\n\n",
  )

  text(
    font: fonts.黑体,
    size: font-size.小初,
    weight: "medium",
    "实    验    报    告\n",
  )
  text(font: fonts.宋体, size: font-size.四号, weight: "medium")[

    （ #info.year 年 #info.season 季 学期 ）
  ]

  v(20pt)

  pad(
    left: 20pt,
    block(
      width: 318pt,
      grid(
        columns: (info-key-width, info-key-width, 1fr),
        column-gutter: info-col-gutter,
        row-gutter: info-row-gutter,
        info-key("课程名称："), info-long-value("lession", info.lesson), info-key("指导教师："),

        info-long-value("major", info.teacher), info-key("学生姓名："), info-long-value("author", info.author),

        info-key("学   号："), info-long-value("student-id", info.student-id), info-key("年   级："),

        info-long-value("grade", info.grade),
      ),
    ),
  )

  v(80pt)

  text(size: font-size.四号, font: fonts.宋体)[
    #info.submit-date
  ]
}

#let report-content(
  fonts: (:),
  lab-info: (:),
  ..args,
  body,
) = {
  fonts = font-family + fonts

  lab-info = (
    (
      lab-title: "A*算法",
      lab-for: "理解A*算法",
      lab-dev: "Intel 13th i5",
      lab-requirement: "实验要求实验要求",
      lab-result: "实验结果与结论，简要概括",
    )
      + lab-info
  )

  pagebreak(weak: true)

  fonts = font-family + fonts

  let text-args = (font: fonts.宋体, size: font-size.小五)


  let heading-font = (fonts.宋体,)
  let heading-size = (font-size.四号, font-size.五号)
  let heading-padding = (
    top: 2 * 15.6pt - .7em,
    bottom: (2 * 15.6pt - .7em, 1.5 * 15.6pt - .7em),
  )


  show heading: i-figured.reset-counters
  show figure: i-figured.show-figure


  show figure.where(kind: table): set figure.caption(position: top)
  set figure.caption(separator: " ")
  show figure.caption: strong
  show figure.caption: set text(..text-args)

  let heading-text-args-lists = args
    .named()
    .pairs()
    .filter(pair => pair.at(0).starts-with("heading-"))
    .map(pair => (
      pair.at(0).slice("heading-".len()),
      pair.at(1),
    ))


  let array-at(arr, pos) = {
    arr.at(calc.min(pos, arr.len()) - 1)
  }

  set heading(
    numbering: numbly(
      "{1:一}、",
      "{1:1}.{2}",
      "{1}.{2}.{3}",
    ),
  )

  show heading: it => {
    // TODO 取消此处的硬编码
    if it.level == 1 {
      v(1em)
    }
    set text(
      font: array-at(heading-font, it.level),
      size: array-at(heading-size, it.level),
      weight: "bold",
      ..unpack(
        heading-text-args-lists.map(pair => (
          pair.at(0),
          array-at(pair.at(1), it.level),
        )),
      ),
    )
    set block(
      above: heading-padding.top,
      below: array-at(heading-padding.bottom, it.level),
    )
    it
    fake-par
  }

  {
    set align(center)
    text(font: fonts.宋体, size: font-size.三号)[
      #fakebold[#lab-info.lab-title]
    ]
  }

  set text(font: fonts.宋体, size: font-size.小四, lang: "zh")
  body
}

#let report(
  fonts: (:),
  info: (:),
  lab-info: (:),
) = {
  fonts = font-family + fonts

  return (
    info: info,
    cover: (..args) => {
      report-cover(
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
        info: info + args.named().at("info", default: (:)),
      )
    },
    ctx: (..args) => {
      report-content(
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
        lab-info: lab-info + args.named().at("lab-info", default: (:)),
      )
    },
  )
}

#let nenu-bibliography(
  bibliography: none,
  full: false,
  style: "gb-7714-2005-numeric",
) = {
  [
    = 参考文献
  ]
  assert(bibliography != none, message: "bibliography 函数不能为空")

  set text(lang: "en", size: font-size.小四, font: font-family.宋体)

  bibliography(
    title: none,
    full: full,
    style: style,
  )
}

#show: codly-init.with()
#codly(languages: codly-languages)


#let (info, cover, ctx) = report(
  fonts: (:),
  info: (
    year: "2024",
    season: "春",
    lesson: "走进智能科学",
    teacher: "李四",
    author: "张三",
    student-id: "123456",
    grade: "2022",
    submit-day: datetime.today(),
  ),
  lab-info: (
    lab-title: "实验名称（请替换成具体实验名称）",
  ),
)


#cover()


#ctx()[
  = 实验环境

  = 实验内容
  == 这是二级标题
  == 这是第二个二级标题

  这里是一张图：

  #figure(
    image("../images/editor.png", width: 50%),
    caption: [这是一张缩放 50% 的图],
  )<ida-star-50>

  这里是一张表：

  #align(
    center,
    (
      stack(dir: ltr)[
        #figure(
          table(
            align: center + horizon,
            columns: 4,
            stroke: none,
            table.hline(),
            [x], [y], [z], [t],
            table.hline(stroke: .5pt),
            [11], [5 ms], [3], [0.7],
            [3000], [80 ms], [1111], [0.9],
            table.hline(),
          ),
          caption: [三线表示例],
        )<three-line-table>
      ]
    ),
  )

  这里是伪代码：
  #figure(
    kind: "algorithm",
    supplement: [算法],
    pseudocode-list(booktabs: true, numbered-title: [Local Search])[
      + $cal(F), "card" arrow.l$ Pre-processing($cal(F)$)
      + *while* elapsed time < cutoff *do*
        + $sigma^prime arrow.l$ a partial assignment with previous solutions
        + $sigma arrow.l$ Unit Propagation($cal(F), sigma^prime$)
        + *while* not_improved $lt$ N *do*
          + *if* $sigma "SAT" cal(F)$ *then*
            + *return* $sigma$
          + $c_i arrow.l$ an unsat clause chosen with $max$ $w_i$
          + *if* $exists x in c_i "with" max "score"(x)$ *then*
            + $v arrow.l x$
          + *else*
            + $v arrow.l cases(
                "random variable in " C ",   " p,
                "with min cost variable in" C ",  " 1-p
              )$
          + Flip $v$ in $sigma$
          + not_improved $++$
        + *end*
      + *end*
    ],
    caption: "局部搜索算法框架",
  )<cardsat>

  这里是真实的代码：
  #figure(
    [
      ```rust
      pub fn main() {
          println!("Hello, world!");
      }
      ```
    ],
    caption: "示例代码展示",
  )


  = 实验总结

  #nenu-bibliography(bibliography: bibliography.with("references.bib"))
]

