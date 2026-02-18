// Bologna University Economics Thesis Template (technically dept. agnostic)
//
// Provides two public functions:
//   - `thesis-cover`: renders a standalone cover page
//   - `thesis`:       full document setup (cover + abstract + ToC + body)
//
// Typical usage:
//
//   #import "@preview/simple-unibo-thesis:0.1.0": thesis
//
//   #show: thesis.with(
//     title: "My Dissertation",
//     author: "Jane Doe",
//     student-number: "1234567",
//     supervisor: "Prof. John Smith",
//     topic: "Economics",
//     degree: "Master's Degree",
//     department: "Department of Economics",
//     academic-year: "2024/2025",
//     graduation-month: "March",
//     abstract: [Your abstract text here.],
//   )
//
//   = Introduction
//   ...
//   #bibliography("references.bib", style: "apa")


/// Renders a formatted thesis cover page following the Bologna University
/// Economics Department layout.
///
/// Parameters:
///   title            - Full dissertation title displayed prominently on the cover.
///   author           - Candidate's first and last name.
///   student-number   - University matriculation / student ID number.
///   supervisor       - Supervisor's full name, including title (e.g. "Prof. Jane Doe").
///   co-supervisor    - Co-supervisor's full name and title; omit to skip.
///   graduation-month - Month of the graduation session (e.g. "March").
///   academic-year    - Academic year string (e.g. "2024/2025").
///   department       - Full department name as it appears on official documents.
///   topic            - Topic of the dissertation (e.g. "Economic Modeling").
///   university       - University name; defaults to the official Italian long form.
///   degree           - Degree type (e.g. "Master's Degree", "Bachelor's Degree").
///   degree-name      - Name of the Degree (e.g. "Economics and Econometrics")
///   cover-font       - Font family used on the cover page. Defaults to
///                      "New Computer Modern". The Econ dept. recommends Times New Roman.
///   layout           - Cover layout variant: "no-logo" (Economics dept. style) or
///                      "logo" (official UniBo style with seal image).
///   logo             - Logo content (e.g. `image("unibo.png")`). Only used
///                      when layout is "logo".
///   labels           - Named tuple of UI strings, allowing the cover to be
///                      localised without changing the layout logic. Fields:
///                        defended-by        – label above the candidate name
///                        supervisor         – label above the supervisor name
///                        co-supervisor      – label above the co-supervisor name
///                        in-word            – word between degree type and programme
///                        graduation-session – prefix for the graduation month line
///                        academic-year      – prefix for the academic year line
#let thesis-cover(
  title: "Dissertation Title",
  author: "Your first and last name",
  student-number: "Your student no.",
  supervisor: "Prof. [Supervisor's first and last name]",
  co-supervisor: none,
  graduation-session: "ZERO-TH",
  graduation-month: "GRADUATION MONTH",
  academic-year: "ACADEMIC YEAR",
  department: "NAME OF DEPARTMENT",
  topic: "TOPIC",
  university: "ALMA MATER STUDIORUM — UNIVERSITÀ DI BOLOGNA",
  degree: "DEGREE TYPE",
  degree-name: "DEGREE NAME",
  cover-font: "New Computer Modern",
  layout: "logo",
  logo: none,
  labels: (
    defended-by: "DEFENDED BY",
    supervisor: "SUPERVISOR",
    co-supervisor: "CO-SUPERVISOR",
    in-word: "in",
    dissertation: "Dissertation",
    graduation-session: "Graduation Session",
    academic-year: "Academic year",
  ),
) = {
  assert(
    layout in ("no-logo", "logo"),
    message: "Invalid Layout: choose between logo and no-logo",
  )
  if layout == "no-logo" {
    // Economics Department style guide
    page(
      margin: 2cm,
      numbering: none,
    )[
      #set align(center)
      #set text(font: cover-font, size: 12pt)

      #v(2cm)

      // University name, largest heading element on the page
      #text(size: 14pt, weight: "bold")[
        #university
      ]

      #v(3cm)

      // Department name
      #text(size: 13pt, weight: "bold")[
        #department
      ]

      #v(3cm)

      // Degree type and programme, separated by the localised "in" word
      #text(size: 11pt)[
        #degree
      ]

      #v(0.3cm)

      #text(size: 11pt)[#labels.in-word]

      #v(0.3cm)

      #text(size: 13pt, weight: "bold")[
        #degree-name
      ]

      #v(3cm)

      // Dissertation title
      #text(size: 13pt, weight: "bold")[
        #title
      ]

      #v(0.8cm)

      #text(size: 11pt)[#labels.dissertation #labels.in-word #topic]

      // Push the candidate/supervisor block and session info to the bottom
      #v(1fr)

      // Two-column layout: candidate info on the left, supervisor on the right
      #grid(
        columns: (1fr, 1fr),
        gutter: 2cm,
        [
          #set align(left)
          #text(size: 11pt, weight: "bold")[#labels.defended-by]

          #v(0.5cm)

          #text(size: 11pt)[#author]

          #v(0.3cm)

          #text(size: 11pt)[#student-number]
        ],
        [
          #set align(left)
          #text(size: 11pt, weight: "bold")[#labels.supervisor]

          #v(0.5cm)

          #text(size: 11pt)[#supervisor]

          #if co-supervisor != none {
            v(0.8cm)
            text(size: 11pt, weight: "bold")[#labels.co-supervisor]
            v(0.5cm)
            text(size: 11pt)[#co-supervisor]
          }
        ],
      )

      #v(2cm)

      // Graduation session and academic year footer
      #text(
        size: 11pt,
      )[#graduation-session #labels.graduation-session, #graduation-month]

      #v(0.5cm)

      #text(size: 11pt)[#labels.academic-year #academic-year]

      #v(1cm)
    ]
  } else {
    // --- Logo layout (official UniBo style) ---
    page(
      margin: 2cm,
      numbering: none,
    )[
      #set align(center)
      #set text(font: cover-font, size: 12pt)

      #v(0.5cm)

      // Seal / logo
      #if logo != none {
        set image(height: 5cm)
        logo
      }

      #v(0.3cm)

      #v(0.8cm)

      // Department name
      #text(size: 11pt)[#department]

      #v(0.5cm)

      // Degree type
      #text(size: 12pt, weight: "bold")[#degree]

      #v(0.3cm)

      #degree-name

      #v(0.8cm)

      // Dissertation title — larger and bold
      #text(size: 16pt, weight: "bold")[#title]

      #v(0.8cm)

      #text(size: 11pt)[#labels.dissertation #labels.in-word #topic]

      // Push candidate/supervisor block to the bottom
      #v(1fr)

      // Two-column layout: supervisor on left, candidate on right
      #grid(
        columns: (1fr, 1fr),
        gutter: 2cm,
        [
          #set align(left)
          #text(size: 10pt)[#labels.supervisor]
          #v(0.2cm)
          #text(size: 11pt, weight: "bold")[#supervisor]

          #if co-supervisor != none {
            v(0.5cm)
            text(size: 10pt)[#labels.co-supervisor]
            v(0.2cm)
            text(size: 11pt, weight: "bold")[#co-supervisor]
          }
        ],
        [
          #set align(right)
          #text(size: 10pt)[#labels.defended-by]
          #v(0.2cm)
          #text(size: 11pt, weight: "bold")[#author]
        ],
      )

      #v(1cm)

      // Horizontal rule + graduation session footer
      #line(length: 100%, stroke: 0.5pt)

      #v(0.3cm)

      #text(
        size: 10pt,
      )[#graduation-session #labels.graduation-session, #graduation-month, #academic-year]

      #v(0.5cm)
    ]
  }
}


/// Full thesis document setup. Apply with `#show: thesis.with(...)`.
///
/// Handles in order:
///   1. Document metadata (title, author)
///   2. Global page, text, and paragraph styles
///   3. Cover page (delegates to `thesis-cover`)
///   4. Optional abstract section
///   5. Optional table of contents
///   6. Main body with arabic page numbering starting at 1
///
/// Parameters:
///   title            - Dissertation title. Passed to both document metadata
///                      and the cover page.
///   university       - University name shown at the top of the cover.
///   degree           - Degree type (e.g. "Master's Degree").
///   topic          - Degree programme name.
///   author           - Candidate's full name.
///   student-number   - University matriculation number.
///   supervisor       - Supervisor's full name and title.
///   co-supervisor    - Co-supervisor's full name and title; omit to skip.
///   academic-year    - Academic year string (e.g. "2024/2025").
///   abstract         - Content block for the abstract. Pass `none` to omit.
///   abstract-title   - Heading text for the abstract section. Defaults to the
///                      locale-appropriate string from `labels`.
///   department       - Full department name.
///   graduation-month - Month of the graduation session.
///   font             - Body text font. The Econ dept. recommends Times New Roman;
///                      defaults to "New Computer Modern".
///   cover-font       - Font used on the cover page (may differ from body font).
///   layout           - Cover layout variant: "no-logo" or "logo".
///   logo             - Logo content (e.g. `image("unibo.png")`); used with "logo" layout.
///   toc              - Whether to render the table of contents. Default: true.
///   locale           - BCP-47 language code used both for Typst's text direction
///                      and to select built-in label translations. Currently
///                      supports "en" (default) and "it".
///   labels           - Override the auto-selected localised strings. When
///                      provided, `locale` is still passed to Typst's `set text`
///                      but label selection is skipped. Useful for languages
///                      other than "en"/"it" or for custom terminology. Fields
///                      mirror those of `thesis-cover.labels` plus
///                      `abstract-title`.
///   body             - The document body content (injected automatically by
///                      `#show: thesis.with(...)`).
#let thesis(
  title: "Dissertation Title",
  university: "ALMA MATER STUDIORUM — UNIVERSITÀ DI BOLOGNA",
  degree: "DEGREE TYPE",
  degree-name: "DEGREE NAME",
  topic: "TOPIC",
  author: "Your Name",
  student-number: "0000000",
  supervisor: "Prof. Supervisor Name",
  co-supervisor: none,
  academic-year: "ACADEMIC YEAR",
  abstract: none,
  abstract-title: none,
  department: "NAME OF DEPARTMENT",
  graduation-session: "ZERO-TH",
  graduation-month: "GRADUATION MONTH",
  font: "New Computer Modern",
  cover-font: "New Computer Modern",
  layout: "logo",
  logo: none,
  toc: true,
  locale: "en",
  labels: none,
  separate-abstract-toc: false,
  body,
) = {
  // Resolve localised UI strings. A caller-supplied `labels` dict takes
  // precedence over the built-in locale defaults.
  let locale-defaults = if locale == "it" {
    (
      defended-by: "CANDIDATO",
      supervisor: "RELATORE",
      co-supervisor: "CORRELATORE",
      in-word: "in",
      dissertation: "Tesi",
      graduation-session: "Sessione",
      academic-year: "Anno Accademico",
      abstract-title: "Abstract",
    )
  } else {
    // Default: English
    (
      defended-by: "DEFENDED BY",
      supervisor: "SUPERVISOR",
      co-supervisor: "CO-SUPERVISOR",
      in-word: "in",
      dissertation: "Dissertation",
      graduation-session: "Graduation Session",
      academic-year: "Academic year",
      abstract-title: "Abstract",
    )
  }

  let resolved-labels = if labels == none {
    locale-defaults
  } else {
    // Assert to catch typos when manually writing keys
    let bad-keys = labels.keys().filter(k => k not in locale-defaults)
    assert(
      bad-keys.len() == 0,
      message: "Unknown label keys: " + bad-keys.join(", "),
    )
    locale-defaults + labels
  }

  // Allow the caller to override just the abstract heading without providing
  // a full labels dict.
  let resolved-abstract-title = if abstract-title == none {
    resolved-labels.abstract-title
  } else {
    abstract-title
  }

  set document(
    title: title,
    author: author,
  )

  // Front matter uses Roman numerals; switched to arabic after the ToC.
  set page(
    paper: "a4",
    margin: 2cm,
    numbering: "I",
    number-align: center,
  )

  // The Econ dept. guidelines recommend Times New Roman at 12 pt.
  set text(
    font: font,
    size: 12pt,
    lang: locale,
  )

  set par(justify: true)
  set heading(numbering: "1.1")

  // --- Cover page ---
  thesis-cover(
    title: title,
    author: author,
    student-number: student-number,
    supervisor: supervisor,
    co-supervisor: co-supervisor,
    graduation-month: graduation-month,
    academic-year: academic-year,
    degree: degree,
    degree-name: degree-name,
    topic: topic,
    university: university,
    department: department,
    cover-font: cover-font,
    layout: layout,
    logo: logo,
    labels: resolved-labels,
    graduation-session: graduation-session,
  )

  // Unnumbered and unoutlined so the abstract doesn't appear in the ToC.
  if abstract != none {
    heading(
      level: 1,
      numbering: none,
      outlined: false,
    )[#resolved-abstract-title]
    abstract
    // Visual separator between the abstract and the ToC
    if toc {
      if separate-abstract-toc {
        pagebreak(weak: true)
      } else {
        line(length: 90%, stroke: 0.3pt)
      }
    }
  }

  // --- Table of contents ---
  if toc {
    outline()
  }

  // --- Main body ---
  // Switch to arabic page numbering and reset the counter to 1 so that the
  // first page of content is labelled "1".
  pagebreak(weak: true)
  set page(numbering: "1")
  counter(page).update(1)

  body
}
