// SCUT 盲审封面（“单盲”/“双盲”评审学位论文封面）
// 版式还原自 local/SCUT_thesis/cover_file/“双盲”评审学位论文模板.docx 与
// local/SCUT_thesis/settings_files/“单盲”评审学位论文模板.dotx
// 覆盖学术型/专业学位 × 普通/留学生 × 普通/同等学力 共九种封面变体；
// 单盲保留作者姓名与指导教师栏，双盲隐去。
#import "../utils/datetime-display.typ": datetime-display, datetime-ym-display
#import "../utils/custom-cuti.typ": fakebold
#import "../utils/section-break.typ": section-break
#import "../utils/style.typ": 字号, 字体

// 封面主标题行：“专业学位硕士留学生学位论文”过长，模板将其断为两行
#let degree-name-lines(doctype: "master", kind: "academic", international: false) = {
  let base = if doctype == "doctor" { "博士" } else { "硕士" }
  if kind == "professional" {
    if international {
      ("专业学位" + base + "留学生", "学位论文")
    } else {
      ("专业学位" + base + "学位论文",)
    }
  } else if international {
    (base + "留学生学位论文",)
  } else {
    (base + "学位论文",)
  }
}

// 同等学力封面的括号副题（三号黑体）
#let equivalent-subtitle(doctype: "master") = if doctype == "doctor" {
  "（同等学力申请博士学位）"
} else {
  "（同等学力申请硕士学位）"
}

// 专业学位封面以“学位类别”取代“学科专业”
#let major-label(kind: "academic") = if kind == "professional" { "学位类别" } else { "学科专业" }

// 博士学位论文须在封面后附专家评阅结果处理办法页
#let review-result-page(fonts: (:), open-right: false) = {
  fonts = 字体 + fonts
  section-break(open-right: open-right)
  set align(left)

  v(106pt)
  align(center, text(font: fonts.宋体, size: 字号.三号)[#fakebold[华南理工大学博士学位（毕业）论文专家评阅结果处理办法]])

  v(21pt)
  set text(font: fonts.宋体, size: 字号.五号)
  block(
    inset: (x: 21pt),
    {
      set par(first-line-indent: 2em, leading: 1.6em)
      [根据《华南理工大学学位（毕业）论文工作管理办法（2025 年修订）》，博士学位（毕业）论文专家评阅结果处理办法如下：]
    },
  )

  v(0pt)
  let red = rgb("C0504D")
  let cell = table.cell.with(inset: (x: 5pt, y: 5pt))
  let head-cell(body) = cell(align: center + horizon, text(font: fonts.宋体, size: 字号.五号)[#fakebold(body)])
  let body-cell(body) = cell(align: left + horizon, text(font: fonts.宋体, size: 字号.五号, body))
  let red-cell(body) = cell(align: left + horizon, text(font: fonts.宋体, size: 字号.五号, fill: red, body))
  let red-merged(body) = cell(rowspan: 2, align: left + horizon, text(font: fonts.宋体, size: 字号.五号, fill: red, body))
  align(center, table(
    columns: (140pt, 265pt),
    rows: (34pt, 33pt, 41pt, 42.5pt, 33pt, 35pt, 43pt),
    stroke: 0.75pt + black,
    head-cell[评阅结果],
    head-cell[处理办法],
    body-cell[均为“同意答辩”],
    body-cell[可申请答辩],
    body-cell[1 份及以上为“适当修改”，其余为“同意答辩”],
    body-cell[导师审核通过后，可申请答辩],
    red-cell[1 份及以上为“重大修改”，其余无“不同意答辩”],
    red-merged[导师审核通过后，分委员会增聘 2 位校外专家评阅论文],
    red-cell[1 份为“不同意答辩”],
    red-cell[2 份“不同意答辩”],
    red-merged[学位申请人有且仅有 1 次在规定时限内重新申请论文评阅的机会],
    red-cell[增聘有“重大修改”或“不同意答辩”],
  ))

  v(14pt)
  block(
    inset: (x: 21pt),
    {
      set par(first-line-indent: 2em)
      [注：每篇论文选聘 3 位专家进行评阅。]
    },
  )
}

#let blind-cover(
  doctype: "master",
  blind: "double",
  kind: "academic",
  international: false,
  equivalent: false,
  open-right: false,
  fonts: (:),
  info: (:),
  logo: image("../assets/scut-logo.jpg", width: 12.1cm),
  stroke-width: 0.5pt,
  datetime-display: datetime-display,
  datetime-ym-display: datetime-ym-display,
) = {
  fonts = 字体 + fonts

  if type(info.title) == str {
    info.title = info.title.split("\n")
  }

  let name-lines = degree-name-lines(doctype: doctype, kind: kind, international: international)
  let label = major-label(kind: kind)
  let submit-date-text = if type(info.submit-date) == datetime {
    // 硕士封面仅写年月，博士封面写全日期
    if doctype == "doctor" {
      datetime-display(info.submit-date)
    } else {
      datetime-ym-display(info.submit-date)
    }
  } else {
    info.submit-date
  }

  // 满宽横线，文字居于一端
  let blind-line(body: []) = rect(
    width: 436pt,
    inset: (x: 0pt, bottom: 3.5pt),
    stroke: (bottom: stroke-width + black),
    align(center, text(font: fonts.黑体, size: 字号.二号, bottom-edge: "descender", body)),
  )

  // ====== 盲审封面 ======
  section-break(open-right: open-right)
  set align(center)

  v(82pt)
  logo
  v(-25pt)
  text(size: 字号.初号, font: fonts.黑体, weight: "bold", name-lines.join("\n"))
  if equivalent {
    v(4pt)
    text(size: 字号.三号, font: fonts.黑体, weight: "bold", equivalent-subtitle(doctype: doctype))
  }
  v(34pt)

  // 论文题目写于横线之上，固定两行
  set align(left)
  stack(
    spacing: 8pt,
    blind-line(body: info.title.at(0)),
    blind-line(body: info.title.at(1, default: [])),
  )

  v(76pt)

  // 信息栏：黑体三号，标签无冒号，值居中落于横线
  // 标签与值使用同几何盒子，保证基线在同一水平线上
  let blind-key(body) = rect(
    inset: (x: 0pt, bottom: 1pt),
    stroke: none,
    align(left, text(font: fonts.黑体, size: 字号.三号, bottom-edge: "descender", body)),
  )
  let blind-value(body) = rect(
    width: 194pt,
    inset: (x: 0pt, bottom: 1pt),
    stroke: (bottom: stroke-width + black),
    align(center, text(font: fonts.黑体, size: 字号.三号, bottom-edge: "descender", body)),
  )

  // 单盲在学科（学位类别）前后保留作者与导师栏
  let rows = if blind == "single" {
    (
      blind-key[作者姓名],
      blind-value(info.author),
      blind-key(label),
      blind-value(info.major),
      blind-key[指导教师],
      blind-value(info.supervisor.intersperse(" ").sum()),
      blind-key[所在学院],
      blind-value(info.department),
      blind-key[论文提交日期],
      blind-value(submit-date-text),
    )
  } else {
    (
      blind-key(label),
      blind-value(info.major),
      blind-key[所在学院],
      blind-value(info.department),
      blind-key[论文提交日期],
      blind-value(submit-date-text),
    )
  }

  set align(left)
  block(
    inset: (left: 64pt),
    grid(
      columns: (123pt, 194pt),
      row-gutter: 11pt,
      align: (left, left),
      ..rows,
    ),
  )

  // 博士学位论文须附专家评阅结果处理办法页
  if doctype == "doctor" {
    review-result-page(fonts: fonts, open-right: open-right)
  }
}
