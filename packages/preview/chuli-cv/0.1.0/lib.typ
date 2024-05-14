#import "@preview/fontawesome:0.1.0": *
#import "modules/styles.typ": *
#import "modules/header.typ": *
#import "modules/section.typ": *
#import "modules/skills.typ": *
#import "modules/languages.typ": *
#import "modules/piechart.typ": *
#import "modules/education.typ": *
#import "modules/entry.typ": *


// Cover letter Components
//--------------------------------------------

#let letter-header(
  name: "Your Name Here",
  address: "Your Address Here",
  recipientName: "Company Name Here",
  recipientAddress: "Company Address Here",
  date: "Today's Date",
  subject: "Subject: Hey!"
) = {
  accent-subtopic-style(name)
  v(1pt)
  inactive-ligth-style(address)
  v(1pt)
  align(right, accent-subtopic-style(recipientName))
  v(1pt)
  align(right, inactive-ligth-style(recipientAddress))
  v(1pt)
  italic-text-style(date)
  v(1pt)
  underline-accent-style(subject)
  linebreak(); linebreak()
}

#let letter-signature(path) = {
  linebreak()
  place(
    letter-signature-style.position, 
    dx:letter-signature-style.dx, 
    dy:letter-signature-style.dy, 
    path,
  )
}

#let letter-footer(name: "Your Name Here") = {
  place(
    letter-footer-style.position,
    table(
      columns: letter-footer-style.table.columns,
      inset: letter-footer-style.table.inset,
      stroke: none,
      footer-style(name),
    )
  )
}

// Cover letter layout
//--------------------------------------------

#let cover-letter(content) = {
  set text(
    font: body-style.fonts,
    weight: body-style.weight,
    size: body-style.size,
  )
  set align(page-style.text.align)
  set page(
    paper: page-style.paper,
    margin: (
      left: page-style.margin.left,
      right: page-style.margin.right,
      top: page-style.margin.top,
      bottom: page-style.margin.bottom,
    ),
  )
  content
}

// CV Components
//--------------------------------------------

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
    margin: page-style.margin,
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
    inset: header-style.table.inset,
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
      create-header-avatar(
        profile-photo: profile-picture
      )
    }
  )
  v(header-style.margins.bottom)
}

#let body(content) = {
  set text(
    font: body-style.fonts,
    weight: body-style.weight,
    size: body-style.size,
  )
  set list(
    indent: list-style.indent
  )
  set align(left)
  content
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
    inset: entry-style.table.inset,
    stroke: none,
    align: entry-style.table.align,
    column-gutter: entry-style.margins.between-logo-and-title,
    {logo},
    render-entry-header(title, company-or-university, date, location)
  )
  
  text()[
    #v(3pt)
    #description
  ]
}

#let skill(
  skills: ()
) = {
  v(skills-style.margins.between-categories)
  render-skills(skills: skills)
}

#let language(
  name: "",
  label: "",
  nivel: 2
) = {
  table(
    columns: language-style.columns,
    inset: 0pt,
    row-gutter: language-style.row-gutter,
    stroke: none,
    align: language-style.align,
    accent-subtopic-style(name),
    render-language(nivel: nivel),
    table.hline(
      stroke: (
        paint: colors.inactive, 
        thickness: 1pt, 
        dash: "dashed"
      ),
    ),
    {
      v(4pt)
      inactive-ligth-style(label)
    }
  )
}

#let freetime(name: "",icon:"") = {
  table(
    columns: freetime-style.columns,
    inset: 0pt,
    column-gutter: freetime-style.column-gutter,
    stroke: none,
    align: freetime-style.align,
    {icon},
    regular-text-style(name),
  )
  dashed-line()
}

#let education-entry(  
  title: "", 
  company-or-university: "", 
  date: "", 
  location: "", 
  logo: "", 
  gpa: "",
  gpa-total: "" 
) = {
  table(
    columns: 2,
    stroke: none,
    inset: 0pt,
    row-gutter: education-entry-style.row-gutter,
    column-gutter: education-entry-style.column-gutter,
    render-education-header(title, logo, company-or-university),
    table.vline(),
    table.cell(
      accent-subtopic-style("GPA"),
      align: center,
    ),
    table.cell(
      render-education-icon-info(date: date, location: location),
      align: center,
    ),
    table.cell(
      {
        accent-subtopic-style(gpa)
        regular-text-style("/ " + gpa-total)
      },
      inset: 4pt,
    )
  )
}

#let piechart(activities: ()) = {
  figure(render-activities(slices: activities))
}