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
  abstract: [],
  acknowledgments: [],
) = {
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
  )

  declaration-of-authorship(
    city: city,
    date: date,
    name: author,
  )

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
