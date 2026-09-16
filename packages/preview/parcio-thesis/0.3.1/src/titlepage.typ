#import "util.typ": _huge, _large, _Large

#let title-page(
  author,
  thesis-type,
  header-logo,
  reviewers,
  translations,
  date,
) = align(center, {
  show std.title: set block(spacing: 2em)
  show std.title: set text(_huge, font: "Libertinus Sans", weight: "bold")
  show std.title: set par(justify: false)

  let (first-reviewer, second-reviewer, supervisor) = translations.title-page
  let (value, compound) = translations.thesis
  let thesis-suffix = if compound { lower(value) } else { " " + value }
  let thesis-type = thesis-type + thesis-suffix

  header-logo
  linebreak()
  v(1.75em) // @todo: figure out how to make it flexible based on title length!
  
  text(_Large, font: "Libertinus Serif")[*#thesis-type*]
  std.title()

  /* ----- */

  set text(_Large)
  
  author.name
  linebreak()
  link("mailto:" + author.mail, text(_large * 0.95, author.mail))

  parbreak()

  [
    #show regex("[a-zA-Z]+"): r => translations.date.months.at(date.month() - 1)
    #date.display(translations.date.date-format)
  ]
  
  v(1fr)

  // First and second reviewer are required, supervisor is optional.
  if reviewers.len() >= 2 {
    let first-reviewer-name = reviewers.first()
    let second-reviewer-name = reviewers.at(1)
    let supervisor-name = reviewers.at(2, default: none)

    [
      #first-reviewer:\
      #first-reviewer-name\   
      
      #second-reviewer:\
      #second-reviewer-name\

      #if supervisor-name != none [
        #supervisor:\
        #supervisor-name
      ]
    ]
  }

  v(1fr)
})
