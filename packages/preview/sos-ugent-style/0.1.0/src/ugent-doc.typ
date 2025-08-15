#import "styling/elements.typ": ugent-show-outlines
#import "styling/cover.typ": ugent-cover-layout-page
#import "utils/links.typ": color-links

#let font-size = 11pt // Guidelines: 11 or 12
#let font-default = "Liberation Sans"

// TODO for ugent-doc:
// - ugent-doc lengths
// - ugent-doc strut
// - titlepage

// Entry point of the ugent-doc template
#let ugent-doc-template(
  /// The title of your document: content
  title: none,
  /// The authors of your document: an array of strings
  authors: (),
  language: "nl", // convenience
  faculty: none,
  front-page: ugent-cover-layout-page.with([This is an empty title-page. The ugent-doc info box is not yet implemented.]),
  // All front-page info

  // UTIL OPTIONS
  /// none | dict | (todo: function --> use as init-glossary, can be 'preconfigured' by `.with()`)
  font: font-default, // use none to disable
  font-size: font-size,
  glossary-entries: none,
  color-external-links: auto,
  color-internal-links: none,
  body,
) = {
  // Set the properties of the main PDF file (only part of template for convenience).
  set document(author: authors, title: title)

  // Set the basic page properties.
  set page(
      paper: "a4",
      // TODO: how to best present this choice in the API: (maybe "book" vs "digital")?
      // - if on paper: use inside/outside
      // - if only digitally: left/right
      /* MPP educational master */
      //margin: (inside: 2cm, outside: 3cm, rest: 2.5cm),
      margin: (right: 2cm, left: 3cm, rest: 2.5cm),
      // TODO: what is the most common margin setting accross all faculties
      // *for documents*? What about dissertations? update both accordingly
      // - present API or clear documentation on default & on how to change it
      /* Dissertation faculty EA */
      // margin: (all: 2.5cm),
      // margin: (inside: 4cm, outside: 1cm, rest: 2.5cm), // Interpreted correctly??
  )

  // Set the basic paragraph properties.
  set par(
      // line spacing. Should be similar to baselinestretch=1.15 in LaTeX (TODO: verify)
      leading: 1em,
      // Disable justification, according to @polleflietScorenMetJe2023[pg. 286] and @VerzorgJeLayout
      //justify: true,            // LaTeX look, but less readable
      linebreaks: "optimized",    // Still try to optimize placement by considering the whole paragraph
      // Only ever use blank line as seperation @polleflietScorenMetJe2023[pg. 299] and @TekststructuurIndelingHoofdstukken
      //first-line-indent: 1.8em, // LaTeX look, but not desired at UGent (TODO: or only in Dutch?)
      spacing: 1.6em,
  )

  // Set the basic text properties.
  set text(font: font) if font != none
  set text(size: font-size) if font-size != none
  set text(
      lang: language,
      fallback: true,
      hyphenate: false,
  )

  // Enable colored links. Need to be before `init-glossary` to prevent coloring glossy refs.
  show: color-links.with(external: color-external-links, internal: color-internal-links)

  // Initialize the glossary if used (not a simple if, due to scoping of show)
  show: body => {
    if glossary-entries != none {
      // Late import, don't make dependency if not used
      import "/utils/lib.typ": glossy
      show: glossy().init-glossary.with(glossary-entries, term-links: true)
      body
    } else {
      body
    }
  }

  // Style outlines & fix state
  show outline: it => {
    let in-outline = state("in-outline", false)
    in-outline.update(true)
    it
    in-outline.update(false)
  }
  show: ugent-show-outlines

  if front-page != none {
    if type(front-page) == content {
      front-page
    } else if type(front-page) == function {
      // TODO: Implement application of title, authors, ...
      front-page()
    } else {
      panic("Cannot handle type " + str(type(front-page)) + " as front-page argument.")
    }
  }
  body
}
