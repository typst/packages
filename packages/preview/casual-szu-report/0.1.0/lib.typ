#let template(
  body,
  course-title: auto,
  experiment-title: auto,
  faculty: auto,
  major: auto,
  instructor: auto,
  reporter: auto,
  student-id: auto,
  class: auto,
  experiment-date: auto,
  submission-date: datetime.today(),
  features: (), // TODO features: "CourseID"
) = {
  let font-family = ("Noto Serif", "Noto Serif CJK SC")
  let bibliography-file = none
  let citation-style = "gb-7714-2015-numeric"

  for (key, value) in features {
    if key == "FontFamily" {
      font-family = value
    } else if key == "Bibliography" {
      bibliography-file = value
    } else if key == "CitationStyle" {
      citation-style = value
    } else if key == "CourseID" {
      // TODO Course ID box on first page
      assert(false, "Not yet implemented")
    } else {
      assert(false, "Unknown Feature")
    }
  }

  set document(
    title: experiment-title,
    author: reporter.text,
  )

  set page(footer: context {
    set align(center)
    set text(8pt)
    counter(page).display(
      "1 / 1",
      both: true,
    )
  })

  set text(
    font: font-family,
    lang: "zh",
    region: "cn",
    size: 10.5pt,
  )

  // Workaround for https://github.com/typst/typst/issues/311
  // By https://github.com/Myriad-Dreamin
  set par(justify: true, first-line-indent: 2em)

  let ss = selector(heading).or(enum).or(figure)
  show ss: it => {
    it
    let b = par[#box()]
    let t = measure(b * 2)
    b
    v(-t.height)
  }

  // Heading
  show heading.where(depth: 1): set text(size: 12pt)
  show heading.where(depth: 2): set text(size: 11.5pt)
  show heading.where(depth: 3): set text(size: 11pt)


  set enum(numbering: "1)a)i)") // TODO taken from ieee, may need further customization

  // TODO figure setup

  /* Header Line */
  line(length: 100%)

  /* Title */
  {
    set align(center)
    set text(
      weight: "semibold",
      size: 20pt,
      tracking: 0.8em,
    )
    pad([深圳大学实验报告], y: 2em)
  }

  /* Info Grid */
  {
    set align(center)
    set text(
      weight: "semibold",
      size: 14pt,
    )

    // Underline Box
    let u(it) = {
      v(-5pt) // TODO use mearure to get precise value
      rect(
        it,
        width: 100%,
        stroke: (bottom: 1pt),
      )
    }

    grid(
      columns: (4em, 1em, 22em),
      row-gutter: 3.5em,
      "课程名称", "：", u(course-title),
      "实验名称", "：", u(experiment-title),
      "学　　院", "：", u(faculty),
      "专　　业", "：", u(major),
      "指导老师", "：", u(instructor),
    )

    pad(
      grid(
        columns: (3em, 1em, 4.5em, 2em, 1em, 7em, 2em, 1em, 5.5em),
        row-gutter: 3.5em,
        "报告人", "：", u(reporter), "学号", "：", u(student-id), "班级", "：", u(class),
      ),
      y: 2em,
    ) // TODO use mearure to get precise value


    let fstr = "[year]年[month]月[day]日"
    grid(
      columns: (4em, 1em, 22em),
      row-gutter: 3.5em,
      "实验日期", "：", u(experiment-date.display(fstr)),
      "提交日期", "：", u(submission-date.display(fstr)),
    )
  }


  /* Footer Line */
  v(3.5em)
  {
    set align(center)
    set text(weight: "semibold", size: 12pt)
    [教育部制]
  }

  pagebreak(weak: true)

  /* Body */
  let cells = ()
  let s = ()

  for it in body.children {
    let is-h1 = it.func() == heading and it.depth == 1
    if s.len() == 0 {
      if is-h1 {
        s = (it,)
      }
    } else {
      if is-h1 {
        cells.push(s.sum())
        s = (it,)
      } else {
        s.push(it)
      }
    }
  }
  cells.push(s.sum())

  table(
    columns: (100%),
    ..cells
  )

  /* Summary */
  pagebreak(weak: true)

  {
    set par(first-line-indent: 0em)
    table(
      columns: (100%),
      [
        指导教师批阅意见：
        #v(10em)
        成绩评定：
        #v(5em)
        #h(24em) 指导教师签字：

        #h(24em) #h(4em)年#h(2em)月#h(2em)日
      ], [
        备注：
        #v(7em)
      ]
    )
    [
      注：
      #pad(left: 2em)[
        + 报告内的项目或内容设置，可根据实际情况加以调整和补充。
        + 教师批改学生实验报告时间应在学生提交实验报告时间后10日内。
      ]
    ]
  }

  /* Bibliography */
  if bibliography-file != none {
    bibliography(bibliography-file, style: citation-style)
  }
}
