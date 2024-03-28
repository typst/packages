#import "@preview/fontawesome:0.1.0": *

#import "settings/styles.typ": *

#import "modules/utils.typ": *
#import "modules/header.typ": *
#import "modules/section.typ": *
#import "modules/skills.typ": *


#let cv(
  content
) = {
  set text(
    font: bodyStyle.fonts,
    weight: bodyStyle.weight,
    size: bodyStyle.size,
  )
  set list(
    indent: listStyle.indent
  )
  set align(left)
  set page(
    paper: pageStyle.paper,
    margin: pageStyle.margin
  )
  content
}

#let header(
  fullName: [],
  jobTitle: [],
  // Each array item must have a property link, text and icon to be displayed.
  socials: (),
  profilePicture: ""
) = {
  table(
    columns: headerStyle.table.columns,
    inset: 0pt,
    stroke: none,
    column-gutter: headerStyle.table.columnGutter,
    align: left + horizon,
    {
      createHeaderInfo(
        fullName: fullName,
        jobTitle: jobTitle,
        socials: socials
      )
    },
    {
      createHeaderImage(
        profilePhoto: profilePicture
      )
    }
  )
  v(headerStyle.margins.bottom)
}

#let section(title) = {
  v(sectionStyle.margins.top)
  createSectionTitle(title)
}

#let entry(
  title: "", 
  companyOrUniversity: "", 
  date: "", 
  location: "", 
  logo: "", 
  description: ()
) = {
  v(entryStyle.margins.top)
  table(
    columns: entryStyle.table.columns,
    inset: 0pt,
    stroke: none,
    align: horizon,
    column-gutter: entryStyle.margins.betweenLogoAndTitle,
    {image(logo)},
    table(
      columns: (1fr),
      inset: 0pt,
      stroke: none,
      row-gutter: entryStyle.margins.betweenTitleAndSubtitle,
      align: auto,
      {
        text(
          size: entryStyle.title.size,
          weight: entryStyle.title.weight,
          fill: entryStyle.title.color,
          title
        )
        text(
          size: entryStyle.companyOrUniversity.size, 
          weight: entryStyle.companyOrUniversity.weight, 
          fill: entryStyle.companyOrUniversity.color, 
          " @" + companyOrUniversity
        )
      },
      {
        table(
          columns: 2,
          inset: 0pt,
          stroke: none,
          align: horizon,
          column-gutter: entryStyle.margins.betweenTimeAndLocation,
          {table(
            columns: 2,
            inset: 0pt,
            stroke: none,
            align: horizon,
            column-gutter: entryStyle.margins.betweenIconAndText,
            {if date.len() > 0{fa-hourglass-2()}},
            {text(
              size: entryStyle.timeAndLocation.size, 
              weight: entryStyle.timeAndLocation.weight, 
              fill: entryStyle.timeAndLocation.color, 
              date
            )},
          )},
          {table(
            columns: 2,
            inset: 0pt,
            stroke: none,
            align: horizon,
            column-gutter: entryStyle.margins.betweenIconAndText,
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
    columns: skillsStyle.columns,
    inset: 0pt,
    column-gutter: 0pt,
    stroke: none,
    align: (horizon, left),
    {text(category)},
    {
      renderSkills(skills: skills)
    }
  )
  v(skillsStyle.margins.betweenCategories)
}
