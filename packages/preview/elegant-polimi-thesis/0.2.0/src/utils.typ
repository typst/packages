/// LaTeX sizes to match original templates (https://tex.stackexchange.com/questions/24599/what-point-pt-font-size-are-large-etc)
/// -> dict
#let _sizes = (
  "10pt": (
    tiny: 5pt,
    scriptsize: 7pt,
    footnotesize: 8pt,
    small: 9pt,
    normalsize: 10pt,
    large: 12pt,
    Large: 14.4pt,
    LARGE: 17.28pt,
    huge: 20.74pt,
    Huge: 24.88pt,
  ),
  "11pt": (
    tiny: 6pt,
    scriptsize: 8pt,
    footnotesize: 9pt,
    small: 10pt,
    normalsize: 10.95pt,
    large: 12pt,
    Large: 14.4pt,
    LARGE: 17.28pt,
    huge: 20.74pt,
    Huge: 24.88pt,
  ),
  "12pt": (
    tiny: 6pt,
    scriptsize: 8pt,
    footnotesize: 10pt,
    small: 10.95pt,
    normalsize: 12pt,
    large: 14.4pt,
    Large: 17.28pt,
    LARGE: 20.74pt,
    huge: 24.88pt,
    Huge: 24.88pt,
  ),
)

/// The current state (title page, front-,main-,backmatter...)
/// -> state
#let _document-state = state("init", "TITLE_PAGE")

/// The current type of document.
/// -> state
#let _document-type = state("init", "phd")

/// Localization dictionary. It could be deprecated since thesises are written exclusively in English.
/// -> dict
#let _localization = yaml("locale.yaml")

/// Signature PoliMi colour (#box(baseline: 0.1em, rect(height: 0.7em, width: 0.7em, fill: rgb("#5f859f")))), used in headings and labels.
/// -> color
#let bluepoli = rgb("#5f859f")

/// Check if a page is empty.
/// -> bool
#let _is-page-empty() = {
  // https://forum.typst.app/t/how-to-use-set-page-without-adding-an-unwanted-pagebreak/3129/2
  let current-page = here().page()
  query(<chapter-end>)
    .zip(query(<chapter-start>))
    .any(((start, end)) => {
      (start.location().page() < current-page and current-page < end.location().page())
    })
}

/// Adds an empty page between an odd page and the next. Used to check when to remove the header and place a raggiera in the bottom left corner.
/// -> content
#let _empty-page() = {
  [#metadata(none) <chapter-end>]
  pagebreak(weak: true, to: "odd")
  [#metadata(none) <chapter-start>]
}

/// It displays a reference using section name (instead of numbering). From Hallon 0.1.3
/// -> content
#let _nameref(label) = {
  show ref: it => {
    if it.element == none {
      it
    } else if it.element.func() != heading {
      it
    } else {
      let l = it.target // label
      let h = it.element // heading
      link(l, h.body)
    }
  }
  ref(label)
}


/// Inserts a raggiera, given a specified width.
/// -> content
#let _raggiera-image(
  /// Width of the raggiera.
  /// -> length
  width,
) = (
  image(
    "img/raggiera.svg",
    width: width,
  )
)

/// Draw a banner.
/// -> content
#let banner(
  /// Body of the banner.
  /// -> content
  body,
) = rect(
  width: 100%,
  fill: bluepoli.lighten(40%), // #9AAFC2
  inset: (rest: 1em, x: 1.7em),
  text(
    fill: white,
    body,
  ),
)

// Numbering functions

/// Alternative numbering: ```typc"1.1." + h-space```.
/// -> content
#let tab-numbering(
  /// Horizontal space.
  /// -> length
  h-space: 0.7em,
  /// Numbers.
  /// -> arguments
  ..n,
) = n.pos().map(str).join(".") + "." + h(h-space)

/// Chapter numbering.
/// -> content
#let chapter-numbering(
  /// Numbers.
  /// -> arguments
  ..n,
) = text(weight: "bold", str(n.pos().first())) + "|" + h(2mm)

/// Numbering used in the theses header.
/// -> content
#let header-number(
  /// Numbers.
  /// -> arguments
  ..n,
) = return str(n.pos().first()) + "| "

#let shared-formatting(title, author, language, body, text-size: 11pt, keywords: "") = {
  set document(
    title: title,
    author: author,
    keywords: keywords,
  )

  set text(
    lang: language,
    size: text-size,
    font: "New Computer Modern",
    hyphenate: true,
  )
  show math.equation: set text(font: "New Computer Modern Math")

  set par(
    justify: true,
    linebreaks: "optimized",
    spacing: 0.7em,
    first-line-indent: 0pt,
  )

  set figure(gap: 1.5em)
  show figure: set block(breakable: true)
  show: _style-figures.with(colored-caption: true, heading-levels: 1)

  body
}
