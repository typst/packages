#import "utils.typ": *

//************************************************************************\\
//                         Global State Management                        \\
//************************************************************************\\

// Stores the current theme color (either from palette or custom RGB)
#let theme-color = state("theme-color", none)

// Tracks all sections for table of contents generation
#let sections = state("sections", ())

// Controls visibility of page numbers in slide footers
#let page-numbers = state("show-page-numbers", true)

// Enables/disables the bottom progress bar on slides
#let progress-enabled = state("show-progress", false)

// Defines the height of the bottom progress bar
#let progress-thickness = state("progress-thickness", 3pt)

//************************************************************************\\
//                      Main Configuration Function                       \\
//************************************************************************\\

// Primary setup function for Typslides presentations
// Configures global settings including theme, typography, and layout
//
// Arguments:
//   ratio: Slide aspect ratio (default: "16-9")
//   theme: Color theme name from palette or custom RGB (default: "bluey")
//   font: Font family for presentation text (default: "Fira Sans")
//   font-size: Base font size for slide content (default: 21pt)
//   link-style: Hyperlink styling - "color", "underline", or "both" (default: "color")
//   show-page-numbers: Display page numbers in footers (default: true)
//   show-progress: Enable Beamer-style progress bar at bottom (default: false)
//   progress-height: Height of the progress bar (default: 3pt)
//   body: The presentation content
//
// Returns: Configured presentation with all styling applied
#let typslides(
  ratio: "16-9",
  theme: "bluey",
  font: "Fira Sans",
  font-size: 21pt,
  link-style: "color",
  show-page-numbers: true,
  show-progress: false,
  progress-height: 3pt,
  body,
) = {
  page-numbers.update(show-page-numbers)
  progress-enabled.update(show-progress)
  progress-thickness.update(progress-height)

  if type(theme) == str {
    theme-color.update(_theme-colors.at(theme))
  } else {
    theme-color.update(theme)
  }

  set text(font: font, size: font-size)
  set page(paper: "presentation-" + ratio, fill: white)

  show ref: it => (
    context {
      text(fill: theme-color.get())[#it]
    }
  )

  show link: it => (
    context {
      if it.has("label") {
        text(fill: theme-color.get())[#it]
      } else if link-style == "underline" {
        underline(stroke: theme-color.get())[#it]
      } else if link-style == "both" {
        text(fill: theme-color.get(), underline[#it])
      } else {
        text(fill: theme-color.get())[#it]
      }
    }
  )

  show footnote: it => (
    context {
      text(fill: theme-color.get())[#it]
    }
  )

  set enum(numbering: (it => context text(fill: black)[*#it.*]))

  body
}

//************************************************************************\\
//                          Text Styling Functions                        \\
//************************************************************************\\

// Applies the current theme color to text
// Arguments:
//   body: Text content to be colored
// Returns: Text with theme color applied
#let themey(body) = context text(fill: theme-color.get())[#body]

// Color utility functions for quick text styling
// Each function applies a specific color from the theme palette
#let bluey(body) = text(fill: rgb("3059AB"))[#body]
#let greeny(body) = text(fill: rgb("28842F"))[#body]
#let reddy(body) = text(fill: rgb("BF3D3D"))[#body]
#let yelly(body) = text(fill: rgb("C4853D"))[#body]
#let purply(body) = text(fill: rgb("862A70"))[#body]
#let dusky(body) = text(fill: rgb("1F4289"))[#body]

//************************************************************************\\

// Emphasizes text with theme color and semibold weight
// Arguments:
//   body: Text content to be emphasized
// Returns: Styled text with theme color and semibold weight
#let stress(body) = context text(fill: theme-color.get(), weight: "semibold")[#body]

//************************************************************************\\

// Creates a framed box with optional title
// Used to highlight important content or create callouts
//
// Arguments:
//   title: Optional title displayed in colored header (default: none)
//   back-color: Custom background color (default: auto-determined)
//   content: The content to be displayed in the frame
//
// Returns: A styled block with rounded corners and optional title bar
#let framed(
  title: none,
  back-color: none,
  content,
) = context {
  set block(
    inset: (x: .6cm, y: .6cm),
    breakable: false,
    above: .7cm,
    below: .7cm,
  )

  let default-back = if title != none { white } else { rgb("FBF7EE") }
  let fill-color = if back-color != none { back-color } else { default-back }

  if title != none {
    set block(width: 100%)
    stack(
      block(
        fill: theme-color.get(),
        inset: (x: .6cm, y: .55cm),
        radius: (top: .2cm, bottom: 0cm),
        stroke: 2pt,
      )[
        #text(weight: "semibold", fill: white)[#title]
      ],
      block(
        fill: fill-color,
        radius: (top: 0cm, bottom: .2cm),
        stroke: 2pt,
        content,
      ),
    )
  } else {
    block(
      width: auto,
      fill: fill-color,
      radius: .2cm,
      stroke: 2pt,
      content,
    )
  }
}

//************************************************************************\\

// Creates a multi-column layout for slide content
// Source: https://github.com/polylux-typ/polylux/blob/main/src/toolbox/toolbox-impl.typ
//
// Arguments:
//   columns: Array of column widths (default: equal width for all)
//   gutter: Spacing between columns (default: 1em)
//   bodies: Variable number of content blocks, one per column
//
// Returns: A grid layout with the specified columns
#let cols(columns: none, gutter: 1em, ..bodies) = {
  let bodies = bodies.pos()

  let columns = if columns == none {
    (1fr,) * bodies.len()
  } else {
    columns
  }

  if columns.len() != bodies.len() {
    panic("Number of columns must match number of content arguments")
  }

  grid(columns: columns, gutter: gutter, ..bodies)
}

//************************************************************************\\

// Creates a centered gray box for highlighting content
// Commonly used for equations, code snippets, or important notes
//
// Arguments:
//   text-size: Font size for content in the box (default: 24pt)
//   content: The content to be displayed
//
// Returns: A centered gray block with rounded corners
#let grayed(
  text-size: 24pt,
  content,
) = {
  set align(center + horizon)
  set text(size: text-size)
  block(
    fill: rgb("#F3F2F0"),
    inset: (x: .8cm, y: .8cm),
    breakable: false,
    above: .9cm,
    below: .9cm,
    radius: (top: .2cm, bottom: .2cm),
  )[#content]
}

//************************************************************************\\

// Registers a new section for the table of contents
// Called internally by title-slide to track presentation structure
//
// Arguments:
//   name: The section name/title to be registered
//
// Returns: Updates the global sections state with the new section
#let register-section(
  name,
) = context {
  let sect-page = here().position()
  sections.update(sections => {
    sections.push((body: name, loc: sect-page))
    sections
  })
}

//************************************************************************\\
//                            Helper Functions                            \\
//************************************************************************\\

// Returns formatted page number if page numbers are enabled
//
// Returns: Page number in "current/total" format, or none if disabled
#let _get-page-number() = context {
  if page-numbers.get() {
    counter(page).display("1 / 1", both: true)
  } else {
    none
  }
}

// Returns the progress bar overlay if progress is enabled
//
// Arguments:
//   color: Optional color override for the progress bar
//
// Returns: Progress bar element or none if disabled
#let _get-progress-foreground(color: none) = context {
  if progress-enabled.get() {
    let bar-color = if color != none { color } else { theme-color.get() }
    _progress-bar(color: bar-color, height: progress-thickness.get())
  } else {
    none
  }
}

// Applies common text styling rules for slide content
// Sets list markers, enumeration style, font size, and text justification
//
// Returns: Configured text styling rules
#let _apply-slide-text-styles() = {
  set list(marker: context text(theme-color.get(), [•]))
  set enum(numbering: (it => context text(fill: theme-color.get())[*#it.*]))
  set text(size: 20pt)
  set par(justify: true)
}

//************************************************************************\\
//                            Slide Templates                             \\
//************************************************************************\\

// Creates the front/title slide of the presentation
// Uses a simple divider without progress indication
//
// Arguments:
//   title: Main presentation title
//   subtitle: Optional subtitle
//   authors: Author name(s)
//   info: Additional information (dates, links, etc.)
//
// Returns: Formatted front slide
#let front-slide(
  title: none,
  subtitle: none,
  authors: none,
  info: none,
) = context {
  _make-frontpage(
    title,
    subtitle,
    authors,
    info,
    theme-color.get(),
  )
}

//************************************************************************\\

// Generates a table of contents from registered sections
// Automatically builds outline from title-slide and slide(outlined: true) entries
// Uses a progress divider to show position in presentation
//
// Arguments:
//   title: Title for the outline slide (default: "Contents")
//   text-size: Font size for outline items (default: 23pt)
//
// Returns: A formatted table of contents with clickable links
#let table-of-contents(
  title: "Contents",
  text-size: 23pt,
) = context {
  text(size: 42pt, weight: "bold")[
    #smallcaps(title)
    #v(-.9cm)
    #_progress-divider(color: theme-color.get())
  ]

  set text(size: text-size)
  show linebreak: none

  let sections = query(<section>)

  if sections.len() == 0 {
    let subsections = query(<subsection>)
    pad(enum(..subsections.map(sub => [#link(sub.location(), sub.value) <toc>])))
  } else {
    pad(enum(..sections.map(section => {
      let section-loc = section.location()
      let subsections = query(
        selector(<subsection>).after(section-loc).before(selector(<section>).after(section-loc, inclusive: false)),
      )

      if subsections.len() != 0 {
        [#link(section-loc, section.value) <toc> #list(
            ..subsections.map(sub => [#link(sub.location(), sub.value) <toc>]),
          )]
      } else {
        [#link(section.location(), section.value) <toc>]
      }
    })))
  }

  pagebreak()
}

//************************************************************************\\

// Creates a section title slide
// Registers the section in the table of contents
// Uses a progress divider to show presentation progress
//
// Arguments:
//   body: Section title/name
//   text-size: Font size for the title (default: 42pt)
//
// Returns: A full-page section title with progress divider
#let title-slide(
  body,
  text-size: 42pt,
) = context {
  register-section(body)

  show heading: text.with(size: text-size, weight: "semibold")
  set align(left + horizon)

  [#heading(depth: 1, smallcaps(body)) #metadata(body) <section>]
  _progress-divider(color: theme-color.get())

  pagebreak()
}

//************************************************************************\\

// Creates a full-screen focus slide with large, centered text
// Background uses theme color, text automatically resizes to fit
// Progress bar (if enabled) is shown in white for contrast
//
// Arguments:
//   text-color: Color for the text (default: white)
//   text-size: Initial font size, auto-adjusted to fit (default: 60pt)
//   body: Content to be displayed
//
// Returns: A full-screen slide with auto-resized centered text
#let focus-slide(
  text-color: white,
  text-size: 60pt,
  body,
) = context {
  set page(
    fill: theme-color.get(),
    foreground: _get-progress-foreground(color: white),
  )

  set text(
    weight: "semibold",
    size: text-size,
    fill: text-color,
  )

  set align(center + horizon)

  _resize-text(body)
}

//************************************************************************\\

// Standard content slide with optional title and header
// Supports custom backgrounds, page numbers, and progress bar
// Can be marked as "outlined" to appear in table of contents
//
// Arguments:
//   title: Optional slide title displayed in colored header
//   back-color: Background color for the slide (default: white)
//   outlined: Whether to register this slide in TOC (default: false)
//   body: Slide content
//
// Returns: A formatted content slide with header and optional progress bar
#let slide(
  title: none,
  back-color: white,
  outlined: false,
  body,
) = context {
  let page-num = _get-page-number()

  set page(
    fill: back-color,
    header-ascent: if title != none { 65% } else { 66% },
    header: [],
    margin: if title != none {
      (x: 1.6cm, top: 2.5cm, bottom: 1.2cm)
    } else {
      (x: 1.6cm, top: 1.75cm, bottom: 1.2cm)
    },
    background: {
      place(_slide-header(
        title,
        outlined,
        theme-color.get(),
        page-num: if title != none { page-num } else { none },
      ))
      if page-num != none and title == none {
        place(top + right, box(
          inset: (right: 0.6cm, top: 0.325cm),
          text(
            fill: white,
            weight: "semibold",
            size: 12pt,
          )[#page-num],
        ))
      }
    },
    foreground: _get-progress-foreground(),
  )

  _apply-slide-text-styles()
  set align(horizon)
  v(0cm)
  body
}

//************************************************************************\\

// Minimal slide without header or title
// Useful for custom layouts or special content
// Still supports page numbers and progress bar
//
// Arguments:
//   body: Slide content
//
// Returns: A clean slide with maximum content area
#let blank-slide(body) = context {
  let page-num = _get-page-number()

  set page(
    background: if page-num != none {
      place(top + right, box(
        inset: (right: 0.6cm, top: 0.6cm),
        text(
          fill: theme-color.get(),
          weight: "semibold",
          size: 12pt,
        )[#page-num],
      ))
    },
    foreground: _get-progress-foreground(),
  )

  _apply-slide-text-styles()
  set align(horizon)
  body
}

//************************************************************************\\

// Creates a bibliography/references slide
// Displays citations from a .bib file with a progress divider
//
// Arguments:
//   bib-call: The bibliography() function call with your .bib file
//   title: Title for the references section (default: "References")
//
// Returns: A formatted bibliography slide
#let bibliography-slide(
  bib-call,
  title: "References",
) = context {
  set text(size: 19pt)
  set par(justify: true)
  set bibliography(title: text(size: 30pt)[
    #smallcaps(title)
    #v(-.85cm)
    #_progress-divider(color: theme-color.get())
    #v(.5cm)
  ])

  bib-call
}
