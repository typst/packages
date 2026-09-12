#import "@preview/pointless-size:0.1.1": zh
#set page(margin: (
  top: 3.5cm,
  bottom: 2.5cm,
  left: 2.5cm,
  right: 2.5cm,
))
#let distr(width: auto, body) = {
  block(
    width: width,
    stack(
      dir: ltr,
      ..body.clusters().map(x => [#x]).intersperse(1fr),
    ),
  )
}
#let number_to_chinese(num) = {
  let chinese_digits = (
    "〇",
    "一",
    "二",
    "三",
    "四",
    "五",
    "六",
    "七",
    "八",
    "九",
  )
  let num_str = str(num)
  let result = ""
  for num_digit in num_str {
    let num_digit = int(num_digit)
    result += chinese_digits.at(num_digit)
  }
  return result
}

//! 封面logo
#place(
  dx: -0.29cm,
  dy: 0.33cm,
  image("../assets/江西财经大学相关元素/硕士毕业论文封面logo.png", width: 6.78cm),
)

//! 出版信息
#{
  let _underline() = {
    rect(
      width: 3.1cm,
      stroke: (bottom: 0.6pt + black),
    )
  }
  set text(font: "SimHei", size: zh(5))
  place(
    dx: 9.35cm,
    dy: 0.87cm,
    grid(
      columns: (4.3em, 1 * 0.25cm),
      rows: 1em,
      gutter: 0.45cm,
      distr(width: 5em, "学校代码"), _underline(),
      distr(width: 5em, "密级"), _underline(),
      distr(width: 5em, "中图分类号"), _underline(),
      distr(width: 5em, "UDC"), _underline(),
    ),
  )
}

//! 以下元素全部居中
#set align(center)

//! 硕士学位论文/MASTER DISSERTATION
#v(183pt)
#{
  set text(font: "Microsoft YaHei", size: 45pt, tracking: 10pt)
  set par(leading: 1em, spacing: 35pt)
  [硕士学位论文]
}
#{
  set text(font: "STZhongsong", size: zh(1))
  set par(leading: 1em)
  [MASTER DISSERTATION]
}

//? 论文题目（中英）
#v(2 * 16.1pt)
#table(
  columns: (2.69cm, 11.49cm),
  rows: 1.1cm,
  align: center + horizon,
  stroke: none,
  text(font: "SimHei", size: zh(-3))[论文题目],
  text(font: "KaiTi", size: zh(3))[基于元学习的],
  table.hline(stroke: 0.5pt, start: 1),
  text(font: "SimHei", size: zh(4))[（中文）],
  text(font: "STZhongsong", size: zh(4))[财务舞弊识别研究],
  table.hline(stroke: 0.5pt, start: 1),
  text(font: "SimHei", size: zh(-3))[论文题目],
  text(font: "Times New Roman", size: zh(3))[Research on Financial Fraud Identification],
  table.hline(stroke: 0.5pt, start: 1),
  text(font: "SimHei", size: zh(4))[（英文）],
  text(font: "STZhongsong", size: zh(3))[Based on Meta-learning],
  table.hline(stroke: 0.5pt, start: 1),
)

//? 作者信息
#v(5pt)
#table(
  columns: (2.44cm, 4.88cm, 0.42cm, 2.45cm, 4.26cm),
  rows: 1.06cm,
  align: center + bottom,
  stroke: none,
  text(font: "SimHei", size: zh(4))[
    #distr(width: 4em, "作者")
  ],
  text(font: "KaiTi", size: zh(-3))[章迎潭],
  none,
  text(font: "SimHei", size: zh(4))[
    #distr(width: 4em, "导师")
  ],
  text(font: "SimHei", size: zh(4))[马海强],
  table.hline(stroke: 0.5pt, start: 1, end: 2),
  table.hline(stroke: 0.5pt, start: 4),
  text(font: "SimHei", size: zh(4))[
    #distr(width: 4em, "申请学位")
  ],
  text(font: "KaiTi", size: zh(-3))[硕士],
  none,
  text(font: "SimHei", size: zh(4))[
    #distr(width: 4em, "学院名称")
  ],
  text(font: "SimHei", size: zh(4))[统计与数据科学],
  table.hline(stroke: 0.5pt, start: 1, end: 2),
  table.hline(stroke: 0.5pt, start: 4),
  text(font: "SimHei", size: zh(4))[
    #distr(width: 4em, "学科专业")
  ],
  text(font: "KaiTi", size: zh(-3))[应用统计],
  none,
  text(font: "SimHei", size: zh(4))[
    #distr(width: 4em, "研究方向")
  ],
  text(font: "KaiTi", size: zh(-3))[机器学习],
  table.hline(stroke: 0.5pt, start: 1, end: 2),
  table.hline(stroke: 0.5pt, start: 4),
)

//? 年月
#v(60pt)
#text(font: "SimHei", size: zh(-2))[
  #number_to_chinese(2025)年#number_to_chinese(4)月
]
