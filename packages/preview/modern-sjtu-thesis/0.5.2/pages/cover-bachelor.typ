#import "../utils/style.typ": zihao, ziti
#import "../utils/distr.typ": distr
#import "../utils/datetime-display.typ": datetime-display-without-day

#let cover-bachelor-page(
  date: datetime.today(),
  twoside: false,
  anonymous: false,
  info: (:),
  key-to-zh: (:),
) = {
  v(0.3cm)

  align(
    center,
    image(
      "../assets/sjtu-logo.pdf",
      width: 2.79cm,
    ),
  )

  v(0.4cm)

  let cover-title = "上海交通大学学位论文"

  let customized = key-to-zh != (:)

  let key-to-zh = if customized {
    key-to-zh
  } else {
    (
      name: "姓名",
      student-id: "学号",
      supervisor: "导师",
      co-supervisor: "联合导师",
      school: "学院",
      major: "专业名称",
      degree: "申请学位层次",
    )
  }

  if anonymous {
    info.name = ""
    info.student-id = ""
    info.supervisor = ""
    if info.keys().contains("co-supervisor") {
      info.co-supervisor = ""
    }
  }

  if not customized and info.keys().contains("co-supervisor") {
    key-to-zh.supervisor = "校内导师"
  }

  for key in key-to-zh.keys() {
    if not info.keys().contains(key) {
      let tmp = key-to-zh.remove(key)
    }
  }

  align(
    center,
    text(font: ziti.songti, size: zihao.xiaoer)[#cover-title],
  )

  v(0.75fr)

  align(
    center,
    text(font: ziti.songti, size: zihao.erhao, weight: "bold")[#info.title],
  )

  v(1fr)

  let info-key(zh) = if zh.len() <= 12 {
    distr(width: 4em, zh)
  } else {
    zh
  }

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
    columns: (36%, 1%, 1fr),
    inset: (right: 0em),
    column-gutter: (-0.3em, 1em),
    row-gutter: 0.81em,

    ..for (key, value) in key-to-zh {
      if key-to-zh.keys().contains(key) {
        (info-key(value), text(weight: "bold")[：], info-value(info.at(key)))
      }
    },
  )

  v(0.8fr)

  align(
    center,
    text(font: ziti.songti, size: zihao.sihao)[#datetime-display-without-day(date)],
  )

  v(2.45cm)

  pagebreak(
    weak: true,
    to: if twoside {
      "odd"
    },
  )
}
