/// Abstract Page (Simplified Chinese version)
///
/// - fonts (dictionary): The font family to use, should be a dictionary.
/// - twoside (bool, str): Whether to use two-sided printing.
/// - default-fonts (dictionary): The default font family to use if not specified in fonts.
/// - title (content): The title of the abstract page.
/// - outlined (bool): Whether to outline the page.
/// - bookmarked (bool): Whether to add a bookmark for the page.
/// - back (content): The back text.
/// - back-font (str): The font for the back text.
/// - back-indent (length): The first line indent for the back text.
/// - back-vspace (length): The vertical space after the abstract content.
/// - keywords (array): Keywords to be included in the abstract.
/// - keyword-sperator (str): The separator for keywords, default is "；".
/// - keyword-font (str): The font for the keywords.
/// - it (content): The main content of the abstract page.
/// -> content
#let abstract(
  // from entry
  fonts: (:),
  twoside: false,
  // options
  default-fonts: (:),
  title: [摘　要],
  outlined: true,
  bookmarked: true,
  embeded: true,
  back: [*关键词：*],
  back-font: "HeiTi",
  back-indent: 0em,
  back-vspace: 1.7em,
  keywords: (),
  keyword-sperator: "；",
  keyword-font: "SongTi",
  // self
  it,
) = {
  import "../utils/font.typ": _use-fonts
  import "../utils/util.typ": twoside-pagebreak

  fonts = fonts + default-fonts

  let use-fonts = name => _use-fonts(fonts, name)

  twoside-pagebreak(twoside)

  heading(level: 1, outlined: outlined, bookmarked: bookmarked, title)

  it

  v(back-vspace)

  par(
    first-line-indent: back-indent,
    text(font: use-fonts(back-font), back) + text(font: use-fonts(keyword-font), keywords.join(keyword-sperator)),
  )

  if embeded { set document(keywords: keywords, description: it) }
}

/// Abstract Page (English version), Inherited from the Chinese version
#let abstract-en = abstract.with(
  title: [Abstract],
  embeded: false,
  back: [*Keywords: *],
  back-font: "SongTi",
  keyword-sperator: "; ",
)
