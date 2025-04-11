#import "mod.typ": *
#show: style
// 英文封面

// 元信息
#{
  set align(left)
  set text(size: 五号)
  block(
    width: 100%,
    stack(
      dir: ltr,
      [Thesis for ] + 论文类型-英文 + [ in ] + 毕业年份,
    ),
  )
}

// 学校信息
#{
  set text(size: 五号)
  block(
    width: 100%,
    above: 20pt,
    grid(
      columns: (1fr, 80pt, 90pt),
      // 设置行间距
      row-gutter: 1.2em,
      [], en-meta-key("University Code"), en-meta-value(学校代码),
      [], en-meta-key("Student ID"), en-meta-value(学号),
    ),
  )
}

// 校徽
#{
  show text: upper
  block(
    width: 100%,
    above: 100pt,
    image("../public/ECNU-英文校徽.svg"),
  )
}

// 标题
#{
  set text(size: 二号)
  block(
    width: 100%,
    above: 100pt,
    grid(
      align: (right, center),
      columns: (1fr, 5fr),
      "Title:", underline(论文题目-分段-英文, extent: 20pt, evade: false),
    ),
  )
}

// 作者信息
#{
  set text(font: 封面字体, weight: "semibold")
  block(
    width: 100%,
    above: 100pt,
    grid(
      columns: (90pt, 220pt),
      align: (right, center),
      row-gutter: .75em,
      en-info-key("Department"), en-info-value(院系-英文),
      en-info-key("Category"), en-info-value(专业-英文),
      en-info-key("Field"), en-info-value(领域-英文),
      en-info-key("Supervisor"), en-info-value(指导教师-英文),
      en-info-key("Candidate"), en-info-value(作者-英文),
    ),
  )
}

// 日期
#{
  set text(font: 封面字体)
  block(
    above: 100pt,
    日期-英文,
  )
}

#switch-two-side(双页模式)
