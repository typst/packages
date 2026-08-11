/// Meta Information for the Document / PDF
///
/// - info (dictionary): The metadata for the document, including title and author.
/// - lang (text.lang): The language of the document, default is "zh" (Chinese).
/// - region (text.region): The region for the document, default is "cn" (China Mainland).
/// - margin (margin): The margin settings for the document.
/// - paper (str): The paper size for the document, default is "a4".
/// - fallback (bool): Whether to use fallback fonts.
/// - use-fakebold (bool): Whether to use fake bold rendering for Chinese text.
/// - use-latexref (bool): Whether to apply LaTeX/i-figured reference compatibility.
/// - unnumbered-label (str): The label for unnumbered equations.
/// - extra-prefixes (array): Additional prefixes for LaTeX references.
/// - default-prefixes (array): Default prefixes for LaTeX references.
/// - it (content): The content of the document.
/// -> content
#let meta(
  // from entry
  info: (:),
  // options
  lang: "zh",
  region: "cn",
  margin: 3cm,
  paper: "a4",
  fallback: false,
  use-fakebold: true,
  use-latexref: true,
  unnumbered-label: "-",
  extra-prefixes: (),
  default-prefixes: ("fig:", "tbl:", "eqt:", "lst:", "img:"),
  // self
  it,
) = {
  import "../utils/util.typ": show-label-equation, show-latexref

  import "../imports.typ": cuti
  import cuti: show-cn-fakebold

  // Apply LaTeX/i-figured reference compatibility
  show: it => if use-latexref { show-latexref(default-prefixes + extra-prefixes, it) } else { it }

  // Fix for Chinese fake bold rendering
  show: it => if use-fakebold { show-cn-fakebold(it) } else { it }

  // Apply unnumbered equation label
  show: it => show-label-equation(unnumbered-label, it)

  set text(fallback: fallback, lang: lang, region: region)

  set page(margin: margin, paper: paper)

  set heading(bookmarked: true)

  set document(title: info.title.sum(), author: info.author, date: info.date)

  it
}

/// Document Configuration
///
/// - fonts (dictionary): A dictionary of font names and their corresponding styles.
/// - default-fonts (dictionary): A dictionary of default font styles to use if not specified in fonts.
/// - indent (length): Paragraph indentation.
/// - justify (bool): Whether to justify text in paragraphs.
/// - leading (length): The leading (line height) for paragraphs.
/// - spacing (length): The spacing (line spacing) between paragraphs.
/// - code-block-leading (length): The leading for code blocks.
/// - code-block-spacing (length): The spacing for code blocks.
/// - heading-font (array): The font for headings.
/// - heading-size (array): The size of headings, can be length value or str.
/// - heading-front-vspace (array): The vertical space before the heading.
/// - heading-back-vspace (array): The vertical space after the heading.
/// - heading-above (array): The space above the heading.
/// - heading-below (array): The space below the heading.
/// - heading-align (array): The alignment of headings.
/// - heading-weight (array): The font weight for headings.
/// - heading-pagebreak (array): Whether to insert a page break before the headings.
/// - body-font (str): The font for body text.
/// - body-size (length, str): The size of body text, can be length value or str.
/// - header-display (bool): Whether to display headers.
/// - header-stroke (stroke): The stroke for the header line.
/// - header-ascent (length): The ascent for the header.
/// - header-font (str): The font for headers.
/// - header-size (length, str): The size of headers, can be length value or str.
/// - footnote-font (str): The font for footnotes.
/// - footnote-size (length, str): The size of footnotes, can be length value or str.
/// - footnote-style ("normal", "super"): The style of footnotes, can be "normal" or "super".
/// - footnote-reset ("by-page", "by-chapter", "off"): Whether to reset the footnote counter by page or chapter.
/// - footnote-numbering (str): The numbering style for footnotes.
/// - math-font (str): The font for math equations.
/// - math-size (length, str): The size of math equations, can be length value or str.
/// - raw-font (str): The font for raw text.
/// - raw-size (length, str): The size of raw text, can be length value or str.
/// - caption-font (str): The font for captions.
/// - caption-size (length, str): The size of captions, can be length value or str.
/// - caption-style (function): The style of captions.
/// - caption-separator (str): The separator for captions.
/// - underline-offset (length): The offset for underlines.
/// - underline-stroke (stroke): The stroke for underlines.
/// - underline-evade (bool): Whether to evade underlines for certain elements.
/// - cite-style ("normal", "super"): The style of citations, can be "normal" or "super".
/// - bibliography-font (str): The font for bibliography entries.
/// - bibliography-size (length, str): The size of bibliography entries, can be length value or str.
/// - bibliography-spacing (length): The spacing for bibliography entries.
/// - extra-fig-kinds (array): Additional figure kinds to reset counter for count reset by chapter.
/// - it (content): The content of the document.
/// -> content
#let doc(
  // from entry
  fonts: (:),
  // options
  default-fonts: (:),
  indent: 2em,
  justify: true,
  leading: 0.98em,
  spacing: 0.98em,
  code-block-leading: 1em,
  code-block-spacing: 1em,
  heading-font: ("HeiTi",),
  heading-size: ("三号", "四号", "中四", "小四"),
  heading-front-vspace: (28.6pt, 0pt),
  heading-back-vspace: (9.4pt, 0pt),
  heading-above: (0pt, 25.1pt, 22pt),
  heading-below: (21.2pt, 18.6pt),
  heading-align: (center, left),
  heading-weight: ("regular",),
  heading-pagebreak: (true, false),
  body-font: "SongTi",
  body-size: "小四",
  header-display: false,
  header-stroke: 1pt + black,
  header-ascent: 10% + 0pt,
  header-font: "SongTi",
  header-size: "五号",
  footnote-font: "SongTi",
  footnote-size: "小五",
  footnote-style: "normal",
  footnote-reset: "by-page",
  footnote-numbering: "①",
  footnote-hanging-indent: 1.5em,
  math-font: "Math",
  math-size: "小四",
  raw-font: "Mono",
  raw-size: "五号",
  caption-font: "SongTi",
  caption-size: "五号",
  caption-style: strong,
  caption-separator: "  ",
  underline-offset: .1em,
  underline-stroke: .05em,
  underline-evade: false,
  cite-style: "super",
  bibliography-font: "SongTi",
  bibliography-size: "五号",
  bibliography-spacing: 12pt,
  extra-fig-kinds: (),
  outline-fill: repeat([.], gap: .1pt),
  // self
  it,
) = {
  import "../utils/font.typ": _use-en-font, _use-fonts, use-size
  import "../utils/util.typ": array-at

  fonts = fonts + default-fonts

  /// Auxiliary functions
  let use-fonts = _use-fonts.with(fonts)

  /// Render the document with the specified fonts and styles.
  /// Paragraph
  set par(justify: justify, leading: leading, spacing: spacing, first-line-indent: (amount: indent, all: true))

  /// List
  set list(indent: indent)

  /// Enum
  set enum(indent: indent)

  /// Term
  show terms: set par(first-line-indent: 0em)

  /// Heading
  // TODO: use `show-set` instead of `show-closure` for better override ability
  show heading: set text(font: use-fonts(heading-font.last()), weight: heading-weight.last())
  show heading: it => {
    if array-at(heading-pagebreak, it.level) { pagebreak(weak: true) }

    v(array-at(heading-front-vspace, it.level))

    align(array-at(heading-align, it.level), block(
      above: array-at(heading-above, it.level),
      below: array-at(heading-below, it.level),
      text(
        size: use-size(array-at(heading-size, it.level)),
        font: use-fonts(array-at(heading-font, it.level)),
        weight: array-at(heading-weight, it.level),
        it,
      ),
    ))

    v(array-at(heading-back-vspace, it.level))
  }

  // Reset counters by chapter
  show heading.where(level: 1): it => {
    it
    for target in (
      math.equation,
      ..(image, table, raw, grid, ..extra-fig-kinds).map(kind => figure.where(kind: kind)),
    ) { counter(target).update(0) }
  }

  /// Body Text
  set text(font: use-fonts(body-font), size: use-size(body-size))

  /// Smartquote
  show smartquote: set text(font: _use-en-font(fonts, body-font))

  /// Header & Footer
  set page(header-ascent: header-ascent, header: context {
    if footnote-reset == "by-page" { counter(footnote).update(0) }

    let head = query(selector(heading.where(level: 1)).after(here()))
      .filter(it => it.location().page() == here().page())
      .first(default: none)

    if head != none { if footnote-reset == "by-chapter" { counter(footnote).update(0) } } else {
      head = query(selector(heading.where(level: 1)).before(here())).last(default: none)
    }

    if head == none or not header-display { return }

    align(center, text(size: use-size(header-size), font: use-fonts(header-font), {
      if head.numbering != none { numbering(head.numbering, ..counter(heading).at(head.location())) }
      head.body
    }))

    v(-0.6em)

    line(length: 100%, stroke: header-stroke)
  })

  set footnote(numbering: footnote-numbering)

  show footnote: it => if footnote-style == "normal" {
    // unset super style, only for bachelor thesis
    show super: it => { it.body }
    it
  } else if footnote-style == "super" { it } else { panic("Unknown footnote-style: " + footnote-style) }

  show footnote.entry: set text(font: use-fonts(footnote-font), size: use-size(footnote-size))

  show footnote.entry: it => par(hanging-indent: footnote-hanging-indent, first-line-indent: 0em)[
    #numbering(it.note.numbering, ..counter(footnote).at(it.note.location())) #it.note.body
  ]

  /// Math Equation
  show math.equation: set text(font: use-fonts(math-font), size: use-size(math-size))

  /// Raw
  show raw: set text(font: use-fonts(raw-font), size: use-size(raw-size))
  // unset paragraph for raw block
  show raw.where(block: true): set par(leading: code-block-leading, spacing: code-block-spacing)

  /// Underline
  set underline(offset: underline-offset, stroke: underline-stroke, evade: underline-evade)

  /// Figure
  show figure.where(kind: table): set figure.caption(position: top)

  /// Figure Caption
  set figure.caption(separator: caption-separator)

  show figure.caption: caption-style
  show figure.caption: set text(font: use-fonts(caption-font), size: use-size(caption-size))

  /// Bibliography
  show cite: it => if cite-style == "normal" {
    // unset super style, for bachelor thesis
    show super: it => { it.body }
    it
  } else if cite-style == "super" { it } else { panic("Unknown cite-style: " + cite-style) }

  show bibliography: set text(font: use-fonts(bibliography-font), size: use-size(bibliography-size))

  show bibliography: set par(spacing: bibliography-spacing)

  set outline.entry(fill: outline-fill)
  show outline.entry: set par(justify: true)

  /// Content
  it
}
