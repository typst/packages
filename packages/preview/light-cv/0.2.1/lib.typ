#import "@preview/fontawesome:0.6.0": *

#import "modules/utils.typ": *
#import "modules/header.typ": *
#import "modules/section.typ": *
#import "modules/skills.typ": *


#let cv(
  styles: (),
  content,
) = {
  set text(
    font: styles.body-style.fonts,
    weight: styles.body-style.weight,
    size: styles.body-style.size,
  )
  set list(
    indent: styles.list-style.indent,
  )
  set align(left)
  set page(
    paper: styles.page-style.paper,
    margin: styles.page-style.margin,
  )
  content
}

#let header(
  styles: (),
  full-name: [],
  job-title: [],
  // Each array item must have a property link, text and icon to be displayed.
  socials: (),
  profile-picture: "",
) = {
  table(
    columns: styles.header-style.table.columns,
    inset: 0pt,
    stroke: none,
    column-gutter: styles.header-style.table.column-gutter,
    align: left + horizon,
    {
      create-header-info(
        styles: styles,
        full-name: full-name,
        job-title: job-title,
        socials: socials,
      )
    },
    {
      create-header-image(
        styles: styles,
        profile-photo: profile-picture,
      )
    }
  )
  v(styles.header-style.margins.bottom)
}

#let section(
  styles: (),
  title: "",
) = {
  v(styles.section-style.margins.top)
  create-section-title(
    styles: styles,
    title: title,
  )
}

#let entry(
  styles: (),
  title: "",
  company-or-university: "",
  date: "",
  location: "",
  logo: "",
  description: (),
) = {
  v(styles.entry-style.margins.top)
  table(
    columns: { if logo != none { styles.entry-style.table.columns } else { auto } },
    inset: 0pt,
    stroke: none,
    align: horizon,
    column-gutter: styles.entry-style.margins.between-logo-and-title,
    { logo },
    table(
      columns: 1fr,
      inset: 0pt,
      stroke: none,
      row-gutter: styles.entry-style.margins.between-title-and-subtitle,
      align: auto,
      {
        text(
          size: styles.entry-style.title.size,
          weight: styles.entry-style.title.weight,
          fill: styles.entry-style.title.color,
          title,
        )
        text(
          size: styles.entry-style.company-or-university.size,
          weight: styles.entry-style.company-or-university.weight,
          fill: styles.entry-style.company-or-university.color,
          { if company-or-university.len() > 0 { " @" } } + company-or-university,
        )
      },
      {
        table(
          columns: 2,
          inset: 0pt,
          stroke: none,
          align: horizon,
          column-gutter: styles.entry-style.margins.between-time-and-location,
          {
            table(
              columns: 2,
              inset: 0pt,
              stroke: none,
              align: horizon,
              column-gutter: styles.entry-style.margins.between-icon-and-text,
              { if date.len() > 0 { fa-hourglass-2() } },
              {
                text(
                  size: styles.entry-style.time-and-location.size,
                  weight: styles.entry-style.time-and-location.weight,
                  fill: styles.entry-style.time-and-location.color,
                  date,
                )
              },
            )
          },
          {
            table(
              columns: 2,
              inset: 0pt,
              stroke: none,
              align: horizon,
              column-gutter: styles.entry-style.margins.between-icon-and-text,
              { if location.len() > 0 { fa-location-dot() } }, { text(size: 10pt, location) },
            )
          },
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
  styles: (),
  category: "",
  skills: (),
) = {
  table(
    columns: styles.skills-style.columns,
    inset: 0pt,
    column-gutter: 0pt,
    stroke: none,
    align: (horizon, left),
    { text(category) },
    {
      render-skills(
        styles: styles,
        skills: skills,
      )
    }
  )
  v(styles.skills-style.margins.between-categories)
}