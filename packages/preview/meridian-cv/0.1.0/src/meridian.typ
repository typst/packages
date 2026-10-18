#import "is-blank.typ": *

// One accent + ink + one muted grey (cv-typography-standard rule 6). The accent is the
// section labels and their leading rule, and the masthead rule; body ink, meta muted.
// A serif mirror layout: masthead and section labels flush RIGHT, content left. Default
// accent a muted steel blue.
#let ink = rgb("#1f2430")
#let muted = rgb("#6b7280")

// Fixed size scale from body B = 10.5pt (standard rule 2), defined ONCE.
#let display-size = 24pt // ~2.3 x B - the name (masthead)
#let subhead-size = 12pt // ~1.14 x B - the profession line
#let body-size = 10.5pt // B
#let label-size = 10pt // ~0.95 x B - section labels (uppercase + tracked)
#let meta-size = 8.6pt // ~0.82 x B - dates, location, contact, level, fine print

// Document shell: set-rules + PDF metadata only. Masthead and sections are composed by
// wrapSections. Libertinus Serif is the single family (standard rule 1).
#let meridian-cv(
  author: "",
  font: "Libertinus Serif",
  font-size: 10.5pt,
  paper: "a4",
  margin: 1.5cm,
  leading: 0.66em,
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

// Masthead (flush RIGHT, the mirror signature): name (bold) over the profession (accent)
// and a quiet contact line, all right-aligned, closed by a thin accent rule. Guarded.
// photo (VFS path string) occupies the header's empty left side as a circle;
// none renders the right-aligned stack alone, byte-identically.
#let masthead(author: "", profession: "", contact: "", accent-color: "#33475a", photo: none, photo-radius: 50%, photo-size: 2.4cm) = {
  let has-name = not is-blank(author)
  let has-prof = not is-blank(profession)
  let has-contact = not is-blank(contact)
  if has-name or has-prof or has-contact {
    block(above: 0pt, below: 1.3em, breakable: false, {
      set block(spacing: 0pt)
      set par(spacing: 0pt, leading: 0.4em, justify: false)
      let text-stack = {
        set align(right)
        if has-name { text(size: display-size, weight: "bold", fill: ink, author) }
        if has-prof {
          if has-name { v(4pt) }
          text(size: subhead-size, weight: "regular", fill: rgb(accent-color), profession)
        }
        if has-contact {
          if has-name or has-prof { v(7pt) }
          text(size: meta-size, fill: muted, contact)
        }
      }
      if photo != none {
        grid(
          columns: (auto, 1fr),
          column-gutter: 14pt,
          align: (left + horizon, right + horizon),
          box(
            clip: true,
            radius: photo-radius,
            width: photo-size,
            height: photo-size,
            stroke: 0.6pt + rgb(accent-color),
            image(photo, width: photo-size, height: photo-size, fit: "cover"),
          ),
          text-stack,
        )
      } else {
        text-stack
      }
      if has-name or has-prof or has-contact { v(9pt); line(length: 100%, stroke: 0.6pt + rgb(accent-color)) }
    })
  }
}

// Section label (flush RIGHT): a thin accent rule fills from the left margin up to the
// UPPERCASE accent label at the right edge. Sticky so a label never orphans.
#let cv-section(title, accent-color: "#33475a") = {
  block(above: 1.3em, below: 0.9em, sticky: true, {
    set block(spacing: 0pt)
    set par(spacing: 0pt, justify: false)
    grid(
      columns: (1fr, auto),
      column-gutter: 12pt,
      align: (left + horizon, right + horizon),
      align(horizon, line(length: 100%, stroke: 0.6pt + rgb(accent-color))),
      text(size: label-size, weight: "semibold", tracking: 0.9pt, fill: rgb(accent-color), upper(title)),
    )
  })
}

// Entry: semibold-ink title leads with a muted subtitle, dates right; location and an
// optional URL meta line below; then the body (all left-aligned, complementing the
// right-flush chrome). No mid-word hyphenation on the title.
#let meridian-entry(title: "", subtitle: "", dates: "", location: "", meta: "", body) = {
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
#let meridian-language(language: "", level: "") = {
  grid(
    columns: (1fr, auto),
    align: (left + horizon, right + horizon),
    column-gutter: 0.6em,
    language,
    if not is-blank(level) { text(size: meta-size, fill: muted, level) } else { [] },
  )
}
