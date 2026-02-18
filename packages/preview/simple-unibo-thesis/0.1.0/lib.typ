// Bologna University Economics Thesis Template (technically dept. agnostic)
//
// Provides two public functions:
//   - `thesis_cover`: renders a standalone cover page
//   - `thesis`:       full document setup (cover + abstract + ToC + body)
//
// Typical usage:
//
//   #import "@preview/simple-unibo-thesis:0.1.0": thesis
//
//   #show: thesis.with(
//     title: "My Dissertation",
//     author: "Jane Doe",
//     student_number: "1234567",
//     supervisor: "Prof. John Smith",
//     program: "Economics",
//     degree: "Master's Degree",
//     department: "Department of Economics",
//     academic_year: "2024/2025",
//     graduation_month: "March",
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
///   student_number   - University matriculation / student ID number.
///   supervisor       - Supervisor's full name, including title (e.g. "Prof. Jane Doe").
///   graduation_month - Month of the graduation session (e.g. "March").
///   academic_year    - Academic year string (e.g. "2024/2025").
///   department       - Full department name as it appears on official documents.
///   program          - Degree programme name (e.g. "Economics and Finance").
///   university       - University name; defaults to the official Italian long form.
///   degree           - Degree type (e.g. "Master's Degree", "Bachelor's Degree").
///   cover_font       - Font family used on the cover page. Defaults to
///                      "New Computer Modern". The Econ dept. recommends Times New Roman.
///   labels           - Named tuple of UI strings, allowing the cover to be
///                      localised without changing the layout logic. Fields:
///                        defended_by       – label above the candidate name
///                        supervisor        – label above the supervisor name
///                        in_word           – word between degree type and programme
///                        graduation_session – prefix for the graduation month line
///                        academic_year     – prefix for the academic year line
#let thesis_cover(
  title: "Dissertation Title",
  author: "Your first and last name",
  student_number: "Your student no.",
  supervisor: "Prof. [Supervisor's first and last name]",
  graduation_month: "GRADUATION MONTH",
  academic_year: "ACADEMIC YEAR",
  department: "NAME OF DEPARTMENT",
  program: "PROGRAM NAME",
  university: "ALMA MATER STUDIORUM - UNIVERSITA' DI BOLOGNA",
  degree: "DEGREE TYPE",
  cover_font: "New Computer Modern",
  labels: (
    defended_by: "DEFENDED BY",
    supervisor: "SUPERVISOR",
    in_word: "in",
    graduation_session: "Graduation session of",
    academic_year: "Academic year",
  ),
) = {
  // Cover page, no page numbering
  page(
    margin: 2cm,
    numbering: none,
  )[
    #set align(center)
    #set text(font: cover_font, size: 12pt)

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

    #text(size: 11pt)[#labels.in_word]

    #v(0.3cm)

    #text(size: 13pt, weight: "bold")[
      #program
    ]

    #v(3cm)

    // Dissertation title
    #text(size: 13pt, weight: "bold")[
      #title
    ]

    // Push the candidate/supervisor block and session info to the bottom
    #v(1fr)

    // Two-column layout: candidate info on the left, supervisor on the right
    #grid(
      columns: (1fr, 1fr),
      gutter: 2cm,
      [
        #set align(left)
        #text(size: 11pt, weight: "bold")[#labels.defended_by]

        #v(0.5cm)

        #text(size: 11pt)[#author]

        #v(0.3cm)

        #text(size: 11pt)[#student_number]
      ],
      [
        #set align(left)
        #text(size: 11pt, weight: "bold")[#labels.supervisor]

        #v(0.5cm)

        #text(size: 11pt)[#supervisor]
      ],
    )

    #v(2cm)

    // Graduation session and academic year footer
    #text(size: 11pt)[#labels.graduation_session #graduation_month]

    #v(0.5cm)

    #text(size: 11pt)[#labels.academic_year #academic_year]

    #v(1cm)
  ]
}


/// Full thesis document setup. Apply with `#show: thesis.with(...)`.
///
/// Handles in order:
///   1. Document metadata (title, author)
///   2. Global page, text, and paragraph styles
///   3. Cover page (delegates to `thesis_cover`)
///   4. Optional abstract section
///   5. Optional table of contents
///   6. Main body with arabic page numbering starting at 1
///
/// Parameters:
///   title            - Dissertation title. Passed to both document metadata
///                      and the cover page.
///   university       - University name shown at the top of the cover.
///   degree           - Degree type (e.g. "Master's Degree").
///   program          - Degree programme name.
///   author           - Candidate's full name.
///   student_number   - University matriculation number.
///   supervisor       - Supervisor's full name and title.
///   academic_year    - Academic year string (e.g. "2024/2025").
///   abstract         - Content block for the abstract. Pass `none` to omit.
///   abstract_title   - Heading text for the abstract section. Defaults to the
///                      locale-appropriate string from `labels`.
///   department       - Full department name.
///   graduation_month - Month of the graduation session.
///   font             - Body text font. The Econ dept. recommends Times New Roman;
///                      defaults to "New Computer Modern".
///   cover_font       - Font used on the cover page (may differ from body font).
///   toc              - Whether to render the table of contents. Default: true.
///   locale           - BCP-47 language code used both for Typst's text direction
///                      and to select built-in label translations. Currently
///                      supports "en" (default) and "it".
///   labels           - Override the auto-selected localised strings. When
///                      provided, `locale` is still passed to Typst's `set text`
///                      but label selection is skipped. Useful for languages
///                      other than "en"/"it" or for custom terminology. Fields
///                      mirror those of `thesis_cover.labels` plus
///                      `abstract_title`.
///   body             - The document body content (injected automatically by
///                      `#show: thesis.with(...)`).
#let thesis(
  title: "Dissertation Title",
  university: "ALMA MATER STUDIORUM — UNIVERSITÀ DI BOLOGNA",
  degree: "DEGREE TYPE",
  program: "PROGRAM NAME",
  author: "Your Name",
  student_number: "0000000",
  supervisor: "Prof. Supervisor Name",
  academic_year: "2013/2014",
  abstract: none,
  abstract_title: none,
  department: "NAME OF DEPARTMENT",
  graduation_month: "GRADUATION MONTH",
  font: "New Computer Modern",
  cover_font: "New Computer Modern",
  toc: true,
  locale: "en",
  labels: none,
  separate_abstract_toc: false,
  body,
) = {
  // Resolve localised UI strings. A caller-supplied `labels` dict takes
  // precedence over the built-in locale defaults.
  let resolved_labels = if labels == none {
    if locale == "it" {
      (
        defended_by: "CANDIDATO",
        supervisor: "RELATORE",
        in_word: "in",
        graduation_session: "Sessione di Laurea:",
        academic_year: "Anno Accademico",
        abstract_title: "Abstract",
      )
    } else {
      // Default: English
      (
        defended_by: "DEFENDED BY",
        supervisor: "SUPERVISOR",
        in_word: "in",
        graduation_session: "Graduation session of",
        academic_year: "Academic year",
        abstract_title: "Abstract",
      )
    }
  } else {
    labels
  }

  // Allow the caller to override just the abstract heading without providing
  // a full labels dict.
  let resolved_abstract_title = if abstract_title == none {
    resolved_labels.abstract_title
  } else {
    abstract_title
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
  thesis_cover(
    title: title,
    author: author,
    student_number: student_number,
    supervisor: supervisor,
    graduation_month: graduation_month,
    academic_year: academic_year,
    degree: degree,
    program: program,
    university: university,
    department: department,
    cover_font: cover_font,
    labels: resolved_labels,
  )

  // Unnumbered and unoutlined so the abstract doesn't appear in the ToC.
  if abstract != none {
    heading(
      level: 1,
      numbering: none,
      outlined: false,
    )[#resolved_abstract_title]
    abstract
    // Visual separator between the abstract and the ToC
    if toc {
      if separate_abstract_toc {
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
