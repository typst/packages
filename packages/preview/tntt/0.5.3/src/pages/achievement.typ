/// Achievement Page
///
/// - anonymous (bool): Whether to use anonymous mode.
/// - twoside (bool, str): Whether to use two-sided layout.
/// - degree (str): The degree.
/// - title (content): The title of the achievement page.
/// - outlined (bool): Whether to outline the page.
/// - bookmarked (bool): Whether to add a bookmark for the page.
/// - resume (content): The resume content.
/// - paper (content): The list of papers.
/// - patent (content): The list of patents.
/// -> content
#let achievement(
  // from entry
  anonymous: false,
  twoside: false,
  degree: "bachelor",
  // options
  title: auto,
  outlined: true,
  bookmarked: true,
  resume: [],
  paper: [],
  patent: [],
) = {
  if anonymous { return }

  import "../utils/font.typ": use-size
  import "../utils/util.typ": is-not-empty, twoside-pagebreak

  title = if title == auto {
    if degree == "bachelor" [在学期间参加课题的研究成果] else [个人简历、在学期间完成的相关学术成果]
  } else { title }

  twoside-pagebreak(twoside)

  heading(level: 1, numbering: none, outlined: outlined, bookmarked: bookmarked, title)

  if degree != "bachelor" {
    show heading.where(level: 2): it => { align(center, text(size: use-size("四号"), it.body)) }
    heading(level: 2, numbering: none, outlined: false, bookmarked: false, [个人简历])
    v(8pt)
    resume
    v(8pt)
    par[]
    heading(level: 2, numbering: none, outlined: false, bookmarked: false, [在学期间完成的相关学术成果])
    if is-not-empty(paper) or is-not-empty(patent) { v(1.7em) }
  }

  set par(first-line-indent: 0pt, leading: 8pt)
  set enum(indent: 0pt, numbering: "[1]", body-indent: 1.2em, spacing: 1.14em)
  show heading.where(level: 2): it => { text(size: use-size("四号"), it.body) }

  if is-not-empty(paper) {
    heading(level: 2, numbering: none, outlined: false, bookmarked: false, [学术论文：])
    v(1pt)
    paper
    par[]
    v(9pt)
  }

  if is-not-empty(patent) {
    heading(level: 2, numbering: none, outlined: false, bookmarked: false, [专利：])
    v(1pt)
    patent
  }

  if not is-not-empty(paper) and not is-not-empty(patent) { [无。] }
}
