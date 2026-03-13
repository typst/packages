/// Record Sheet Page
///
/// - anonymous (bool): Whether to use anonymous mode.
/// - twoside (bool, str): Whether to use two-sided layout.
/// - info (dictonary): Information about the student and thesis.
/// - degree (str): The degree, this page is only for bachelor's thesis.
/// - doc-info (dictionary): The document information to extend the info with.
/// - title (content): The title of the record sheet page.
/// - outlined (bool): Whether to outline the page.
/// - bookmarked (bool): Whether to add a bookmark for the page.
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
  degree: "bachelor",
  // options
  doc-info: (:),
  title: [综合论文训练记录表],
  outlined: false,
  bookmarked: false,
  prefill: true,
  rows: (1cm, 1cm, 12cm, 6.5cm),
  columns: (2cm, 1fr, 1.5cm, 1fr, 1.5cm, 1fr),
  content: [],
  mid-term-comment: [],
  instructor-comment: [],
  reviewer-comment: [],
  defense-comment: [],
) = {
  /// Precheck
  if anonymous or degree != "bachelor" { return }

  import "../utils/font.typ": use-size
  import "../utils/text.typ": v-text
  import "../utils/util.typ": twoside-pagebreak

  info = info + doc-info

  twoside-pagebreak(twoside)

  set page(numbering: none)
  set par(first-line-indent: 0em, spacing: 1.75em)
  set text(size: use-size("五号"))

  heading(level: 1, numbering: none, outlined: outlined, bookmarked: bookmarked, title)

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
    [学生姓名], info.author, [学号], info.student-id, [班级], info.class,
    [论文题目], table.cell(colspan: 5, info.title.sum()),
    v-text[主要内容以及进度安排],
    cell-with-back(content, [
      指导教师签字：#h(4em)

      考核组组长签字：#h(4em)

      年#h(1em)月#h(1em)日
    ]),
    v-text[中期考核意见],
    cell-with-back(mid-term-comment, [
      考核组组长签字：#h(4em)

      年#h(1em)月#h(1em)日
    ]),
    v-text[指导教师评语],
    cell-with-back(instructor-comment, [
      指导教师签字：#h(4em)

      年#h(1em)月#h(1em)日
    ]),
    v-text[评阅教师评语],
    cell-with-back(reviewer-comment, [
      评阅教师签字：#h(4em)

      年#h(1em)月#h(1em)日
    ]),
    v-text[答辩小组评语],
    cell-with-back(defense-comment, [
      答辩小组组长签字：#h(4em)

      年#h(1em)月#h(1em)日
    ]),
  )

  v(1em)

  align(right, strong[
    总成绩：#underline(" " * 12) // 3em

    教学负责人签字：#underline(" " * 12)

    #v(1em)

    年#h(1em)月#h(1em)日#h(3em)
  ])
}

/// Common review page for anything
///
/// - anonymous (bool): Whether to use anonymous mode.
/// - twoside (bool, str): Whether to use two-sided layout.
/// - degree (str): The degree.
/// - title (content): The title of the acknowledgement page.
/// - outlined (bool): Whether to outline the page.
/// - bookmarked (bool): Whether to add a bookmark for the page.
/// - it (content): The content of the acknowledgement page.
/// -> content
#let _review-of(
  // from entry
  anonymous: false,
  twoside: false,
  degree: "master",
  // options
  title: [评审材料],
  outlined: true,
  bookmarked: true,
  // self
  it,
) = {
  if anonymous or degree == "bachelor" { return }

  import "../utils/util.typ": twoside-pagebreak

  twoside-pagebreak(twoside)

  heading(level: 1, numbering: none, outlined: outlined, bookmarked: bookmarked, title)

  it
}

/// Advisor Comment Page
#let comments = _review-of.with(title: [指导教师学术评语])

/// Committee Resolution Page
#let resolution = _review-of.with(title: [答辩委员会决议书])
