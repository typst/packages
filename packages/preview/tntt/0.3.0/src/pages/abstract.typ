#import "../utils/font.typ": _use-fonts

/// Abstract Page (Simplified Chinese version)
#let abstract(
  // from entry
  fonts: (:),
  anonymous: false,
  twoside: false,
  // options
  outlined: false,
  title: [摘　要],
  back: [*关键词：*],
  back-font: "HeiTi",
  back-vspace: 20.1pt,
  keywords: (),
  keyword-sperator: "；",
  // self
  it,
) = {
  pagebreak(weak: true, to: if twoside { "odd" })

  heading(
    level: 1,
    outlined: outlined,
    title,
  )

  it

  v(back-vspace)

  par(
    first-line-indent: 0pt,
    text(font: _use-fonts(fonts, back-font), back) + (("",) + keywords.intersperse(keyword-sperator)).sum(),
  )
}

/// Abstract Page (English version)
#let abstract-en(..args) = abstract(
  title: [Abstract],
  back: [*Keywords: *],
  back-font: "SongTi",
  keyword-sperator: "; ",
  ..args,
)
