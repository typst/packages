#import "numbering-tools.typ": number-with-circle, chinese-numbering
#import "packages.typ": show-cn-fakebold
#import "bachelor-footnote.typ": bachelor-footnote
#import "show-heading.typ": show-heading
#import "figure-and-ref.typ": show-figure, show-ref, set-math-numbering
#import "bilingual-bibliography.typ": show-bibliography
#import "fonts.typ": 字体, 字号

#let set-bachelor(bilingual-bib: true, doc) = {
  set page(paper: "a4", margin: (top: 2cm+0.5cm, bottom: 2cm+0.5cm, left: 2cm + 0.5cm, right: 2cm))
  set text(font: 字体.宋体, size: 字号.小四, weight: "regular", lang: "zh")
  set par(first-line-indent: 2em, leading: 15pt, justify: true)
  show par: set block(spacing: 15pt)

  show: show-cn-fakebold

  show: show-bibliography.with(bilingual: bilingual-bib)

  show heading: show-heading.with(always-new-page: true)

  show figure: show-figure.with(
    main-body-table-numbering: "1.1",
    main-body-image-numbering: "1-1", // 其他也会视为 image
    appendix-table-numbering: "A.1",
    appendix-image-numbering: "A-1", // 其他也会视为 image
  )
  show ref: show-ref.with(
    main-body-table-numbering: "1.1",
    main-body-image-numbering: "1-1", // 其他也会视为 image
    appendix-table-numbering: "A.1",
    appendix-image-numbering: "A-1", // 其他也会视为 image
  )
  set math.equation(numbering: set-math-numbering.with(
    main-body-numbering: "(1.1)",
    appendix-numbering: "(A.1)",
  ))

  set footnote(numbering: num => number-with-circle(num))
  set footnote.entry(
    separator: line(start: (2.5em, 0pt),length: 30%, stroke: 0.5pt)+v(0.5em),
    gap: 1em
  )
  show footnote.entry: bachelor-footnote

  set heading(numbering: chinese-numbering)

  doc
}