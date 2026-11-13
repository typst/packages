// Design tokens for shiyin-reader.
//
// A theme has two layers:
//
//   structure  school | kindle  — page geometry, heading behaviour, sizes
//   palette    school | kami    — colours only
//
// `school` is the original branded reading layer. `kindle` is the e-ink
// structure. The Kami look survives as a palette over the school structure,
// so it no longer needs its own layout, margin, note or heading rules.

#let school = (
  name: "school",
  palette: "school",
  page-fill: white,
  text-fill: black,
  title-fill: rgb("#B33A20"),
  author-fill: luma(92),
  note-fill: luma(78),
  rule-fill: luma(205),
  toc-level-1: rgb("#D5672D"),
  toc-level-2: rgb(111, 150, 55),
  toc-level-3: luma(45),
  toc-level-4: luma(38),
  toc-chapter-1-fill: rgb("#D5672D"),
  toc-chapter-2-fill: rgb(111, 150, 55),
  toc-title: rgb("#A7351D"),
  toc-title-size: 30pt,
  chapter-title: white,
  chapter-cover-fill: none,
  chapter-sub: white.transparentize(12%),
  preface-title: rgb("#D5672D"),
  preface-text-fill: luma(35),
  appendix-title: rgb("#D5672D"),
  appendix-accent: rgb("#DBA17C"),
  appendix-name: rgb("#D5672D"),
  appendix-meta: rgb(181, 83, 43),
  famous-lines-fill: luma(30),
  famous-source-fill: luma(60),
  poet-name-fill: rgb("#D5672D"),
  poet-bio-fill: black,
  index-initial-fill: rgb("#D5672D"),
  index-name-fill: rgb(181, 83, 43),
  index-dynasty-fill: rgb(181, 83, 43).transparentize(35%),
  index-poem-fill: luma(52),
  end-mark: rgb("#DDA777"),
  end-motto: luma(105),
  end-page-fill: rgb("#F8F4EC"),
  header-fill: luma(150),
  footer-fill: luma(120),
  serif: ("STKaiti", "KaiTi", "Noto Serif CJK SC"),
  body-font: ("Noto Serif CJK SC", "SimSun"),
  title-weight: "medium",
  topic-size: 15pt,
  subtopic-size: 12pt,
  topic-fill: rgb(111, 150, 55),
  subtopic-fill: luma(48),
  note-rule: true,
  note-label: true,
  split-clauses: false,
  margin: none,
  chapter-size: none,
  preface-title-size: 26pt,
  appendix-title-size: 18pt,
  end-mark-size: 26pt,
  poem-gap: none,
  pinyin-fill: luma(95),
  author-pinyin-fill: luma(120),
  title-pinyin-fill: luma(105),
  page-number-fill: luma(120),
)

// kindle: a high-contrast reading layer for grayscale e-ink. White pages,
// near-black titles, gray accents; no full-bleed color blocks.
#let kindle = (
  name: "kindle",
  palette: "school",
  page-fill: white,
  text-fill: rgb("#1a1a1a"),
  title-fill: rgb("#1a1a1a"),
  author-fill: luma(70),
  note-fill: luma(55),
  rule-fill: luma(190),
  toc-level-1: rgb("#1a1a1a"),
  toc-level-2: luma(60),
  toc-level-3: luma(50),
  toc-level-4: luma(40),
  toc-chapter-1-fill: rgb("#1a1a1a"),
  toc-chapter-2-fill: luma(60),
  toc-title: rgb("#1a1a1a"),
  toc-title-size: 22pt,
  chapter-title: rgb("#1a1a1a"),
  chapter-cover-fill: white,
  chapter-sub: luma(85),
  preface-title: rgb("#1a1a1a"),
  preface-text-fill: luma(35),
  appendix-title: rgb("#1a1a1a"),
  appendix-accent: luma(190),
  appendix-name: rgb("#1a1a1a"),
  appendix-meta: luma(80),
  famous-lines-fill: luma(30),
  famous-source-fill: luma(60),
  poet-name-fill: rgb("#1a1a1a"),
  poet-bio-fill: rgb("#1a1a1a"),
  index-initial-fill: rgb("#1a1a1a"),
  index-name-fill: rgb("#1a1a1a"),
  index-dynasty-fill: luma(80),
  index-poem-fill: luma(50),
  end-mark: luma(60),
  end-motto: luma(75),
  end-page-fill: rgb("#F8F4EC"),
  header-fill: luma(70),
  footer-fill: luma(70),
  // STKaiti has cleaner vertical metrics for display titles; KaiTi stays the
  // body face for reading.
  serif: ("STKaiti", "KaiTi", "Noto Serif CJK SC"),
  body-font: ("KaiTi", "STKaiti", "Noto Serif CJK SC"),
  title-weight: "medium",
  topic-size: 13pt,
  subtopic-size: 10.5pt,
  topic-fill: rgb("#1a1a1a"),
  subtopic-fill: luma(50),
  note-rule: true,
  note-label: true,
  split-clauses: false,
  margin: none,
  chapter-size: 18pt,
  preface-title-size: 18pt,
  appendix-title-size: 14pt,
  end-mark-size: 20pt,
  poem-gap: none,
  pinyin-fill: luma(60),
  author-pinyin-fill: luma(90),
  title-pinyin-fill: luma(80),
  page-number-fill: luma(70),
)

// Kami palette: warm paper, ink blue, stone. Colours only — the school
// structure (single column, couplets on one line, labelled notes) stays.
#let kami-palette = (
  page-fill: rgb("#f5f4ed"),
  text-fill: rgb("#1f1d18"),
  title-fill: rgb("#1B365D"),
  author-fill: rgb("#6b665b"),
  note-fill: rgb("#6b665b"),
  rule-fill: rgb("#e8e6dc"),
  toc-level-1: rgb("#1B365D"),
  toc-level-2: rgb("#6b665b"),
  toc-level-3: rgb("#6b665b"),
  toc-level-4: rgb("#1f1d18"),
  toc-chapter-1-fill: rgb("#1B365D"),
  toc-chapter-2-fill: rgb("#6b665b"),
  toc-title: rgb("#1B365D"),
  preface-title: rgb("#1B365D"),
  preface-text-fill: rgb("#1f1d18"),
  appendix-title: rgb("#1B365D"),
  appendix-accent: rgb("#e8e6dc"),
  appendix-name: rgb("#1B365D"),
  appendix-meta: rgb("#6b665b"),
  famous-lines-fill: rgb("#1f1d18"),
  famous-source-fill: rgb("#6b665b"),
  poet-name-fill: rgb("#1B365D"),
  poet-bio-fill: rgb("#1f1d18"),
  index-initial-fill: rgb("#1B365D"),
  index-name-fill: rgb("#1B365D"),
  index-dynasty-fill: rgb("#6b665b"),
  index-poem-fill: rgb("#6b665b"),
  end-mark: rgb("#1B365D"),
  end-motto: rgb("#6b665b"),
  end-page-fill: rgb("#f5f4ed"),
  header-fill: rgb("#6b665b"),
  footer-fill: rgb("#6b665b"),
  topic-fill: rgb("#1B365D"),
  subtopic-fill: rgb("#6b665b"),
  pinyin-fill: rgb("#1f1d18"),
  author-pinyin-fill: rgb("#6b665b"),
  title-pinyin-fill: rgb("#1B365D"),
  page-number-fill: rgb("#6b665b"),
)

#let palettes = (
  school: (:),
  kami: kami-palette,
)

// Resolve `design` (structure) plus `palette` (colours). `design: "kami"` is
// kept as a compatibility alias for the old structural Kami theme.
#let resolve-theme(design: "school", palette: none) = {
  let structure = if design == "kindle" { "kindle" } else { "school" }
  let base = if structure == "kindle" { kindle } else { school }
  let palette-name = if palette != none and palette != "" {
    palette
  } else if design == "kami" {
    "kami"
  } else {
    "school"
  }
  let colors = palettes.at(palette-name, default: palettes.school)
  base + colors + (name: structure, palette: palette-name)
}
