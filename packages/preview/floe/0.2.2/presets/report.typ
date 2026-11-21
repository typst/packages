// ============================================================================
// FLOE DESIGN SYSTEM — REPORT PRESET (presets/report.typ)
// Clean Sans-Serif Engineering Report & Decision Memo
// ============================================================================
#import "../core/lib.typ": *
#import "../mixins/lib.typ": *

/// Clean sans-serif engineering report
#let report(
  title: "Engineering Report",
  subtitle: "",
  author: "Author",
  date: none,
  ..sink,
  body,
) = {
  set document(title: title, author: author)

  set page(
    paper: "a4",
    margin: (x: 2.5cm, top: 2.5cm, bottom: 2.5cm),
  )

  set text(font: fonts.sans, size: 10pt, fill: slate-900, lang: "en")
  set par(justify: true, leading: 0.65em, spacing: 1em)

  show: with-code-theme
  show: with-heading-theme.with(numbering: "1.1", section-symbol: false)
  show: with-math-theme
  show: with-running-chrome.with(
    header-left: title,
    header-right: author,
    footer-note: if date != none { date } else { "Technical Report" },
    suppress-pages: 1,
  )

  body
}
