#import "styles_modern.typ"
#import "styles_classic.typ"
#import "i18n.typ": i18n
#import "titlepage.typ": titlepage
#import "sections.typ": *
#import "constants.typ": THESIS_STYLE, WORK_TYPES

/// Wraps the document in the full-thesis template. This includes a title page and various other sections common in theses.
/// You must have configured the document data in the main document (title, author, description, keywords) before using this template. E.g. ```typ
/// #set document(
///   title: "Thesis Title",
///   author: "Author Name",
///   description: "Thesis Description",
///   keywords: ("Keyword 1 ", "Keyword 2"),  // Optional, only used in PDF Metadata
/// )
/// ```
///
/// You may find yourself needing to configure some styles to your liking. This can be done by passing an appropiate styling function for the acording section. Example - Styling the table header in the abbreviations section to be gray:
/// ```typ
/// #show: full-thesis.with(
///   ...
///   abbreviations-style: it => {
///     set table(fill: (x, y) => if y == 0 { gray })
///     it
///   }
/// )
/// ```
/// The styles cover the following sections:
/// - global-style: Style global settings like fonts, page margins, language, etc.
/// - document-style: Style the entire text document (same as global-style apart title page)
/// - content-style: Style the main content of the document. That is everthing after applying the template `#show: full-thesis.with(...)`
/// - others: The other styles covern their respective sections and are further documented as parameters.
///
/// For highly advanced usecases, you can also clone the template repository from #link("https://github.com/timerertim/hagenberg-thesis-template", "GitHub") and adjust it as needed for your project requirements.
///
///
/// - include-tableoutline (auto, true, false): `auto` includes a table outline if there is at least one table in the document,`true` forces to display an outline and `false` deactivates entirely.
/// - include-figureoutline (auto, true, false): `auto` includes a figure outline if there is at least one figure in the document,`true` forces to display an outline and `false` deactivates entirely.
/// - include-declaration (true, false): `true` includes a declaration page, `false` deactivates entirely.
/// - include-print-size-control (true, false): `true` includes a print size control box at the end, `false` deactivates entirely.
///
/// - thesis-style (classic, modern): Select the base style for the thesis. `classic` is the default style and `modern` is a more modern approach. Use THESIS_STYLE.classic or THESIS_STYLE.modern.
///
/// - global-style (): Style global settings like fonts, page margins, language, etc.
/// - document-style (): Style the entire text document (same as global-style apart title page)
/// - declaration-style (): Style for the declaration page.
/// - acknowledgement-style (): Style for the acknowledgement section.
/// - abstract-style (): Style for the abstract section. Will also be applied to the kurzfassung section (to ensure consistency).
/// - preamble-style (): Style for the preamble section.
/// - outline-style (): Style for all outline sections. Will be applied to chapter, table and figure outlines.
/// - abbreviations-style (): Style for the abbreviations section.
/// - content-style (): Style the main content of the document. That is everthing after applying the template `#show: full-thesis.with(...)`
/// - bibliography-style (): Style for the bibliography section.
/// - appendix-style (): Style for the appendix section.
///
/// - abbreviations (dict): List of abbreviations to display in the abbreviations section. Form (\<abbreviation>: \<description-content>). Example: (`(AI: "Artificial Intelligence")`). If empty, no abbreviations section is displayed.
/// - bibl (content): The bibliography to display. Citation style can be manually overriden here: `#bibliography("...", style: "ieee")`
#let full-thesis(
  // Sections with content
  titlepage: titlepage(
    "Computer Science",
    "Dr. Max Mentorman",
    work-type: WORK_TYPES.bachelor-thesis,
  ),
  acknowledgement: none,
  abstract: [],
  kurzfassung: [],
  appendix: none,
  preamble: none,

  // Feature toggles
  include-tableoutline: auto,
  include-figureoutline: auto,
  include-declaration: true,
  include-print-size-control: false,

  // Thesis base style
  thesis-style: THESIS_STYLE.classic,

  // Styles
  global-style: it => it,
  document-style: it => it,
  declaration-style: it => it,
  acknowledgement-style: it => it,
  abstract-style: it => it,
  preamble-style: it => it,
  outline-style: it => it,
  abbreviations-style: it => it,
  content-style: it => it,
  bibliography-style: it => it,
  appendix-style: it => it,

  // Abbreviations
  abbreviations: (:),

  // Bibliography
  bibl: none,

  doc,
) = context {
  let default-styles = if thesis-style == THESIS_STYLE.modern {
    styles_modern
  } else { styles_classic }

  // Define global styles that exist everywhere in the document (like fonts, page size, etc.)
  show: default-styles.global-style
  show: global-style
  // Show titlepage
  if titlepage != none {
    titlepage-section(titlepage)
  }

  // Setup document-wide styles that cover normal text content (everything apart title page)
  show: default-styles.document-style
  show: document-style

  // Declaration page with styles applied
  let declaration = if include-declaration {
    declaration-page(
      style-preface: declaration-style,
      thesis-style: thesis-style,
    )
  }

  // Acknowledgement section with styles applied if applicable
  let acknowledgement = if acknowledgement != none {
    acknowledgement-section(
      acknowledgement,
      style-preface: acknowledgement-style,
      thesis-style: thesis-style,
    )
  }

  // Kurzfassung section with styles applied
  let kurzfassung = if kurzfassung != none {
    kurzfassung-section(
      kurzfassung,
      style-preface: abstract-style,
      thesis-style: thesis-style,
    )
  }

  // Abstract section with styles applied
  let abstract = if abstract != none {
    abstract-section(
      abstract,
      style-preface: abstract-style,
      thesis-style: thesis-style,
    )
  }

  // Preamble section with styles applied if applicable
  let preamble = if preamble != none {
    preamble-section(
      preamble,
      style-preface: preamble-style,
      thesis-style: thesis-style,
    )
  }

  // Depending on document language, show different order
  let abstracts = if text.lang == "de" {
    (kurzfassung, abstract)
  } else {
    (abstract, kurzfassung)
  }

  // Chapter outline with styles applied
  let chapter-outline = chapter-outline(
    style-preface: outline-style,
    thesis-style: thesis-style,
  )

  // Abbreviations section with styles applied if applicable
  let abbreviations = if abbreviations.len() >= 1 {
    abbreviations-section(
      abbreviations,
      style-preface: abbreviations-style,
      thesis-style: thesis-style,
    )
  }

  // Content with styles applied
  let content = {
    show: default-styles.content-style
    show: content-style
    doc
  }

  // Figure outline with styles applied if applicable (forced or if there is at least one non-table figure)
  let figure-outline = context if (
    include-figureoutline == true
      or (
        include-figureoutline == auto
          and query(figure.where(outlined: true)).len()
            - query(figure.where(kind: table, outlined: true)).len()
            >= 1
      )
  ) {
    figure-outline(style-preface: outline-style, thesis-style: thesis-style)
  }

  // Table outline with styles applied if applicable (forced or if there is at least one table)
  let table-outline = context if (
    include-tableoutline == true
      or (
        include-tableoutline == auto
          and query(figure.where(kind: table, outlined: true)).len() >= 1
      )
  ) {
    table-outline(style-preface: outline-style, thesis-style: thesis-style)
  }

  // Bibliography section with styles applied
  let bibliography = if bibl != none {
    bibliography-section(
      bibl,
      style-preface: bibliography-style,
      thesis-style: thesis-style,
    )
  }

  // Appendix section with styles applied if applicable
  let appendix = if appendix != none {
    appendix-section(
      appendix,
      style-preface: appendix-style,
      thesis-style: thesis-style,
    )
  }

  // Ordering per thesis-base-style
  let section-order = if thesis-style == THESIS_STYLE.modern {
    (
      declaration,
      acknowledgement,
      ..abstracts,
      preamble,
      chapter-outline,
      abbreviations,
      content,
      figure-outline,
      table-outline,
      bibliography,
      appendix,
    )
  } else {
    (
      declaration,
      acknowledgement,
      preamble,
      ..abstracts,
      chapter-outline,
      content,
      appendix,
      bibliography,
      abbreviations,
      figure-outline,
      table-outline,
    )
  }

  // Show sections in order
  section-order.filter(it => it != none).join(pagebreak())

  // Print size control box
  if include-print-size-control {
    _print-size-control-box()
  }
}
