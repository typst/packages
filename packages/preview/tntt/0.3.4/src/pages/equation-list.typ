/// Equation List Page
///
/// - twoside (bool): Whether to use two-sided printing
/// - title (content): The title of the equation index page
/// - outlined (bool): Whether to outline the page
/// -> content
#let equation-list(
  // from entry
  twoside: false,
  // options
  title: [公式清单],
  outlined: false,
) = {
  pagebreak(weak: true, to: if twoside { "odd" })

  heading(
    level: 1,
    numbering: none,
    outlined: outlined,
    bookmarked: true,
    title,
  )

  outline(
    title: none,
    target: math.equation.where(block: true),
  )
}
