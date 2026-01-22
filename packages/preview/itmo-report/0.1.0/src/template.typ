#import "config.typ": config
#import "components.typ": title-page, table-of-contents

#let report(
  title: "Untitled Report",
  student: "Student Name",
  faculty: none,
  program: none,
  field-of-study: none,
  show-toc: true,
  supervisor: none,
  responsible: none,
  bib-file: none,
  body,
) = {
    set page(
    paper: config.page.paper,
    margin: (
      left: config.page.margin-left,
      right: config.page.margin-right,
      top: config.page.margin-top,
      bottom: config.page.margin-bottom,
    ),
  )

    set text(
    font: config.font.main,
    size: config.font.size,
  )

    title-page(
    title: title,
    student: student,
    faculty: faculty,
    program: program,
    field-of-study: field-of-study,
    supervisor: supervisor,
    responsible: responsible,
  )

  pagebreak()

  counter(page).update(1)

    show: doc => {
        set par(first-line-indent: (amount: config.indent.paragraph, all: true))

        show heading.where(level: 1): it => {
      pagebreak(weak:true)
      align(center)[
        #upper(it)
        #v(1.5em)
      ]
    }

        set heading(numbering: (..nums) => {
      let n = nums.pos()
      if n.len() == 1 { none }
      else { numbering("1.1", ..n) }
    })

    doc
  }

    set page(numbering: "1")

  if show-toc {
    table-of-contents()
    pagebreak()
  }

  set par(justify: true)
  set text(hyphenate: false)
  show figure.caption: set text(size: config.font.caption-size)

    body

  set par(justify: false)

  if bib-file != none {
    pagebreak(weak: true)
    bibliography(bib-file, full:true,  style: "vancouver-superscript", title: "  References")
  }
}
