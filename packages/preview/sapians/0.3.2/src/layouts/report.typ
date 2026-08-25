#import "../tokens.typ": *
#import "../components/index.typ": *

// SAPIANS Technical Report & Memo Layout (Crisp White Edition)
// Branding defaults carry the SAPIANS identity; every one of them is a
// parameter so the layout works for any organization or language.
/// The single-column technical-report page layout: sets the A4 page (with
/// a running header from the second page on), base typography, and a
/// title block (kicker, title, subtitle, author/date/version line). Apply
/// it once per document with a show rule — it sets page-level rules, so
/// it cannot be called from inside another container (a card, a box, ...)
/// or from a live doc example; see the usage snippet below.
///
/// ```typ
/// #import "@local/sapians:0.3.2": * // x-release-please-version
///
/// #show: sapians-report.with(
///   title: "Fixed Report Title",
///   subtitle: "A fixed subtitle for the reference render",
///   author: "Test Author",
///   date: "01/01/2026",
///   version: "1.0",
/// )
///
/// = Executive Summary
/// Body text flows in a single column from here on.
/// ```
/// -> content
#let sapians-report(
  /// Document and title-block title. Also shown in the running header
  /// from the second page on. -> str
  title: "SAPIANS Technical Report",

  /// Subtitle shown under the title. Omitted entirely when `none`.
  /// -> none | str
  subtitle: none,

  /// Author name shown in the byline row. -> str
  author: "SAPIANS Team",

  /// Date shown in the byline row and the running header, already
  /// formatted (e.g. `"01/01/2026"`). Defaults to today's date as
  /// `"[day]/[month]/[year]"` when `none`. -> none | str
  date: none,

  /// Version string shown in the byline row. -> str
  version: "1.0",

  /// Document language, forwarded to `set text(lang: ...)`. -> str
  lang: "en",

  /// Uppercase kicker shown above the title, e.g. `"SAPIANS TECHNICAL
  /// REPORT"`. -> str
  kicker: "SAPIANS TECHNICAL REPORT",

  /// Organization name shown in the page footer. -> str
  org: "SAPIANS Research & Development",

  /// Label shown before the author name in the byline row. -> str
  author-title: "Author",

  /// Label shown before the date in the byline row. -> str
  date-title: "Date",

  /// Label shown before the version string in the byline row. -> str
  version-title: "Version",

  /// Report body, laid out in a single column. Supplied automatically by
  /// `#show: sapians-report.with(...)`. -> content
  body,
) = {
  set document(title: title, author: author)

  let formatted-date = if date != none { date } else {
    datetime.today().display("[day]/[month]/[year]")
  }

  set page(
    paper: "a4",
    margin: (x: 25mm, top: 25mm, bottom: 25mm),
    fill: sapians-paper,
    header: context [
      #if counter(page).get().first() > 1 [
        #grid(
          columns: (1fr, auto),
          text(size: 7.5pt, fill: sapians-muted-dark, weight: "medium")[#title],
          text(size: 7.5pt, fill: sapians-muted-dark)[#formatted-date],
        )
        #v(1.0mm)
        #line(length: 100%, stroke: stroke-light)
      ]
    ],
    footer: context [
      #grid(
        columns: (1fr, auto),
        text(size: 7.5pt, fill: sapians-muted-dark)[#org],
        text(size: 7.5pt, fill: sapians-muted-dark, weight: "bold")[#counter(
          page,
        ).display()],
      )
    ],
  )

  set text(
    font: font-sans,
    fill: sapians-text-dark,
    size: 9.0pt,
    lang: lang,
  )

  set par(justify: true, leading: 0.60em)

  // Document Title Header
  block(width: 100%, inset: (bottom: 5mm))[
    #text(
      fill: sapians-terracotta,
      size: 7.5pt,
      weight: "bold",
      tracking: 0.15em,
    )[#upper(kicker)]
    #v(1.5mm)
    #text(fill: sapians-text-dark, size: 20pt, weight: "bold")[#title]
    #if subtitle != none [
      #v(1.0mm)
      #text(fill: sapians-muted-dark, size: 11pt)[#subtitle]
    ]
    #v(2.5mm)
    #line(length: 100%, stroke: 0.5pt + sapians-line)
    #v(2.0mm)
    #grid(
      columns: (1fr, 1fr, 1fr),
      text(size: 8.0pt)[*#author-title:* #author],
      text(size: 8.0pt)[*#date-title:* #formatted-date],
      align(right)[#text(size: 8.0pt)[*#version-title:* #version]],
    )
    #v(4.0mm)
  ]

  body
}
