/// Table of Contents (ToC) module for Pepentation presentation library.
///
/// This module provides functions to render different styles of table of contents
/// for presentations, supporting both detailed (multi-column with subheadings)
/// and simple (grid-based) layouts.

/// Renders the table of contents title based on the locale.
///
/// # Parameters
/// - `theme-config` (dictionary): Theme configuration dictionary.
/// - `locale` (string): Language locale ("EN" or "RU").
///
/// # Returns
/// Content for the localized table of contents title.
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

/// Renders a detailed table of contents with 3 columns and subheadings.
///
/// This style displays level 1 headings with slide numbers and includes
/// level 2 subheadings in a compact multi-column layout.
///
/// # Parameters
/// - `theme-config` (dictionary): Theme configuration dictionary.
///
/// # Returns
/// Content for the detailed table of contents.
#let detailed-style(theme-config) = {
  show outline.entry.where(level: 1): it => {
    if it.element.body == [] {
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
              text(size: 1.2em, weight: "bold", fill: theme-config.toc-text, hyphenate: true)[#counter(heading).at(it.element.location()).first(). #it.element.body],
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

/// Renders a simple table of contents in a 2-column grid layout.
///
/// This style displays level 1 headings only in a grid of styled boxes
/// with slide numbers.
///
/// # Parameters
/// - `theme-config` (dictionary): Theme configuration dictionary.
///
/// # Returns
/// Content for the simple table of contents.
#let simple-style(theme-config) = {
  context {
    let entries = query(heading.where(level: 1))
    let grid-items = ()

    for entry in entries {
      if entry.body != [] {
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
              text(size: 1.3em, weight: "bold", fill: theme-config.toc-text, hyphenate: true)[#counter(heading).at(entry.location()).first(). #entry.body],
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

/// Renders the table of contents with the specified style.
///
/// # Parameters
/// - `toc-style` (string): The style to use ("detailed" or "simple").
/// - `theme-config` (dictionary): Theme configuration dictionary.
/// - `locale` (string): Language locale ("EN" or "RU").
///
/// # Returns
/// Content for the table of contents page.
#let render-toc(toc-style, theme-config, locale) = {
  toc-title(theme-config, locale)

  if toc-style == "detailed" {
    detailed-style(theme-config)
  } else if toc-style == "simple" {
    simple-style(theme-config)
  }
}
