#import "../../assets/text-blobs.typ": copyright
/// inserts the copyright page
/// -> content
#let insert-copyright(
  /// Whether the thesis is done during an English master
  /// -> bool
  english-master,
  /// The language of the thesis
  /// -> Str
  lang,
) = {
  // Copyright
  set align(left + bottom)
  set par(justify: true, first-line-indent: 0pt)
  show link: it => [#text(font: "Nimbus Mono PS", weight: 300)[#it]]
  set text(hyphenate: false)
  copyright.tm + v(2em)
  if lang == "en" {
    copyright.en + v(2em)
  }
  if not english-master {
    copyright.nl
  }

  // par(first-line-indent: 0pt, leading: 5pt, justify: true)[
  // text(hyphenate: false, size: 10.5pt)[
  //   #copyright-text
  // ]
  // ]
  v(7%)
}
