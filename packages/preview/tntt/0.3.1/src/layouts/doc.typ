#import "../utils/font.typ": use-size, _use-fonts
#import "../utils/util.typ": array-at

#import "../imports.typ": cuti
#import cuti: show-cn-fakebold

#let meta(
  // from entry
  info: (:),
  // options
  lang: "zh",
  region: "cn",
  margin: 3cm,
  fallback: false,
  // self
  it,
) = {
  if type(info.title) == str { info.title = info.title.split("\n") }

  show: show-cn-fakebold

  set text(fallback: fallback, lang: lang, region: region)

  set page(margin: margin, paper: "a4")

  set document(
    title: (("",) + info.title).sum(),
    author: info.author,
  )

  set heading(bookmarked: true)

  it
}

#let doc(
  // from entry
  fonts: (:),
  // options
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
  footnote-font: "SongTi",
  footnote-size: "小五",
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
  underline-evade: true,
  bibliography-font: "SongTi",
  bibliography-size: "五号",
  bibliography-spacing: 12pt,
  // self
  it,
) = {
  /// Auxiliary functions
  let use-fonts(name) = { _use-fonts(fonts, name) }

  /// Render the document with the specified fonts and styles.
  /// Paragraph
  set par(
    justify: justify,
    leading: leading,
    spacing: spacing,
    first-line-indent: (amount: indent, all: true),
  )

  /// List
  set list(indent: indent)

  /// Enum
  set enum(indent: indent)

  /// Term
  show terms: set par(first-line-indent: 0em)

  /// Heading
  show heading: it => {
    if array-at(heading-pagebreak, it.level) { pagebreak(weak: true) }

    set text(
      size: use-size(array-at(heading-size, it.level)),
      font: use-fonts(array-at(heading-font, it.level)),
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
  set text(font: use-fonts(body-font), size: use-size(body-size))

  /// Fontnote
  show footnote.entry: set text(font: use-fonts(footnote-font), size: use-size(footnote-size))

  /// Math Equation
  show math.equation: set text(font: use-fonts(math-font), size: use-size(math-size))

  /// Raw
  show raw: set text(font: use-fonts(raw-font), size: use-size(raw-size))

  // unset paragraph for raw block
  show raw.where(block: true): set par(
    leading: code-block-leading,
    spacing: code-block-spacing,
  )

  /// Underline
  set underline(
    offset: underline-offset,
    stroke: underline-stroke,
    evade: underline-evade,
  )

  /// Stroke

  /// Figure
  show figure.where(kind: table): set figure.caption(position: top)

  /// Figure Caption
  set figure.caption(separator: caption-separator)

  show figure.caption: caption-style
  show figure.caption: set text(font: use-fonts(caption-font), size: use-size(caption-size))

  /// Bibliography
  show bibliography: set text(font: use-fonts(bibliography-font), size: use-size(bibliography-size))

  show bibliography: set par(spacing: bibliography-spacing)

  it
}
