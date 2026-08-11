/// Committee Page
///
/// - anonymous (bool): Whether to use anonymous mode.
/// - twoside (bool, str): Whether to use two-sided layout.
/// - degree (str): The degree.
/// - title (content, str): The title of the committee page.
/// - outlined (bool): Whether to outline the page.
/// - bookmarked (bool): Whether to add a bookmark for the page.
/// - supervisors (array): The list of supervisors.
/// - supervisors-title (content, str): The title for the supervisors section.
/// - supervisors-columns (array): The widths of the grid columns for supervisors.
/// - reviewers (array): The list of reviewers.
/// - reviewers-title (content, str): The title for the reviewers section.
/// - reviewers-columns (array): The widths of the grid columns for reviewers.
/// - defenders (dictionary): The dictionary of defenders, where keys are roles and values are lists of names.
/// - defenders-title (content, str): The title for the defenders section.
/// - defenders-columns (array): The widths of the grid columns for defenders.
/// -> content
#let committee(
  // from entry
  anonymous: false,
  twoside: false,
  degree: "master",
  // options
  title: [学位论文指导小组、公开评阅人和答辩委员会名单],
  outlined: false,
  bookmarked: true,
  supervisors: (),
  supervisors-title: [指导小组名单],
  supervisors-columns: (3cm, 3cm, 9cm),
  reviewers: (),
  reviewers-title: [公开评阅人名单],
  reviewers-columns: (3cm, 3cm, 9cm),
  defenders: (:),
  defenders-title: [答辩委员会名单],
  defenders-columns: (2.75cm, 2.98cm, 4.63cm, 4.63cm),
) = {
  if anonymous or degree == "bachelor" { return }

  import "../utils/util.typ": is-not-empty, twoside-pagebreak
  import "../utils/font.typ": use-size

  let use-fonts = name => _use-fonts(fonts, name)
  let format-text = str => {
    show heading.where(level: 2): it => { align(center, text(size: use-size("小三"), it.body)) }
    v(20pt)
    heading(level: 2, numbering: none, outlined: false, bookmarked: false, str)
    v(2pt)
  }
  let length-checker = it => it.len() == 3 // (name, title, affiliation)

  /// Render
  twoside-pagebreak(twoside)

  set page(header: none)
  set align(center)
  set par(justify: false) // disable full justify
  set grid(row-gutter: 1em, align: horizon)

  heading(level: 1, numbering: none, outlined: outlined, bookmarked: bookmarked, title)
  v(2pt)

  if is-not-empty(supervisors) and supervisors != () {
    format-text(supervisors-title)
    if type(supervisors) == array {
      grid(columns: supervisors-columns, ..supervisors.filter(length-checker).flatten())
    } else { supervisors }
  }

  if is-not-empty(reviewers) {
    format-text(reviewers-title)
    if type(reviewers) == array {
      if reviewers != () {
        grid(columns: reviewers-columns, ..reviewers.filter(length-checker).flatten())
      } else { [无（全隐名评阅）] }
    } else { reviewers }
  }


  if is-not-empty(defenders) and defenders != (:) {
    format-text(defenders-title)
    if type(defenders) == dictionary {
      grid(columns: defenders-columns, ..defenders
          .keys()
          .filter(k => type(defenders.at(k)) == array and defenders.at(k) != ())
          .map(k => (k, defenders.at(k).filter(length-checker).intersperse("")))
          .flatten())
    } else { defenders }
  }
}
