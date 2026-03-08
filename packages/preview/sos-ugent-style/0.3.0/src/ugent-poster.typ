#import "styling/colors.typ"
#import "styling/cover.typ": ugent-cover-layout-page
#import "styling/elements.typ": ugent-heading-title-text, ugent-heading-rules

// Sources:
// - Betterposter Generation 2: https://www.youtube.com/watch?v=SYk29tnxASs
// - UGent styleguide: https://styleguide.ugent.be/templates/print.html#poster
// - Templates: https://cespe.be/ugent-poster-templates/
// - How to design an academic poster by Evelynn Devos:
//   https://www.ugent.be/eb/en/services/library/short-sessions-on-hot-topics-ssht/postertheory
// Typst inspirations:
// - Litfass (tiling layout)
// - postercise (API)
// - peace-of-posters (API, completeness)
// - poster-syndrome (grid layout)

#let gridunit-state = state("ugent-gridunit")

// Entry point of the ugent-poster template
#let ugent-poster-template(
  page-args: (paper: "a0", flipped: false),
  /// The font size of the body text. When auto, depends on `page-args.paper`.
  body-size: auto,
  /// The title of your document: content
  title: none,
  /// The authors of your document: an array of strings
  authors: (),
  language: "nl", // convenience
  faculty: none,
  header: none,
  footer: none,
  background-color: colors.ugent-poster-grey,
  body,
) = {
  // Set the properties of the main PDF file (only part of template for convenience).
  let document-args = if title != none { (title: title) } + if authors != () { (author: authors) }
  set document(..document-args)

  // Set the basic page properties.
  set page(..page-args)

  // Set the basic paragraph properties. (TODO: check if this makes sense)
  set par(
      // line spacing. Should be similar to baselinestretch=1.15 in LaTeX (TODO: verify)
      leading: 1em,
      // Disable justification, according to @polleflietScorenMetJe2023[pg. 286] and @VerzorgJeLayout
      justify: true,            // LaTeX look, but less readable
      linebreaks: "optimized",    // Still try to optimize placement by considering the whole paragraph
      // Only ever use blank line as seperation @polleflietScorenMetJe2023[pg. 299] and @TekststructuurIndelingHoofdstukken
      //first-line-indent: 1.8em, // LaTeX look, but not desired at UGent (TODO: or only in Dutch?)
      spacing: 1.6em,
  )

  // Set the basic text properties.
  body-size = if body-size == auto {
    // according to peace-of-posters package:
    let paper-to-body-size-mapping = (a0: 38pt, a1: 32pt, a2: 25pt, a3: 19pt, a4: 13pt)
    if not "paper" in page-args {
      panic("When the paper argument is not used, set body-size manually.")
    }
    if not page-args.paper in paper-to-body-size-mapping {
      panic("The paper size '" + page-args.paper
            + "' has no mapping to a body-size, set it manually.")
    }
    paper-to-body-size-mapping.at(page-args.paper)
  }
  set text(
      size: body-size,
      lang: language,
      fallback: true,
      hyphenate: false,
  )
  // https://github.com/typst/typst/discussions/2919 => reverse default size
  show heading.where(level: 1): set text(size: 1.53/1.4 * 1em)
  show heading: set text(weight: "extrabold", fill: colors.ugent-blue)
  //show heading: ugent-heading-title-text
  // Title: 2.28em - subtitle: 1.85em - authors: 1.53em
  // institutes: 1.39em - keywords: 1.24em according to peace-of-posters

  // If a glossary would be needed, check ugent-doc.typ.
  // Since it is unlikely to be needed for a poster, it is not yet incorporated here.

  let poster-info = (
    title: title,
    authors: authors,
    faculty: faculty,
  )
  [#metadata(poster-info) <ugent-poster-info>]

  ugent-cover-layout-page(
    faculty: faculty,
    header: header,
    footer: footer,
    background-color: background-color,
    gridunit-factor: 0.5, // fit 56 gridunits along the long side (normal: 28)
    context {
      // put everything in a block with extra margins - should this be done here?
      show: block.with(inset: (right: 0pt, rest: gridunit-state.get()))
      body
    }
  )
}

#let ugent-poster-info() = query(<ugent-poster-info>).first().value

// TODO: fix layout of the title
#let title(
  size: 2.28em, // peace-of-posters
  it
) = context {
  show: ugent-heading-rules
  show heading: set heading(outlined: false)
  show heading: set par(leading: 0.45em)
  show heading.where(level: 1): set text(size: size)
  show heading.where(level: 1): set underline(stroke: 0.05em)
  // Destructive
  show heading.where(level: 1): h => block(
    ugent-heading-title-text(underlined: true, h),
    below: 20pt,
  )
  heading(upper(ugent-poster-info().title), level: 1)
}

// Create a filled block with text color matched to the background color
#let ugent-fullcolor-frame(
  gridunit: auto,
  background-color: "ugent-blue",
  ..args
) = context {
  let gridunit = if gridunit == auto { gridunit-state.get() } else { gridunit }
  let foreground-color = colors.background-color-to-foreground-map
                               .at(background-color)

  // Be specific enough
  show heading: set text(fill: foreground-color) if foreground-color != none
  set text(fill: foreground-color) if foreground-color != none

  block(
    fill: dictionary(colors).at(background-color),
    inset: gridunit/2,
    width: 100%, // Assume it is placed at the left
    ..args
  )
}

// Create a filled block, either ugent-blue or the accent color
#let ugent-frame(
  highlight: false,
  // Can be a string or
  // a function returning the supplied faculty - see DESIGN_RATIONALE.md
  faculty: auto,
  ..args
) = {
  if highlight {
    // if auto, detect primary faculty
    faculty = if faculty == auto {
      () => ugent-poster-info().faculty
    } else { faculty }

    context {
      let faculty = if type(faculty) == function { faculty() } else { faculty }
      ugent-fullcolor-frame(
        background-color: if faculty == none { "ugent-yellow" } else { faculty },
        ..args
      )
    }
  } else {
    ugent-fullcolor-frame(..args)
  }
}

#let contact-frame(
  ..args
) = {
  show heading: set text(size: 1/1.53 * 1em)
  show heading: set block(below: 1.6em)
  set par(leading: 0.65em)
  //context text.size
  ugent-fullcolor-frame(
    background-color: "ugent-blue",
    ..args
  )
}

// use accent color - or highlight color
#let focus-frame = ugent-frame.with(highlight: true)
