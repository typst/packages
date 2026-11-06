/// Acknowledgement Page
///
/// - anonymous (bool): Whether to use anonymous mode.
/// - twoside (bool, str): Whether to use two-sided layout.
/// - title (content): The title of the acknowledgement page.
/// - title-vspace (length): The vertical space after the title.
/// - outlined (bool): Whether to outline the page.
/// - bookmarked (bool): Whether to add a bookmark for the page.
/// - it (content): The content of the acknowledgement page.
/// -> content
#let acknowledge(
  // from entry
  anonymous: false,
  twoside: false,
  // options
  title: [致　谢],
  title-vspace: 2pt,
  outlined: true,
  bookmarked: true,
  // self
  it,
) = {
  if anonymous { return }

  import "../utils/util.typ": twoside-pagebreak

  twoside-pagebreak(twoside)

  heading(level: 1, numbering: none, outlined: outlined, bookmarked: bookmarked, title)

  v(title-vspace)

  it
}
