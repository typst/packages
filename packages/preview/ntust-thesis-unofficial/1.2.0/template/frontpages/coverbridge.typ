// frontpages/coverbridge.typ
// ============================================================================
// 書背 / Spine page for thesis binding
// ============================================================================
// This is a standalone document. Compile separately:
//   typst compile frontpages/coverbridge.typ
// ============================================================================

#import "names.typ": thesis-info

// Helper: vertical CJK text (stack characters top-to-bottom)
#let vertical-cjk(s, size: 18pt, weight: "regular", spacing: 2pt) = {
  set text(size: size, weight: weight)
  let chars = s.clusters()
  stack(
    dir: ttb,
    spacing: spacing,
    ..chars.map(c => align(center, c)),
  )
}

// Page setup: landscape A4
#set page(
  width: 297mm,
  height: 210mm,
  margin: (top: 2.5cm, bottom: 3cm, left: 2.5cm, right: 3cm),
  numbering: none,
)

#set text(
  font: ("Times New Roman", "DFKai-SB"),
  size: 12pt,
  lang: "zh",
  region: "TW",
)

#set par(first-line-indent: 0pt)

// Layout
// The spine is laid out horizontally on a landscape page.
// From left to right: Graduation Class | Degree | Title | University+Dept | Author
#align(
  horizon,
  grid(
    columns: (1cm, 2.5cm, 1fr, auto, 2cm),
    align: (center + horizon, center + horizon, center + horizon, center + horizon, center + horizon),
    column-gutter: 1cm,

    // (1) Graduation class — rotated number
    rotate(-90deg, text(size: 14pt)[#thesis-info.graduation-class]),

    // (2) Degree type — vertical CJK
    vertical-cjk(thesis-info.degree.zh + "論文", size: 18pt),

    // (3) Thesis title — vertical CJK
    vertical-cjk(thesis-info.title.zh, size: 18pt, spacing: 0.5pt),

    // (4) University + Department — stacked vertically
    {
      vertical-cjk(thesis-info.university.zh, size: 11pt, spacing: 0pt)
      v(4pt)
      vertical-cjk(thesis-info.department.zh.replace(" ", ""), size: 9pt, spacing: 0pt)
    },

    // (5) Author name — vertical CJK
    vertical-cjk(thesis-info.author.zh, size: 18pt),
  ),
)
