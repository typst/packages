#import "src/utils.typ"
#import "src/layout.typ"
#import "src/blocks.typ"
#import "src/themes.typ" as themes
#import "src/toc.typ"

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

/// A styled block for displaying informational content.
///
/// This function creates a blue-colored block suitable for highlighting
/// informational content, facts, or additional details in your presentation.
///
/// # Example
/// ```typ
/// #info[
///   *Information – Time Complexity*
///   The algorithm runs in `O(n log n)` time.
/// ]
/// ```
#let info = blocks.info

/// A styled block for displaying examples.
///
/// This function creates a purple-colored block suitable for highlighting
/// examples, demonstrations, or sample code in your presentation.
///
/// # Example
/// ```typ
/// #example[
///   *Example – Usage*
///   ```python
///   result = gcd(48, 18)
///   ```
/// ]
/// ```
#let example = blocks.example

/// A styled block for displaying quotations.
///
/// This function creates a neutral gray-colored block suitable for displaying
/// quotes, citations, or referenced text in your presentation.
///
/// # Example
/// ```typ
/// #quote[
///   "The best way to understand an algorithm is to implement it yourself."
///   — Computer Science Professor
/// ]
/// ```
#let quote = blocks.quote

/// A styled block for displaying success messages.
///
/// This function creates a green-colored block suitable for highlighting
/// successful outcomes, achievements, or positive results in your presentation.
///
/// # Example
/// ```typ
/// #success[
///   *Success – Implementation Complete*
///   All test cases pass!
/// ]
/// ```
#let success = blocks.success

/// A styled block for displaying failure messages.
///
/// This function creates a red-colored block suitable for highlighting
/// failures, errors, or issues that need attention in your presentation.
///
/// # Example
/// ```typ
/// #failure[
///   *Failure – Test Failed*
///   The implementation does not handle edge cases correctly.
/// ]
/// ```
#let failure = blocks.failure

/// Creates a section slide with an optional subtitle.
///
/// This function creates a dedicated section title slide with a title and
/// optional subtitle. The slide is styled with the primary theme color.
/// The title will appear in the table of contents.
///
/// # Example
/// ```typ
/// #section-slide(title: "Introduction", subtitle: "Overview of the topic")
/// ```
///
/// # Parameters
/// - `title` (string or content): The section title (required).
/// - `subtitle` (string or content, default: `none`): Optional subtitle displayed below the title.
#let section-slide(title: none, subtitle: none) = {
  assert(title != none, message: "section-slide requires a title")
  if subtitle != none {
    heading(level: 1, [#title #metadata(subtitle) <section-subtitle>])
  } else {
    heading(level: 1, title)
  }
}

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
///   - `text-size` (length, default: `9pt`): Font size of the names and the title.
///   - `secondary-size` (length, default: `7.5pt`): Font size of the institute,
///     the date and the page number, which read as supporting labels.
///   - `min-text-size` (length, default: `7pt`): Smallest size the text is
///     shrunk to before it is allowed to wrap onto another row.
///   - `line-height` (length, default: `13pt`): Height of one footer row. The
///     colored band is `2 * 2pt + line-height * rows` tall for the rows used.
///   - `max-lines` (integer, default: `2`): How many rows the footer may use
///     before compilation fails. The page reserves this much room below the
///     content for every slide, so a taller footer pushes the body up instead of
///     covering it. No label is ever cut: if the footer does not fit into
///     `max-lines` rows, the build fails with a message naming the labels.
///
/// - `theme` (dictionary): Color scheme for the presentation.
///   - `primary` (color, default: `rgb("#003365")`): Primary brand color for headers/footers/titles.
///   - `secondary` (color, default: `rgb("#00649F")`): Secondary accent color.
///   - `background` (color, default: `rgb("#FFFFFF")`): Slide background color.
///   - `main-text` (color, default: `rgb("#000000")`): Body text color.
///   - `sub-text` (color, default: `rgb("#FFFFFF")`): Text color on dark backgrounds.
///   - `sub-text-dimmed` (color, default: `rgb("#FFFFFF")`): Dimmed text color.
///   - `section-subtitle-size` (length, default: `1em`): Font size for section subtitles.
///   - `section-subtitle-position` (string, default: `"inside"`): Where to display section subtitles. Options: `"inside"` (within title box with separator), `"below"` (below title box).
///   - `code-background` (color, default: `luma(240)`): Background color for inline code.
///   - `code-text` (color or none, default: `none`): Text color for inline code.
///   - `blocks` (dictionary): Block-specific colors.
///     - `definition-color`, `warning-color`, `remark-color`, `hint-color`
///     - `info-color`, `example-color`, `quote-color`, `success-color`, `failure-color`
///
/// - `height` (length, default: `12cm`): Slide height (aspect ratio fixed at 16:10).
/// - `table-of-contents` (string, default: `"detailed"`): Style for the table of contents. Options: `"none"`, `"detailed"`, `"simple"`. Use `"none"` to disable the table of contents.
/// - `header` (boolean, default: `true`): Whether to show the navigation header with progress tracker.
/// - `locale` (string, default: `"EN"`): Language locale, either `"EN"` or `"RU"`.
/// - `content` (content): The content of your presentation.
///
/// # Slide Structure
/// The presentation uses standard Typst headings to structure slides:
/// - Level 1 headings (`= Section`): Creates a dedicated section title slide.
/// - `#section-slide(title: "Title", subtitle: "Subtitle")`: Creates a section slide with optional subtitle.
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
///   table-of-contents: "detailed",  // or "simple" or "none"
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
  table-of-contents: "detailed",
  header: true,
  locale: "EN",
  content
) = {
  assert(locale in ("RU", "EN"))
  assert(table-of-contents in ("none", "detailed", "simple"))

  let theme-state = state("pepentation-theme", none)

  let title-slide-config = utils.merge-dictionary((
    enable: false, title: none, authors: (), institute: none
  ), title-slide)

  let footer-config = utils.merge-dictionary((
    enable: false,
    title: none,
    institute: none,
    authors: (),
    date: utils.today(locale),
    text-size: layout.footer-text-size,
    secondary-size: layout.footer-secondary-size,
    min-text-size: layout.footer-min-text-size,
    line-height: layout.footer-line-height,
    max-lines: layout.footer-max-lines,
  ), footer)
  // Ensure authors is always an array
  if footer-config.authors == none {
    footer-config.authors = ()
  }

  let default-theme = themes.default-theme
  let theme-config = utils.merge-nested-dictionary(default-theme, theme)

  theme-state.update(theme-config)

  let page-width = height * 16 / 10
  // The reservation is the height of the tallest band the configuration allows,
  // not of the band this footer ends up needing: a page margin cannot depend on
  // measured text, and a footer that outgrew the margin would cover slide
  // content instead of pushing it up. A footer that fits into fewer rows than
  // that leaves the rest of the margin empty above the band.
  let footer-h = layout.footer-reserved-height(footer-config)
  // Absolute on purpose: an `em` here would be relative to the default text
  // size, while the body text below is set to 14pt, and the header needs to do
  // exact arithmetic with the page margins.
  let page-margin = 11pt
  // The margin only has to keep the band off the content, and `footer-gap` is a
  // length instead of an `em` to stay on the same scale as the band.
  let bottom-margin = if footer-config.enable { footer-h + layout.footer-gap } else { 0pt }

  // Centred: the band is as wide as the page, so centring it is what makes it
  // reach both page edges, exactly like the navigation header.
  let footer-content = align(bottom + center,
    layout.create-footer(footer-config, theme-config, page-width)
  )

  set page(
    width: page-width,
    height: height,
    fill: theme-config.background,
    margin: (top: 0em, right: page-margin, left: page-margin, bottom: bottom-margin),
    header: none,
    footer: footer-content,
    // The band is meant to sit on the bottom edge of the page.
    footer-descent: 0pt,
  )

  set text(size: 14pt, fill: theme-config.main-text)
  set par(first-line-indent: (amount: 1em, all: true), justify: true)
  set heading(numbering: "1.")

  let code-bg = theme-config.code-background
  let code-text = theme-config.code-text
  show raw.where(block: false): it => {
    let styled-content = if code-text != none {
      text(fill: code-text, it.text)
    } else {
      it.text
    }
    box(
      fill: code-bg,
      inset: (x: 3pt, y: 0pt),
      outset: (y: 3pt),
      radius: 5pt,
      styled-content
    )
  }

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

  if table-of-contents != "none" {
    pagebreak()
    set page(header: none)
    context toc.render-toc(table-of-contents, theme-config, locale)
  }

show heading.where(level: 1): it => {
  // Read before the page break, because a section that opts out of its slide
  // must not break the page or suppress the header either.
  let parts = utils.heading-parts(it.body)
  if parts.section-slide == false {
    // Structural only: the heading still numbers, still appears in the table of
    // contents and still owns the slides below it.
    return none
  }
  pagebreak(weak: true)
  set page(header: none)
  let title-content = parts.title
  let subtitle = parts.subtitle
  let subtitle-position = theme-config.section-subtitle-position
  align(center + horizon, {
    // A title and a subtitle read as labels, so they are neither hyphenated nor
    // justified. Turning justification off also lets a title that runs over two
    // lines centre itself instead of being stretched.
    set par(justify: false)
    if subtitle != none and subtitle-position == "inside" {
      box(
        fill: theme-config.primary,
        radius: 15pt, inset: 2em, width: 100%,
        [
          #text(
            size: 2.2em,
            weight: "bold",
            fill: theme-config.sub-text,
            hyphenate: false,
            title-content,
          )
          #line(length: 50%, stroke: theme-config.sub-text-dimmed + 1pt)
          #v(0.3em)
          #text(
            size: theme-config.section-subtitle-size,
            weight: "regular",
            fill: theme-config.sub-text-dimmed,
            hyphenate: false,
            subtitle,
          )
        ]
      )
    } else if subtitle != none and subtitle-position == "below" {
      box(
        fill: theme-config.primary,
        radius: 15pt, inset: 2em, width: 100%,
        text(
          size: 2.2em,
          weight: "bold",
          fill: theme-config.sub-text,
          hyphenate: false,
          title-content,
        )
      )
      v(0.5em)
      align(center, text(
        size: theme-config.section-subtitle-size,
        weight: "regular",
        fill: theme-config.sub-text-dimmed,
        hyphenate: false,
        subtitle,
      ))
    } else {
      box(
        fill: theme-config.primary,
        radius: 15pt, inset: 2em, width: 100%,
        text(
          size: 2.2em,
          weight: "bold",
          fill: theme-config.sub-text,
          hyphenate: false,
          title-content,
        )
      )
    }
  })
}

  let render-slide(title) = {
    pagebreak(weak: true)
    if header {
      grid(box(
        width: 100%,
        outset: (left: 2em, right: 2em, top: 1em, bottom: 0.2em),
        fill: theme-config.primary,
        layout.create-header(theme-config, page-width - page-margin * 2)
      ))
    }

    if title != [] {
      set align(center)
      set text(size: 20pt)
      box(inset: 0.2em, text(weight: "bold", title))
      v(-0.6em)
    }
  }
  
  show heading.where(level: 2): it => render-slide(it.body)
  show heading.where(level: 3): it => render-slide(it.body)

  content
}
