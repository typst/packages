#import "@preview/tuhi-programme-vuw:0.1.0": tuhi-programme-vuw

#let courses = json("teas.json")
#let ids = yaml("teas.yml")

#show: tuhi-programme-vuw.with(
  author:"SCPS",
  title: text[*teas* and *clay* double major],
  tagline: "Recommended for careers involving tea and its groundbreaking vessels",
  search-url: "tea.academy/what-s-brewing/",
  course-info: courses,
  course-ids: ids,
  show-trimester: false)
