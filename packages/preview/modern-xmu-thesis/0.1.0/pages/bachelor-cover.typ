#import "../utils/datetime-display.typ": datetime-display-full
#import "../utils/style.typ": 字号, 字体

// 本科生封面
#let bachelor-cover(
  // documentclass 传入的参数
  twoside: false,
  fonts: (:),
  info: (:),
  // 其他参数
  isdesign: false, // 是否为毕业设计
  isminor: false, // 是否为辅修
  datetime-display: datetime-display-full,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    title: ("基于 Typst 的", "厦门大学本科毕业论文模板"),
    title-en: "An XMU Undergraduate Thesis Template\nPowered by Typst",
    grade: "20XX",
    student-id: "1234567890",
    author: "张三",
    department: "某学院",
    major: "某专业",
    supervisor: ("李四", "教授"),
    submit-date: datetime.today(),
  ) + info

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }
  if type(info.title-en) == str {
    info.title-en = info.title-en.split("\n")
  }
  // 2.2 处理提交日期
  if type(info.submit-date) == datetime {
    info.submit-date = datetime-display(info.submit-date)
  }

  // 3.  内置辅助函数
  let info-key-short(str) = {
    box(width: 4.5em, str.codepoints().join(h(1fr)) + "：")
  }
  let info-key-long(str) = {
    box(width: auto, str + "：")
  }

  // 4.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  // 居中对齐
  set align(center)

  // 学校 LOGO
  v(20pt)
  image("../assets/xmu-zi-jiageng.svg", width: 208pt)
  v(3em)

  // 将中文之间的空格间隙从 0.25em 调整到 1em
  text(size: 字号.小二, font: fonts.宋体, spacing: 400%, weight: "bold")[本 科 毕 业 #if isdesign [设 计] else [论 文]]
  v(0pt)
  if isminor { text(size: 字号.三号, font: fonts.宋体, weight: "bold")[（辅修）] }

  v(2em)

  text(size: 字号.二号, font: fonts.黑体, info.title.join("\n"))

  v(1em)

  text(size: 字号.三号, font: fonts.宋体, info.title-en.join("\n"), weight: "bold")

  v(2em)

  text(size: 字号.四号, font: fonts.宋体, grid(
    align: (right, left),
    columns: (1fr, 1fr),
    row-gutter: 1.5em,
    column-gutter: 1.5em,
    info-key-short("姓名"),
    info.author,
    info-key-short("学号"),
    info.student-id,
    info-key-short("学院"),
    info.department,
    info-key-short("专业"),
    info.major,
    info-key-short("年级"),
    info.grade + "级",
    info-key-long("校内指导老师"),
    info.supervisor.join(" "),
    info-key-long("校外指导老师"),
    if info.supervisor-outside != () { info.supervisor-outside.join(" ") },
  ))

  v(10em)

  text(size: 字号.四号, font: fonts.宋体, info.submit-date)
}