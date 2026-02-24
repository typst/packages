#import "src/utils.typ"
#import "src/layout.typ"
#import "src/blocks.typ"

/// A styled block for displaying definitions.
/// 
/// This function creates a gray-colored block suitable for highlighting
/// definitions, theorems, or important concepts in your presentation.
///
/// # Example
/// ```typ
/// #definition[
///   *Euclid's Algorithm*
///   An efficient method for computing the GCD.
/// ]
/// ```
#let definition = blocks.definition

/// A styled block for displaying warnings.
///
/// This function creates a red-colored block suitable for highlighting
/// warnings, cautions, or important notices in your presentation.
///
/// # Example
/// ```typ
/// #warning[
///   *Warning – undefined case*
///   `gcd(0, 0)` is mathematically undefined.
/// ]
/// ```
#let warning = blocks.warning

/// A styled block for displaying remarks.
///
/// This function creates an orange-colored block suitable for highlighting
/// remarks, notes, or additional observations in your presentation.
///
/// # Example
/// ```typ
/// #remark[
///   *Remark – symmetry property*
///   `gcd(a, b)` should always equal `gcd(b, a)`.
/// ]
/// ```
#let remark = blocks.remark

/// A styled block for displaying hints.
///
/// This function creates a green-colored block suitable for highlighting
/// hints, tips, or helpful suggestions in your presentation.
///
/// # Example
/// ```typ
/// #hint[
///   *Hint – simplifying fractions*
///   Once `gcd(a,b)` works, you can reduce fractions to lowest terms.
/// ]
/// ```
#let hint = blocks.hint

/// Sets up the presentation with customizable options.
///
/// This is the main function that configures the entire presentation layout,
/// including page dimensions, theme colors, headers, footers, and slide structure.
/// It should be called at the beginning of your document using `#show: setup-presentation.with(...)`.
///
/// # Parameters
/// - `title-slide` (dictionary): Configuration for the title slide.
///   - `enable` (boolean, default: `false`): Whether to show a title slide.
///   - `title` (string or none, default: `none`): Full title displayed on title page.
///   - `authors` (array of strings, default: `()`): Array of author names.
///   - `institute` (string or none, default: `none`): Institute or organization name.
///
/// - `footer` (dictionary): Configuration for the footer on each slide.
///   - `enable` (boolean, default: `false`): Whether to show footer on slides.
///   - `title` (string or none, default: `none`): Short title displayed in center of footer.
///   - `authors` (array of strings, default: `()`): Array of short author names (left side).
///   - `institute` (string or none, default: `none`): Short institute name (left side).
///   - `date` (string or content, default: current date): Date displayed (right side).
///
/// - `theme` (dictionary): Color scheme for the presentation.
///   - `primary` (color, default: `rgb("#003365")`): Primary brand color for headers/footers/titles.
///   - `secondary` (color, default: `rgb("#00649F")`): Secondary accent color.
///   - `background` (color, default: `rgb("#FFFFFF")`): Slide background color.
///   - `main-text` (color, default: `rgb("#000000")`): Body text color.
///   - `sub-text` (color, default: `rgb("#FFFFFF")`): Text color on dark backgrounds.
///   - `sub-text-dimmed` (color, default: `rgb("#FFFFFF")`): Dimmed text color.
///
/// - `height` (length, default: `12cm`): Slide height (aspect ratio fixed at 16:10).
/// - `table-of-contents` (boolean, default: `false`): Whether to show an interactive table of contents.
/// - `header` (boolean, default: `true`): Whether to show the navigation header with progress tracker.
/// - `locale` (string, default: `"EN"`): Language locale, either `"EN"` or `"RU"`.
/// - `content` (content): The content of your presentation.
///
/// # Slide Structure
/// The presentation uses standard Typst headings to structure slides:
/// - Level 1 headings (`= Section`): Creates a dedicated section title slide.
/// - Level 2 headings (`== Slide Title`): Creates a new main slide with title.
/// - Empty Level 2 headings (`== `): Creates a slide without a title (excluded from ToC).
/// - Level 3 headings (`=== Subsection`): Creates a slide with title, excluded from ToC.
///
/// # Example
/// ```typ
/// #show: setup-presentation.with(
///   title-slide: (
///     enable: true,
///     title: "My Presentation",
///     authors: ("John Doe", "Jane Smith"),
///     institute: "University of Example",
///   ),
///   footer: (
///     enable: true,
///     title: "Short Title",
///     authors: ("J. Doe", "J. Smith"),
///   ),
///   table-of-contents: true,
///   header: true,
///   locale: "EN"
/// )
///
/// = Introduction
/// == First Slide
/// Your content here...
/// ```
#let setup-presentation(
  title-slide: none,
  footer: none,
  theme: none,
  height: 12cm,
  table-of-contents: false,
  header: true,
  locale: "EN",
  content
) = {
  assert(locale in ("RU", "EN"))

  let title-slide-config = utils.merge-dictionary((
    enable: false, title: none, authors: (), institute: none
  ), title-slide)

  let footer-config = utils.merge-dictionary((
    enable: false, title: none, institute: none, authors: (), date: utils.today(locale)
  ), footer)

  let theme-config = utils.merge-dictionary((
    primary: rgb("#003365"),
    secondary: rgb("#00649F"),
    background: rgb("#FFFFFF"),
    main-text: rgb("#000000"),
    sub-text: rgb("#FFFFFF"),
    sub-text-dimmed: rgb("#FFFFFF"),
  ), theme)

  let page-width = height * 16 / 10
  let footer-h = layout.estimate-footer-height(footer-config, theme-config, height)
  let bottom-margin = if footer-config.enable { footer-h + 1em } else { 0em }

  let footer-content = align(bottom, 
    box(width: 100%, layout.create-footer(footer-config, theme-config, page-width, footer-h))
  )

  set page(
    width: page-width,
    height: height,
    fill: theme-config.background,
    margin: (top: 0em, right: 1em, left: 1em, bottom: bottom-margin),
    header: none,
    footer: footer-content, 
  )
  
  set text(size: 14pt, fill: theme-config.main-text)
  set par(first-line-indent: (amount: 1em, all: true), justify: true)
  
  show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 5pt,
  )

  if title-slide-config.enable {
    set page(header: none, footer: none, margin: 2em)
    align(center + horizon, box(
      fill: theme-config.primary,
      radius: 15pt, inset: 2em, width: 100%,
      text(size: 2.2em, weight: "bold", fill: theme-config.sub-text, title-slide-config.title)
    ))
    align(center, text(size: 1.8em, title-slide-config.authors.join(", ")))
    align(center, text(size: 1.4em, title-slide-config.institute))
  }

  if table-of-contents {
    pagebreak() 
    set page(header: none)
    show outline.entry.where(level: 1): set text(size: 1.6em)
    show outline.entry.where(level: 2): set text(size: 1.2em)
    show outline.entry: it => if it.element.body == [] { none } else { it }

    let toc-title = if locale == "RU" { [*Оглавление*] } else { [*Table of contents*] }
    align(center, text(size: 2.2em)[#v(0.2em) #toc-title])
    columns(2, outline(depth: 2, title: none))
  }

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    set page(header: none)
    align(center + horizon, box(
      fill: theme-config.primary,
      radius: 15pt, inset: 2em, width: 100%,
      text(size: 2.2em, weight: "bold", fill: theme-config.sub-text, it.body)
    ))
  }

  let render-slide(title) = {
    pagebreak(weak: true)
    if header {
      grid(box(
        width: 100%,
        outset: (left: 2em, right: 2em, top: 1em, bottom: 0.2em),
        fill: rgb("#142d69"), 
        layout.create-header(theme-config)
      ))
    }
    set align(center)
    set text(size: 20pt)
    box(inset: 0.2em, text(weight: "bold", title))

    v(-0.6em)
  }
  
  show heading.where(level: 2): it => render-slide(it.body)
  show heading.where(level: 3): it => render-slide(it.body)

  content
}
