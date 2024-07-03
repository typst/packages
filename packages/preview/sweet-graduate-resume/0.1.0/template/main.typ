#import "@preview/sweet-graduate-resume:0.1.0": *

#show: doc => preamble(doc)

#let urls = (
  (
    name: "Codeberg",
    url: "https://codeberg.org/innocent_zero",
    svg: image("svg/codeberg.svg"),
    fa: false,
    brand: false,
    solid: false,
  ),
  (name: "Website", url: "https://example.com", svg: "link", fa: true, brand: false, solid: false),
  (name: "Website", url: "https://example.com", svg: "github", fa: true, brand: true, solid: true),
)

#header("InnocentZero", "roll", "school", urls)

#let edu = ((prog: "Bachelors", school: "college", grade: "4.0"), (prog: "grad", school: "school", grade: "4.0"))

#section-header("Education")
#education(edu)

#let achievements = ([#lorem(30)], [#lorem(20)])

#section-header("Scholastic Achievements")
#points(achievements)

#let skills = ([#lorem(30)], [#lorem(20)])

#section-header("Major Competitions and Technical Skills")
#points(skills)

#let courses = ([#lorem(4)], [#lorem(5)], [#lorem(3)], [#lorem(2)], [#lorem(4)])

#section-header("Relevant Coursework")
#dual(courses)

#section-header("Professional Experience")

#let interner = ([#lorem(25)], [#lorem(30)])
#dated-section(
  "Software Intern",
  "industrial",
  date-start: "May 2024",
  date-end: "Aug 2024",
  ongoing: false,
  points: interner,
)

#dated-section(
  "AI Intern",
  "research",
  date-start: "May 2024",
  ongoing: true,
  points: interner,
)

#section-header("Projects")
#let interner = ([#lorem(25)], [#lorem(30)])
#dated-section(
  "Cybersecurity Project Maintainer",
  "self",
  points: interner,
)
