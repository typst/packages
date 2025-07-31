#import "util.typ": _huge, _large, _Large

#let title-page(
  title,
  author,
  thesis-type,
  header-logo,
  reviewers,
  translations,
  date,
) = {
  set align(center)

  let (first-reviewer, second-reviewer, supervisor) = translations.title-page
  let (value, compound) = translations.thesis
  let thesis-suffix = if compound { lower(value) } else { " " + value }
  let thesis-type = thesis-type + thesis-suffix

  header-logo

  v(4.75em)

  text(_Large, font: "Libertinus Serif")[*#thesis-type*]
  v(2.5em)
  text(_huge, font: "Libertinus Sans")[
    #set par(justify: false)
    *#title*
  ]
  v(1.25em)

  set text(_Large)
  show raw: set text(_large * 0.95)
  
  author.name
  v(0.75em, weak: true)
  link("mailto:" + author.mail)[#raw(author.mail)]

  v(0.5em)
  [
    #show regex("[a-zA-Z]+"): r => translations.date.months.at(date.month() - 1)
    #date.display(translations.date.date-format)
  ]
  v(5.35em)

  /* First and second reviewer are required, supervisor is optional. */
  if reviewers.len() >= 2 {
    let first-reviewer-name = reviewers.first()
    let second-reviewer-name = reviewers.at(1)
    let supervisor-name = reviewers.at(2, default: none)

    [
      #first-reviewer:\
      #first-reviewer-name\ \
      #v(-1.5em)
  
      #second-reviewer:\
      #second-reviewer-name\ \
      #v(-1.5em)

      #if supervisor-name != none [
        #supervisor:\
        #supervisor-name
      ]
    ]
  }
}