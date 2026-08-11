// pages/appendix.typ
// Anhang-Rendering: user-defined entries (1, 2, 3...) + KI-Verzeichnis automatisch als letztes
// STR-09: Anhang optional, arabische Seitennummerierung (fortlaufend)
// STR-12: KI-Verzeichnis als letztes Anhang-Item (wenn ai-tools nicht leer)
// api-design §4: KI-Verzeichnis Tabellen-Format; §7: Anhang-Array
//
// TOC structure (HWR §3.10 — Anhangsverzeichnis optional):
//   Anhang                    ← H1, no number, in TOC
//     Anhang 1: Title         ← H2, no number, in TOC
//     Anhang 2: Title         ← H2, no number, in TOC
//   Ehrenwörtliche Erklärung
//
// Anhangsverzeichnis (optional, show-toc: true): separate page with clickable links + page numbers.
// Numbering: 1, 2, 3... (Arabic, unlimited — letters A-Z limited to 26 entries)

#import "@preview/linguify:0.5.0": linguify

/// Render a single appendix entry as H2 under the "Anhang" H1.
/// num: string "1", "2", ...
#let _render-entry(num, title, content) = {
  // Label for TOC links and Anhangsverzeichnis links
  [#metadata(num) #label("anhang-" + num)]

  // H2: appears in TOC as sub-entry under "Anhang"
  heading(level: 2, numbering: none, outlined: true)[
    #linguify("appendix-label") #num: #title
  ]

  content
  pagebreak()
}

/// Render the KI-Verzeichnis (AI Tools Register) table.
/// CNT-10–13: mandatory when AI tools were used
/// Columns: KI-Tool | Einsatzform | Betroffene Teile | Bemerkungen
#let _render-ai-tools(ai-tools, num) = {
  [#metadata(num) #label("anhang-" + num)]

  heading(level: 2, numbering: none, outlined: true)[
    #linguify("appendix-label") #num: #linguify("ai-tools-title")
  ]

  v(0.5em)

  table(
    columns: (1fr, 2fr, 1fr, 1fr),
    align: left,
    stroke: 0.5pt,
    table.header(
      strong(linguify("ai-col-tool")),
      strong(linguify("ai-col-usage")),
      strong(linguify("ai-col-chapters")),
      strong(linguify("ai-col-remarks")),
    ),
    ..ai-tools.map(entry => (
      entry.at("tool",        default: ""),
      entry.at("usage",       default: ""),
      entry.at("chapters",    default: ""),
      entry.at("bemerkungen", default: "—"),
    )).flatten()
  )

  pagebreak()
}

/// Render the optional Anhangsverzeichnis (separate page, before entries).
/// entries: array of (num-string, title-string)
#let _render-appendix-toc(entries) = {
  // H2 under "Anhang" — but not in TOC (it's a helper page, not a content section)
  heading(level: 2, numbering: none, outlined: false)[#linguify("appendix-toc-title")]
  v(1em)

  for entry in entries {
    let num   = entry.at(0)
    let title = entry.at(1)
    context {
      let pg = query(label("anhang-" + num)).first().location().page()
      grid(
        columns: (auto, 1fr, auto),
        align: (left, left, right),
        column-gutter: 0.5em,
        [#linguify("appendix-label") #num:],
        link(label("anhang-" + num))[#title #box(width: 1fr, repeat[.])],
        [#pg],
      )
    }
    v(0.3em)
  }

  pagebreak()
}

/// Render the full appendix section.
///
/// - appendix: array of (title, content) — user-defined entries
/// - ai-tools: array of (tool, usage, chapters, bemerkungen?) — AI tools register
/// - lang: "de" | "en"
/// - show-toc: bool — render optional Anhangsverzeichnis page (default: false)
#let render-appendix(appendix, ai-tools, lang, show-toc: false) = {
  // Numbers as strings: "1", "2", ... — unlimited, no 26-entry cap
  let ai-num = if ai-tools.len() > 0 {
    str(appendix.len() + 1)
  } else {
    none
  }

  // H1 "Anhang" container heading — appears in TOC as top-level, no number
  heading(level: 1, numbering: none, outlined: true)[#linguify("appendix-section-title")]

  // Optional Anhangsverzeichnis page (HWR §3.10: "ist es möglich")
  if show-toc {
    context {
      let ai-title = if ai-num != none { linguify("ai-tools-title") } else { "" }
      let entries = ()
      for (i, entry) in appendix.enumerate() {
        entries.push((str(i + 1), entry.at("title", default: "")))
      }
      if ai-num != none {
        entries.push((ai-num, ai-title))
      }
      _render-appendix-toc(entries)
    }
  }

  // User-defined appendix entries
  for (i, entry) in appendix.enumerate() {
    _render-entry(
      str(i + 1),
      entry.at("title",   default: ""),
      entry.at("content", default: []),
    )
  }

  // KI-Verzeichnis as last item
  if ai-num != none {
    _render-ai-tools(ai-tools, ai-num)
  }
}
