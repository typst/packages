#import "../utils/font.typ": use-size, _use-font
#import "../utils/util.typ": array-at

#import "../imports.typ": show-cn-fakebold

#let meta(
  // from entry
  info: (:),
  // options
  lang: "zh",
  region: "zh",
  margin: (:),
  fallback: false,
  // self
  it,
) = {
  // fix bold and italic
  show: show-cn-fakebold

  set text(lang: lang, fallback: fallback, region: region)

  set page(margin: margin)

  set document(
    title: info.title.title,
    author: info.authors.map(author => author.name),
  )

  set heading(bookmarked: true)

  it
}

#let doc(
  // from entry
  font: (:),
  // options
  indent: 2em,
  justify: true,
  leading: 1em,
  spacing: 1em,
  code-block-leading: 1em,
  code-block-spacing: 1em,
  heading-font: ("HeiTi", "HeiTi", "SongTi"),
  heading-size: ("三号", "四号", "中四", "小四"),
  heading-front-vspace: (28.6pt, 0pt),
  heading-back-vspace: (9.4pt, 0pt),
  heading-above: (0pt, 25.1pt, 22pt),
  heading-below: (21.2pt, 18.6pt),
  heading-align: (center, left),
  heading-weight: ("regular", "regular", "bold", "bold"),
  heading-pagebreak: (true, false),
  body-font: "SongTi",
  body-size: "小四",
  footnote-font: "SongTi",
  footnote-size: "五号",
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
  enum-numbering: "①",
  bibliography-font: "SongTi",
  bibliography-size: "五号",
  bibliography-spacing: 12pt,
  // self
  it,
) = {
  /// Auxiliary functions
  let use-font(name) = { _use-font(font, name) }

  /// Paragraph
  ///
  /// set justify, leading, spacing, and first-line-indent
  set par(
    justify: justify,
    leading: leading,
    spacing: spacing,
    first-line-indent: (amount: indent, all: true),
  )

  /// List
  ///
  /// set indent for list
  set list(indent: indent)

  /// Term
  ///
  /// disable first-line-indent for terms
  show terms: set par(first-line-indent: 0em)

  /// Heading
  ///
  /// only set default font family
  /// set font weight to "regular" for better HeiTi performance
  show heading: it => {
    if array-at(heading-pagebreak, it.level) { pagebreak(weak: true) }

    set text(
      size: use-size(array-at(heading-size, it.level)),
      font: use-font(array-at(heading-font, it.level)),
      weight: array-at(heading-weight, it.level),
    )

    set block(
      above: array-at(heading-above, it.level),
      below: array-at(heading-below, it.level),
    )

    v(array-at(heading-front-vspace, it.level))

    align(array-at(heading-align, it.level), it)

    v(array-at(heading-back-vspace, it.level))
  }

  /// Body Text
  ///
  /// set default body font family and size
  set text(font: font.SongTi, size: use-size(body-size))

  /// Fontnote
  show footnote.entry: set text(font: use-font(footnote-font), size: use-size(footnote-size))

  /// Math Equation
  show math.equation: set text(font: use-font(math-font), size: use-size(math-size))

  /// Raw
  ///
  /// set font for raw block
  show raw: set text(font: use-font(raw-font), size: use-size(raw-size))

  // unset paragraph for raw block
  show raw.where(block: true): set par(
    leading: code-block-leading,
    spacing: code-block-spacing,
  )

  /// Figure
  show figure.where(kind: table): set figure.caption(position: top)

  /// Figure Caption
  set figure.caption(separator: caption-separator)

  show figure.caption: caption-style
  show figure.caption: set text(font: use-font(caption-font), size: use-size(caption-size))

  /// Underline
  ///
  /// fix underline offset and stroke
  set underline(
    offset: underline-offset,
    stroke: underline-stroke,
    evade: underline-evade,
  )

  /// Enum
  ///
  /// set default enum numbering and indent
  set enum(
    numbering: enum-numbering,
    indent: indent,
  )

  /// Bibliography
  show bibliography: set text(font: use-font(bibliography-font), size: use-size(bibliography-size))

  show bibliography: set par(spacing: bibliography-spacing)

  /// Stroke

  it
}
