#let vocabulo(
  words,
  langs,
  format: ("remarkable", "paper-pro"),
  flipped: false,
  num-writing-lines: 4,
  bar-pos: "top",
  seed: none,
  theme: "light",
  links: ("to-writing", "to-right"),
  sections: ("outline", "left", "full", "right", "writing"),
) = {
  import "@preview/slate-geometry:0.1.0": get-size, get-toolbar
  import "src/lib.typ": shuffle-words, table-vocab, tables-writing, themes

  // Create a page matching the device size

  // No margin by default, add extra space for an optional bar
  let margin = (top: 0pt, bottom: 0pt, left: 0pt, right: 0pt)
  if type(format) == array and bar-pos != none {
    let toolbar-size = get-toolbar(format.first(), format.last())
    if toolbar-size != none {
      margin.insert(bar-pos, toolbar-size)
    }
  }

  // Create parameters for page configuration
  let page-params = if type(format) == array {
    // Custom device format with explicit dimensions
    let device-size = get-size(format.first(), format.last())

    (
      width: device-size.at(0),
      height: device-size.at(1),
      margin: margin,
      flipped: flipped,
    )
  } else {
    // Standard paper size - let Typst handle it
    (paper: format, margin: margin, flipped: flipped)
  }
  // Page setup
  set page(
    ..page-params,
  )

  // Do not show the header, use it only for the outline
  show heading.where(level: 2): set text(size: 0pt)

  // Outline with a wider height to make following the link easier
  show outline: set text(size: 1.5em)
  show outline.entry.where(level: 2): set block(inset: 1em)
  set outline.entry(fill: none)

  // Resolve theme
  let theme = if type(theme) == str {
    themes.at(theme, default: themes.light)
  } else {
    theme
  }
  // Use theme text color globally
  set text(fill: theme.text)
  set page(fill: theme.background)

  // Shuffle words if a seed is provided
  let words = if seed != none {
    shuffle-words(words, seed)
  } else {
    words
  }

  let (lang-learning, lang-native) = langs

  // Create an array from the `links` parameter
  let links = if type(links) == str {
    (links,)
  } else if links == none {
    ()
  } else {
    links
  }

  // Check which sections exist
  let has-writing = sections.contains("writing")
  let has-full = sections.contains("full")
  let has-left = sections.contains("left")
  let has-right = sections.contains("right")

  // Determine if forward links (to writing) should be created
  let create-links-to-writing = links.contains("to-writing") and has-writing

  // Determine backlink target based on user preference and section availability
  let backlink-target = if links.contains("to-full") and has-full {
    "full"
  } else if links.contains("to-left") and has-left {
    "left"
  } else if links.contains("to-right") and has-right {
    "right"
  } else {
    none
  }

  // ========================
  // Render sections based on the sections parameter

  // ========================
  // Render sections based on the sections parameter
  let writing-seen = false
  let full-seen = false
  for (i, section) in sections.enumerate() {
    // Add pagebreak before sections (except the first one)
    if i > 0 {
      pagebreak()
    }

    if section == "outline" {
      // Outline in the center of the page
      align(horizon)[
        #outline(
          title: "",
          target: heading.where(level: 2),
        )
      ]
    } else if section == "left" {
      heading(level: 2, lang-learning)
      table-vocab(
        words,
        theme,
        mode: "left",
        links-to-writing: create-links-to-writing,
        attach-label: backlink-target == "left",
      )
    } else if section == "full" {
      heading(level: 2, [#lang-learning - #lang-native])
      table-vocab(
        words,
        theme,
        mode: "full",
        links-to-writing: create-links-to-writing,
        attach-label: backlink-target == "full",
      )
    } else if section == "right" {
      heading(level: 2, lang-native)
      table-vocab(
        words,
        theme,
        mode: "right",
        links-to-writing: create-links-to-writing,
        attach-label: backlink-target == "right",
      )
    } else if section == "writing" {
      heading(level: 2, [Writing practice])
      tables-writing(
        words,
        num-writing-lines,
        theme,
        create-backlinks: backlink-target != none,
        backlink-target: backlink-target,
      )
    }
  }
}
