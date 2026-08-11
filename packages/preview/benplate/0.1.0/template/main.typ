#import "@preview/benplate:0.1.0": thesis, accent-color, todo
#import "frontmatter.typ": *
#import "backmatter.typ": *

#let author = "Your Name"
#let date = datetime.today()

#show: thesis.with(
  title: "Your Thesis Title",
  author: author,
  date: date,
  frontmatter: default-frontmatter(
    university: "Your University",
    faculty: "Your Faculty",
    field: "Your Program of Study",
    type: "Thesis Type",
    city: "Your City",
    author: author,
    date: date,
    advisor: "Your Advisor",
    first-reviewer: "Your First Reviewer",
    second-reviewer: "Your Second Reviewer",
    abstract: todo[Write an abstract],
    acknowledgments: todo[Write your acknowledgments]
  ),
  appendix: [
    // Optional content for the appendix
  ],
  backmatter: default-backmatter(
    bibliography:  bibliography("references.bib"),
    bib-style: "ieee"
  )
)

= Your First Chapter

#lorem(75)

#lorem(130)

#lorem(90)
