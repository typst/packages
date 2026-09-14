// ─── Header ───────────────────────────────────────────────────────────────────

// Returns true if `secondary-heading` appears after `main-heading` in the
// document (comparing page number, then vertical position).
#let is-after(secondary-heading, main-heading) = {
  let sec-pos = secondary-heading.location().position()
  let main-pos = main-heading.location().position()

  if sec-pos.at("page") > main-pos.at("page") {
    true
  } else if sec-pos.at("page") == main-pos.at("page") {
    sec-pos.at("y") > main-pos.at("y")
  } else {
    false
  }
}

// Renders a centered, small-caps header with a full-width rule beneath it.
// Used when a level-1 heading starts on the current page.
#let build-main-header(content) = {
  align(center, smallcaps(content))
  line(length: 100%)
}

// Renders a two-column header (chapter title left, section title right) with a
// full-width rule beneath it. Used when a sub-heading is the most recent heading.
#let build-secondary-header(main-content, secondary-content) = {
  smallcaps(main-content)
  h(1fr)
  emph(secondary-content)
  line(length: 100%)
}

// Selects the appropriate header for the current page at render time:
//   - If a level-1 heading starts on this page, show it centered.
//   - Otherwise, if the most recent sub-heading follows the most recent
//     level-1 heading, show the two-column secondary format.
//   - Otherwise, fall back to the centered level-1 heading.
#let create-dynamic-header() = {
  let loc = here()

  // Try to use level 1 heading from current page
  let next-main-heading = query(selector(heading).after(loc)).find(h => (
    h.location().page() == loc.page() and h.level == 1
  ))

  if next-main-heading != none {
    build-main-header(next-main-heading.body)
  } else {
    // Fall back to most recent level 1 heading
    let last-main-heading = query(selector(heading).before(loc)).filter(h => h.level == 1).last()

    // Find most recent secondary heading
    let previous-secondary-headings = query(selector(heading).before(loc)).filter(h => h.level > 1)

    let last-secondary-heading = if previous-secondary-headings.len() != 0 {
      previous-secondary-headings.last()
    } else {
      none
    }

    // Choose header format based on heading positions
    if last-secondary-heading != none and is-after(last-secondary-heading, last-main-heading) {
      build-secondary-header(last-main-heading.body, last-secondary-heading.body)
    } else {
      build-main-header(last-main-heading.body)
    }
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────

// Renders a full-width rule, a centered page counter, and a logo aligned to the
// right. Pass `show-page-total: false` to show only the current page number.
#let create-footer(logo-small, show-page-total: true) = {
  line(length: 100%)
  place(center + horizon)[
    #text(
      1.2em,
      counter(page).display(
        "1 / 1",
        both: show-page-total,
      ),
    )
  ]
  place(right + horizon, image(logo-small, width: 10%))
}

// ─── Page components ──────────────────────────────────────────────────────────

// Renders the title page: logo, department, course, document type, title,
// author grid, optional adviser grid, and date. Ends with a page break.
#let create-title-page(
  logo,
  logo-width,
  department,
  course-name,
  course-code,
  document-type,
  title,
  authors,
  author-columns,
  advisers,
  adviser-columns,
  font,
  date,
) = {
  set par(justify: false)

  v(1em)
  set text(font: ("Open Sans", font), lang: "en")

  // Logo
  if logo != none {
    align(center, image(logo, width: logo-width))
  }

  // Department and course information
  if department != none {
    align(center, text(1.4em, department))
  }

  let course = if course-name != none and course-code != none {
    course-name + " - " + course-code
  } else if course-code != none {
    course-code
  } else if course-name != none {
    course-name
  } else {
    ""
  }

  if course != "" {
    if department != none {
      v(-0.5em)
    }
    align(center, text(1.4em, course))
  }

  v(4em)
  set text(font: font, lang: "en")

  // Document type and title
  if document-type != none {
    align(center, text(1.6em, document-type))
    v(1em)
  } else {
    v(4em)
  }

  align(center, text(2.6em, weight: "bold", title))

  // Authors section
  align(
    center,
    [
      #line(length: 60%, stroke: 0.5pt + gray)
      #v(1em)
      #text(1.2em, smallcaps[By])
      #v(1em)
    ],
  )

  let author-columns = calc.min(author-columns, authors.len())
  grid(
    columns: (1fr,) * author-columns,
    gutter: 2em,
    ..authors.map(author => align(
      center,
      text(
        1.2em,
        [
          *#author.name* \
          #author.email
        ],
      ),
    ))
  )

  v(8em)

  // Advisers section (if any)
  if advisers.len() > 0 {
    align(center, text(1.2em, smallcaps[Advised by]))
    v(0.8em)

    let adviser-columns = calc.min(adviser-columns, advisers.len())
    grid(
      columns: (1fr,) * adviser-columns,
      gutter: 2em,
      ..advisers.map(adviser => align(
        center,
        text(
          1.2em,
          [
            *#adviser.name* \
            #adviser.email
          ],
        ),
      ))
    )
  }

  place(bottom + center, text(1.2em, date))

  set par(justify: true)

  pagebreak()
}

// Renders the abstract on its own page with roman-numeral page numbering,
// resets the page counter to 1, then page-breaks into the TOC.
#let create-abstract-page(abstract) = {
  set page(numbering: "I", number-align: center, margin: 10em)
  v(1fr)
  align(center, heading(outlined: false, numbering: none, text(0.85em, smallcaps[Abstract])))
  abstract
  v(1.618fr)

  counter(page).update(1)
  pagebreak()
}

// Renders the table of contents (up to depth 3) followed by a page break.
#let create-toc-page() = {
  outline(depth: 3)
  pagebreak()
}

// ─── Body helpers ─────────────────────────────────────────────────────────────

// Wraps `body` in a show rule that inserts a weak page break before every
// level-1 heading after the first one, keeping sections on fresh pages.
#let setup-section-page-breaks(body) = {
  let section-counter = counter("section-counter")

  show heading: it => {
    if it.level == 1 {
      let count = section-counter.get().at(0, default: 0)
      section-counter.step()

      if count > 0 {
        pagebreak(weak: true)
      }

      it
    } else {
      it
    }
  }

  body
}

// Validates and normalises a glossary dictionary (typically loaded from
// `glossary.yaml`) into the list of entry dictionaries expected by the
// glossarium package. Asserts on unknown keys or wrong value types.
#let read-glossary-entries(entries) = {
  let file-name = "glossary.yaml"

  assert(
    type(entries) == dictionary,
    message: "The glossary `" + file-name + "` is not a dictionary",
  )

  for (k, v) in entries.pairs() {
    assert(
      type(v) == dictionary,
      message: "The glossary entry `" + k + "` in `" + file-name + "` is not a dictionary",
    )

    for key in v.keys() {
      assert(
        key
          in (
            "short",
            "long",
            "description",
            "group",
            "plural",
            "longplural",
            "artshort",
            "artlong",
          ),
        message: "Found unexpected key `" + key + "` in glossary entry `" + k + "` in `" + file-name + "`",
      )
    }

    // assert(
    //   type(v.short) == str,
    //   message: "The short form of glossary entry `" + k + "` in `" + file + "` is not a string",
    // )

    if "long" in v {
      assert(
        type(v.long) == str,
        message: "The long form of glossary entry `" + k + "` in `" + file-name + "` is not a string",
      )
    }

    if "description" in v {
      assert(
        type(v.description) == str,
        message: "The description of glossary entry `" + k + "` in `" + file-name + "` is not a string",
      )
    }

    if "group" in v {
      assert(
        type(v.group) == str,
        message: "The optional group of glossary entry `" + k + "` in `" + file-name + "` is not a string",
      )
    }
  }

  return entries
    .pairs()
    .map(((key, entry)) => (
      key: key,
      short: eval(entry.at("short", default: ""), mode: "markup"),
      long: eval(entry.at("long", default: ""), mode: "markup"),
      description: eval(entry.at("description", default: ""), mode: "markup"),
      group: entry.at("group", default: ""),
      // file: file,
    ))
}

// ─── Main entry point ─────────────────────────────────────────────────────────

// The top-level template function. Call this from `main.typ` to apply all
// document styling and structure. Renders (in order):
//   1. Title page
//   2. Abstract page (roman numerals)
//   3. Table of contents
//   4. Body content with running header/footer (arabic numerals)
#let academic-document(
  logo: "logos/logo.png",
  logo-dark-mode: "logos/logo-dark-mode.png",
  logo-small: "logos/logo-small.png",
  logo-small-dark-mode: "logos/logo-small-dark-mode.png",
  logo-width: 70%,
  document-type: none,
  department: none,
  course-name: none,
  course-code: none,
  title: "",
  abstract: [],
  authors: (),
  author-columns: 3,
  advisers: (),
  adviser-columns: 3,
  font: "New Computer Modern",
  show-page-total: true,
  date: datetime.today().display("[month repr:long] [day], [year]"),
  page-break-after-sections: true,
  dark-mode: false,
  body,
) = {
  // Document metadata and base typography
  set document(author: authors.map(a => a.name), title: title)
  show math.equation: it => set text(weight: 400)
  set heading(numbering: "1.1")
  set par(justify: true, first-line-indent: 20pt)

  // Dark mode: invert page/text colours and adjust link and table stroke colours
  set page(fill: if dark-mode { black } else { white })
  set text(fill: if dark-mode { white } else { black })
  let link-fill = if dark-mode { blue.lighten(60%) } else { blue.darken(60%) }
  show link: set text(fill: link-fill)
  show ref: set text(fill: link-fill)
  set table(stroke: if dark-mode { white } else { black })

  // Create title page
  create-title-page(
    if dark-mode { logo-dark-mode } else { logo },
    logo-width,
    department,
    course-name,
    course-code,
    document-type,
    title,
    authors,
    author-columns,
    advisers,
    adviser-columns,
    font,
    date,
  )

  // Create abstract page
  create-abstract-page(abstract)

  // Create table of contents
  create-toc-page()

  // Switch to arabic page numbers with running header and footer
  set page(
    header: context create-dynamic-header(),
    footer: context create-footer(
      if dark-mode { logo-small-dark-mode } else { logo-small },
      show-page-total: show-page-total,
    ),
  )

  counter(page).update(1)

  set page(numbering: "1") // to change the numbering style, look at `create-footer`

  // Apply section page breaks and render body
  if page-break-after-sections {
    setup-section-page-breaks(body)
  } else {
    body
  }
}
