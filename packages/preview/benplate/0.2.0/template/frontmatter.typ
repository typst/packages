#import "frontmatter/titlepage.typ": *
#import "frontmatter/declaration-of-authorship.typ": *
#import "frontmatter/outline.typ": *

#let default-frontmatter(
  university: "",
  faculty: "",
  field: "",
  type: "",
  author: "",
  date: datetime.today(),
  city: "",
  advisor: "",
  first-reviewer: "",
  second-reviewer: "",
  accent-color: rgb(165, 28, 48),
  date-format: "[day].[month].[year]",
  abstract: [],
  acknowledgments: [],
) = {
  // The title page, declaration and the blank pages after them aren't numbered
  {
    set page(numbering: none)

    titlepage(
      university: university,
      faculty: faculty,
      field: field,
      type: type,
      author: author,
      date: date,
      advisor: advisor,
      first-reviewer: first-reviewer,
      second-reviewer: second-reviewer,
      accent-color: accent-color,
      date-format: date-format,
    )

    declaration-of-authorship(
      city: city,
      date: date,
      name: author,
      date-format: date-format,
    )
  }

  counter(page).update(1)

  [
    = Abstract

    #abstract
  ]

  [
    = Acknowledgments

    #acknowledgments
  ]

  default-outline()
}
