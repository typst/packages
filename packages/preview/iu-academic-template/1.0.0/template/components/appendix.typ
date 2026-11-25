/*
 * ============================================================
 * APPENDIX COMPONENT
 * ============================================================
 *
 * Provides:
 * - Main appendices and optional subsections
 * - Configurable appendix numbering
 * - Automatic appendix list with page numbers
 * - Appendix state shared with figures and tables
 *
 * The document's page numbering continues unchanged.
 * ============================================================
 */


// ------------------------------------------------------------
// STATE AND COUNTERS
// ------------------------------------------------------------

// Public: imported by the figure and table components.
#let appendix-mode = state("template-appendix-mode", false)

#let appendix-counter = counter("template-appendix")
#let appendix-section-counter = counter("template-appendix-section")

// Internal settings for the currently active main appendix.
#let _has-intro = state("template-appendix-has-intro", false)
#let _numbering-pattern = state("template-appendix-numbering", "A1")


// ------------------------------------------------------------
// SHARED HELPERS
// ------------------------------------------------------------

#let _appendix-label(language) = if language == "de" {
  "Anhang"
} else {
  "Appendix"
}


#let _render-heading(title, number, level, label, language) = {
  let prefix = _appendix-label(language)

  // Use the appendix number for native cross-references.
  let heading-content = heading(
    level: level,
    numbering: (..numbers) => number,
    supplement: [#prefix],
    outlined: false,
  )[#prefix #number: #title]

  // Attach the optional reference label.
  let labeled-heading = if label == none {
    heading-content
  } else {
    [#heading-content#label]
  }

  [
    // The number is already included in the heading body.
    // Suppress the additional automatic number.
    #show heading: it => block(it.body)

    #labeled-heading
  ]
}


#let _register-entry(level, number, title) = [
  #metadata((
    level: level,
    number: number,
    title: title,
  )) <appendix-entry>
]


// ============================================================
// MAIN APPENDIX
// ============================================================
//
// An appendix always starts on a new page.
//
// If intro is provided, the first subsection also starts on
// a new page. Without intro, it may follow the main heading.
//
// Example:
// #insert-appendix(
//   [Research Materials],
//   intro: [A short description of the materials.],
// )[
//   #insert-appendix-section([Questionnaire])[
//     Questionnaire content.
//   ]
// ]

#let insert-appendix(
  title,
  body,
  label: none,
  language: none,
  intro: none,
  numbering-pattern: none,
) = {
  assert(
    type(numbering-pattern) == str,
    message: "Appendix numbering must be a pattern string.",
  )

  [
    // Every main appendix starts on a new page.
    #pagebreak(weak: true)

    // Activate appendix mode and advance the counters.
    #appendix-mode.update(true)
    #appendix-counter.step()
    #appendix-section-counter.update(0)

    // Reset the dedicated appendix figure and table counters.
    // Main-text counters remain untouched for continuous numbering.
    #counter(figure.where(kind: "iu-appendix-image")).update(0)
    #counter(figure.where(kind: "iu-appendix-table")).update(0)

    // Store settings for nested appendix sections.
    #_has-intro.update(intro != none)
    #_numbering-pattern.update(numbering-pattern)

    #context {
      let number = numbering(
        numbering-pattern,
        appendix-counter.get().first(),
      )

      [
        #_register-entry(1, number, title)
        #_render-heading(title, number, 1, label, language)
      ]
    }

    // An optional introduction belongs to the main appendix.
    #if intro != none [
      #intro
    ]

    // The body may contain subsections or direct content.
    #body
  ]
}


// ============================================================
// APPENDIX SECTION
// ============================================================
//
// The first section shares its main appendix's first page
// only when no introduction was provided.
// All subsequent sections start on new pages.

#let insert-appendix-section(
  title,
  body,
  label: none,
  language: none,
) = [
  // Decide before advancing the subsection counter.
  #context {
    assert(
      appendix-mode.get(),
      message: "An appendix section requires a main appendix.",
    )

    let previous-sections = appendix-section-counter.get().first()

    if _has-intro.get() or previous-sections > 0 {
      pagebreak(weak: true)
    }
  }

  #appendix-section-counter.step()

  #context {
    let number = numbering(
      _numbering-pattern.get(),
      appendix-counter.get().first(),
      appendix-section-counter.get().first(),
    )

    [
      #_register-entry(2, number, title)
      #_render-heading(title, number, 2, label, language)
    ]
  }

  #body
]


// ============================================================
// LIST OF APPENDICES
// ============================================================
//
// enabled: true   -> Show if at least one appendix exists.
// enabled: false  -> Never show the list.
// enabled: "auto" -> Show if at least two main appendices exist.
//
// The list includes main appendices and sections, each with
// a link and its automatically resolved logical page number.
// The list heading appears in the main table of contents.

#let render-list-of-appendices(
  enabled: "auto",
  language: "de",
) = {
  let list-title = if language == "de" {
    [Anhangsverzeichnis]
  } else {
    [List of Appendices]
  }

  let prefix = _appendix-label(language)

  context {
    let entries = query(<appendix-entry>)
    let main-count = entries.filter(
      entry => entry.value.level == 1,
    ).len()

    let show-list = if enabled == "auto" {
      main-count >= 2
    } else {
      enabled and main-count > 0
    }

    if show-list [
      // Position the list immediately before the appendices.
      #pagebreak(weak: true)

      // Include the list heading in the main table of contents.
      #heading(
        numbering: none,
        outlined: true,
      )[#list-title]

      #for entry in entries {
        let data = entry.value
        let target = entry.location()

        let entry-title = [
          #prefix #(data.number): #(data.title)
        ]

        let linked-title = link(target, entry-title)
        let linked-page = link(
          target,
          counter(page).display("1", at: target),
        )

        let row = grid(
          columns: (auto, 1fr, auto),
          column-gutter: 0.5em,
          if data.level == 1 {
            strong(linked-title)
          } else {
            linked-title
          },
          repeat(gap: 0.15em)[.],
          linked-page,
        )

        if data.level == 1 [
          #block(below: 6pt)[#row]
        ] else [
          #block(below: 6pt)[
            #pad(left: 1em)[#row]
          ]
        ]
      }
    ]
  }
}