#import "utils.typ": *

//************************************************************************\\
//                         Global State Management                        \\
//************************************************************************\\

// Stores the current theme color (either from palette or custom RGB)
#let theme-color = state("theme-color", none)

// Stores the default background color for all slides
#let default-back-color = state("default-back-color", white)

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
//   ratio:  Slide aspect ratio (default: "16-9")
//   theme: Color theme name from palette or custom RGB (default: "bluey")
//   font: Font family for presentation text (default: "Fira Sans")
//   font-size: Base font size for slide content (default: 21pt)
//   link-style: Hyperlink styling - "color", "underline", or "both" (default: "color")
//   show-page-numbers: Display page numbers in footers (default: true)
//   show-progress: Enable Beamer-style progress bar at bottom (default: false)
//   progress-height: Height of the progress bar (default: 3pt)
//   back-color: Default background color for all slides (default: white)
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
  back-color: white,
  body,
) = {
  page-numbers.update(show-page-numbers)
  progress-enabled.update(show-progress)
  progress-thickness.update(progress-height)
  default-back-color.update(back-color)
  
  if type(theme) == str {
    theme-color.update(_theme-colors.at(theme))
  } else {
    theme-color.update(theme)
  }
  
  set text(font: font, size: font-size)
  set page(paper: "presentation-" + ratio, fill: back-color)
  
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
// Returns:  A grid layout with the specified columns
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
  fill-color: color.silver.lighten(50%),
  content,
) = {
  set align(center + horizon)
  set text(size: text-size)
  block(
    fill: fill-color,
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
//                  Dynamic content: #pause, #only, #uncover                //
//************************************************************************\\

// Index of the subslide currently being rendered (1-based).
// Updated at the beginning of every generated page of a slide.
#let _subslide = state("typslides-subslide", 1)

// Counts the extra pages generated by subslides (index > 1), so that page
// numbers shown in slides refer to logical slides, not to physical pages.
#let _extra-pages = counter("typslides-extra-pages")

// Marker produced by #pause. It is a (invisible) metadata element that
// slide / blank-slide look for among the top-level elements of their body.
//
// Usage: #pause
// Everything that follows #pause is hidden (but keeps its space) until the
// next subslide. A slide with N pauses generates N + 1 pages.
#let pause = metadata((typslides: "pause"))

// Converts a visibility specification into a list of ranges `(from, to)`.
// Accepted specifications:
//   2            -> only subslide 2
//   "2-"         -> from subslide 2 on
//   "-3"         -> up to subslide 3
//   "2-4"        -> subslides 2, 3 and 4
//   "1, 3-"      -> subslide 1 and from subslide 3 on
//   (1, "3-")    -> array with any of the previous forms
#let _ranges(spec) = {
  if type(spec) == int {
    ((from: spec, to: spec),)
  } else if type(spec) == str {
    spec.split(",").map(part => {
      let part = part.trim()
      if "-" in part {
        let (a, b) = part.split("-")
        (
          from: if a.trim() == "" { 1 } else { int(a.trim()) },
          to: if b.trim() == "" { none } else { int(b.trim()) },
        )
      } else {
        (from: int(part), to: int(part))
      }
    })
  } else if type(spec) == array {
    spec.map(_ranges).flatten()
  } else {
    panic("Invalid subslide specification: " + repr(spec))
  }
}

// Does subslide `k` match the ranges?
#let _matches(ranges, k) = ranges.any(r => k >= r.from and (r.to == none or k <= r.to))

// Highest subslide explicitly mentioned by the ranges.
#let _max-index(ranges) = ranges.map(r => if r.to != none { r.to } else { r.from }).fold(1, calc.max)

// Shows body only in the subslides matching spec. In the other ones
// the content is removed (it does not take any space).
//
// Usage: #only(2)[...], #only("2-")[...], #only((1, 3))[...]
#let only(spec, body) = {
  let ranges = _ranges(spec)
  metadata((typslides: "mark", max: _max-index(ranges)))
  context if _matches(ranges, _subslide.get()) { body }
}

// Like #only, but the content is hidden instead of removed, so it keeps
// its space in the layout of the slide.
//
// Usage: #uncover("2-")[...]
#let uncover(spec, body) = {
  let ranges = _ranges(spec)
  metadata((typslides: "mark", max: _max-index(ranges)))
  context if _matches(ranges, _subslide.get()) { body } else { hide(body) }
}

// Is this element a #pause marker?
#let _is-pause(c) = (
  type(c) == content
    and c.func() == metadata
    and type(c.value) == dictionary
    and c.value.at("typslides", default: none) == "pause"
)

// Top-level elements of a content block
#let _children(body) = if type(body) == content and repr(body.func()) == "sequence" {
  body.children
} else {
  (body,)
}

// Searches (recursively, as far as it is possible) the highest subslide
// referenced by #only / #uncover inside a content block.
#let _max-index-in(c) = {
  if type(c) != content {
    1
  } else if c.func() == metadata {
    if type(c.value) == dictionary and c.value.at("typslides", default: none) == "mark" { c.value.max } else { 1 }
  } else if c.has("children") {
    c.children.map(_max-index-in).fold(1, calc.max)
  } else if c.has("body") {
    _max-index-in(c.body)
  } else if c.has("child") {
    _max-index-in(c.child)
  } else {
    1
  }
}

// Is this element an item of a list / enum? (they need special care when covered)
#let _is-item(c) = type(c) == content and repr(c.func()) in ("item", "list.item", "enum.item")

// Generates one page per subslide.
//
// Arguments:
//   body: Slide content (may contain #pause, #only and #uncover)
//   subslides: Number of subslides. auto computes it from the pauses and from
//     the #only / #uncover found in the slide. Set it manually if some of them
//     are hidden inside functions (e.g. #framed) that cannot be inspected.
//   make: Function content => ... that builds ONE page (set page(...), etc.)
//
// Note: #pause is detected among the top-level elements of the slide body
// (including list / enum items). Use #uncover / #only for nested content.
#let _subslides(body, subslides, make) = {
  let children = _children(body)
  let pauses = children.enumerate().filter(((i, c)) => _is-pause(c)).map(((i, c)) => i)
  let n = if subslides == auto {
    calc.max(pauses.len() + 1, _max-index-in(body))
  } else {
    subslides
  }

  for k in range(1, n + 1) {
    // Elements shown in this subslide: everything before the k-th pause
    let cut = if k <= pauses.len() { pauses.at(k - 1) } else { children.len() }
    let is-space(c) = repr(c.func()) == "space"
    let before = children.slice(0, cut).filter(c => not _is-pause(c))
    let after = children.slice(cut).filter(c => not _is-pause(c))

    let content = {
      _subslide.update(k)
      before.join()
      if after.len() > 0 {
        // hide does not hide the markers of list items that share a list with
        // visible items, so the covered part is put in its own block. Between
        // two tight list items the gap is the paragraph leading instead of the
        // paragraph spacing, so it is compensated to avoid vertical jumps.
        let item-idx = children.enumerate().filter(((i, c)) => _is-item(c)).map(((i, c)) => i)
        let lo = item-idx.filter(i => i < cut)
        let hi = item-idx.filter(i => i >= cut)
        let tight = if lo.len() > 0 and hi.len() > 0 {
          let (l, h) = (lo.last(), hi.first())
          let same-kind = children.at(l).func() == children.at(h).func()
          let wide = children.slice(l + 1, h).filter(c => c.func() == parbreak).len() > 0
          same-kind and not wide
        } else {
          false
        }
        context {
          if tight { v(par.leading - par.spacing, weak: false) }
          hide(block(width: 100%, after.join()))
        }
      }
      // Next page must already see the extra page (logical page numbers)
      if k < n { _extra-pages.step() }
    }
    make(content)
  }
}

//************************************************************************\\
//                            Helper Functions                            \\
//************************************************************************\\

// Returns formatted page number if page numbers are enabled
//
// Returns: Page number in "current/total" format, or none if disabled
#let _get-page-number() = context {
  if page-numbers.get() {
    // Subslides share the number of their slide
    let current = counter(page).get().first() - _extra-pages.get().first()
    let total = counter(page).final().first() - _extra-pages.final().first()
    [#current / #total]
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
//   back-color: Background color for the slide (default: global default)
//
// Returns: Formatted front slide
#let front-slide(
  title: none,
  subtitle: none,
  authors: none,
  info: none,
  back-color: none,
  margin: auto,
) = context {
  let bg-color = if back-color != none { back-color } else { default-back-color.get() }
  
  set page(fill: bg-color)
  
  _make-frontpage(
    title,
    subtitle,
    authors,
    info,
    theme-color.get(),
    margin,
  )
}

//************************************************************************\\

// Generates a table of contents from registered sections
// Automatically builds outline from title-slide and slide(outlined:  true) entries
// Uses a progress divider to show position in presentation
//
// Arguments:
//   title: Title for the outline slide (default: "Contents")
//   text-size: Font size for outline items (default: 23pt)
//   back-color: Background color for the slide (default: global default)
//
// Returns: A formatted table of contents with clickable links
#let table-of-contents(
  title: "Contents",
  text-size: 23pt,
  back-color: none,
) = context {
  let bg-color = if back-color != none { back-color } else { default-back-color.get() }
  
  set page(fill: bg-color)
  
  text(size: 42pt, weight: "bold")[
    #smallcaps(title)
    #v(-.9cm)
    #_progress-divider(color: theme-color.get())
  ]
  
  set text(size: text-size)
  show linebreak: none
  
  let sections = query(<section>).dedup()
  
  if sections.len() == 0 {
    let subsections = query(<subsection>).dedup()
    pad(enum(..subsections.map(sub => [#link(sub.location(), sub.value) <toc>])))
  } else {
    pad(enum(..sections.map(section => {
      let section-loc = section.location()
      let subsections = query(
        selector(<subsection>).after(section-loc).before(selector(<section>).after(section-loc, inclusive: false)),
      ).dedup()
      
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
//   back-color: Background color for the slide (default: global default)
//
// Returns: A full-page section title with progress divider
#let title-slide(
  body,
  text-size: 42pt,
  back-color: none,
) = context {
  let bg-color = if back-color != none { back-color } else { default-back-color.get() }
  
  set page(fill: bg-color)
  
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
//   back-color: Background color for the slide (default: theme color)
//   body: Content to be displayed
//
// Returns: A full-screen slide with auto-resized centered text
#let focus-slide(
  text-color: white,
  text-size: 60pt,
  back-color: none,
  body,
) = context {
  let bg-color = if back-color != none { back-color } else { theme-color.get() }
  
  set page(
    fill: bg-color,
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
//   back-color: Background color for the slide (default: global default)
//   outlined: Whether to register this slide in TOC (default: false)
//   subslides: Number of subslides (default: auto, computed from #pause / #only / #uncover)
//   body: Slide content
//
// Returns: A formatted content slide with header and optional progress bar
#let slide(
  title: none,
  back-color: none,
  outlined: false,
  margin: none,
  subslides: auto,
  body,
) = context {
  let bg-color = if back-color != none { back-color } else { default-back-color.get() }
  let page-num = _get-page-number()
  
  _subslides(body, subslides, content => {
  set page(
    fill: bg-color,
    header-ascent: if title != none { 65% } else { 66% },
    header: [],
    margin: if margin != none {
      margin
    } else if title != none {
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
  content
  })
}

//************************************************************************\\

// Minimal slide without header or title
// Useful for custom layouts or special content
// Still supports page numbers and progress bar
//
// Arguments: 
//   back-color: Background color for the slide (default: global default)
//   subslides: Number of subslides (default: auto, computed from #pause / #only / #uncover)
//   body: Slide content
//
// Returns: A clean slide with maximum content area
#let blank-slide(
  back-color: none,
  subslides: auto,
  body,
) = context {
  let bg-color = if back-color != none { back-color } else { default-back-color.get() }
  let page-num = _get-page-number()
  
  _subslides(body, subslides, content => {
  set page(
    fill: bg-color,
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
  content
  })
}

//************************************************************************\\

// Creates a bibliography/references slide
// Displays citations from a .bib file with a progress divider
//
// Arguments: 
//   bib-call: The bibliography() function call with your .bib file
//   title: Title for the references section (default: "References")
//   back-color: Background color for the slide (default: global default)
//
// Returns: A formatted bibliography slide
#let bibliography-slide(
  bib-call,
  title: "References",
  back-color: none,
) = context {
  let bg-color = if back-color != none { back-color } else { default-back-color.get() }
  
  set page(fill: bg-color)
  
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