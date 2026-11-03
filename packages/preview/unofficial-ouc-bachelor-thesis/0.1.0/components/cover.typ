#import "@preview/pointless-size:0.1.2": zh
#import "@preview/cuti:0.4.0": fakebold
#import "/components/logo.typ": logo

#let empty-underline(width: 100%) = box("", width: width, stroke: (bottom: 0.5pt))

#let cover-info(fonts: (:)) = {
  set text(font: fonts.宋体, size: zh("小五"))

  place(center, dx: 1em, float: false, grid(
    columns: (25em, 22.4em),
    align: top,
    table(
      columns: (3em, 1fr) * 2,
      inset: (x: 0pt),
      row-gutter: .65em,
      stroke: none,
      align: center,
      fakebold[分类号], empty-underline(),
      fakebold[密级], empty-underline(),
      [*UDC*], table.cell(colspan: 3, empty-underline()),
    ),
    place(right + top, dy: -2em, logo),
  ))
}

#let cover-title(fonts: (:), title: "") = {
  set text(font: fonts.宋体, size: zh("小初"))

  align(center, fakebold(
    "本科毕业论文".clusters().join(h(.4em)) + "（设计）",
  ))

  v(0.5cm)


  align(center, text(font: fonts.黑体, size: zh("一号"), if type(title) == str { title } else { title.join("\n") }))
}

#let underline-box(c, width, stroke: (bottom: 0.5pt)) = box(width: 1fr, move(dy: .21em, box(
  width: width,
  stroke: stroke,
  move(dy: -.21em, c),
)))

#let thesis-info(
  author: "",
  advisor: "",
  college: "",
  department: "",
  defense-date: datetime.today(),
  fonts: (:),
) = {
  set text(font: fonts.宋体, size: zh("四号"), lang: "zh", region: "cn")

  let bold(c) = {
    set text(font: fonts.黑体, size: zh("四号"), lang: "zh", region: "cn")
    (c)
  }

  align(
    center,
    table(
      columns: 20em,
      inset: (x: 0pt),
      row-gutter: .95em,
      stroke: none,
      align: center,
      bold[学生姓名] + underline-box(author.name, 1fr) + bold[学号] + underline-box(author.id, 1fr),
      bold[指导教师] + underline-box(advisor, 1fr),
      bold[学部、学院（中心）] + underline-box(college, 1fr),
      bold[年级专业] + underline-box(department, 1fr),
      bold[论文答辩日期]
        + underline-box("", 0.5fr, stroke: none)
        + bold[年]
        + underline-box("", 0.5fr, stroke: none)
        + bold[月]
        + underline-box("", 0.5fr, stroke: none)
        + bold[日]
    ),
  )
}

#let cover(
  title: "",
  name: "",
  id: "",
  advisor: "",
  college: "",
  department: "",
  fonts: (:),
) = page(
  {
    cover-info(fonts: fonts)

    v(6.27cm)

    cover-title(fonts: fonts, title: title)

    v(4.65cm)

    thesis-info(
      author: (name: name, id: id),
      advisor: advisor,
      college: college,
      department: department,
      fonts: fonts,
    )

    v(.2cm)

    align(center, fakebold(text(font: fonts.楷体, size: zh("小二"), "中国海洋大学".clusters().join(h(.5em)))))
  },
  // background: image("/1d6f220a-7701-49c4-8084-16a8f20fb41a(1).pdf", page: 5),
)
