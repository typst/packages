/// Renders the presentation table of contents in its detailed or simple style.

#import "utils.typ": heading-title, plain-text

/// Returns the text a table of contents entry shows for a heading body, or
/// `none` when the heading has no text to show.
///
/// A heading without a visible title falls back to its header label; a heading
/// that does render text is passed through untouched.
///
/// = Parameters
/// - `body` (content): The body of a heading.
///
/// = Returns
/// The entry text, or `none`.
#let entry-label(body) = {
  if plain-text(body).trim() != "" {
    body
  } else {
    let label = heading-title(body)
    if label.trim() == "" { none } else { label }
  }
}

/// Renders the table of contents title for `locale`.
///
/// = Parameters
/// - `theme-config` (dictionary): Theme configuration.
/// - `locale` (string): Language locale, `"EN"` or `"RU"`.
///
/// = Returns
/// The localized table of contents title.
#let toc-title(theme-config, locale) = {
  let title = if locale == "RU" { [*Оглавление*] } else { [*Table of contents*] }
  v(0.5em)
  align(center, box(
    fill: theme-config.primary,
    radius: 15pt,
    inset: 1em,
    width: 100%,
    text(size: 2.2em, weight: "bold", fill: theme-config.sub-text)[#title]
  ))

  v(1.5em)
}

/// Renders the detailed table of contents: level 1 and level 2 headings in a
/// three-column layout with slide numbers.
///
/// = Parameters
/// - `theme-config` (dictionary): Theme configuration.
///
/// = Returns
/// The detailed table of contents.
#let detailed-style(theme-config) = {
  show outline.entry.where(level: 1): it => {
    if entry-label(it.element.body) == none {
      none
    } else {
      context {
        let slide-num = counter(page).at(it.element.location()).first()
        block(
          width: 100%,
          box(
            fill: theme-config.toc-background,
            stroke: theme-config.toc-stroke,
            radius: 5pt,
            inset: 0.5em,
            link(it.element.location(), grid(
              columns: (1fr, auto),
              align: (left, right),
              text(size: 1.2em, weight: "bold", fill: theme-config.toc-text, hyphenate: true)[#counter(heading).at(it.element.location()).first(). #entry-label(it.element.body)],
              text(size: 0.9em, fill: theme-config.toc-text.lighten(30%))[#slide-num]
            ))
          )
        )
      }
    }
  }

  show outline.entry.where(level: 2): it => {
    if it.element.body == [] {
      none
    } else {
      let nums = counter(heading).at(it.element.location())
      let num-str = nums.map(str).join(".")
      context {
        let slide-num = counter(page).at(it.element.location()).first()
        block(
          width: 100%,
          box(
            inset: (left: 1em, top: 0.2em, bottom: 0.2em),
            link(it.element.location(), grid(
              columns: (1fr, auto),
              align: (left, right),
              text(size: 0.9em, fill: theme-config.main-text, hyphenate: true)[#num-str #it.element.body],
              text(size: 0.7em, fill: theme-config.main-text.lighten(30%))[#slide-num]
            ))
          )
        )
      }
    }
  }

  columns(3, outline(depth: 2, title: none))
}

/// Renders the simple table of contents: level 1 headings in a two-column grid
/// of styled boxes.
///
/// = Parameters
/// - `theme-config` (dictionary): Theme configuration.
///
/// = Returns
/// The simple table of contents.
#let simple-style(theme-config) = {
  context {
    let entries = query(heading.where(level: 1))
    let grid-items = ()

    for entry in entries {
      if entry-label(entry.body) != none {
        let slide-num = counter(page).at(entry.location()).first()
        grid-items.push(
          box(
            width: 100%,
            fill: theme-config.toc-background,
            stroke: theme-config.toc-stroke,
            radius: 5pt,
            inset: 0.8em,
            link(entry.location(), grid(
              columns: (1fr, auto),
              align: (left, right),
              text(size: 1.3em, weight: "bold", fill: theme-config.toc-text, hyphenate: true)[#counter(heading).at(entry.location()).first(). #entry-label(entry.body)],
              text(size: 1.0em, fill: theme-config.toc-text.lighten(30%))[#slide-num]
            ))
          )
        )
      }
    }

    if grid-items.len() > 0 {
      grid(columns: 2, gutter: 0.5em, ..grid-items)
    }
  }
}

/// Renders the table of contents in the requested style.
///
/// = Parameters
/// - `toc-style` (string): `"detailed"` or `"simple"`.
/// - `theme-config` (dictionary): Theme configuration.
/// - `locale` (string): Language locale, `"EN"` or `"RU"`.
///
/// = Returns
/// The table of contents page.
#let render-toc(toc-style, theme-config, locale) = {
  toc-title(theme-config, locale)

  if toc-style == "detailed" {
    detailed-style(theme-config)
  } else if toc-style == "simple" {
    simple-style(theme-config)
  }
}
