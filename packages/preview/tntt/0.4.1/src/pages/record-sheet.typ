/// Record Sheet Page
///
/// - anonymous (bool): Whether to use anonymous mode.
/// - twoside (bool): Whether to use two-sided layout.
/// - info (dictonary): Information about the student and thesis.
/// - title (content): The title of the record sheet page.
/// - prefill (bool): Whether to prefill the student information.
/// - rows (list(length)): The heights of the table rows.
/// - columns (list(length)): The widths of the table columns.
/// - author (content): The name of the student.
/// - student-id (content): The student ID.
/// - class (content): The class of the student.
/// - thesis-title (content): The title of the thesis.
/// - content (content): The main content and progress arrangement.
/// - mid-term-comment (content): The mid-term assessment comments.
/// - instructor-comment (content): The instructor's comments.
/// - reviewer-comment (content): The reviewer's comments.
/// - defense-comment (content): The defense committee's comments.
/// -> content
#let record-sheet(
  // from entry
  anonymous: false,
  twoside: false,
  info: (:),
  // options
  title: [综合论文训练记录表],
  prefill: true,
  rows: (1cm, 1cm, 12cm, 6.5cm),
  columns: (2cm, 1fr, 1.5cm, 1fr, 1.5cm, 1fr),
  author: [],
  student-id: [],
  class: [],
  thesis-title: [],
  content: [],
  mid-term-comment: [],
  instructor-comment: [],
  reviewer-comment: [],
  defense-comment: [],
) = {
  if anonymous { return }

  import "../utils/font.typ": use-size
  import "../utils/text.typ": use-stack

  if prefill {
    author = info.author
    student-id = info.student-id
    class = info.class
    thesis-title = info.title
  }

  pagebreak(weak: true, to: if twoside { "odd" })

  set page(numbering: none)

  set text(size: use-size("五号"))

  heading(level: 1, numbering: none, outlined: false, bookmarked: false, title)

  {
    show table.cell: it => if it.x == 0 or it.y == 0 and calc.even(it.x) { strong(it) } else { it }

    let cell-with-back(body, back) = table.cell(colspan: 5, grid(
      columns: 1fr,
      rows: (1fr, auto),
      body,
      align(right, strong(back))
    ))

    table(
      stroke: .5pt,
      rows: rows,
      columns: columns,
      align: (x, y) => if x == 0 or y <= 1 { center + horizon } else { auto },
      [学生姓名], author, [学号], student-id, [班级], class,
      [论文题目], table.cell(colspan: 5, thesis-title),
      use-stack[主要内容以及进度安排],
      cell-with-back(
        content,
        [
          #set par(spacing: 1.75em)

          指导教师签字：#h(4em)

          考核组组长签字：#h(4em)

          年#h(1em)月#h(1em)日
        ],
      ),
      use-stack[中期考核意见],
      cell-with-back(
        mid-term-comment,
        [
          #set par(spacing: 1.75em)

          考核组组长签字：#h(4em)

          年#h(1em)月#h(1em)日
        ],
      ),
      use-stack[指导教师评语],
      cell-with-back(
        instructor-comment,
        [
          #set par(spacing: 1.75em)

          指导教师签字：#h(4em)

          年#h(1em)月#h(1em)日
        ],
      ),
      use-stack[评阅教师评语],
      cell-with-back(
        reviewer-comment,
        [
          #set par(spacing: 1.75em)

          评阅教师签字：#h(4em)

          年#h(1em)月#h(1em)日
        ],
      ),
      use-stack[答辩小组评语],
      cell-with-back(
        defense-comment,
        [
          #set par(spacing: 1.75em)

          答辩小组组长签字：#h(4em)

          年#h(1em)月#h(1em)日
        ],
      ),
    )
  }

  v(1em)

  align(right, strong[
    #set par(spacing: 1.75em)

    总成绩：#underline(" " * 12) // 3em

    教学负责人签字：#underline(" " * 12)

    #v(1em)

    年#h(1em)月#h(1em)日#h(3em)
  ])
}
