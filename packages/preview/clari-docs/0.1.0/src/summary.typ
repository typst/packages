// ============================================================
// clari-slides — Summary Document Type
// ============================================================
// Sets up a compact A4 summary document that shares the same
// color system and components as the slides document type.
//
// Usage:
//   #import "@local/clari-docs:0.1.0": *
//   #show: clari-summary.with(
//     theme:    "ocean",
//     title:    "My Summary",
//     author:   "Jane Doe",
//   )

#import "state.typ": *
#import "colors.typ": _resolve-palette, _category-defaults

// ============================================================
// Internal: compact inline title block (not a full page)
// ============================================================

#let _summary-title-block(title, subtitle, author, date-str, institution, primary, accent) = {
  block(width: 100%, below: 1em, {
    // ── Title (left) + meta (right), bottom-aligned ───────
    grid(
      columns:       (1fr, auto),
      column-gutter: 1.2em,
      align:         (left + bottom, right + bottom),
      // left: title + optional subtitle
      stack(
        dir:     ttb,
        spacing: 0.25em,
        text(size: 20pt, weight: "bold", fill: primary)[#title],
        if subtitle != none {
          text(size: 11pt, weight: "semibold", fill: accent)[#subtitle]
        } else { [] },
      ),
      // right: author / institution / date stacked, right-aligned
      align(right, {
        set text(size: 9pt, fill: luma(130))
        stack(
          dir:     ttb,
          spacing: 2pt,
          if author      != none { text(weight: "semibold")[#author] }      else { [] },
          if institution != none { text[#institution] }                      else { [] },
          if date-str    != none { text[#date-str] }                         else { [] },
        )
      }),
    )
    v(0.45em)
    // ── thin rule — primary left portion, muted right ─────
    line(length: 100%, stroke: 1.5pt + primary)
  })
}

// ============================================================
// Public: clari-summary — Main #show: setup function
// ============================================================

/// Compact A4 summary document initialiser. Apply with `#show: clari-summary.with(...)`.
///
/// All shared components (callout, definition, theorem, highlight-box, etc.)
/// work unchanged — they read the same global color state.
///
/// Parameters:
/// - `category`    — Style category (affects default theme): "simple" | "math" |
///                   "professional" | "allrounder".
/// - `theme`       — Theme name (e.g. "ocean") or raw `rgb(...)` color.
/// - `accent`      — Optional accent color override.
/// - `font`        — Font family string.
/// - `font-size`   — Base font size (default 11pt).
/// - `back-color`  — Page background color.
/// - `title`       — Document title shown in the inline title block.
/// - `subtitle`    — Subtitle shown below the title.
/// - `author`      — Author name(s).
/// - `date`        — Date; `auto` resolves to today, `none` hides it.
/// - `institution` — Affiliation / institution name.
/// - `show-toc`    — Whether to render a table of contents after the title.
/// - `body`        — Document body (injected by `#show:`).
#let clari-summary(
  category:    "simple",
  theme:       "ocean",
  accent:      none,
  font:        "Fira Sans",
  font-size:   11pt,
  back-color:  white,
  title:       none,
  subtitle:    none,
  author:      none,
  date:        auto,
  institution: none,
  show-toc:    false,
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

  // ── Page geometry ─────────────────────────────────────────
  set page(
    paper:        "a4",
    margin:       (x: 2.5cm, top: 2.5cm, bottom: 3cm),
    fill:         back-color,
    numbering:    "1 / 1",
    number-align: center + bottom,
    footer: context [
      #h(1fr)
      #text(size: 9pt, fill: luma(160))[
        #counter(page).display("1 / 1", both: true)
      ]
      #h(1fr)
    ],
  )

  // ── Base text ─────────────────────────────────────────────
  set text(font: font, size: font-size, fill: rgb("#1A1A2E"))
  set par(justify: true, leading: 0.7em, spacing: 0.85em)

  // ── Heading styles ────────────────────────────────────────
  show heading.where(level: 1): it => {
    v(1.2em, weak: true)
    block(
      width: 100%,
      below: 0.45em,
      stack(
        dir: ttb,
        spacing: 0.3em,
        text(
          size:   font-size * 1.3,
          weight: "bold",
          fill:   primary-color,
        )[#it.body],
        line(length: 100%, stroke: 1.5pt + primary-color.lighten(40%)),
      ),
    )
  }

  show heading.where(level: 2): it => {
    v(0.9em, weak: true)
    block(
      below: 0.3em,
      text(
        size:   font-size * 1.12,
        weight: "semibold",
        fill:   primary-color,
      )[#it.body],
    )
  }

  show heading.where(level: 3): it => {
    v(0.7em, weak: true)
    block(
      below: 0.25em,
      text(
        size:   font-size * 1.0,
        weight: "semibold",
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

  // ── Title block ───────────────────────────────────────────
  if title != none {
    _summary-title-block(
      title, subtitle, author, resolved-date, institution,
      primary-color, accent-color,
    )
  }

  // ── Table of contents ─────────────────────────────────────
  if show-toc {
    outline(title: [Contents], indent: true)
    v(1em)
    line(length: 100%, stroke: 0.5pt + luma(200))
    v(0.5em)
  }

  body
}
