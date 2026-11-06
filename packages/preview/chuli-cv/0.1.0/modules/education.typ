#import "@preview/fontawesome:0.1.0": *
#import "./styles.typ": *

#let render-education-header(title, logo, company-or-university) = {
  table(
      columns: (5%, 1fr),
      inset: 0pt,
      column-gutter: 2pt,
      row-gutter: 2pt,
      stroke: none,
      align: horizon,
      logo,
      black-topic-style(title),
      {},
      accent-subtopic-style(" " + company-or-university)
  )
}

#let render-education-icon-info(date: "", location: "") = {
  table(
    columns: 4,
    stroke: none,
    inset: 3pt,
    fa-calendar-days(),
    regular-text-style(date),
    fa-location-dot(),
    regular-text-style(location)   
  )
}

