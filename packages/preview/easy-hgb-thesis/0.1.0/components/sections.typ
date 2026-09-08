#import "i8n.typ": i8n, i8n-declaration-page
#import "styles.typ" as default-styles

/// Shows the title page.
#let titlepage-section(
  course-of-study,
  schoolyear,
  mentor-name,
  work-type,
) = {
  import "titlepage.typ": titlepage
  titlepage(
    course-of-study,
    schoolyear,
    mentor-name,
    work-type: work-type,
  )
}

/// Shows the declaration page with the given style.
/// - style-preface (): A function that takes the content, styles it and returns a styled content.
#let declaration-page(
  style-preface: it => it,
) = {
  // Behavioral specs integral for document

  // Aesthetic styles
  show: default-styles.declaration-style
  show: style-preface

  // Content
  i8n-declaration-page()
}

/// Shows the acknowledgement section with the given content and style.
/// - content (content): The content to display.
/// - style-preface (): A function that takes the content, styles it and returns a styled content.
#let acknowledgement-section(
  content,
  style-preface: it => it,
) = {
  // Behavioral specs integral for document
  set heading(offset: 1, outlined: false)

  // Aesthetic styles
  show: default-styles.acknowledgement-style
  show: style-preface

  // Content
  heading(level: 1, i8n("acknowledgement"))
  content
}

/// Shows the kurzfassung section with the given content and style.
/// - content (content): The content to display.
/// - style-preface (): A function that takes the content, styles it and returns a styled content.
#let kurzfassung-section(
  content,
  style-preface: it => it,
) = {
  // Behavioral specs integral for document
  set heading(offset: 1, outlined: false)

  // Aesthetic styles
  show: default-styles.abstract-style
  show: style-preface

  // Content
  heading(level: 1, i8n("kurzfassung"))
  content
}

/// Shows the abstract section with the given content and style.
/// - content (content): The content to display.
/// - style-preface (): A function that takes the content, styles it and returns a styled content.
#let abstract-section(
  content,
  style-preface: it => it,
) = {
  // Behavioral specs integral for document
  set heading(offset: 1, outlined: false)

  // Aesthetic styles
  show: default-styles.abstract-style
  show: style-preface

  // Content
  heading(level: 1, i8n("abstract"))
  content
}

/// Shows the preamble section with the given content and style.
/// - content (content): The content to display.
/// - style-preface (): A function that takes the content, styles it and returns a styled content.
#let preamble-section(
  content,
  style-preface: it => it,
) = {
  // Behavioral specs integral for document
  set heading(offset: 1, outlined: false)

  // Aesthetic styles
  show: default-styles.preamble-style
  show: style-preface

  // Content
  heading(level: 1, i8n("preamble"))
  content
}

/// Shows the chapter outline with the given style.
/// - style-preface (): A function that takes the content, styles it and returns a styled content.
#let chapter-outline(
  style-preface: it => it,
) = {
  // Behavioral specs integral for document

  // Aesthetic styles
  show: default-styles.chapter-outline-style
  show: style-preface

  // Content
  outline(title: [#i8n("chapter-outline") <_ght-chapter-outline>])
}

/// Shows the abbreviations section with the given items and style.
/// - items (dict): The items to display. Form (\<abbreviation>: \<description-content>). Example: (`(AI: "Artificial Intelligence")`).
/// - style-preface (): A function that takes the content, styles it and returns a styled content.
#let abbreviations-section(
  items,
  style-preface: it => it,
) = {
  // Behavioral specs integral for document

  // Aesthetic styles
  show: default-styles.abbreviations-style
  show: style-preface

  // Content
  heading(level: 1, i8n("abbreviations"))
  table(
    columns: (2fr, 7fr),
    table.header(strong(i8n("abbreviation")), strong(i8n("description"))),
    ..items.pairs().flatten(),
  )
}

/// Shows the figure outline with the given style.
/// - style-preface (): A function that takes the content, styles it and returns a styled content.
#let figure-outline(
  style-preface: it => it,
) = {
  // Behavioral specs integral for document
  show outline: set heading(outlined: true)

  // Aesthetic styles
  show: default-styles.figure-outline-style
  show: style-preface

  // Content
  outline(title: i8n("figure-outline"), target: figure.where(kind: image))
}

/// Shows the table outline with the given style.
/// - style-preface (): A function that takes the content, styles it and returns a styled content.
#let table-outline(
  style-preface: it => it,
) = {
  // Behavioral specs integral for document
  show outline: set heading(outlined: true)

  // Aesthetic styles
  show: default-styles.table-outline-style
  show: style-preface

  // Content
  outline(title: i8n("table-outline"), target: figure.where(kind: table))
}

/// Shows the bibliography section with the given bibliography and style.
/// - bibl (bibliography): The bibliography to display.
/// - style-preface (): A function that takes the content, styles it and returns a styled content. Can be used to change the citation style. F.e. ```typc
/// it => {
///   set bibliography(style: "ieee")
///   it
/// }
/// ```
#let bibliography-section(
  bibl,
  style-preface: it => it,
) = {
  // Behavioral specs integral for document
  show bibliography: set heading(outlined: true)

  // Aesthetic styles
  show: default-styles.bibliography-style
  show: style-preface

  // Content
  bibl
}

/// Shows the appendix section with the given appendix and style.
/// - appendix (content): The appendix to display.
/// - style-preface (): A function that takes the content, styles it and returns a styled content.
#let appendix-section(
  appendix,
  style-preface: it => it,
) = {
  // Behavioral specs integral for document
  set heading(offset: 1)

  // Aesthetic styles
  show: default-styles.appendix-style
  show: style-preface

  // Content
  heading(level: 1, i8n("appendix"))
  appendix
}
