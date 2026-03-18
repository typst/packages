#import "../pages/graduate-cover.typ": graduate-cover
#import "../pages/template-individual.typ": template-individual
#import "../pages/panel-exam-page.typ": panel-exam-page
#import "../pages/outline.typ": main-outline, figure-outline, table-outline

#import "../utils/fonts.typ": thesis_font_size, thesis_font
#import "../utils/header.typ": header, footer
#import "../utils/fakebold.typ": show-cn-fakebold
#import "../utils/indent-first-par.typ": indent-first-par
#import "../utils/supplement.typ": show-set-supplement
#import "../utils/twoside.typ": show-twoside-pagebreak, twoside-numbering-footer, twoside-pagebreak
#import "../utils/near-chapter.typ": near-chapter
#import "../utils/near-section.typ": near-section
#import "../utils/bilingual-bibliography.typ": show-bilingual-bibliography
#import "../utils/structure.typ": frontmatter, mainmatter
#import "../utils/appendix.typ": appendix


#import "../dependency/i-figured.typ"
#import "../dependency/lovelace.typ"

#let show-outline-indent(s) = {

  show outline.entry: it => {
    if it.level == 1 {
      show repeat: none // different fill for level 1 and level 2
      text(weight: "bold", it)
    } else {
      h(2em * (it.level - 1)) + it
    }
  }
  s
}

#let graduate-general-default-info = (
  univ-en: "CITY UNIVERSITY OF HONG KONG",
  univ-zh: "香港城市大学",
  title: ("毕业论文/设计题目", ""),
  title-en: ("Graduation Project/Design Title", ""),
  grade: "20XX",
  student-id: "1234567890",
  clc: "O643.12",
  unitcode: "10335",
  reviewer: ("隐名", "隐名", "隐名", "隐名", "隐名"),
  committe: ("主席", "委员", "委员", "委员", "委员", "委员"),
  reviewer-en: ("Anonymous", "Anonymous", "Anonymous", "Anonymous", "Anonymous"),
  committe-en: ("Chair", "Committeeman", "Committeeman", "Committeeman", "Committeeman", "Committeeman"),
  secret-level: "无",
  author: "张三",
  department: "某学院",
  major: "某专业",
  degree: "硕士",
  field: "某方向",
  supervisor: "李四",
  submit-date: datetime.today(),
  defense-date: ("二一九三年六月", "September 2193"),
)

#let graduate-general-set-style(
  doc,
  twoside: false,
) = {
  // Page geometry
  set page(
    paper: "a4",

    margin: (
      x: 3.27cm,
      bottom: 3.8cm,
      top: 3.8cm,
    ),
  )
  show: show-twoside-pagebreak.with(twoside: twoside)


  // Header and footer
  set page(
    header-ascent: 24pt,
    footer-descent: 35pt,
    header:  header(
      left: near-chapter,
      right: near-section
    ),
    footer: twoside-numbering-footer,
  )

  // Paragraph and text
  set par(leading: 1em, first-line-indent: 2em, justify: true)
  show: indent-first-par
  set text(font: thesis_font.times, size: thesis_font_size.small)
  show: show-cn-fakebold
  set underline(offset: 0.2em)


  // Headings
  show heading: i-figured.reset-counters.with(extra-kinds: ("algorithm", "listing"))

  show heading.where(level: 1): set text(size: thesis_font_size.lllarge)
  set heading(numbering: (..nums) => {
    nums = nums.pos()
    if nums.len() == 1 {
      // "Chapter " + numbering("1.", ..nums)
      numbering("1.", ..nums)
    } else {
      numbering("1.", ..nums)
      // numbering((..nums) => nums.map(str).join("."), ..nums)
    }
  })

  show heading.where(level: 1): x => {
    twoside-pagebreak
    v(12pt)
    x
    v(6pt)
  }

  show heading.where(level: 2): set text(size: thesis_font_size.large)
  show heading.where(level: 3): set text(size: thesis_font_size.normal)
  show heading.where(level: 4): set text(size: thesis_font_size.normal)
  show heading: set block(above: 1.5em, below: 1.5em)


  // Reference
  show: show-set-supplement
  show figure: i-figured.show-figure.with(extra-prefixes: (algorithm: "alg:", listing: "lst:"))
  show math.equation.where(block: true): i-figured.show-equation
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: "algorithm"): set figure(supplement: [Algorithm])
  show figure.where(kind: "algorithm"): set figure.caption(position: top)
  show figure.where(kind: "listing"): set figure(supplement: [Listing])

  show: show-bilingual-bibliography
  doc
}


#let graduate-general(info: (:), twoside: false) = {
  let info = graduate-general-default-info + info
  (
    pages: (
      cover: graduate-cover(info: info),
      outline: show-outline-indent(main-outline(outlined: true, titlelevel: 1)),
      figure-outline: figure-outline(outlined: true, titlelevel: 1),
      table-outline: table-outline(outlined: true, titlelevel: 1),
      individual: template-individual.with(outlined: true, titlelevel: 1),
      panel-exam: panel-exam-page(info: info, "Qualifying Panel and Examination Panel"),
    ),
    style: doc => {
      set document(title: info.title.join())
      graduate-general-set-style(doc, twoside: twoside)
    },
  )
}
