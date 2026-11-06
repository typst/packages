// SCUT 封面（中文封面 + 英文内封 + 提名页）
// 版式还原自 local/SCUT_thesis/cover_file/master_cover.docx
#import "../utils/datetime-display.typ": datetime-display, datetime-ym-display
#import "../utils/justify-text.typ": justify-text
#import "../utils/section-break.typ": section-break
#import "../utils/style.typ": 字体, 字号
#import "@preview/cuti:0.4.0": cn-fakebold, fakebold
#import "./blind-cover.typ": blind-cover

#let cover(
  doctype: "master",
  open-right: false,
  blind: "none",
  kind: "academic",
  international: false,
  equivalent: false,
  fonts: (:),
  info: (:),
  logo: image("../assets/scut-logo.jpg", width: 12.1cm),
  stroke-width: 0.5pt,
  committee-line-inset: 1.6pt,
  min-title-lines: 2,
  info-key-width: 112pt,
  info-value-width: 210pt,
  info-column-gutter: 10pt,
  info-row-gutter: 7.5pt,
  datetime-display: datetime-display,
  datetime-ym-display: datetime-ym-display,
) = {
  fonts = 字体 + fonts

  // 盲审模式：仅盲审封面（博士另附专家评阅结果处理办法页）
  if blind != "none" {
    return blind-cover(
      doctype: doctype,
      blind: blind,
      kind: kind,
      international: international,
      equivalent: equivalent,
      open-right: open-right,
      fonts: fonts,
      info: info,
      logo: logo,
      stroke-width: stroke-width,
      datetime-display: datetime-display,
      datetime-ym-display: datetime-ym-display,
    )
  }

  if type(info.title) == str {
    info.title = info.title.split("\n")
  }
  if type(info.title-en) == str {
    info.title-en = info.title-en.split("\n")
  }
  // 标题补空行，日期格式化
  info.title = info.title + range(min-title-lines - info.title.len()).map(it => "　")
  if type(info.defend-date) == datetime {
    info.defend-date = datetime-display(info.defend-date)
  }

  // 信息栏：黑体三号，标签四字分散对齐无冒号，值居中带下划线
  let info-key(body) = {
    set text(font: fonts.黑体, size: 字号.三号)
    rect(
      width: 100%,
      inset: (x: 0pt, bottom: 2pt),
      stroke: none,
      justify-text(with-tail: false, body),
    )
  }

  let info-value(body, size: 字号.三号, width: info-value-width) = {
    rect(
      width: width,
      inset: (x: 0pt, bottom: 4pt),
      stroke: (bottom: stroke-width + black),
      align(center, text(
        font: fonts.黑体,
        size: size,
        bottom-edge: "descender",
        body,
      )),
    )
  }

  let degree-name = if doctype == "doctor" { "博士学位论文" } else { "硕士学位论文" }
  let degree-name-en = if doctype == "doctor" { "Doctor of Philosophy" } else { "Master" }
  let degree-level = info.degree-type + (if doctype == "doctor" { "博士" } else { "硕士" })

  // ====== 中文封面 ======
  section-break(open-right: open-right)
  set align(center)

  v(70pt)
  logo
  v(-10pt)
  text(size: 字号.初号, font: fonts.黑体, weight: "bold", degree-name)
  v(36pt)

  // 论文题目：无标签，标题居中带下划线，空行补足横线
  stack(
    spacing: 5pt,
    ..info.title.map(s => info-value(s, size: 字号.二号, width: 15cm)),
  )

  v(90pt)

  grid(
    columns: (info-key-width, info-value-width),
    column-gutter: info-column-gutter,
    row-gutter: info-row-gutter,
    info-key("作者姓名"), info-value(info.author),
    info-key("学科专业"), info-value(info.major),
    info-key("指导教师"), info-value(info.supervisor.intersperse(" ").sum()),
    info-key("所在学院"), info-value(info.department),
    info-key("论文提交日期"),
    // 硕士封面仅写年月，博士封面写全日期
    info-value(if type(info.submit-date) == datetime {
      if doctype == "doctor" {
        datetime-display(info.submit-date)
      } else {
        datetime-ym-display(info.submit-date)
      }
    } else {
      info.submit-date
    }),
  )

  // ====== 英文内封 ======
  section-break(open-right: open-right)
  set text(font: fonts.宋体)
  set align(center)

  v(44pt)
  text(size: 字号.小二, weight: "bold", info.title-en.intersperse("\n").sum())
  v(64pt)
  text(size: 字号.四号)[A Dissertation Submitted for the Degree of #degree-name-en]
  v(64pt)
  text(size: 字号.小三, weight: "bold")[Candidate：#info.author-en]
  v(16pt)
  text(size: 字号.小三, weight: "bold")[Supervisor：#info.supervisor-en]
  v(96pt)
  text(size: 字号.小三)[#info.school-name-en]
  v(16pt)
  text(size: 字号.小三)[#info.school-address-en]

  // ====== 提名页 ======
  section-break(open-right: open-right)
  set align(left)
  set text(font: fonts.宋体, size: 字号.小四)

  v(10pt)
  set text(font: fonts.黑体, size: 字号.四号)
  stack(
    dir: ltr,
    // 标签黑体无真粗体，用伪粗；值为纯拉丁字符，Times New Roman 有真粗体
    fakebold[分类号：] + text(weight: "bold", info.clc),
    h(1fr),
    fakebold[学校代号：] + text(weight: "bold", info.school-code),
  )
  v(4pt)
  fakebold[学　号：] + text(weight: "bold", info.student-id)

  v(70pt)
  align(center, text(font: fonts.黑体, size: 字号.小二, info.school-name + degree-name))
  v(46pt)
  // 题名中英文混排：汉字黑体伪粗，拉丁字符 Times New Roman 真粗体
  align(center, text(font: fonts.黑体, size: 字号.二号, weight: "bold", cn-fakebold(info.title.intersperse("\n").sum())))
  v(66pt)

  let confer-date-text = if type(info.confer-date) == datetime {
    datetime-display(info.confer-date)
  } else {
    "　　年　　月　　日"
  }

  set text(font: fonts.宋体, size: 字号.小四, weight: "regular")
  set par(leading: 1.2em)
  grid(
    columns: (auto, 1fr),
    column-gutter: 24pt,
    row-gutter: 22pt,
    [作者姓名：#h(0.5em)#info.author], [指导教师姓名、职称：#h(0.5em)#info.supervisor.intersperse(" ").sum()],
    [申请学位级别：#h(0.5em)#degree-level], [学科专业名称：#h(0.5em)#info.major],
    [研究方向：#h(0.5em)#info.field], [],
    [论文提交日期：#h(0.5em)#datetime-display(info.submit-date)], [论文答辩日期：#h(0.5em)#info.defend-date],
    [学位授予单位：#h(0.5em)#info.school-name], [学位授予日期：#h(0.5em)#confer-date-text],
  )

  // 答辩委员会：姓名置于横线之上，留空则为固定宽空白横线
  // 横线位于基线下方约 1pt（与 Word 单下划线位置一致），避免紧贴字形底部导致视觉上浮；
  // 留空时用全角空格占位，使空白横线与有姓名时的高度、基线完全一致。
  let committee-line(width, body) = if body == "" or body == none {
    box(width: width, stroke: (bottom: stroke-width + black), inset: (bottom: committee-line-inset))[\u{3000}]
  } else {
    box(stroke: (bottom: stroke-width + black), inset: (bottom: committee-line-inset), body)
  }

  v(10pt)
  parbreak()
  [答辩委员会成员：]
  v(2pt)
  parbreak()
  [主席：#committee-line(54pt, info.chairman)]
  v(6pt)
  parbreak()
  [委员：#committee-line(385pt, info.reviewer.join("　"))]
}
