#import "../utils/style.typ": 字号, 字体
#import "../utils/datetime-display.typ": datetime-display
#import "@preview/cuti:0.3.0": show-cn-fakebold
#show: show-cn-fakebold

// 本科生声明页
#let bachelor-decl-page(
  anonymous: false,
  twoside: false,
  student-sign: "",
  student-sign-datetime: auto,
  teacher-sign: "",
  teacher-sign-datetime: auto,
  datetime-display: datetime-display,
  fonts: (:),
  info: (:),
) = {
  // 0. 如果需要匿名则短路返回
  if anonymous {
    return
  }
  counter(page).update(0)

  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    (
      title: ("基于 Typst 的", "南京大学学位论文"),
    )
      + info
  )

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }
  if type(info.title) == array {
    info.title = info.title.join("")
  }
  if type(student-sign-datetime) == datetime {
    student-sign-datetime = datetime-display(student-sign-datetime)
  }
  if type(teacher-sign-datetime) == datetime {
    teacher-sign-datetime = datetime-display(teacher-sign-datetime)
  }

  // 3.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  show: show-cn-fakebold
  align(
    center,
    text(
      font: fonts.宋体,
      size: 字号.三号,
      weight: "bold",
      "福州大学本科生毕业设计（论文）诚信承诺书",
    ),
  )
  set text(font: fonts.宋体, size: 字号.小四)
  let student-commitment = {
    v(2em)
    align(
      center,
      text(size: 字号.小四)[
        *学生承诺*
      ],
    )
    v(1em)
    par(first-line-indent: 2em)[
      我承诺在毕业设计（论文）过程中遵守学校有关规定，恪守学术规范, 未存在买卖、代写、作假等行为。在本人的毕业设计（论文）中未剽窃、抄袭他人的学术观点、思想和成果，未篡改实验数据。如有违规行为发生我愿承担一切责任，接受学校的处理。
    ]

    v(2em)
    align(right)[
      学生（签名）：#box(width: 10em, student-sign)
      \
      #if student-sign-datetime == auto {
        box(width: 4em)
        [年]
        box(width: 2em)
        [月]
        box(width: 2em)
        [日]
        box(width: 2em)
      } else {
        student-sign-datetime
        box(width: 2em)
      }
    ]
    v(2em)
  }
  let teacher-commitment = {
    v(2em)
    align(
      center,
      text(size: 字号.小四)[
        *指导教师承诺*
      ],
    )
    v(1em)
    par(first-line-indent: 2em)[
      我承诺在指导学生毕业设计（论文）过程中遵守学校有关规定，恪守学术规范，经过本人认真的核查，该同学未存在买卖、代写、作假等行为，毕业设计（论文）中未发现有剽窃、抄袭他人的学术观点、思想和成果的现象，未发现篡改实验数据。
    ]

    v(2em)
    align(right)[
      指导教师（签名）：#box(width: 10em, teacher-sign)
      \
      #if teacher-sign-datetime == auto {
        box(width: 4em)
        [年]
        box(width: 2em)
        [月]
        box(width: 2em)
        [日]
        box(width: 2em)
      } else {
        teacher-sign-datetime
        box(width: 2em)
      }
    ]
    v(2em)
  }
  table(
    align: horizon,
    columns: (auto, auto, auto, 1fr, auto, 1fr),
    stroke: .5pt,
    [学生姓名], info.author, [年　级], info.grade, [学　号], info.student-id,
    [所在学院], table.cell(colspan: 3, info.department), [所学专业], info.major,
    table.cell(rowspan: 2, colspan: 2)[毕业设计（论文）题目],
    table.cell(colspan: 4)[中文： #info.title],
    table.cell(colspan: 4)[英文： #info.title-en],
    table.cell(colspan: 6)[#student-commitment],
    table.cell(colspan: 6)[#teacher-commitment],
  )
  counter(page).update(0)
}
