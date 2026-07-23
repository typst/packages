// 社会实践登记表模板
//
// 使用方法：在自己的 Typst 文件中导入并调用本模板。
//
//   #import "@preview/scut-social-practice-form:0.1.0": social-practice-form
//   #social-practice-form(
//     name: [张三],
//     political-status: [共青团员],
//     hometown: [广东省广州市],
//     college: [软件学院],
//     major: [软件工程],
//     grade: [2024 级],
//     practice-unit: [华南理工大学],
//     practice-summary: [在此输入个人实践小结，可分段撰写。],
//     practice-unit-assessment: [在此输入实践单位评议。],
//     college-opinion: [在此输入学院意见。],
//     school-opinion: [在此输入学校意见。],
//     show-original-page-numbers: false,
//   )
//
// 未传入的字段保持为空。长文本可直接使用 Typst 内容块编写多段文字。

// Public template function. Each parameter accepts Typst content, e.g. [张三].
#let social-practice-form(
  name: none,
  political-status: none,
  hometown: none,
  college: none,
  major: none,
  grade: none,
  practice-unit: none,
  practice-summary: none,
  practice-unit-assessment: none,
  college-opinion: none,
  school-opinion: none,
  show-original-page-numbers: true,
  title: "学生社会实践登记表",
) = {
  // Keep the original form's A4 geometry and typography.
  set page(width: 210mm, height: 297mm, margin: 0mm)
  set text(font: "SimSun", size: 12pt)
  set par(leading: 0pt)

  // Shared drawing helpers for the form's borders, fields, and vertical labels.
  let border = 0.48pt
  let field(value) = if value == none {
    []
  } else {
    // Leave a small inset so entered text does not touch the cell border.
    align(left + horizon)[#h(2mm)#value]
  }
  let vertical-label(..items) = align(center + horizon)[
    #stack(dir: ttb, spacing: 4mm, ..items)
  ]
  let area(value) = if value == none {
    []
  } else {
    align(left + top)[#value]
  }
  let signature() = align(left + bottom)[
    // Fixed positions match the original signature and seal fields.
    #grid(
      columns: (63.5mm, 16.9mm, 31.3mm, 1fr),
      inset: 0pt,
      align: left,
      [ ], [负责人：], [ ], [单位盖章],
    )
    #v(2.5mm)
    #h(97mm)年 #h(12mm)月 #h(12mm)日
  ]
  let assessment(value) = block(width: 100%, height: 100%)[
    #align(left + top)[#area(value)]
    #place(bottom + left)[#signature()]
  ]

  // First page header and basic-information table.
  place(top + center, dx: 0mm, dy: 54.6mm)[
    #text(size: 16pt)[#title]
  ]

  place(top + left, dx: 18.47mm, dy: 62.6mm)[
    // Column and row sizes reproduce the original merged-cell layout.
    #grid(
      columns: (23.9mm, 20.8mm, 22.1mm, 21.8mm, 25.7mm, 15.9mm, 37.8mm),
      rows: (10.18mm, 10.18mm, 10.18mm, 162.1mm),
      stroke: border,
      inset: 0pt,
      align: center + horizon,
      [姓名], field(name), [政治面貌], field(political-status), [生源地], grid.cell(colspan: 2)[#field(hometown)],
      [学院], grid.cell(colspan: 2)[#field(college)], [专业], field(major), [年级], field(grade),
      [实践单位], grid.cell(colspan: 6)[#field(practice-unit)],
      grid.cell(rowspan: 1)[#vertical-label[个][人][实][践][小][结]],
      grid.cell(colspan: 6, inset: (left: 3.6mm, top: 3mm, right: 3.6mm, bottom: 2.6mm))[
        #area(practice-summary)
      ],
    )
  ]

  // The source form continues the assessment sections on a second page.
  pagebreak()

  place(top + left, dx: 18.47mm, dy: 35.0mm)[
    // Assessment text is typeset at the top; the signature block stays at the bottom.
    #grid(
      columns: (9.54mm, 158.4mm),
      rows: (98.9mm, 55.03mm, 59.23mm),
      stroke: border,
      inset: 0pt,
      align: center + horizon,
      [#vertical-label[实][践][单][位][评][议]],
      grid.cell(inset: (left: 4mm, top: 4mm, right: 8.1mm, bottom: 3mm))[#assessment(practice-unit-assessment)],
      [#vertical-label[学][院][意][见]],
      grid.cell(inset: (left: 4mm, top: 4mm, right: 8.1mm, bottom: 3mm))[#assessment(college-opinion)],
      [#vertical-label[学][校][意][见]],
      grid.cell(inset: (left: 4mm, top: 4mm, right: 8.1mm, bottom: 3mm))[#assessment(school-opinion)],
    )
  ]
}
