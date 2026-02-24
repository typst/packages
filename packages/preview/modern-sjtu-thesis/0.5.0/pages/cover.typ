#import "../utils/style.typ": zihao, ziti
#import "../utils/distr.typ": distr
#import "../utils/datetime-display.typ": datetime-display

#let cover-page(
  date: datetime.today(),
  doctype: "master",
  twoside: false,
  anonymous: false,
  info: (:),
) = {
  align(
    center,
    image(
      "../assets/sjtu-logo.png",
      width: 3cm,
    ),
  )

  let cover-title = if doctype == "doctor" {
    "上海交通大学博士学位论文"
  } else {
    "上海交通大学硕士学位论文"
  }

  align(
    center,
    text(font: ziti.songti, size: zihao.xiaoer)[#cover-title],
  )

  v(3.6cm)

  align(
    center,
    text(font: ziti.songti, size: zihao.erhao, weight: "bold")[#info.title],
  )

  v(1fr)

  let info-key(zh) = distr(width: 5em, zh)

  let info-value(zh) = (
    text(
      zh,
      font: ziti.songti,
      size: zihao.sihao,
    )
  )

  set text(font: ziti.heiti, size: zihao.sihao)
  table(
    stroke: none,
    align: (x, y) => (
      if x >= 1 {
        left
      } else {
        right
      }
    ),
    columns: (46%, 1%, 53%),
    inset: (right: 0em),
    column-gutter: (-0.3em, 1em),
    row-gutter: 0.7em,
    [#info-key("姓名")],
    [#text(weight: "bold")[：]],
    [#if anonymous {} else {
      info-value(info.name)
    }],

    [#info-key("学号")],
    [#text(weight: "bold")[：]],
    [#if anonymous {} else {
      info-value(info.student_id)
    }],

    [#info-key("导师")],
    [#text(weight: "bold")[：]],
    [#if anonymous {} else {
      info-value(info.supervisor)
    }],

    [#info-key("院系")], [#text(weight: "bold")[：]], [#info-value(info.school)],
    [#info-key("学科/专业")], [#text(weight: "bold")[：]], [#info-value(info.major)],
    [#info-key("申请学位")], [#text(weight: "bold")[：]], [#info-value(info.degree)],
  )

  linebreak()

  align(
    center,
    text(font: ziti.songti, size: zihao.sihao, weight: "bold")[#datetime-display(date)],
  )

  v(0.2cm)

  pagebreak(
    weak: true,
    to: if twoside {
      "odd"
    },
  )
}
