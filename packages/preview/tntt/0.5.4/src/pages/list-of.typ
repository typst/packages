/// Figure and Table Index Page
///
/// - twoside (bool, str): Whether to use two-sided printing.
/// - title (content): The title of the master list page.
/// - outlined (bool): Whether to outline the page.
/// - bookmarked (bool): Whether to add a bookmark for the page.
/// - body (content): The body content of the page.
/// -> content
#let figure-table-list(
  // from entry
  twoside: false,
  // options
  title: [插图和附表清单],
  outlined: true,
  bookmarked: true,
) = {
  import "../utils/util.typ": twoside-pagebreak

  twoside-pagebreak(twoside)

  heading(level: 1, numbering: none, outlined: outlined, bookmarked: bookmarked, title)

  outline(target: figure.where(kind: image), title: none)

  par[] // add a blank line

  outline(target: figure.where(kind: table), title: none)
}

/// Common list page of single target
///
/// - twoside (bool, str): Whether to use two-sided printing.
/// - title (content): The title of the master list page.
/// - outlined (bool): Whether to outline the page.
/// - bookmarked (bool): Whether to add a bookmark for the page.
/// - target (selector): The target selector for the outline.
/// -> content
#let _list-of(
  // from entry
  twoside: false,
  // options
  title: [清单],
  outlined: true,
  bookmarked: true,
  target: figure,
) = {
  import "../utils/util.typ": twoside-pagebreak

  twoside-pagebreak(twoside)

  heading(level: 1, numbering: none, outlined: outlined, bookmarked: bookmarked, title)

  outline(target: target, title: none)
}

/// Master List Page
#let master-list = _list-of.with(title: [插图和附表清单], target: figure)

/// Figure Index Page
#let figure-list = _list-of.with(title: [插图清单], target: figure.where(kind: image).or(figure.where(kind: grid)))

/// Table Index Page
#let table-list = _list-of.with(title: [附表清单], target: figure.where(kind: table))

/// Equation Index Page
#let equation-list = _list-of.with(title: [公式清单], target: math.equation)
