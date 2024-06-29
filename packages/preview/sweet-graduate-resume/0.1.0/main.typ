#import "template.typ": *

#show: doc => preamble(doc)

#let urls = (
  (
    name: "Codeberg",
    url: "https://codeberg.org/innocent_zero",
    svg: "codeberg.svg",
    fa: false,
    brand: false,
    solid: false,
  ),
  (name: "Website", url: "https://example.com", svg: "link", fa: true, brand: false, solid: false),
  (name: "Website", url: "https://example.com", svg: "github", fa: true, brand: true, solid: true),
)

#header("InnocentZero", "roll", "school", urls)

#let edu = ((prog: "Bachelors", school: "college", grade: "4.0"), (prog: "grad", school: "school", grade: "4.0"))

#section_header("Education")
#education(edu)

#let achievements = ([#lorem(30)], [#lorem(20)])

#section_header("Scholastic Achievements")
#points(achievements)

#let skills = ([#lorem(30)], [#lorem(20)])

#section_header("Major Competitions and Technical Skills")
#points(skills)

#let courses = ([#lorem(4)], [#lorem(5)], [#lorem(3)], [#lorem(2)], [#lorem(4)])

#section_header("Relevant Coursework")
#dual(courses)

#section_header("Professional Experience")

#let interner = ([#lorem(25)], [#lorem(30)])
#dated_section(
  "Software Intern",
  "industrial",
  date_start: "May 2024",
  date_end: "Aug 2024",
  ongoing: false,
  points: interner,
)

#dated_section(
  "AI Intern",
  "research",
  date_start: "May 2024",
  ongoing: true,
  points: interner,
)

#section_header("Projects")
#let interner = ([#lorem(25)], [#lorem(30)])
#dated_section(
  "Cybersecurity Project Maintainer",
  "self",
  points: interner,
)
