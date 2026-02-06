#import "../utils/font.typ": _use-fonts

/// Abstract Page (Simplified Chinese version)
///
/// - fonts (dictionary): the font family to use, should be a dictionary
/// - anonymous (bool): anonymous mode
/// - twoside (bool): two-sided printing
/// - outlined (bool): whether to outline the page
/// - title (content): the title of the abstract page
/// - indent-back (bool): whether to indent the back text
/// - back (content): the back text, default is [*关键词：*]
/// - back-font ("SongTi" | "HeiTi" | "KaiTi" | "FangSong" | "Mono" | "Math"): the font for the back text
/// - back-vspace (length): the vertical space after the abstract content
/// - keywords (array): keywords to be included in the abstract
/// - keyword-sperator (str): the separator for keywords, default is "；"
/// - keyword-font ("SongTi" | "HeiTi" | "KaiTi" | "FangSong" | "Mono" | "Math"): the font for the keywords
/// - it (content): the main content of the abstract page
/// -> content
#let abstract(
  // from entry
  fonts: (:),
  anonymous: false,
  twoside: false,
  // options
  outlined: false,
  title: [摘　要],
  indent-back: false,
  back: [*关键词：*],
  back-font: "HeiTi",
  back-vspace: 20.1pt,
  keywords: (),
  keyword-sperator: "；",
  keyword-font: "SongTi",
  // self
  it,
) = {
  /// Auxiliary function to handle the font usage
  let use-fonts = name => _use-fonts(fonts, name)

  /// Render the abstract page
  pagebreak(weak: true, to: if twoside { "odd" })

  heading(level: 1, outlined: outlined, title)

  it

  v(back-vspace)

  par(
    first-line-indent: if indent-back { 2em } else { 0em },
    text(font: use-fonts(back-font), back) + text(font: use-fonts(keyword-font), keywords.join(keyword-sperator)),
  )
}

/// Abstract Page (English version), Inherited from the Chinese version
#let abstract-en(..args) = abstract(
  title: [Abstract],
  back: [*Keywords: *],
  back-font: "SongTi",
  keyword-sperator: "; ",
  ..args,
)
