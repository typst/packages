#import "numbering-tools.typ": chinese-numbering
#import "packages.typ": show-cn-fakebold
#import "show-heading.typ": show-heading
#import "figure-and-ref.typ": show-figure, show-ref, set-math-numbering, show-math-equation-degree
#import "bilingual-bibliography.typ": show-bibliography
#import "fonts.typ": 字体, 字号

#let set-degree(always-new-page: true, bilingual-bib: true, doc) = {
  set page(paper: "a4", margin: (top: 2cm, bottom: 2cm, left:2cm, right: 2cm))
  set text(font: 字体.宋体, size: 字号.小四, weight: "regular", lang: "zh")
  set par(first-line-indent: 2em, leading: 9.6pt, justify: true)
  show par: set block(spacing: 9.6pt)

  show: show-cn-fakebold

  show: show-bibliography.with(bilingual: bilingual-bib)

  show heading: show-heading.with(
    always-new-page: always-new-page,
    heading-top-margin: (1cm, 0.1cm, 0.05cm),
    heading-bottom-margin: (1cm, 0cm, 0cm),
    heading-text: (
      (font: 字体.黑体, size: 字号.三号, weight: "regular"),
      (font: 字体.宋体, size: 字号.四号, weight: "bold"),
      (font: 字体.黑体, size: 字号.小四, weight: "regular"),
    ),
  )

  show figure: show-figure.with(
    main-body-table-numbering: "1.1",
    main-body-image-numbering: "1-1", // 其他也会视为 image
    appendix-table-numbering: "A-1",
    appendix-image-numbering: "A-1", // 其他也会视为 image
  )
  show ref: show-ref.with(
    main-body-table-numbering: "1.1",
    main-body-image-numbering: "1-1", // 其他也会视为 image
    appendix-table-numbering: "A-1",
    appendix-image-numbering: "A-1", // 其他也会视为 image
  )
  set math.equation(numbering: set-math-numbering.with(
    main-body-numbering: "(1.1)",
    appendix-numbering: "(A-1)",
  ))
  show math.equation: show-math-equation-degree

  set heading(numbering: chinese-numbering)

  doc
}