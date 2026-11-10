#import "styles.typ" as default-styles
#import "i8n.typ": i8n, i8n-declaration-page
#import "sections.typ": *

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
/// For more advanced usecases, you can also clone the template repository from #link("https://github.com/timerertim/hagenberg-thesis-template", "GitHub") and adjust it as needed for your project requirements.
///
/// - course-of-study (string): The course of study to display in the title page.
/// - schoolyear (string): The school year to display in the title page.
/// - mentor-name (string): The name of the mentor to display in the title page.
/// - work-type (string): The type of work to display in the title page. Either "bachelor-thesis" or "master-thesis" currently.
///
/// - include-tableoutline (auto, true, false): `auto` includes a table outline if there is at least one table in the document,`true` forces to display an outline and `false` deactivates entirely.
/// - include-figureoutline (auto, true, false): `auto` includes a figure outline if there is at least one figure in the document,`true` forces to display an outline and `false` deactivates entirely.
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
  // General settings
  course-of-study,
  schoolyear,
  mentor-name,
  work-type: "bachelor-thesis",

  // Sections with content
  acknowledgement: none,
  abstract: [],
  kurzfassung: [],
  appendix: none,
  preamble: none,

  // Feature toggles
  include-tableoutline: auto,
  include-figureoutline: auto,

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
) = {
  // Define global styles that exist everywhere in the document (like fonts, page size, etc.)
  show: default-styles.global-style
  show: global-style
  // Show titlepage
  titlepage-section(
    course-of-study,
    schoolyear,
    mentor-name,
    work-type,
  )
  pagebreak()

  // Setup document-wide styles that cover normal text content (everything apart title page)
  show: default-styles.document-style
  show: document-style

  // Show declaration page with styles applied
  declaration-page(style-preface: declaration-style)

  // Show acknowledgement section with styles applied if applicable
  if acknowledgement != none {
    pagebreak()
    acknowledgement-section(
      acknowledgement,
      style-preface: acknowledgement-style,
    )
  }

  // Show kurzfassung section with styles applied
  pagebreak()
  kurzfassung-section(kurzfassung, style-preface: abstract-style)

  // Show abstract section with styles applied
  pagebreak()
  abstract-section(abstract, style-preface: abstract-style)

  // Show preamble section with styles applied if applicable
  if preamble != none {
    pagebreak()
    preamble-section(preamble, style-preface: preamble-style)
  }

  // Show chapter outline with styles applied
  pagebreak()
  chapter-outline(style-preface: outline-style)

  // Show abbreviations section with styles applied if applicable
  if abbreviations.len() >= 1 {
    pagebreak()
    abbreviations-section(abbreviations, style-preface: abbreviations-style)
  }

  // Show content with styles applied
  pagebreak()
  {
    show: default-styles.content-style
    show: content-style
    doc
  }

  // Show figure outline with styles applied if applicable (forced or if there is at least one non-table figure)
  context if (
    include-figureoutline == true
      or (
        include-figureoutline == auto
          and query(figure).len() - query(figure.where(kind: table)).len() >= 1
      )
  ) {
    pagebreak()
    figure-outline(style-preface: outline-style)
  }

  // Show table outline with styles applied if applicable (forced or if there is at least one table)
  context if (
    include-tableoutline == true
      or (
        include-tableoutline == auto
          and query(figure.where(kind: table)).len() >= 1
      )
  ) {
    pagebreak()
    table-outline(style-preface: outline-style)
  }

  // Show bibliography section with styles applied
  if bibl != none {
    pagebreak()
    bibliography-section(bibl, style-preface: bibliography-style)
  }

  // Show appendix section with styles applied if applicable
  if appendix != none {
    pagebreak()
    appendix-section(appendix, style-preface: appendix-style)
  }
}
