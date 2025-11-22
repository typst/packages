#import "@preview/fontawesome:0.1.0": *

#import "template/settings/styles.typ": *

#import "modules/utils.typ": *
#import "modules/header.typ": *
#import "modules/section.typ": *
#import "modules/skills.typ": *


#let cv(
  content
) = {
  set text(
    font: body-style.fonts,
    weight: body-style.weight,
    size: body-style.size,
  )
  set list(
    indent: list-style.indent
  )
  set align(left)
  set page(
    paper: page-style.paper,
    margin: page-style.margin
  )
  content
}

#let header(
  full-name: [],
  job-title: [],
  // Each array item must have a property link, text and icon to be displayed.
  socials: (),
  profile-picture: ""
) = {
  table(
    columns: header-style.table.columns,
    inset: 0pt,
    stroke: none,
    column-gutter: header-style.table.column-gutter,
    align: left + horizon,
    {
      create-header-info(
        full-name: full-name,
        job-title: job-title,
        socials: socials
      )
    },
    {
      create-header-image(
        profile-photo: profile-picture
      )
    }
  )
  v(header-style.margins.bottom)
}

#let section(title) = {
  v(section-style.margins.top)
  create-section-title(title)
}

#let entry(
  title: "", 
  company-or-university: "", 
  date: "", 
  location: "", 
  logo: "", 
  description: ()
) = {
  v(entry-style.margins.top)
  table(
    columns: entry-style.table.columns,
    inset: 0pt,
    stroke: none,
    align: horizon,
    column-gutter: entry-style.margins.between-logo-and-title,
    {logo},
    table(
      columns: (1fr),
      inset: 0pt,
      stroke: none,
      row-gutter: entry-style.margins.between-title-and-subtitle,
      align: auto,
      {
        text(
          size: entry-style.title.size,
          weight: entry-style.title.weight,
          fill: entry-style.title.color,
          title
        )
        text(
          size: entry-style.company-or-university.size, 
          weight: entry-style.company-or-university.weight, 
          fill: entry-style.company-or-university.color, 
          " @" + company-or-university
        )
      },
      {
        table(
          columns: 2,
          inset: 0pt,
          stroke: none,
          align: horizon,
          column-gutter: entry-style.margins.between-time-and-location,
          {table(
            columns: 2,
            inset: 0pt,
            stroke: none,
            align: horizon,
            column-gutter: entry-style.margins.between-icon-and-text,
            {if date.len() > 0{fa-hourglass-2()}},
            {text(
              size: entry-style.time-and-location.size, 
              weight: entry-style.time-and-location.weight, 
              fill: entry-style.time-and-location.color, 
              date
            )},
          )},
          {table(
            columns: 2,
            inset: 0pt,
            stroke: none,
            align: horizon,
            column-gutter: entry-style.margins.between-icon-and-text,
            {if location.len() > 0{fa-location-dot()}},
            {text(size: 10pt, location)}
          )},
        )
      },
    )
  )
  
  text()[
    #v(3pt)
    #description
  ]
}

#let skill(
  category: "",
  skills: ()
) = {
  table(
    columns: skills-style.columns,
    inset: 0pt,
    column-gutter: 0pt,
    stroke: none,
    align: (horizon, left),
    {text(category)},
    {
      render-skills(skills: skills)
    }
  )
  v(skills-style.margins.between-categories)
}
