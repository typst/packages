/// Acknowledgement Page
///
/// - anonymous (bool): Whether to use anonymous mode.
/// - twoside (bool): Whether to use two-sided layout.
/// - title (content): The title of the acknowledgement page.
/// - title-vspace (length): The vertical space after the title.
/// - outlined (bool): Whether to outline the page.
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
  // self
  it,
) = {
  if anonymous { return }

  pagebreak(weak: true, to: if twoside { "odd" })

  heading(level: 1, numbering: none, outlined: outlined, title)

  v(title-vspace)

  it
}
