// Book entry point — a KOMA-inspired authoring path over satz's shared class.

#import "../class.typ": document-class
#import "../defaults.typ": defaults, merge
#import "../themes.typ": theme-config
#import "components.typ": book-style

#let book-running-heading = state("satz-book-running-heading", (
  number: none,
  chapter: [],
))

/// A configurable book with a title page, front matter, contents, and main matter.
///
/// Common choices are direct arguments; less common layout details stay available
/// through `config`. Put preliminary pages before `book-contents()`, then place
/// numbered chapters inside `book-mainmatter[...]`.
///
/// ```example
/// #import "@local/satz:0.2.0": book, book-contents, book-mainmatter
/// #show: book.with(
///   title: [The Maths Behind Your Analysis],
///   author: [Your Name],
///   accent: teal,
///   font: "Georgia",
/// )
///
/// = How to use this book
/// ...
/// #book-contents()
/// #book-mainmatter[
///   = Chapter one
///   ...
/// ]
/// ```
///
/// - title (content, none): title shown on the typographic cover; required
///   unless `cover-image` supplies a complete cover
/// - cover-image (str, none): full-page image replacing the typographic cover
/// - subtitle (content, none): optional subtitle
/// - author (content, none): author or recipient line
/// - eyebrow (content, none): small line above the title
/// - note (content, none): small text near the bottom of the cover
/// - date (content, none): date near the bottom of the cover
/// - accent (color, none): heading and component accent; defaults to `#23616B`
/// - ink (color, none): cover title and chapter-heading color; defaults to `#24313B`
/// - theme (str, none): `neutral` (default), `slate`, `soft-jade`, `soft-slate`,
///   `warm-editorial`, `plum`, or `soft-rose`; direct arguments and `config` win
/// - font (str, none): body family; `none` keeps `"Libertinus Serif"`
/// - math-font (str, none): equation family; `none` keeps `"New Computer Modern Math"`
/// - font-size (length, none): body size; `none` keeps 11pt
/// - leading (length, none): line-box gap; `none` keeps 0.74em
/// - paragraph-spacing (length, none): paragraph gap; `none` keeps 14pt
/// - paper (str, none): paper name; `none` keeps `"a4"`
/// - margin (dictionary, none): page margins; `none` keeps left 27mm, right
///   25mm, top 25mm, bottom 27mm
/// - binding (auto, alignment, none): inside edge for two-sided pages. `auto`
///   keeps the book's left binding; `none` disables two-sided layout
/// - binding-correction (length): extra room at the binding edge; defaults to 5mm
/// - running-headers (str): `"bottom"` (default), `"top"`, or `"none"`.
///   `config.book.running-headers` takes precedence over this direct argument
/// - config (dictionary): partial nested overrides; nested dictionaries merge recursively.
///   Template defaults: A4; margins `(left: 27mm, right: 25mm, top: 25mm, bottom: 27mm)`; left binding with `5mm` correction; Libertinus Serif `11pt`; New Computer Modern Math; `0.74em` leading; `14pt` paragraph gap; no page headers; neutral black accent/ink by default. `theme: "slate"` selects the former blue-gray palette.
///   Direct style arguments can be overridden by config. book.running-headers overrides the running-headers argument; book also accepts headings.h1-number-size.
///   The following values are the shared baseline; template defaults above override them.
///
/// Every key below is nested under its group, for example
/// `typography.font` means `(typography: (font: ...))`.
///
/// **Page (`page`)**
/// - `paper` (paper name or custom size; `"a4"`): page format.
/// - `margin` (dictionary of edge lengths; 2.5cm on every edge): page margins.
///   Use `top`, `bottom`, `left`, and `right`; two-sided layouts may instead
///   derive inside/outside margins. `x` and `y` are shorthand for horizontal
///   and vertical margins.
/// - `binding` (`none`, `left`, or `right`; `none`): enables two-sided layout
///   and selects the binding edge where supported.
/// - `binding-correction` (length; `0pt`): extra space at the binding edge.
/// - `headers` (bool; `false`): enables the template's running header where
///   implemented.
/// - `columns` (positive integer; `1`): number of text columns where supported.
/// - `column-gutter` (length; `5mm`): gap between columns.
///
/// **Typography (`typography`)**
/// - `font` (font name; `"Libertinus Serif"`): body text typeface.
/// - `math-font` (font name or `auto`; `auto`): math typeface. `auto` leaves
///   math font selection to Typst.
/// - `mono-font` (font name or `auto`; `auto`): monospace typeface. `auto`
///   leaves raw text in Typst's native style.
/// - `size` (length; `11pt`): body text size.
/// - `line-spacing` (positive number or `none`; `none`): optional baseline to
///   baseline distance as a multiple of body size, for example `1.25`. Satz
///   uses the selected font's metrics to calculate leading. When set, it
///   overrides `leading`.
/// - `leading` (length; `0.65em`): Typst's gap between adjacent line boxes.
///   This is a direct length, not a baseline-distance multiplier.
/// - `list-spacing` (non-negative number; `0.5`): additional gap between list
///   items as a fraction of the calculated body baseline distance. Zero adds
///   no extra gap. The baseline follows `line-spacing` when set, or the
///   selected font metrics and `leading` otherwise.
/// - `paragraph-spacing` (length; `1.2em`): vertical gap between paragraphs.
/// - `first-line-indent` (bool; `false`): whether to indent the first line of
///   every paragraph. `true` uses one em (the current body font size, so 11pt
///   at an 11pt text size), including the first paragraph in a
///   document/container and paragraphs immediately after blocks such as
///   headings; `false` uses no indent. This horizontal measure is independent
///   of vertical `line-spacing` and `paragraph-spacing` and does not change
///   either setting.
/// - `hyphenate` (bool; `false`): automatic word hyphenation in body text.
/// - `justify` (bool; `true`): justify body paragraphs where supported.
///
/// **Headings (`headings`)**
/// - `numbering` (Typst numbering pattern/function or `none`; `"1.1"`):
///   numbering for native headings.
/// - `hyphenate` (bool; `false`): allow line breaks by hyphenation in headings.
/// - `h1-pagebreak` (bool; `false`): start level-one headings on a new page
///   where supported.
/// - `spacing` (`"koma"` or `"native"`; `"koma"`): `"koma"` derives heading
///   gaps from KOMA-style baseline skips and font metrics; `"native"` keeps
///   Typst's native spacing policy.
/// - `h1-size` … `h4-size` (lengths; `14pt`, `12pt`, `11pt`, `11pt`): text size
///   for heading levels one through four.
/// - `h1-above` … `h4-above` (`auto` or length; `auto`): gap before each level.
///   `auto` follows the selected spacing policy.
/// - `h1-below` … `h4-below` (`auto` or length; `auto`): gap after each level.
///   An explicit length overrides the template's automatic value.
///
/// **Journal (`journal`)**
/// - `header-below` (length; `1.5em`): gap after the full entry heading/date
///   block and before the notes.
/// - `running-gutter` (length; `1em`): gap between columns in a running header.
/// - `running-leading` (length; `0.35em`): line gap in a multi-line running
///   header.
/// - `running-header-size` (length; `9pt`): journal running-header text size.
/// - `date-size` (length; `10pt`): journal date text size.
/// - `keywords-size` (length; `9pt`): journal keyword text size.
/// Journal lists use the shared `typography.list-spacing` setting.
///
/// **Decorative text and lists (`decorative`)**
/// - `header-size` (length; `9pt`): running-header text size.
/// - `footer-size` (length; `10pt`): footer text size where implemented.
/// - `date-size` (length; `10pt`): date text size where implemented.
/// - `keywords-size` (length; `9pt`): keyword text size where implemented.
/// General list spacing uses `typography.list-spacing`. DFG templates also
/// accept the extension fields `list-indent`, `list-body-indent`,
/// `list-block-spacing`, and `list-spacing` in this group. These control DFG
/// geometry and a DFG-specific length override.
///
/// **Page number (`page-footer`)**
/// - `format` (Typst numbering pattern/function; `"1"`): page-number format.
/// - `size` (length; `10pt`): page-number text size.
/// - `weight` (Typst font weight; `"regular"`): page-number text weight.
///
/// **Line numbers (`line-numbers`)**
/// - `enabled` (bool; `false`): show line numbers in templates that support
///   draft line numbering.
/// - `format` (Typst numbering pattern; `"1"`): line-number format.
/// - `scope` (`"document"` or `"page"`; `"document"`): keep numbering
///   continuous across pages or restart on each page.
/// - `size` (length; `8pt`): line-number text size.
/// - `color` (color; `#64748B`): line-number color.
/// - `clearance` (`auto` or length; `auto`): gap between numbers and body text.
///
/// **Links (`links`)**
/// - `color` (color; `#0563C1`): color of internal references.
/// - `url-color` (color; `#0563C1`): color of external URLs.
///
/// **Tables (`tables`)**
/// - `stroke` (length; `0.5pt`): default rule thickness for shared table
///   helpers.
/// - `inset` (length or dictionary; `(x: 8pt, y: 4pt)`): cell padding. A
///   dictionary can set horizontal and vertical padding independently.
/// - `font-size` (length; `10pt`): text size in shared styled tables.
/// - `caption-position` (`top` or `bottom`; `top`): caption location in the
///   scientific-table show rule.
/// - `caption-gap` (length; `6pt`): space between a table caption and table.

/// **Figures (`figures`)**
/// - `placement` (`auto`, `none`, or vertical alignment; `none`): native
///   placement policy for figures, including tables represented as figures.
///   `none` keeps them in source order; `auto` lets Typst place them at a
///   suitable page edge. Templates may override this baseline.
///
/// **Callouts (`callouts`)**
/// - `inset` (length; `9pt`): inner padding.
/// - `radius` (length; `3pt`): corner radius.
/// - `stroke` (length; `0.8pt`): border thickness.
/// - `title-below` (length; `1em`): gap below a callout title.
/// - `paragraph-spacing` (length; `1em`): gap between callout paragraphs.
/// - `list-spacing` (length; `1.2em`): gap between callout list items.
///
/// **Captions (`captions`)**
/// - `size` (length; `10pt`): caption text size.
/// - `weight` (Typst font weight; `"regular"`): caption text weight.
/// - `alignment` (Typst alignment; `left`): caption alignment when not hanging.
/// - `label-weight` (Typst font weight; `"regular"`): weight of the caption
///   label, independently of the rest of the caption.
/// - `hanging` (boolean; `true`): put the label in its own column so wrapped
///   lines align with the caption text. Set to `false` for inline labels.
///
/// **Contents (`toc`)**
/// - `depth` (`none` or non-negative integer; `none`): included heading depth.
///   In report/thesis documents, `0` disables the automatic contents.
/// - `title` (content or `none`; `[Table of Contents]`): title above the list;
///   `none` omits it.
/// - `indent` (`auto` or length; `auto`): indentation of nested entries.
/// - `entry-size` (length; `10pt`): entry text size.
/// - `leading` (length; `0.65em`): line gap in wrapped entries.
/// - `entry-above` (length; `0.65em`): gap between ordinary entries.
/// - `main-entry-above` (length; `1.25em`): extra gap before main-section
///   entries.
/// - `title-below` (length; `1.5em`): gap between title and first entry.
/// - `below` (length; `2em`): gap after the contents.
///
/// **List of Figures (`lof`) and List of Tables (`lot`)**
/// Both groups use the same fields and meanings as `toc`, with these defaults:
/// `depth: none` (automatic depth), `title: [List of Figures]` or
/// `[List of Tables]`, `indent: auto`, `entry-size: 10pt`, `leading: 0.65em`,
/// `entry-above: 0.85em`, `title-below: 1.5em`, and `below: 2em`.
/// - `compact` (bool; `false`): when true, show only the figure/table label
///   and page number, omitting caption text.
///
/// **Bibliography (`bibliography`)**
/// - `style` (CSL style name; `"apa"`): citation style where bibliography
///   support is enabled.
///
/// **Colors (`colors`)**
/// - `bg-paper` (color; `white`): page or paper background.
/// - `bg-subtle` (color; `white`): subtle surface/background color.
/// - `brand-primary` (color; `black`): primary brand and heading accent.
/// - `brand-accent` (color; `black`): secondary accent.
/// - `text-main` (color; `black`): primary body text.
/// - `text-muted` (color; `black`): secondary or muted text.
///
/// Some templates add validated settings not present in this baseline,
/// including `page.header-ascent`, `headings.h1-number-size`, and
/// `decorative.list-indent`, `decorative.list-body-indent`, `decorative.list-spacing`,
/// and `decorative.list-block-spacing`. Consult the relevant template's API and
/// the configuration reference before using template-specific keys.
///
/// With `math-font: auto`, Typst selects its default math font. The Typst CLI
/// embeds New Computer Modern Math, so users do not need to install it.
/// Template defaults may differ from this shared baseline.
///
/// For details about which templates consume each key and for template-specific
/// overrides, see the versioned configuration reference.
///
/// - body (content): preliminary pages and book structure
#let book(
  body,
  title: none,
  cover-image: none,
  subtitle: none,
  author: none,
  eyebrow: none,
  note: none,
  date: none,
  accent: none,
  ink: none,
  theme: "neutral",
  paper: none,
  margin: none,
  math-font: none,
  font: none,
  font-size: none,
  leading: none,
  paragraph-spacing: none,
  binding: auto,
  binding-correction: none,
  running-headers: "bottom",
  config: (:),
) = {
  assert(title != none or cover-image != none,
    message: "Book requires either `title` or `cover-image`.")
  assert(cover-image == none or type(cover-image) == str,
    message: "Book `cover-image` must be a file path string or none.")
  let default-accent = rgb("#23616B")
  let default-link = color.mix((default-accent, 60%), (black, 40%), space: rgb)
  let book-defaults = merge(defaults, (
    page: (
      paper: "a4",
      margin: (left: 27mm, right: 25mm, top: 25mm, bottom: 27mm),
      binding: left,
      binding-correction: 5mm,
      headers: false,
    ),
    typography: (
      font: "Libertinus Serif",
      math-font: "New Computer Modern Math",
      size: 11pt,
      leading: 0.74em,
      paragraph-spacing: 14pt,
      first-line-indent: false,
      hyphenate: true,
      justify: true,
    ),
    page-footer: (weight: "regular"),
    headings: (
      numbering: "1",
      h1-size: 18pt,
      h1-number-size: 25pt,
      h1-below: 33pt,
      h2-size: 12pt,
      h3-size: 11pt,
    ),
    colors: (
      bg-paper: white,
      brand-primary: default-accent,
      brand-accent: default-accent,
      text-main: black,
      text-muted: luma(110),
    ),
    links: (color: default-link, url-color: default-link),
    book: (
      ink: rgb("#24313B"),
      contents: (
        title-before: 24.5pt,
        title-after: 26pt,
        title-size: 17pt,
        entry-size: 10pt,
        entry-spacing: 11.8pt,
      ),
      worked-example: (
        inset: 27pt,
        above: 26pt,
        below: 27pt,
        label-gap: 0pt,
        label-size: 9pt,
        body-size: 9pt,
      ),
      exercise: (
        grid-gap: 11pt,
        group-gap: 20pt,
      ),
      running-headers: running-headers,
      footer-dy: 5pt,
      cover-top: 28mm,
      cover-eyebrow-size: 14.3pt,
      cover-eyebrow-below: 14mm,
      cover-title-size: 25pt,
      cover-title-leading: 8pt,
      cover-title-below: 13.5mm,
      cover-subtitle-size: 14.3pt,
      cover-subtitle-leading: 6.5pt,
      cover-subtitle-below: 21.6mm,
      cover-rule-width: 0.8pt,
      cover-author-size: 12pt,
      cover-author-below: 3pt,
      cover-note-size: 10pt,
      cover-note-below: 11.2mm,
      cover-date-dy: 6.5pt,
    ),
    toc: (depth: 0),
  ))
  let themed-defaults = merge(book-defaults, theme-config(theme))
  let themed-defaults = merge(themed-defaults, (book: (ink: themed-defaults.colors.text-main)))
  let accent-link = if accent != none { color.mix((accent, 60%), (black, 40%), space: rgb) } else { none }
  let direct-config = (
    page: (:
      ..(if paper != none { (paper: paper) } else { (:) }),
      ..(if margin != none { (margin: margin) } else { (:) }),
      ..(if binding != auto { (binding: binding) } else { (:) }),
      ..(if binding-correction != none { (binding-correction: binding-correction) } else { (:) }),
    ),
    typography: (:
      ..(if font != none { (font: font) } else { (:) }),
      ..(if font-size != none { (size: font-size) } else { (:) }),
      ..(if leading != none { (leading: leading) } else { (:) }),
      ..(if paragraph-spacing != none { (paragraph-spacing: paragraph-spacing) } else { (:) }),
      ..(if math-font != none { (math-font: math-font) } else { (:) }),
    ),
    colors: (:
      ..(if accent != none { (brand-primary: accent, brand-accent: accent) } else { (:) }),
    ),
    links: (:
      ..(if accent-link != none { (color: accent-link, url-color: accent-link) } else { (:) }),
    ),
    book: (:
      ..(if ink != none { (ink: ink) } else { (:) }),
    ),
  )
  let c = merge(merge(themed-defaults, direct-config), config)
  assert(
    c.book.running-headers in ("bottom", "top", "none"),
    message: "book running-headers must be \"bottom\", \"top\", or \"none\".",
  )
  let class-config = merge(c, (page: (headers: c.book.running-headers == "top")))

  document-class(kind: "book", config: class-config, [
    #book-style.update((
      accent: c.colors.brand-primary,
      ink: c.book.ink,
      contents: c.book.contents,
      worked-example: c.book.worked-example,
      exercise: c.book.exercise,
      running-headers: c.book.running-headers,
      footer-dy: c.book.footer-dy,
      footer: c.colors.text-main,
      grid: rgb("#D2D2D2"),
      grid-width: 0.2pt,
      footer-size: c.page-footer.size,
      footer-weight: c.page-footer.weight,
      numbering: c.headings.numbering,
    ))
    #set page(numbering: none)
    #set heading(numbering: none)
    #show math.equation: set text(font: c.typography.math-font)
    #show heading.where(level: 1): it => context {
      let style = book-style.get()
      let number = if it.numbering == none { none } else { counter(heading).display(it.numbering) }
      book-running-heading.update((number: number, chapter: it.body))
      [
        #pagebreak(weak: true)
        #v(19pt)
        #if number != none { counter("satz-exercise").update(0) }
        #block(above: 0pt, below: c.headings.h1-below)[
          #if number != none {
            place(top, dx: -48pt)[
              #text(size: c.headings.h1-number-size, fill: style.accent, weight: "bold")[#number]
            ]
          }
          #move(dy: 5.5pt)[
            #text(size: c.headings.h1-size, fill: style.ink, weight: "bold")[#it.body]
          ]
        ]
      ]
    }
    // Subsection gaps come from the shared KOMA spacing policy. Keep the
    // chapter opener custom, but don't give level two a competing block rule.
    #show heading.where(level: 2): set text(size: c.headings.h2-size, fill: c.colors.brand-primary, weight: "bold")
    #show heading.where(level: 2): set heading(numbering: none)
    #show heading.where(level: 3): set text(size: c.headings.h3-size, fill: c.colors.text-main, weight: "bold")
    #show heading.where(level: 4): set text(size: c.headings.h4-size, fill: c.colors.text-main, weight: "bold")
    #if cover-image != none {
      {
        set page(margin: 0pt, footer: none)
        image(cover-image, width: 100%, height: 100%, fit: "cover")
      }
    } else {
      set page(footer: none)
      block(width: 100%, height: 100%)[
        #v(c.book.cover-top)
        #if eyebrow != none { block(below: c.book.cover-eyebrow-below, text(size: c.book.cover-eyebrow-size, fill: c.colors.brand-primary)[#eyebrow]) }
        #block(below: c.book.cover-title-below)[
          #set par(leading: c.book.cover-title-leading)
          #text(size: c.book.cover-title-size, weight: "bold", fill: c.book.ink)[#title]
        ]
        #if subtitle != none {
          block(below: c.book.cover-subtitle-below)[
            #set par(leading: c.book.cover-subtitle-leading)
            #text(size: c.book.cover-subtitle-size)[#subtitle]
          ]
        }
        #line(length: 100%, stroke: c.book.cover-rule-width)
        #v(6mm)
        #if author != none {
          block(below: c.book.cover-author-below)[
            #set par(leading: 0.5em)
            #text(size: c.book.cover-author-size)[#author]
          ]
        }
        #v(1fr)
        #if note != none { block(below: c.book.cover-note-below, text(size: c.book.cover-note-size)[#note]) }
        #if date != none { move(dy: c.book.cover-date-dy, text(size: 10pt)[#date]) }
      ]
    }
    #pagebreak(to: "odd")
    #counter(page).update(1)
    #set page(numbering: "i")
    #set page(footer: context {
      let n = counter(page).get().first()
      if n > 0 {
        let folio = text(size: c.page-footer.size, weight: c.page-footer.weight, fill: c.colors.text-main, counter(page).display())
        let positioned = move(dy: c.book.footer-dy, folio)
        if calc.rem(n, 2) == 0 { align(left, positioned) } else { align(right, positioned) }
      }
    })
    #body
  ])
}

// Shared footer for Arabic main matter, appendices, and back matter.
/// Draw the running footer used on book main-matter, appendix, and back-matter pages.
///
/// The footer accepts the resolved internal style record created by `book()`.
/// It prints an Arabic page number on chapter-opening pages. Other pages show
/// the configured running chapter label and page number when
/// `book.running-headers` is `"bottom"`, or only the page number for `"top"`
/// and `"none"`. Even and odd pages place these items on opposite outer edges.
///
/// - style (dictionary): resolved book style with `footer-size`,
///   `footer-weight`, `footer` color, `footer-dy`, `running-headers`, and the
///   current chapter/number state. This is an internal helper; configure these
///   values through `book()` rather than calling this function directly.
/// -> content: positioned running footer or page number
#let book-page-footer(style) = context {
  let n = counter(page).get().first()
  if n > 0 {
    let d = counter(page).display()
    let folio = text(size: style.footer-size, weight: style.footer-weight, fill: style.footer, d)
    let opening = query(heading.where(level: 1)).any(h => h.location().page() == here().page())
    if style.running-headers == "bottom" and not opening {
      let is-even = calc.rem(n, 2) == 0
      let current = book-running-heading.get()
      let title = if is-even {
        if current.number == none { smallcaps(current.chapter) } else { [CHAPTER #current.number] }
      } else {
        smallcaps(current.chapter)
      }
      let running-line = if is-even {
        grid(columns: (1fr, 1fr),
          align(left)[#text(size: 8pt, fill: rgb("#666666"))[#d #h(0.8em) #title]],
          [],
        )
      } else {
        grid(columns: (1fr, 1fr),
          [],
          align(right)[#text(size: 8pt, fill: rgb("#666666"))[#title #h(0.8em) #d]],
        )
      }
      move(dy: style.footer-dy, running-line)
    } else {
      let positioned = move(dy: style.footer-dy, folio)
      if calc.rem(n, 2) == 0 { align(left, positioned) } else { align(right, positioned) }
    }
  }
}

/// Insert a styled contents page at the current location.
///
/// This inserts a page break, prints a book-styled title, then renders Typst's
/// native outline. Links and page numbers update when the document is compiled.
/// By default only level-one chapter headings appear. Nested heading levels can
/// be included by increasing `depth`. The appearance follows the active book
/// style. Its title position and entry typography/spacing are set by
/// `book.contents.title-before` (24.5pt), `title-after` (26pt),
/// `title-size` (17pt), `entry-size` (10pt), and `entry-spacing` (11.8pt).
/// Each field is a length and directly controls the indicated gap or type size;
/// `book()` config values override these defaults.
///
/// ```typst
/// #book-contents(title: [Contents], depth: 2)
/// #book-mainmatter[
///   = First chapter
///   == First section
/// ]
/// ```
///
/// - title (content, none): contents heading; defaults to `[Contents]`. `none`
///   hides the words but retains the configured title spacing.
/// - depth (int): heading depth to include; defaults to 1 (chapters only).
///   Must be a non-negative integer. `0` renders an empty outline below the
///   heading; it does not suppress the contents page.
/// -> content: a page break, styled title, and linked outline
#let book-contents(title: [Contents], depth: 1) = context {
  assert(type(depth) == int and depth >= 0, message: "book-contents depth must be a nonnegative integer.")
  let style = book-style.get()
  let toc = style.contents
  [
    #pagebreak()
    #v(toc.title-before)
    #block(below: toc.title-after)[
      #text(size: toc.title-size, weight: "bold", fill: style.ink)[#title]
    ]
    #set text(size: toc.entry-size)
    #set par(leading: 0.45em, spacing: 0pt)
    #show outline.entry: it => context {
      block(above: toc.entry-spacing)[
        #link(it.element.location())[
          #it.indented(it.prefix(), [#it.body() #h(1fr) #it.page()])
        ]
      ]
    }
    #show outline.entry.where(level: 1): set text(fill: style.accent)
    #outline(title: none, depth: depth)
  ]
}

/// Begin the book's numbered main matter on a right-hand page.
///
/// This inserts a page break to the next recto page, resets the displayed page
/// number to Arabic `1`, resets the heading counter, and enables the book footer.
/// The main matter uses `headings.numbering` (the book default is `"1"`) unless
/// `numbering` supplies a Typst heading-numbering pattern override. Level-two
/// headings remain unnumbered.
/// Place front matter and `book-contents()` before this call; place appendices
/// or back matter after the main matter.
///
/// ```typst
/// #book-contents()
/// #book-mainmatter[
///   = First chapter
///   Main text.
/// ]
/// ```
///
/// - body (content): chapters in the numbered main matter
/// - numbering (str, none): optional Typst heading-numbering pattern; `none`
///   uses the document's `headings.numbering` (the book default is `"1"`)
/// -> content: page and heading setup followed by `body`
#let book-mainmatter(body, numbering: none) = context {
  let style = book-style.get()
  let number-format = if numbering == none { style.numbering } else { numbering }
  [
    #book-style.update((
      accent: style.accent,
      ink: style.ink,
      contents: style.contents,
      worked-example: style.worked-example,
      exercise: style.exercise,
      running-headers: style.running-headers,
      footer-dy: style.footer-dy,
      footer: style.footer,
      grid: style.grid,
      grid-width: style.grid-width,
      footer-size: style.footer-size,
      footer-weight: style.footer-weight,
      numbering: number-format,
    ))
    #set heading(numbering: number-format)
    #show heading.where(level: 2): set heading(numbering: none)
    #set page(footer: none)
    #pagebreak(to: "odd")
    #counter(page).update(1)
    #counter(heading).update(0)
    #set page(numbering: "1")
    #set page(footer: book-page-footer(style))
    #body
  ]
}

/// Start lettered appendices while keeping Arabic page numbers.
///
/// Resets the heading counter and switches level-one heading numbering to
/// uppercase letters (`A`, `B`, …). Page numbering remains Arabic and continues
/// from the preceding content. Figure, table, and equation counters are not
/// reset or lettered automatically; call `chapter-numbering(appendix: true)`
/// inside the appendix when those numbers should include appendix letters.
/// Place appendices after `book-mainmatter`; use `book-backmatter` for any later
/// unnumbered sections.
///
/// ```typst
/// #book-appendix[
///   = Supplementary methods
///   Appendix content.
/// ]
/// ```
///
/// - body (content): one or more appendix chapters, beginning at heading level 1
/// -> content: appendix heading and page-number setup followed by `body`
#let book-appendix(body) = context {
  let style = book-style.get()
  [
    #book-style.update((
      accent: style.accent,
      ink: style.ink,
      contents: style.contents,
      worked-example: style.worked-example,
      exercise: style.exercise,
      running-headers: style.running-headers,
      footer-dy: style.footer-dy,
      footer: style.footer,
      grid: style.grid,
      grid-width: style.grid-width,
      footer-size: style.footer-size,
      footer-weight: style.footer-weight,
      numbering: "A",
    ))
    #set heading(numbering: "A")
    #set page(numbering: "1")
    #set page(footer: book-page-footer(style))
    #counter(heading).update(0)
    #body
  ]
}

/// Begin unnumbered back matter after appendices, solutions, or references.
///
/// Inserts a weak page break so existing page flow is preserved when possible,
/// disables numbering on headings that follow, and keeps Arabic page numbers
/// with the book footer. It does not reset the page counter or add entries to
/// the contents. Use this wrapper for material such as acknowledgments, notes,
/// or a bibliography that should follow the numbered chapters.
///
/// ```typst
/// #book-backmatter[
///   = Acknowledgments
///   Thank you to everyone who helped.
/// ]
/// ```
///
/// - body (content): unnumbered back-matter content
/// -> content: page and heading setup followed by `body`
#let book-backmatter(body) = context {
  let style = book-style.get()
  [
    #pagebreak(weak: true)
    #set heading(numbering: none)
    #set page(numbering: "1")
    #set page(footer: book-page-footer(style))
    #body
  ]
}

/// Start a fresh, two-column index with hanging entries.
///
/// Use one `book-index` call after the references and supply index entries as
/// paragraphs. The page counter continues from the preceding back-matter page.
///
/// - body (content): index entries as paragraphs
/// - title (content): index heading; defaults to `[Index]`
/// - column-count (int): number of index columns; defaults to 2
/// - gutter (length): space between columns; defaults to 18pt
/// - indent (length): continuation-line indent for each entry; defaults to 10pt
/// - spacing (length): space between index entries; also sets paragraph
///   spacing inside each hanging-indent entry; defaults to 3pt
#let book-index(
  body,
  title: [Index],
  column-count: 2,
  gutter: 18pt,
  indent: 10pt,
  spacing: 3pt,
) = context {
  assert(type(column-count) == int and column-count >= 1, message: "book-index column-count must be a positive integer.")
  assert(indent >= 0pt, message: "book-index indent must be nonnegative.")
  assert(spacing >= 0pt, message: "book-index spacing must be nonnegative.")
  [
    #set page(numbering: "1")
    #set page(columns: column-count)
    #set columns(gutter: gutter)
    #set heading(numbering: none)
    #set page(footer: book-page-footer(book-style.get()))
    #pagebreak(weak: true)
    #heading(level: 1, numbering: none)[#title]
    #block(inset: (left: indent))[
      #set par(first-line-indent: -indent, spacing: spacing)
      #body
    ]
  ]
}
