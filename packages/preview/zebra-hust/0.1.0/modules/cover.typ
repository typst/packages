#import "@preview/zh-format:0.1.0": *
#import "@preview/pointless-size:0.1.2": zh

#let cover-label(width, label, font: "FandolSong", weight: "regular") = box(width: width, {
  set text(font: font, weight: weight)
  stack(dir: ltr, spacing: 1fr, ..label.clusters())
})

#let thesis-cover(cover, fonts, layout) = {
  set page(margin: 0pt, header: none, footer: none, numbering: none)
  set par(first-line-indent: 0pt, justify: false)
  set text(font: (..fonts.latin, ..fonts.cover), size: 16pt, top-edge: "bounds", bottom-edge: "bounds")

  context {
    let field(label, value) = {
      let value-body = block(width: 12em, align(center, value))
      let value-height = calc.max(18pt, measure(value-body).height + 2pt)
      (
        cover-label(4em, label, font: fonts.cover),
        block(width: 12em, height: value-height, stroke: (bottom: 0.4pt), value-body),
      )
    }
    let fields = grid(
      columns: (4em, 12em),
      column-gutter: 12pt,
      row-gutter: layout.row-height - 18pt,
      align: top,
      ..field("院系", cover.college),
      ..field("专业班级", cover.class),
      ..field("姓名", cover.name),
      ..field("学号", cover.student-id),
      ..field("指导教师", cover.teacher),
    )
    let sections = (
      (top: layout.logo-top, body: image("../images/HUSTGreen.svg", height: 1.61cm)),
      (top: layout.heading-top, body: text(font: fonts.cover, size: 36pt, weight: "bold")[本科生毕业设计]),
      (top: layout.title-top, body: block(width: 146mm, align(center,
        text(font: (..fonts.latin, ..fonts.hei), size: 22pt, weight: "bold", cover.title),
      ))),
      (top: layout.fields-top, body: fields),
      (top: layout.date-top, body: cover.report-date),
    )
    let cursor = 0pt
    let contents = ()
    for section in sections {
      let section-body = block(width: 210mm, align(center, section.body))
      let gap = calc.max(section.top - cursor, if cursor == 0pt { 0pt } else { layout.min-gap })
      contents.push(v(gap))
      contents.push(section-body)
      cursor += gap + measure(section-body).height
    }
    assert(cursor <= 297mm - 20mm, message: "封面内容过长，请缩短题目或信息字段，或调整 thesis_config.cover 的间距")
    stack(dir: ttb, spacing: 0pt, ..contents)
  }
  pagebreak()
}

#let cover-page(
  title: "课程实验报告",
  course: "数据结构实验",
  class: "计卓 2401",
  student-id: "U2024xxxxx",
  name: "张三",
  teacher: "李四",
  report-date: "2024年1月1日",
  college: "计算机科学与技术学院",
  title-font: "FandolSong",
  font: "FandolSong",
) = {
  v(1em)

  align(center, image("../images/HUSTGreen.svg", width: 20em))

  v(-1em)

  align(center, text(font: title-font, size: zh(0.5), weight: "bold", tracking: 0.5em)[#title])

  v(3em)

  set text(size: zh(3))

  let format-key = cover-label.with(font: font, weight: "bold")
  let format-value(width, s) = text(font: font, weight: "bold")[#u(width: width)[#s]]

  let key = format-key.with(5em)
  let value = format-value.with(10em)

  align(center, text(size: zh(2))[#key("课程名称： ")#value(course)])

  v(8em)

  let key-width = 4em
  let key = format-key.with(key-width)
  let value = format-value.with(12em)

  align(center, grid(
    columns: (key-width, auto),
    column-gutter: 0.5em,
    row-gutter: 2em,
    key("专业班级"), value(class),
    key("学号"), value(student-id),
    key("姓名"), value(name),
    key("指导教师"), value(teacher),
    key("报告日期"), value(report-date),
  ))

  v(3em)

  align(center, text(college, font: font, size: zh(3), weight: "bold"))

  pagebreak()
}
