#import "theme.typ": active-theme, active-theme-name, resolve-theme
#import "helpers.typ": format-date
#import "components.typ": question-counter
#import "cover.typ": assignment-cover

#let assignment(
  title: none,
  subtitle: none,
  course: none,
  assignment: none,
  student: none,
  author: none,
  student-id: none,
  id: none,
  instructor: none,
  department: none,
  university: none,
  semester: none,
  section: none,
  date: none,
  logo: none,
  cover-page: false,
  cover-style: "modern",
  scale: none,
  doc-ref: none,
  rev: none,
  revision: none,
  theme: "nord-light",
  primary: none,
  accent: none,
  font: ("Liberation Sans", "DejaVu Sans", "Noto Sans"),
  code-font: ("JetBrains Mono", "DejaVu Sans Mono", "Liberation Mono"),
  radius: 6pt,
  paper: "a4",
  height: none,
  height-auto: false,
  margin: (x: 2.2cm, top: 2.6cm, bottom: 2.4cm),
  header-show: true,
  footer-show: true,
  question-numbering: "1",
  toc: false,
  watermark: none,
  body,
) = {
  let th = resolve-theme(theme, primary: primary, accent: accent)
  active-theme.update(th)
  active-theme-name.update(if type(theme) == str { theme } else { "custom" })
  question-counter.update(0)

  let stu-name = if student != none { student } else { author }
  let stu-id = if student-id != none { student-id } else { id }
  let active-rev = if revision != none { revision } else { rev }
  let date-str = format-date(date)

  let effective-height = if height-auto { auto } else { height }
  let is-cover = cover-page != false and (title != none or course != none or assignment != none or stu-name != none)

  set page(
    paper: paper,
    margin: margin,
    fill: th.background,
    ..if effective-height != none and (not is-cover or effective-height != auto) { (height: effective-height,) } else { (:) },
    header: context {
      let page-num = counter(page).get().first()
      if header-show and (not cover-page or page-num > 1) [
        #let left-title = if course != none { course } else if title != none { title } else { "" }
        #let right-info = if assignment != none { assignment } else if date-str != none { date-str } else { "" }
        #grid(
          columns: (1fr, auto),
          align: horizon,
          [
            #set text(size: 8.5pt, fill: th.text-muted)
            #left-title
          ],
          [
            #set text(size: 8.5pt, fill: th.text-muted, weight: "bold")
            #right-info
          ],
        )
        #v(0.3em)
        #line(length: 100%, stroke: 0.5pt + th.border)
      ]
    },
    footer: context {
      let page-num = counter(page).get().first()
      if footer-show and (not cover-page or page-num > 1) [
        #line(length: 100%, stroke: 0.5pt + th.border)
        #v(0.3em)
        #grid(
          columns: (1fr, auto),
          align: horizon,
          [
            #set text(size: 8.5pt, fill: th.text-muted)
            #if stu-name != none [ #stu-name ]
          ],
          [
            #set text(size: 8.5pt, fill: th.text-muted, weight: "semibold")
            #counter(page).display("1 / 1", both: true)
          ],
        )
      ]
    },
  )

  set text(
    font: font,
    size: 10.5pt,
    fill: th.text,
    spacing: 120%,
  )
  set par(justify: true, leading: 0.7em)

  show heading.where(level: 1): it => block(
    width: 100%,
    below: 1em,
    above: 1.8em,
  )[
    #set text(fill: th.primary, size: 13.5pt, weight: "bold")
    #it.body
    #v(0.35em)
    #line(length: 100%, stroke: 0.6pt + th.border)
  ]

  show heading.where(level: 2): it => block(
    below: 0.8em,
    above: 1.4em,
  )[
    #set text(fill: th.primary.darken(10%), size: 11.5pt, weight: "bold")
    #it.body
  ]

  show heading.where(level: 3): it => block(
    below: 0.6em,
    above: 1.1em,
  )[
    #set text(fill: th.text, size: 10.5pt, weight: "bold")
    #it.body
  ]

  show raw.where(block: true): it => block(
    width: 100%,
    fill: th.code-bg,
    inset: 9pt,
    radius: 4pt,
    stroke: (paint: th.border, thickness: 0.5pt),
    below: 1.2em,
  )[
    #set text(font: code-font, size: 8.8pt)
    #it
  ]

  show raw.where(block: false): it => box(
    fill: th.code-bg,
    inset: (x: 4pt, y: 1.5pt),
    radius: 3pt,
    stroke: (paint: th.border, thickness: 0.4pt),
  )[
    #set text(font: code-font, size: 8.8pt)
    #it
  ]

  show figure: it => align(center)[
    #block(below: 1.2em)[
      #it.body
      #if it.has("caption") and it.caption != none [
        #v(0.5em)
        #text(size: 9pt, fill: th.text-muted)[#it.caption]
      ]
    ]
  ]

  show image: it => box(
    radius: 4pt,
    clip: true,
    stroke: (paint: th.border, thickness: 0.5pt),
    it,
  )

  show table: set table(
    inset: (x: 12pt, y: 8pt),
    stroke: (x, y) => if y == 0 {
      (bottom: 1.5pt + th.primary, top: 0.8pt + th.border, left: none, right: none)
    } else {
      (bottom: 0.4pt + th.border, top: none, left: none, right: none)
    },
    fill: (x, y) => if y == 0 { th.primary.lighten(93%) } else if calc.even(y) { th.surface.lighten(60%) } else { none },
  )

  show table: it => block(
    width: 100%,
    below: 1.4em,
    align(center, it)
  )

  if title != none or course != none or assignment != none or stu-name != none {
    assignment-cover(
      title: title,
      subtitle: subtitle,
      course: course,
      assignment: assignment,
      student: stu-name,
      student-id: stu-id,
      instructor: instructor,
      department: department,
      university: university,
      semester: semester,
      section: section,
      date: date,
      logo: logo,
      cover-page: cover-page,
      cover-style: cover-style,
      scale: scale,
      doc-ref: doc-ref,
      rev: active-rev,
    )
  }

  let main-body = [
    #if is-cover and effective-height != none [
      #set page(height: effective-height)
    ]
    #if watermark != none [
      #place(
        center + horizon,
        dx: 0pt,
        dy: 0pt,
        text(size: 48pt, weight: "bold", fill: th.border.darken(5%).transparentize(60%))[
          #rotate(-30deg)[#watermark]
        ],
      )
    ]
    #if toc [
      #block(width: 100%, below: 1.8em)[
        #text(weight: "bold", fill: th.primary, size: 12pt)[Table of Contents]
        #v(0.6em)
        #outline(indent: 1.5em)
      ]
    ]
    #body
  ]

  main-body
}

#let template = assignment
