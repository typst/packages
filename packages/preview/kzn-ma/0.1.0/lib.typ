/*
 * ==========================================================
 * Project: Typst Academic Thesis Template (KZN)
 * File: kzn-ma.typ
 * Description:
 *   A comprehensive Typst template for academic theses and
 *   dissertations. Provides functions for title pages, headers,
 *   footers, table of contents, list of figures/tables, figure
 *   and table formatting with subfigures, and full document
 *   layout management. Supports multilingual documents (DE/EN/FR)
 *   with customizable fonts, spacing, and numbering schemes.
 *
 * Authors: Christian Prim and Lukas Zuberbühler
 * License: MIT License
 * ==========================================================
 *
 * Copyright (c) 2026 Christian Prim and Lukas Zuberbühler
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */


// Import multilingual string definitions
#import "translations.typ": *


// ------------------------------------------------------------
// Utility Functions
// ------------------------------------------------------------

// State variable to control visibility of private content
#let show-private-content = state("private", true)

// Check if a variable is empty (either an empty array or none)
// Parameters:
//   var: the value to check
// Returns: true if empty, false otherwise
#let is-empty(var) = {
  if var == [] or var == none {
    return true
  } else {
    return false
  }
}

// Check if a key exists in a dictionary and has a non-empty value
// Parameters:
//   key: the key to check
//   dict: the dictionary to search in
// Returns: true if key exists and has a non-empty value, false otherwise
#let exists(key, dict) = {
  if key in dict {
    if not is-empty(dict.at(key)) {
      return true
    }
  }
  return false
}

// Resolve a localized string from a dictionary based on the current text language
// Falls back to German, then English, then the first available value
// Parameters:
//   input: a string or a dictionary keyed by language code (e.g. (de: "...", en: "..."))
// Returns: the localized string for the current language
#let localize(input) = {
  context {
    if type(input) != dictionary {
      return input
    }

    let lang = text.lang

    // Try to match the current language
    if lang in input {
      return input.at(lang)
    }

    // Fallback: German, then English, then first available entry
    if "de" in input {
      return input.de
    }
    if "en" in input {
      return input.en
    }

    return input.values().at(0)
  }
}

// Join an array of items with a language-aware "and" separator
// Parameters:
//   items: array of items to join
// Returns: formatted content with items separated by commas and a localized "and"
#let join-with-und(items) = {
  if items != none {
    if items.len() == 0 {
      []
    } else if items.len() == 1 {
      items.at(0)
    } else {
      for (i, item) in items.enumerate() {
        item
        if i < items.len() - 2 {
          ", "
        } else if i == items.len() - 2 {
          localize(and-str)
        }
      }
    }
  }
}

// Conditionally display content based on the private-content state
// Parameters:
//   body: content to display or hide
// Returns: body if private content is enabled, empty content otherwise
#let private(body) = {
  context {
    if show-private-content.get() {
      body
    } else {
      []
    }
  }
}

// TeX and LaTeX Logo
// Returns: the logos formatted as in LaTeX
#let TeX = {
  set text(font: "New Computer Modern",)
  let t = "T"
  let e = text(baseline: 0.22em, "E")
  let x = "X"
  box(t + h(-0.14em) + e + h(-0.14em) + x)
}

#let LaTeX = {
  set text(font: "New Computer Modern")
  let l = "L"
  let a = text(baseline: -0.35em, size: 0.66em, "A")
  box(l + h(-0.32em) + a + h(-0.13em) + TeX)
}

// ------------------------------------------------------------
// Title Page
// ------------------------------------------------------------

// Create a title page with customizable layout and KZN school branding
// Parameters:
//   authors: array of author names
//   supervisors: array of supervisor names
//   date: submission date string (defaults to today)
//   nord-image: optional path to a background image for the decorative bottom area
//   nord-color: fill color for the decorative bottom area (default: white)
//   nord-image-source: optional caption/credit for the background image
//   background-color: page background color (default: white)
//   zh-blue: Zurich canton blue accent color
//   heading-font: font used for all title page text
//   title: main title content
//   title-size: font size for the main title
//   subtitle: subtitle content
//   subtitle-size: font size for the subtitle
//   strings: dictionary of localized label strings (written-by, supervised-by, etc.)
#let kzn-titlepage(
  authors: none,
  supervisors: none,
  date: datetime.today().display("[day].[month].[year]"),
  nord-image: none,
  nord-color: white,
  nord-image-source: [],
  background-color: white,
  zh-blue: rgb("009EE0"),
  heading-font: "EB Garamond",
  title: none,
  title-size: 36pt,
  subtitle: none,
  subtitle-size: 18pt,
  strings: (
    written-by: localize(written-by),
    supervised-by: localize(supervised-by),
    submitted-on: localize(submitted-on),
    thesis-type: localize(thesis-type-ma),
  ),
) = {
  context {
    if show-private-content.get() {
      let pat = none
      let nord-filling = nord-color
      let zh-blue = zh-blue
      let background-color = background-color
      let segment-color = nord-color

      set page(
        numbering: none,
        footer: none,
      )

      // Build tiling pattern from nord-image if provided
      if not is-empty(nord-image) {
        let pat = tiling(
          size: (page.width, page.height),
          relative: "parent",
          place(
            dx: 0cm,
            dy: page.height - page.width - page.margin.top,
            box(height: page.width + page.margin.inside, nord-image)
          ),
        )
        nord-filling = pat
      }

      set page(fill: background-color)

      // Main triangular fill covering the bottom-left corner
      place(
        dx: 0cm - page.margin.inside,
        dy: -page.margin.top,
        polygon(
          fill: nord-filling,
          stroke: none,
          (0cm, page.height - page.width),
          (0cm, page.height),
          (page.width, page.height),
        ),
      )

      // Circular accent — large semicircle at bottom center
      place(
        dx: 0cm - page.margin.inside + page.width / 2,
        dy: page.height - page.width - page.margin.top,
        circle(fill: nord-filling, radius: page.width / 4),
      )

      // D-segment: small triangle cut in the bottom-right corner
      place(
        dx: 0cm - page.margin.inside,
        dy: -page.margin.top,
        polygon(
          fill: segment-color,
          stroke: none,
          (0cm + page.width - page.width / 3, page.height - page.width / 3),
          (page.width - page.width / 3, page.height),
          (page.width, page.height),
        ),
      )

      // R upper arc — top half of the right-side circle
      place(
        dx: -page.margin.inside + page.width / 2,
        dy: page.height - page.width - page.margin.top + page.width / 2,
        circle(fill: nord-filling, radius: page.width / 4),
      )

      // R body — rectangular fill connecting circle halves
      place(
        dx: -page.margin.inside + page.width / 2,
        dy: page.height - page.width - page.margin.top + page.width / 2,
        rect(width: page.width / 4, height: page.width / 2, fill: nord-filling, radius: 0cm),
      )

      // R notch upper-right — segment-colored cutout block (top)
      place(
        dx: 0cm - page.margin.inside + page.width / 2 - page.width / 6,
        dy: page.height - page.width - page.margin.top + page.width / 2,
        rect(width: page.width / 6, height: page.width / 6, fill: segment-color, radius: 0cm),
      )

      // R notch lower-right — segment-colored cutout block (bottom)
      place(
        dx: 0cm - page.margin.inside + page.width / 2 - page.width / 6,
        dy: page.height - page.width - page.margin.top + page.width / 2 + page.width / 6,
        rect(width: page.width / 6, height: page.width / 3, fill: segment-color, radius: 0cm),
      )

      // R inner fill — rectangular overlap to shape the counter-form
      place(
        dx: -page.margin.inside + page.width / 12,
        dy: page.height - page.width - page.margin.top + page.width / 2 - page.width / 128,
        rect(width: page.width / 4, height: page.width / 3, fill: nord-filling, radius: 0cm),
      )

      // R inner circle — circular cutout left of center
      place(
        dx: -page.margin.inside + page.width / 2 - page.width / 3,
        dy: page.height - page.width - page.margin.top + page.width / 2 - page.width / 128,
        circle(fill: nord-filling, radius: page.width / 6),
      )

      // R leg triangle — diagonal fill closing the bottom of the R leg
      place(
        dx: 0cm - page.margin.inside,
        dy: -page.margin.top,
        polygon(
          fill: nord-filling,
          stroke: none,
          (
            0cm + page.width / 2 - page.width / 6,
            page.height - page.width + page.width / 2 + page.width / 3 - page.width / 127,
          ),
          (page.width / 2 - page.width / 6, page.height),
          (page.width / 2, page.height),
        ),
      )

      // ZH blue transparent overlay — semi-transparent canton color wash over the bottom area
      place(
        dx: 0cm - page.margin.inside,
        dy: -page.margin.top,
        polygon(
          fill: zh-blue.transparentize(20%),
          stroke: none,
          (0cm, page.height - page.width),
          (0cm, page.height),
          (page.width, page.height),
        ),
      )

      // School logo (Loewe) in the top-left margin
      place(
        dx: -page.margin.inside + page.margin.inside / 5,
        dy: -page.margin.top + 4 * page.margin.top / 5,
        top + left,
        image("template/img/loewe.svg", width: 2 * page.margin.inside / 3),
      )

      // School name, title, subtitle, /home/christian/.local/share/typst/packages/local/ma-template/0.1.0/img/and thesis type — top-left content block
      place(
        top + left,
        [
          #block(text(font: heading-font, weight: "bold", size: 16pt, [Kantonsschule Zürich Nord]))
          #block(text(font: heading-font, weight: "bold", size: 12pt, [Lang- und Kurzgymnasium]))
          #block(text(font: heading-font, weight: "bold", size: 12pt, [Fachmittelschule]))

          #v(1cm)

          #block(text(font: heading-font, weight: "bold", size: title-size, title))
          #block(text(font: heading-font, weight: "bold", size: subtitle-size, subtitle))

          #v(1cm)

          #block(text(font: heading-font, weight: "bold", size: 14pt, [#strings.thesis-type]))
        ],
      )

      // Author, supervisor, and date block — bottom-left
      place(
        bottom + left,
        [
          #if not is-empty(authors) {
            block(text(font: heading-font, weight: "bold", size: 14pt, [#strings.written-by]))
          }
          #if not is-empty(authors) {
            block(text(font: heading-font, weight: "bold", size: 16pt, [#join-with-und(authors)]))
          }
          #if not is-empty(supervisors) {
            block(text(font: heading-font, weight: "bold", size: 12pt, [#strings.supervised-by]))
          }
          #if not is-empty(supervisors) {
            block(text(font: heading-font, weight: "bold", size: 14pt, [#join-with-und(supervisors)]))
          }
          #if not is-empty(date) {
            block(text(font: heading-font, weight: "bold", size: 11pt, [#strings.submitted-on #date]))
          }
        ],
      )

      // Optional image source credit on a new page
      if not is-empty(nord-image-source) {
        pagebreak()
        place(bottom + left, [#nord-image-source])
      }
    } else {
      // Anonymous version: show only title, subtitle, and anonymization notice
      place(
        horizon + center,
        [
          #block(text(font: heading-font, weight: "bold", size: title-size, title))
          #block(text(font: heading-font, weight: "bold", size: subtitle-size, subtitle))
          #v(2cm)
          #block(text(size: 20pt, localize(anonymous-version)))
        ],
      )
    }
  }
}


// ------------------------------------------------------------
// Header and Footer Helpers
// ------------------------------------------------------------

// Retrieve the full heading information (number and body) for the current page
// Parameters:
//   skip: number of pages to skip from the beginning (default: 1)
//   level: heading level to retrieve (default: 1)
// Returns: array containing a dictionary with keys "number" and "body"
#let get-heading-full(skip: 1, level: 1) = {
  let result = ()

  if counter(page).at(here()).first() > skip {
    // Search for headings after the current position on the same page
    let h_after = query(heading.where(level: level).after(here()))
      .filter(it => it.location().page() == here().page())

    let h = if h_after.len() > 0 {
      h_after.first()
    } else {
      let h_before = query(heading.where(level: level).before(here()))
      if h_before.len() > 0 {
        h_before.last()
      } else {
        none
      }
    }

    if h != none {
      let heading-body = h.body
      let heading-location = h.location()

      // Resolve the heading number using the heading's own numbering scheme
      let headingNumber = if h.numbering != none {
        let nums = counter(heading).at(heading-location).slice(0, level)
        numbering(h.numbering, ..nums)
      } else {
        // Fallback: construct number manually from counter values
        str(counter(heading).at(heading-location).slice(0, level).map(str).join("."))
      }

      if heading-body != none and heading-body != "" {
        result.push((number: headingNumber, body: heading-body))
      }
    } else {
      result.push((number: "", body: []))
    }
  } else {
    result.push((number: "", body: []))
  }

  return result
}

// Get only the body text of the current page heading
// Parameters:
//   skip: number of pages to skip from the beginning (default: 1)
//   level: heading level to retrieve (default: 1)
// Returns: heading body content or empty array
#let get-heading-body(skip: 1, level: 1) = {
  let heading-full = get-heading-full(skip: skip, level: level)
  if heading-full.len() > 0 {
    return heading-full.first().body
  }
  return []
}

// Get only the number string of the current page heading
// Parameters:
//   skip: number of pages to skip from the beginning (default: 1)
//   level: heading level to retrieve (default: 1)
// Returns: heading number as string or empty string
#let get-heading-number(skip: 1, level: 1) = {
  let heading-full = get-heading-full(skip: skip, level: level)
  if heading-full.len() > 0 {
    return heading-full.first().number
  }
  return ""
}

// Create a page header displaying the current chapter number and title
// Parameters:
//   even-text: content to display on even (left) pages
// Returns: dictionary with "odd" and "even" keys containing header content
#let kzn-header(even-text: none) = {
  return (
    odd: [
      #context {
        get-heading-number(skip: 1, level: 1) + " " + get-heading-body(level: 1, skip: 1)
      }
    ],
    even: even-text,
  )
}

// Create a page footer with page numbers and optional custom text
// Parameters:
//   footer-text: custom text to display in the footer (hidden in anonymous mode)
//   number-prefix: prefix string prepended to the page number
// Returns: dictionary with "odd" and "even" keys containing footer content
#let kzn-footer(footer-text: none, number-prefix: none) = {
  return (
    odd: [
      #context(if show-private-content.get() { footer-text } + h(1fr) + number-prefix + counter(page).display())
    ],
    even: [
      #context(number-prefix + counter(page).display() + h(1fr) + if show-private-content.get() { footer-text })
    ],
  )
}


// ------------------------------------------------------------
// Outline Generation Functions
// ------------------------------------------------------------

// Render outlines (table of contents, list of figures, list of tables)
// at the specified position ("before" or "after" main matter)
// Parameters:
//   outline-def: outline configuration dictionary
//   layout-def: layout configuration dictionary
//   position: placement marker — either "before" or "after"
#let outlines(outline-def, layout-def, position) = {
  // Default visibility flags
  let toc = false
  let lof = false
  let lot = false

  // Default positions
  let toc-position = "before"
  let lof-position = "before"
  let lot-position = "before"

  // Default outline visibility in TOC itself
  let toc-outlined = true
  let lof-outlined = true
  let lot-outlined = true

  // Read configuration values if provided
  if exists("toc", outline-def) { toc = true }
  if exists("toc-position", outline-def) { toc-position = outline-def.toc-position }
  if exists("toc-outlined", outline-def) { toc-outlined = outline-def.toc-outlined }

  if exists("lof", outline-def) { lof = true }
  if exists("lof-position", outline-def) { lof-position = outline-def.lof-position }
  if exists("lof-outlined", outline-def) { lof-outlined = outline-def.lof-outlined }

  if exists("lot", outline-def) { lot = true }
  if exists("lot-position", outline-def) { lot-position = outline-def.lot-position }
  if exists("lot-outlined", outline-def) { lot-outlined = outline-def.lot-outlined }

  // Render table of contents
  if toc and toc-position == position {
    outline(
      title: [
        #set heading(outlined: toc-outlined)
        #set text(font: layout-def.mainFont, size: layout-def.font-size)
        #outline-def.toc
      ],
    )
    pagebreak(weak: true)
  }

  // Render list of figures
  if lof and lof-position == position {
    outline(
      title: [
        #set heading(outlined: lof-outlined)
        #set text(font: layout-def.mainFont, size: layout-def.font-size)
        #outline-def.lof
      ],
      target: figure.where(kind: figure),
    )
    pagebreak(weak: true)
  }

  // Render list of tables
  if lot and lot-position == position {
    outline(
      title: [
        #set heading(outlined: lot-outlined)
        #set text(font: layout-def.mainFont, size: layout-def.font-size)
        #outline-def.lot
      ],
      target: figure.where(kind: table),
    )
    pagebreak(weak: true)
  }
}

// Render outlines before the main matter using Roman page numbering
// Resets the page counter to 1 after the outlines
// Parameters:
//   outline-def: outline configuration dictionary
//   layout-def: layout configuration dictionary
#let outlines-before(outline-def, layout-def) = {
  let numbering = "i"
  if exists("numbering", outline-def) { numbering = outline-def.numbering }
  set page(numbering: numbering, header: none)
  outlines(outline-def, layout-def, "before")
  pagebreak(weak: true, to: "odd")
  counter(page).update(1)
}

// Render outlines after the main matter (e.g. before appendices)
// Parameters:
//   outline-def: outline configuration dictionary
//   layout-def: layout configuration dictionary
#let outlines-after(outline-def, layout-def) = {
  set page(header: none)
  outlines(outline-def, layout-def, "after")
}


// ------------------------------------------------------------
// Main Document Template Function
// ------------------------------------------------------------

// Main template entry point for academic documents
// Applies global page layout, typography, figure/table formatting,
// heading styles, and renders title page, frontmatter, outlines,
// and main content in the correct order
// Parameters:
//   layout-def: layout configuration dictionary
//   frontmatter-def: frontmatter configuration dictionary (abstracts, declarations, etc.)
//   titlepage-def: title page configuration dictionary
//   outline-def: outline configuration dictionary
//   doc: main document body content
#let ma(layout-def: none, frontmatter-def: none, titlepage-def: none, outline-def: none, doc) = {

  // ----------------------------------------------------------------
  // Page Layout
  // ----------------------------------------------------------------

  set page(
    paper: layout-def.paper,
    margin: layout-def.margin,
    numbering: layout-def.numbering,
    footer: context {
      if calc.odd(counter(page).get().first()) [
        #align(right)[#layout-def.footer.odd]
      ] else [
        #layout-def.footer.even
      ]
    },
    header: context { 
      if calc.odd(counter(page).get().first()) [
        #align(right)[#layout-def.header.odd]
      ] else [
        #layout-def.header.even
      ]
    },
  )

  // Activate copy protection (anonymization) if requested
  if layout-def.copystop {
    show-private-content.update(false)
  }

  // Replace images with a cross mark when private content is hidden
  show image: it => {
    if show-private-content.get() {
      it
    } else {
      [#emoji.crossmark]
    }
  }

  // Style of cross-references
  show ref: it => {
    if it.element == none {
      // Bibliography reference (@key) → normal
      it
    } else {
      // Label reference (@fig:..., @eq:..., etc.) → bold
      strong(it)
    }
  }

  // ----------------------------------------------------------------
  // Default Abbreviations for Figures, Tables, and Sections
  // ----------------------------------------------------------------

  let figure-short-str = "Abb."
  let table-short-str = "Tab."
  let sec-short-str = "Kap."

  if exists("fig-desc", layout-def) { figure-short-str = layout-def.fig-desc }
  if exists("tab-desc", layout-def) { table-short-str = layout-def.tab-desc }
  if exists("heading-desc", layout-def) { sec-short-str = layout-def.heading-desc }

  set heading(supplement: sec-short-str)

  // ----------------------------------------------------------------
  // Language and Region
  // ----------------------------------------------------------------

  let lang = "de"
  let reg = "CH"

  if exists("language", layout-def) { lang = layout-def.language }
  if exists("language-region", layout-def) { reg = layout-def.language-region }

  set text(lang: lang)
  set text(region: reg)

  // ----------------------------------------------------------------
  // Typography
  // ----------------------------------------------------------------

  let font = "New Computer Modern"
  let font-size = "11pt"

  if exists("mainFont", layout-def) { font = layout-def.mainFont }
  if exists("font-size", layout-def) { font-size = layout-def.font-size }

  set text(font: font)
  set text(size: font-size)

  // Math font
  let math-font = "Libertinus Math"
  if exists("mathFont", layout-def) { math-font = layout-def.mathFont }
  show math.equation: set text(font: math-font)

  // Hyperlink color
  let link-color = blue
  if exists("link-color", layout-def) { link-color = layout-def.link-color }
  show link: set text(rgb(link-color))

  // ----------------------------------------------------------------
  // Paragraph and List Formatting
  // ----------------------------------------------------------------

  set par(justify: true, leading: 1em)
  set par(spacing: 1.5em)

  show list: set block(above: 0.8em, below: 1.5em, inset: 0.2em)
  show enum: set block(above: 0.8em, below: 1.5em, inset: 0.2em)

  // ----------------------------------------------------------------
  // Heading Formatting
  // ----------------------------------------------------------------

  show heading: set block(above: 1.4em, below: 1em)
  set heading(numbering: "1.1")

  // Determine TOC depth — headings beyond this level are unnumbered
  let toc-depth = 3
  if exists("toc-depth", outline-def) { toc-depth = outline-def.toc-depth }
  set outline(depth: toc-depth)

  // Suppress numbering for headings deeper than toc-depth
  show heading: it => {
    if it.level > toc-depth {
      block(it.body)
    } else {
      it
    }
  }

  // Render references to deep headings as supplement + body (no number)
  show ref: it => {
    if it.element != none and it.element.func() == heading and it.element.level > toc-depth {
      [#it.element.supplement #it.element.body]
    } else {
      it
    }
  }

  // ----------------------------------------------------------------
  // Figure and Table Formatting
  // ----------------------------------------------------------------

  show figure: set place(clearance: 1em)
  show figure: set block(above: 2em, below: 2.5em)

  // Subfigure numbering style: (a), (b), ...
  show figure.where(kind: "subfigure"): set figure(
    supplement: "",
    numbering: it => {
      strong(str(counter(figure.where(kind: "subfigure")).display("(a)")))
    },
  )

  // Subfigure caption separator
  show figure.where(kind: "subfigure"): set figure.caption(separator: " ")

  // Render subfigures with hanging-indent caption layout
  show figure.where(kind: "subfigure"): it => {
    block(breakable: false, {
      it.body
      let fignum = ""
      let caption-body = ""
      let number-size-width = 0pt
      if type(it.caption) != type(none) {
        fignum = context it.caption.counter.display(it.numbering) + it.caption.separator
        let number-size = measure(fignum)
        caption-body = it.caption.body
        number-size-width = number-size.width
      }
      box(width: 90%, box(align(left)[
        #par(fignum + caption-body, hanging-indent: number-size-width + 1pt, justify: true)
      ]))
    })
  }

  // Render regular figures — reset subfigure counter and apply hanging-indent caption
  show figure.where(kind: figure): it => {
    counter(figure.where(kind: "subfigure")).update(0)
    block(breakable: false, {
      it.body
      let fignum = ""
      let caption-body = ""
      let number-size-width = 0pt
      if type(it.caption) != type(none) {
        fignum = it.caption.supplement + " " + context it.caption.counter.display(it.numbering) + it.caption.separator
        let number-size = measure(fignum)
        caption-body = it.caption.body
        number-size-width = number-size.width
      }
      box(width: 90%, box(align(left)[
        #par(fignum + caption-body, hanging-indent: number-size-width + 1pt, justify: true)
      ]))
    })
  }

  // Figure supplement label and numbering format
  show figure.where(kind: figure): set figure(
    supplement: it => { strong(figure-short-str) },
    numbering: it => { strong(str(counter(figure.where(kind: figure)).get().at(0))) },
  )

  // Table supplement label and numbering format
  show figure.where(kind: table): set figure(
    supplement: it => { strong(table-short-str) },
    numbering: it => { strong(str(counter(figure.where(kind: table)).get().at(0))) },
  )

  show figure.where(kind: table): it => {
    counter(figure.where(kind: "subfigure")).update(0)
    it
  }


  // ----------------------------------------------------------------
  // Title Page
  // ----------------------------------------------------------------

  if not is-empty(titlepage-def.content) {
    set heading(numbering: none, outlined: false)
    set page(numbering: none, footer: none, header: none)
    titlepage-def.content
    pagebreak(to: "odd")
    counter(heading).update(0)
    counter(page).update(1)
  }

  // ----------------------------------------------------------------
  // Frontmatter
  // ----------------------------------------------------------------

  if not is-empty(frontmatter-def.content) {
    set heading(numbering: none, outlined: false)

    let numbering = "i"
    if exists("numbering", frontmatter-def) { numbering = frontmatter-def.numbering }

    set page(numbering: numbering, header: none)

    // Apply custom footer if defined in frontmatter configuration
    if exists("footer", frontmatter-def) {
      set page(
        footer: context {
          if calc.odd(counter(page).get().first()) [
            #align(right)[#abstract_def.footer.odd]
          ] else [
            #abstract_def.footer.even
          ]
        },
      )
    }

    // Render each frontmatter section followed by a page break
    for item in frontmatter-def.content {
      item
      pagebreak(weak: true)
    }

    pagebreak(weak: true, to: "odd")
  }

  // ----------------------------------------------------------------
  // Outlines and Main Content
  // ----------------------------------------------------------------

  show outline: set text(font: layout-def.mainFont, size: layout-def.font-size)

  outlines-before(outline-def, layout-def)

  doc
}
