#import "i18n.typ": i18n
#import "constants.typ": THESIS_STYLE
#import "styles_modern.typ"
#import "styles_classic.typ"

#let base-style(style) = if style == THESIS_STYLE.modern {
  styles_modern
} else { styles_classic }

/// Shows the title page.
#let titlepage-section(
  cont,
) = {
  cont
}

/// Shows the declaration page with the given style.
/// - style-preface (): A function that takes the content, styles it and returns a styled content.
/// - thesis-style (classic, modern): The base style for this section.
#let declaration-page(
  style-preface: it => it,
  thesis-style: THESIS_STYLE.classic,
) = {
  // Behavioral specs integral for document

  // Aesthetic styles
  show: base-style(thesis-style).declaration-style
  show: style-preface

  // Content
  include "declaration.typ"
}

/// Shows the acknowledgement section with the given content and style.
/// - content (content): The content to display.
/// - style-preface (): A function that takes the content, styles it and returns a styled content.
/// - thesis-style (classic, modern): The base style for this section.
#let acknowledgement-section(
  content,
  style-preface: it => it,
  thesis-style: THESIS_STYLE.classic,
) = {
  // Behavioral specs integral for document
  set heading(offset: 1, outlined: false)

  // Aesthetic styles
  show: base-style(thesis-style).acknowledgement-style
  show: style-preface

  // Content
  heading(level: 1, i18n("acknowledgement"))
  content
}

/// Shows the kurzfassung section with the given content and style.
/// - content (content): The content to display.
/// - style-preface (): A function that takes the content, styles it and returns a styled content.
/// - thesis-style (classic, modern): The base style for this section.
#let kurzfassung-section(
  content,
  style-preface: it => it,
  thesis-style: THESIS_STYLE.classic,
) = {
  // Aesthetic styles
  show: base-style(thesis-style).abstract-style
  show: style-preface

  // Content
  heading(level: 1, i18n("kurzfassung"))
  content
}

/// Shows the abstract section with the given content and style.
/// - content (content): The content to display.
/// - style-preface (): A function that takes the content, styles it and returns a styled content.
/// - thesis-style (classic, modern): The base style for this section.
#let abstract-section(
  content,
  style-preface: it => it,
  thesis-style: THESIS_STYLE.classic,
) = {
  // Aesthetic styles
  show: base-style(thesis-style).abstract-style
  show: style-preface

  // Content
  heading(level: 1, i18n("abstract"))
  content
}

/// Shows the preamble section with the given content and style.
/// - content (content): The content to display.
/// - style-preface (): A function that takes the content, styles it and returns a styled content.
/// - thesis-style (classic, modern): The base style for this section.
#let preamble-section(
  content,
  style-preface: it => it,
  thesis-style: THESIS_STYLE.classic,
) = {
  // Aesthetic styles
  show: base-style(thesis-style).preamble-style
  show: style-preface

  // Content
  heading(level: 1, if thesis-style == THESIS_STYLE.modern {
    i18n("preamble")
  } else { i18n("preface") })
  content
}

/// Shows the chapter outline with the given style.
/// - style-preface (): A function that takes the content, styles it and returns a styled content.
/// - thesis-style (classic, modern): The base style for this section.
#let chapter-outline(
  style-preface: it => it,
  thesis-style: THESIS_STYLE.classic,
) = {
  // Behavioral specs integral for document

  // Aesthetic styles
  show: base-style(thesis-style).chapter-outline-style
  show: style-preface

  // Content
  outline(title: [#i18n("chapter-outline") <_ght-chapter-outline>])
}

/// Shows the abbreviations section with the given items and style.
/// - items (dict): The items to display. Form (\<abbreviation>: \<description-content>). Example: (`(AI: "Artificial Intelligence")`).
/// - style-preface (): A function that takes the content, styles it and returns a styled content.
/// - thesis-style (classic, modern): The base style for this section.
#let abbreviations-section(
  items,
  style-preface: it => it,
  thesis-style: THESIS_STYLE.classic,
) = {
  // Behavioral specs integral for document

  // Aesthetic styles
  show: base-style(thesis-style).abbreviations-style
  show: style-preface

  // Content
  heading(level: 1, i18n("abbreviations"))
  table(
    columns: (2fr, 7fr),
    table.header(strong(i18n("abbreviation")), strong(i18n("description"))),
    ..items.pairs().flatten(),
  )
}

/// Shows the figure outline with the given style.
/// - style-preface (): A function that takes the content, styles it and returns a styled content.
/// - thesis-style (classic, modern): The base style for this section.
#let figure-outline(
  style-preface: it => it,
  thesis-style: THESIS_STYLE.classic,
) = {
  // Behavioral specs integral for document
  show outline: set heading(outlined: true)

  // Aesthetic styles
  show: base-style(thesis-style).figure-outline-style
  show: style-preface

  // Content
  outline(title: i18n("figure-outline"), target: figure.where(kind: image))
}

/// Shows the table outline with the given style.
/// - style-preface (): A function that takes the content, styles it and returns a styled content.
/// - thesis-style (classic, modern): The base style for this section.
#let table-outline(
  style-preface: it => it,
  thesis-style: THESIS_STYLE.classic,
) = {
  // Behavioral specs integral for document
  show outline: set heading(outlined: true)

  // Aesthetic styles
  show: base-style(thesis-style).table-outline-style
  show: style-preface

  // Content
  outline(title: i18n("table-outline"), target: figure.where(kind: table))
}

/// Shows the bibliography section with the given bibliography and style.
/// - bibl (bibliography): The bibliography to display.
/// - style-preface (): A function that takes the content, styles it and returns a styled content. Can be used to change the citation style. F.e. ```typc
/// it => {
///   set bibliography(style: "ieee")
///   it
/// }
/// ```
/// - thesis-style (classic, modern): The base style for this section.
#let bibliography-section(
  bibl,
  style-preface: it => it,
  thesis-style: THESIS_STYLE.classic,
) = {
  // Behavioral specs integral for document
  show bibliography: set heading(outlined: true)

  // Aesthetic styles
  show: base-style(thesis-style).bibliography-style
  show: style-preface

  // Content
  bibl
}

/// Shows the appendix section with the given appendix and style.
/// - appendix (content): The appendix to display.
/// - style-preface (): A function that takes the content, styles it and returns a styled content.
/// - thesis-style (classic, modern): The base style for this section.
#let appendix-section(
  appendix,
  style-preface: it => it,
  thesis-style: THESIS_STYLE.classic,
) = {
  // Aesthetic styles
  show: base-style(thesis-style).appendix-style
  show: style-preface

  // Content
  if thesis-style == THESIS_STYLE.modern {
    // Autoinsert top level appendix heading
    heading(level: 1, i18n("appendix"))
  }
  appendix
}

#let _print-size-control-box() = {
  pagebreak(weak: true)
  set page(footer: none, header: none)
  counter(page).update(it => it - 1)
  set align(center)
  [\- Check print size! -\ ]
  box(stroke: black, width: 100mm, height: 50mm)[
    #show: align.with(center + horizon)
    width = 100mm\
    height = 50mm
  ]
  [\ - Discard this page after printing! -]
}
