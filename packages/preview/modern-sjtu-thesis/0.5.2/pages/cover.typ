#import "../utils/style.typ": zihao, ziti
#import "../utils/distr.typ": distr
#import "../utils/datetime-display.typ": datetime-display

#let cover-page(
  date: datetime.today(),
  doctype: "master",
  twoside: false,
  anonymous: false,
  info: (:),
  key-to-zh: (:),
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

  let customized = key-to-zh != (:)

  let key-to-zh = if customized {
    key-to-zh
  } else {
    (
      name: "姓名",
      student-id: "学号",
      supervisor: "导师",
      co-supervisor: "联合导师",
      school: "院系",
      major: [学科/#h(0.1em)专业],
      degree: "申请学位",
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

  if not customized and doctype == "master" and info.keys().contains("co-supervisor") {
    cover-title = "上海交通大学专业学位硕士学位论文"
    key-to-zh.supervisor = "校内导师"
    key-to-zh.school = "学院"
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

  v(1fr)

  align(
    center,
    text(font: ziti.songti, size: zihao.erhao, weight: "bold")[#info.title],
  )

  v(1.1fr)

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

    ..for (key, value) in key-to-zh {
      if key-to-zh.keys().contains(key) {
        (info-key(value), text(weight: "bold")[：], info-value(info.at(key)))
      }
    },
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
