// ============================================================
// clari-slides — Lecture Notes Document Type
// ============================================================
// Sets up a detailed A4 lecture-notes document that shares the
// same color system and components as the slides document type.
//
// Usage:
//   #import "@local/clari-docs:0.1.0": *
//   #show: clari-notes.with(
//     theme:    "midnight",
//     title:    "Introduction to Topology",
//     author:   "Prof. Jane Doe",
//     show-toc: true,
//   )

#import "state.typ": *
#import "colors.typ": _resolve-palette, _category-defaults

// ============================================================
// Internal: full-page title page
// ============================================================

#let _notes-title-page(title, subtitle, author, date-str, institution, primary, accent) = {
  page(
    paper:  "a4",
    margin: 0pt,
    fill:   white,
    header: none,
    footer: none,
    numbering: none,
    {
      // ── Top color band ──────────────────────────────────────
      rect(
        fill:   primary,
        width:  100%,
        height: 38%,
        inset:  (x: 3cm, y: 0pt),
        align(left + horizon,
          stack(
            dir: ttb,
            spacing: 0.5em,
            // "Lecture Notes" badge
            box(
              fill:   accent,
              radius: 3pt,
              inset:  (x: 0.7em, y: 0.3em),
              text(fill: white, size: 10pt, weight: "semibold")[Lecture Notes],
            ),
            v(0.4em),
            // Title
            text(size: 32pt, weight: "bold", fill: white)[#title],
          )
        ),
      )
      // ── Lower content area ──────────────────────────────────
      pad(x: 3cm, top: 1.8cm, {
        if subtitle != none {
          text(size: 15pt, weight: "semibold", fill: accent)[#subtitle]
          v(0.6em)
        }
        line(length: 6cm, stroke: 2pt + primary)
        v(1cm)
        set text(size: 12pt, fill: luma(80))
        stack(
          dir: ttb,
          spacing: 0.5em,
          if author      != none { text(weight: "semibold")[#author] },
          if institution != none { text[#institution] },
          if date-str    != none { text[#date-str] },
        )
      })
    }
  )
}

// ============================================================
// Public: clari-notes — Main #show: setup function
// ============================================================

/// Detailed A4 lecture-notes initialiser. Apply with `#show: clari-notes.with(...)`.
///
/// All shared components (callout, definition, theorem, highlight-box, etc.)
/// work unchanged — they read the same global color state.
///
/// Parameters:
/// - `category`       — Style category (affects default theme): "simple" | "math" |
///                      "professional" | "allrounder".
/// - `theme`          — Theme name (e.g. "midnight") or raw `rgb(...)` color.
/// - `accent`         — Optional accent color override.
/// - `font`           — Font family string.
/// - `font-size`      — Base font size (default 11pt).
/// - `back-color`     — Page background color.
/// - `title`          — Document title; triggers a full title page when set.
/// - `subtitle`       — Subtitle shown on the title page.
/// - `author`         — Author name(s).
/// - `date`           — Date; `auto` resolves to today, `none` hides it.
/// - `institution`    — Affiliation / institution name.
/// - `show-toc`       — Whether to render a table of contents.
/// - `running-header` — Whether to show title + page number in the page header.
/// - `body`           — Document body (injected by `#show:`).
#let clari-notes(
  category:       "simple",
  theme:          "ocean",
  accent:         none,
  font:           "Fira Sans",
  font-size:      11pt,
  back-color:     white,
  title:          none,
  subtitle:       none,
  author:         none,
  date:           auto,
  institution:    none,
  show-toc:       true,
  running-header: true,
  body,
) = {
  // ── Resolve palette ───────────────────────────────────────
  let resolved-theme = if type(theme) == str {
    let t = if theme == "auto" or theme == "" {
      _category-defaults.at(category, default: "ocean")
    } else {
      theme
    }
    _resolve-palette(t)
  } else {
    _resolve-palette(theme)
  }

  let primary-color = resolved-theme.primary
  let accent-color  = if accent != none { accent } else { resolved-theme.accent }

  // ── Initialise global state ───────────────────────────────
  cs-primary.update(primary-color)
  cs-accent.update(accent-color)
  cs-back-color.update(back-color)
  cs-category.update(category)
  cs-font.update(font)
  cs-font-size.update(font-size)
  cs-show-nums.update(true)
  cs-show-prog.update(false)

  // ── Resolve date ──────────────────────────────────────────
  let resolved-date = if date == auto {
    datetime.today().display("[month repr:long] [day], [year]")
  } else if date == none {
    none
  } else if type(date) == datetime {
    date.display("[month repr:long] [day], [year]")
  } else {
    date
  }

  // ── Page geometry ─────────────────────────────────────────
  // Capture title for use in running header closure
  let doc-title = title

  set page(
    paper:   "a4",
    margin:  (x: 3cm, top: 3cm, bottom: 3cm),
    fill:    back-color,
    numbering: "1",
    header: context {
      if running-header and doc-title != none and counter(page).get().first() > 1 {
        stack(
          dir: ttb,
          spacing: 3pt,
          grid(
            columns: (1fr, auto),
            align:   (left + horizon, right + horizon),
            text(size: 9pt, fill: luma(140))[#doc-title],
            text(size: 9pt, fill: primary-color, weight: "semibold")[
              #counter(page).display()
            ],
          ),
          line(length: 100%, stroke: 0.5pt + luma(200)),
        )
      }
    },
    footer: none,
  )

  // ── Base text ─────────────────────────────────────────────
  set text(font: font, size: font-size, fill: rgb("#1A1A2E"))
  set par(justify: true, leading: 0.75em, spacing: 1em)

  // ── Heading styles ────────────────────────────────────────
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(0.5em)
    stack(
      dir: ttb,
      spacing: 0.4em,
      // accent bar above
      rect(width: 3cm, height: 4pt, fill: accent-color, radius: 2pt),
      text(
        size:   font-size * 1.55,
        weight: "bold",
        fill:   primary-color,
      )[#it.body],
    )
    v(0.2em, weak: true)
  }

  show heading.where(level: 2): it => {
    v(1em, weak: true)
    stack(
      dir: ttb,
      spacing: 0.3em,
      text(
        size:   font-size * 1.22,
        weight: "bold",
        fill:   primary-color,
      )[#it.body],
      line(length: 100%, stroke: 0.8pt + primary-color.lighten(50%)),
    )
    v(0.2em, weak: true)
  }

  show heading.where(level: 3): it => {
    v(0.8em, weak: true)
    block(
      below: 0.2em,
      text(
        size:   font-size * 1.07,
        weight: "semibold",
        fill:   primary-color.lighten(20%),
      )[#it.body],
    )
  }

  show heading.where(level: 4): it => {
    v(0.6em, weak: true)
    block(
      below: 0.15em,
      text(
        size:   font-size,
        weight: "semibold",
        style:  "italic",
        fill:   accent-color,
      )[#it.body],
    )
  }

  // ── Link / ref coloring ───────────────────────────────────
  show link: it => text(fill: primary-color)[#it]
  show ref:  it => text(fill: accent-color)[#it]

  // ── Math ──────────────────────────────────────────────────
  set math.equation(numbering: "(1)")

  // ── Lists ─────────────────────────────────────────────────
  set list(marker: context text(fill: cs-primary.get())[•])
  set enum(numbering: it => context text(fill: cs-primary.get())[*#it.*])

  // ── Footnotes ─────────────────────────────────────────────
  show footnote.entry: set text(size: 0.85em)

  // ── Title page ────────────────────────────────────────────
  if title != none {
    _notes-title-page(
      title, subtitle, author, resolved-date, institution,
      primary-color, accent-color,
    )
  }

  // ── Table of contents ─────────────────────────────────────
  if show-toc {
    set outline.entry(fill: repeat[.])
    outline(
      title: text(
        size:   font-size * 1.3,
        weight: "bold",
        fill:   primary-color,
      )[Table of Contents],
      indent: 1.5em,
      depth:  3,
    )
    pagebreak(weak: true)
  }

  body
}
