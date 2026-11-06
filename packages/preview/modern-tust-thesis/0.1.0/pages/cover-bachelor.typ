#import "../utils/style.typ": zihao, ziti
#import "../utils/uline.typ": uline

#let zh-month-map = (
  "1": "一",
  "2": "二",
  "3": "三",
  "4": "四",
  "5": "五",
  "6": "六",
  "7": "七",
  "8": "八",
  "9": "九",
  "10": "十",
  "11": "十一",
  "12": "十二",
)

#let zh-year(year) = {
  let s = str(year)
    .replace("0", "〇")
    .replace("1", "一")
    .replace("2", "二")
    .replace("3", "三")
    .replace("4", "四")
    .replace("5", "五")
    .replace("6", "六")
    .replace("7", "七")
    .replace("8", "八")
    .replace("9", "九")
  s + "年"
}

#let zh-year-month(date) = {
  zh-year(date.year()) + " " + zh-month-map.at(str(date.month())) + "月"
}

#let cover-bachelor-page(
  twoside: false,
  anonymous: false,
  info: (:),
  date: datetime.today(),
  key-to-zh: (:),
) = {
  let title = info.at("title", default: "论文题目")
  let title-en = info.at("title-en", default: "")
  let school = info.at("school", default: "学院名称")
  let major = info.at("major", default: "专业名称")
  let research = info.at("research", default: "研究方向")
  let grade = info.at("grade", default: "年级")
  let student-id = info.at("student-id", default: "学号")
  let name = info.at("name", default: "姓名")
  let supervisor = info.at("supervisor", default: "指导教师")
  let supervisor-rank = info.at("supervisor-rank", default: "")

  let work-type = info.at("work-type", default: "design")
  let cover-color = if work-type == "thesis" { "green" } else { "blue" }
  let myblue = rgb(53%, 76.5%, 80.4%)
  let mygreen = rgb(74.5%, 82.4%, 60.8%)
  let fill-color = if cover-color == "green" { mygreen } else { myblue }

  set page(fill: fill-color, header: none, footer: none)
  pagebreak(weak: true)
  align(center, {
    v(60pt)
    image("../assets/tust.png", width: 70%)
    v(10.5pt)
    image("../assets/tust-logo.png", width: 15%)
    v(5pt)
    text(font: ziti.fangsong, size: zihao.erhao, weight: "bold")[
      #if work-type == "thesis" {
        [本#h(0.5em)科#h(0.5em)毕#h(0.5em)业#h(0.5em)论#h(0.5em)文]
      } else {
        [本#h(0.5em)科#h(0.5em)毕#h(0.5em)业#h(0.5em)设#h(0.5em)计]
      }
    ]
    v(32pt)
    v(48pt)
    set text(font: ziti.fangsong, size: zihao.sanhao, weight: "bold")
    table(
      stroke: none,
      inset: (0pt, 0pt),
      columns: (4cm, 12cm),
      row-gutter: 1em,
      [学院名称：], uline(12cm)[#school],
      [专业名称：], uline(12cm)[#major],
      [题~~~~~~目：], uline(12cm)[#title],
      [研究方向：], uline(12cm)[#research],
      [年~~~~~~级：],
      uline(3.6cm)[#grade] + h(0.3em) + [学号：] + uline(6.6cm)[#student-id],
      [学生姓名：], uline(12cm)[#name],
    )
    v(60pt)
    text(font: ziti.fangsong, size: zihao.sanhao, weight: "bold")[#zh-year-month(date)]
  })

  pagebreak()
  set page(fill: none, header: none, footer: none)

  align(right, {
    text(font: ziti.songti, size: zihao.wuhao)[学校代码~~~10057]
    v(0pt)
    text(font: ziti.songti, size: zihao.wuhao)[密级~~~公开]
  })

  v(64pt)
  align(center, {
    text(font: ziti.fangsong, size: 22pt, weight: "bold")[#title]
    v(0pt)
    text(font: "Times New Roman", size: 22pt, weight: "bold")[#title-en]
  })

  place(center + horizon, dy: 100pt, {
    set text(font: ziti.fangsong, size: zihao.sihao)
    table(
      stroke: none,
      inset: (0pt, 0pt),
      columns: (3.5cm, 4.5cm, 3.5cm, 4.5cm),
      column-gutter: 0.5em,
      row-gutter: 2em,
      [作　　者：], uline(4.5cm)[#align(center)[#name]], [指导老师：], uline(4.5cm)[#align(center)[#supervisor]],
      [申请学位：], uline(4.5cm)[#align(center)[工学学士]], [培养单位：], uline(4.5cm)[#align(center)[人工智能学院]],
      [学科专业：], uline(4.5cm)[#align(center)[#major]], [研究方向：], uline(4.5cm)[#align(center)[#research]],
    )
  })

  place(center + bottom, dy: -80pt, {
    text(font: ziti.fangsong, size: zihao.sanhao)[#zh-year-month(date)]
  })
}
