#import "is-blank.typ": *

// One accent + ink + one muted grey (cv-typography-standard rule 6). The accent is
// used as ONE tasteful block: a filled monogram SQUARE (the initials, in near-white)
// beside the name, plus the section label rules. Off the square: ink on white.
// Default accent a deep forest green.
#let ink = rgb("#1f2430")
#let muted = rgb("#6b7280")
#let mono-ink = rgb("#f4f7f5")

// Fixed size scale from body B = 10.5pt (standard rule 2), defined ONCE.
#let display-size = 22pt // ~2.1 x B - the name (masthead)
#let subhead-size = 12pt // ~1.14 x B - the profession line
#let body-size = 10.5pt // B
#let label-size = 9.5pt // ~0.9 x B - section labels (uppercase + tracked)
#let mono-size = 19pt // the monogram initials
#let meta-size = 8.6pt // ~0.82 x B - dates, location, contact, level, fine print

// Document shell: set-rules + PDF metadata only. The masthead and sections are
// composed by wrapSections. HK Grotesk is the single family (standard rule 1).
#let emblem-cv(
  author: "",
  font: "HK Grotesk",
  font-size: 10.5pt,
  paper: "a4",
  margin: 1.5cm,
  leading: 0.65em,
  lang: "en",
  body,
) = {
  let author-str = if type(author) == str { author } else { "CV" }
  set document(author: author-str, title: author-str + " - CV")

  set text(font: font, size: font-size, fill: ink, lang: lang, ligatures: false, hyphenate: false)
  set page(margin: margin, paper: paper)
  set par(justify: false, leading: leading)

  show link: set text(fill: muted)

  body
}

// Masthead: a filled accent monogram SQUARE (initials in near-white) at the left, the
// name (bold), profession (accent) and a quiet contact line stacked to its right, over
// a thin accent hairline. Guarded so an empty CV shows nothing.
// photo (VFS path string) replaces the monogram square in the same 46pt
// footprint when present; none keeps the monogram, byte-identically.
#let masthead(author: "", profession: "", contact: "", initials: "", accent-color: "#2f4a3f", photo: none, photo-radius: 4pt, photo-size: 46pt) = {
  let has-name = not is-blank(author)
  let has-prof = not is-blank(profession)
  let has-contact = not is-blank(contact)
  if has-name or has-prof or has-contact {
    block(above: 0pt, below: 1.2em, breakable: false, {
      set block(spacing: 0pt)
      grid(
        columns: (auto, 1fr),
        column-gutter: 14pt,
        align: (left + horizon, left + horizon),
        if photo != none {
          box(
            clip: true,
            width: photo-size,
            height: photo-size,
            radius: photo-radius,
            image(photo, width: photo-size, height: photo-size, fit: "cover"),
          )
        } else if not is-blank(initials) {
          box(
            width: 46pt,
            height: 46pt,
            radius: 4pt,
            fill: rgb(accent-color),
            align(center + horizon, text(fill: mono-ink, weight: "bold", size: mono-size, tracking: 0.5pt, initials)),
          )
        } else {
          []
        },
        {
          set par(spacing: 0pt, leading: 0.45em, justify: false)
          if has-name { text(size: display-size, weight: "bold", fill: ink, author) }
          if has-prof {
            if has-name { v(3pt) }
            text(size: subhead-size, weight: "medium", tracking: 0.3pt, fill: rgb(accent-color), profession)
          }
          if has-contact {
            if has-name or has-prof { v(6pt) }
            text(size: meta-size, fill: muted, contact)
          }
        },
      )
      v(9pt)
      line(length: 100%, stroke: 0.6pt + rgb(accent-color))
    })
  }
}

// Section label: accent UPPERCASE + tracking over a thin accent rule. Sticky.
#let cv-section(title, accent-color: "#2f4a3f") = {
  block(above: 1.25em, below: 0.9em, sticky: true, {
    set block(spacing: 0pt)
    set par(spacing: 0pt, justify: false)
    text(size: label-size, weight: "semibold", tracking: 0.9pt, fill: rgb(accent-color), upper(title))
    v(3pt)
    line(length: 100%, stroke: 0.6pt + rgb(accent-color))
  })
}

// Entry: semibold-ink title leads with a muted subtitle, dates right; location and an
// optional URL meta line below; then the body. No mid-word hyphenation on the title.
#let emblem-entry(title: "", subtitle: "", dates: "", location: "", meta: "", body) = {
  block(breakable: false, {
    set block(spacing: 0pt)
    set par(spacing: 0pt)
    block(sticky: true, breakable: false, {
      set par(justify: false)
      set text(hyphenate: false)
      grid(
        columns: (1fr, auto),
        align: (left + top, right + top),
        column-gutter: 0.75em,
        {
          if not is-blank(title) { text(weight: "semibold", fill: ink, title) }
          if not is-blank(title) and not is-blank(subtitle) { text(fill: muted)[ #sym.dash.en ] }
          if not is-blank(subtitle) { text(fill: muted, subtitle) }
        },
        if not is-blank(dates) { text(size: meta-size, fill: muted, dates) } else { [] },
      )
      if not is-blank(location) {
        v(3pt)
        text(size: meta-size, fill: muted, location)
      }
      if not is-blank(meta) {
        v(3pt)
        text(size: meta-size, fill: muted, meta)
      }
    })
    if not is-blank(body) {
      v(3.5pt)
      block(spacing: 0pt, { set text(fill: ink); body })
    }
  })
}

// Language row: language left, level muted right.
#let emblem-language(language: "", level: "") = {
  grid(
    columns: (1fr, auto),
    align: (left + horizon, right + horizon),
    column-gutter: 0.6em,
    language,
    if not is-blank(level) { text(size: meta-size, fill: muted, level) } else { [] },
  )
}
