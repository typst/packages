///////////////////////////////
// modernpro-cv.typ
// A CV template with modern Sans font and professional look
// Copyright (c) 2025
// Author:  Jiaxin Peng
// License: MIT
// Version: 1.2.1
// Date:    2025-10-14
// Email:   jiaxin.peng@outlook.com
///////////////////////////////

// Define the colour scheme
#let date-colour = rgb("#666666")
#let primary-colour = rgb("#000000")
#let headings-colour = rgb("#2b2b2b")
#let subheadings-colour = rgb("#333333")

#let sectionsep = {
  [#v(0.5pt)]
}

#let subsectionsep = {
  [#v(0.5pt)]
}

// Section Headings (Education, Experience, etc)
#let section(title) = {
  text(12pt, fill: headings-colour, weight: "bold")[
    #upper[#title]
    #v(-8pt)
    #line(length: 100%)
    #v(-5pt)
  ]
}

// Subsection Headings (institution, Company, etc)
#let subsection(content) = {
  text(11pt, fill: subheadings-colour, weight: "bold")[#content]
}

// Education part
#let education(institution: none, major: none, date: none, location: none, description: none) = {
  let institution_location = if (institution != none) and (location != none) {
    // With comma separator
    [#institution, #location]
  } else {
    // Without comma separator
    [#institution #location]
  }
  text(11pt, fill: subheadings-colour, weight: "bold")[#institution_location]
  h(1fr)
  text(11pt, style: "italic", fill: headings-colour, weight: "regular")[#date \ ]
  text(11pt, style: "italic", fill: subheadings-colour, weight: "medium")[#major \ ]
  if description != [] or description != none {
    text(11pt, fill: primary-colour, weight: "regular")[#description]
  }
}

// Projects
#let project(title, date, info) = {
  text(11pt, fill: subheadings-colour, weight: "semibold")[#title ]
  if date != [] or date != none {
    h(1fr)
    text(11pt, fill: headings-colour, weight: "medium")[#date \ ]
  } else {
    [\ ]
  }
  if info != [] or info != none {
    text(11pt, fill: primary-colour, weight: "light")[#info ]
  }
}

// Description of a job, degree, etc
#let descript(content) = {
  text(11pt, fill: subheadings-colour, weight: "regular")[#content ]
}

// Job title
#let job(position: none, institution: none, location: none, date: none, description: none) = {
  text(11pt, fill: subheadings-colour, weight: "semibold")[#position]
  h(1fr)
  text(11pt, style: "italic", fill: headings-colour, weight: "regular")[#location \ ]
  text(11pt, style: "italic", fill: subheadings-colour, weight: "medium")[#institution]
  h(1fr)
  text(11pt, style: "italic", fill: headings-colour, weight: "regular")[#date]
  if description != [] or description != none {
    text(11pt, fill: primary-colour, weight: "regular")[#description]
  }
}

// Details
#let info(content) = {
  text(11pt, fill: primary-colour, weight: "light")[#content\ ]
}

#let oneline-title-item(title: none, content: none) = {
  text(11pt, fill: subheadings-colour, weight: "bold")[#title: ]
  text(11pt, fill: primary-colour, weight: "light")[#content \ ]
}

#let oneline-two(entry1: none, entry2: none) = {
  let left-content = if entry1 != none { entry1 } else { [] }
  let right-content = if entry2 != none { [#entry2 \ ] } else { [] }

  text(11pt, fill: subheadings-colour, weight: "regular")[#left-content]
  h(1fr)
  text(11pt, fill: primary-colour, weight: "regular")[#right-content]
}

#let twoline-item(entry1: none, entry2: none, entry3: none, entry4: none, description: none) = {
  text(11pt, fill: subheadings-colour, weight: "semibold")[#entry1]
  if entry2 != none {
    h(1fr)
    text(11pt, style: "italic", fill: headings-colour, weight: "regular")[#entry2 \ ]
  }
  if entry3 != [] or entry3 != none {
    text(11pt, style: "italic", fill: subheadings-colour, weight: "medium")[#entry3]
  }
  if entry4 != none {
    h(1fr)
    text(11pt, style: "italic", fill: headings-colour, weight: "regular")[#entry4 \ ]
  }
  if description != [] or description != none {
    text(11pt, fill: primary-colour, weight: "regular")[#description]
  }
}

#let award(award: none, institution: none, date: none) = {
  [#text(11pt, fill: primary-colour, weight: "medium")[#award,] #text(
      11pt,
      fill: primary-colour,
      weight: "regular",
    )[#emph(institution)] #h(1fr) #text(11pt, fill: primary-colour, weight: "regular")[#emph(date)\ ]]
}

#let references(references: ()) = {
  grid(columns: (1fr, 1fr), row-gutter: 10pt, ..references.map(reference => {
      align(
        left,
        {
          if ("position" in reference) {
            text(11pt, fill: primary-colour, weight: "semibold")[#reference.name | #reference.position\ ]
          } else {
            text(11pt, fill: primary-colour, weight: "semibold")[#reference.name\ ]
          }

          if ("department" in reference) {
            text(10pt, fill: primary-colour, weight: "regular")[#reference.department\ ]
          }
          if ("institution" in reference) {
            text(10pt, fill: primary-colour, weight: "regular")[#reference.institution\ ]
          }
          if ("address" in reference) {
            text(10pt, fill: primary-colour, weight: "regular")[#reference.address\ ]
          }
          if ("email" in reference) {
            text(10pt, fill: primary-colour, weight: "regular")[
              #reference.email \
            ]
          }
          v(2pt)
        },
      )
    }))
}

// Publications
#let publication(path, styletype) = {
  set text(11pt, fill: primary-colour, weight: "light")
  bibliography(path, title: none, full: true, style: styletype)
}

// show contact details
#let contact-display(contacts) = {
  v(-5pt)
  set text(10pt, fill: headings-colour, weight: "regular")
  contacts
    .map(contact => {
        if ("link" in contact) {
          link(contact.link)[#contact.text]
        } else {
          [#contact.text]
        }
      })
    .join(" | ")
}

#let cv-single(
  font-type: "Times New Roman",
  continue-header: "false",
  margin: none,
  name: none,
  address: none,
  lastupdated: "true",
  pagecount: "true",
  date: none,
  contacts: (),
  mainbody,
) = {
  set text(font: font-type, weight: "regular")
  set cite(form: "full")

  if date == none {
    let date = [#datetime.today().display()]
  }

  // last update
  let lastupdate(lastupdated, date) = {
    if lastupdated == "true" {
      set text(8pt, style: "italic", fill: primary-colour, weight: "light")
      [Last updated: #date]
    }
  }

  set page(footer: [
    #lastupdate(lastupdated, date)
    #h(1fr)
    #text(9pt, style: "italic", fill: primary-colour, weight: "light")[#name]
    #h(1fr)
    #if pagecount == "true" {
      text(
        9pt,
        style: "italic",
        fill: primary-colour,
        weight: "light",
      )[Page #context counter(page).display("1 / 1", both: true)]
    }
  ])

  let resolved-margin = if margin != none {
    margin
  } else if continue-header == "true" {
    (left: 1.25cm, right: 1.25cm, top: 2.5cm, bottom: 1.5cm)
  } else {
    (left: 1.25cm, right: 1.25cm, top: 1cm, bottom: 1cm)
  }

  if continue-header == "true" {
    set page(
      margin: resolved-margin,
      header: {
        text(
          20pt,
          fill: primary-colour,
          weight: "bold",
          top-edge: "baseline",
          bottom-edge: "baseline",
          baseline: 11pt,
        )[#align(center, [#name])]
        // address
        if address != none {
          v(3pt)
          text(
            11pt,
            fill: primary-colour,
            weight: "regular",
            top-edge: "baseline",
            bottom-edge: "baseline",
            baseline: 2pt,
          )[#align(center, [#address])]
        }
        v(2pt)
        align(center)[#contact-display(contacts)]
      },
      header-ascent: 1em,
    )
    mainbody
  } else {
    set page(margin: resolved-margin)
    text(
      20pt,
      fill: primary-colour,
      weight: "bold",
      top-edge: "baseline",
      bottom-edge: "baseline",
      baseline: 11pt,
    )[#align(center, [#name])]
    // address
    if address != none {
      v(3pt)
      text(
        11pt,
        fill: primary-colour,
        weight: "regular",
        top-edge: "baseline",
        bottom-edge: "baseline",
        baseline: 2pt,
      )[#align(center, [#address])]
    }
    v(2pt)
    align(center)[#contact-display(contacts)]
    // line(length: 100%, stroke: 0.5pt + primary-colour)
    mainbody
  }
  //Main Body
}

#let cv-double(
  font-type: "Times New Roman",
  continue-header: "false",
  margin: none,
  name: none,
  address: none,
  lastupdated: "true",
  pagecount: "true",
  date: none,
  contacts: (),
  left: none,
  right: none,
) = {
  set text(font: font-type, weight: "regular")
  set cite(form: "full")

  if date == none {
    let date = [#datetime.today().display()]
  }

  // last update
  let lastupdate(lastupdated, date) = {
    if lastupdated == "true" {
      set text(8pt, style: "italic", fill: primary-colour, weight: "light")
      [Last updated: #date]
    }
  }

  set page(footer: [
    #lastupdate(lastupdated, date)
    #h(1fr)
    #text(9pt, style: "italic", fill: primary-colour, weight: "light")[#name]
    #h(1fr)
    #if pagecount == "true" {
      text(
        9pt,
        style: "italic",
        fill: primary-colour,
        weight: "light",
      )[Page #context counter(page).display("1 / 1", both: true)]
    }
  ])

  let resolved-margin = if margin != none {
    margin
  } else if continue-header == "true" {
    (left: 1.25cm, right: 1.25cm, top: 2.5cm, bottom: 1.5cm)
  } else {
    (left: 1.25cm, right: 1.25cm, top: 1cm, bottom: 1.5cm)
  }

  if continue-header == "true" {
    set page(
      margin: resolved-margin,
      header: {
        text(
          20pt,
          fill: primary-colour,
          weight: "bold",
          top-edge: "baseline",
          bottom-edge: "baseline",
          baseline: 11pt,
        )[#align(center, [#name])]
        // address
        if address != none {
          v(3pt)
          text(
            11pt,
            fill: primary-colour,
            weight: "regular",
            top-edge: "baseline",
            bottom-edge: "baseline",
            baseline: 2pt,
          )[#align(center, [#address])]
        }
        v(2pt)
        align(center)[#contact-display(contacts)]
        v(2pt)
      },
      header-ascent: 1em,
    )
    //Main Body
    grid(
      columns: (1fr, 2fr),
      column-gutter: 2em,
      left, right,
    )
  } else {
    set page(margin: resolved-margin)
    text(
      20pt,
      fill: primary-colour,
      weight: "bold",
      top-edge: "baseline",
      bottom-edge: "baseline",
      baseline: 11pt,
    )[#align(center, [#name])]
    // address
    if address != none {
      v(3pt)
      text(
        11pt,
        fill: primary-colour,
        weight: "regular",
        top-edge: "baseline",
        bottom-edge: "baseline",
        baseline: 2pt,
      )[#align(center, [#address])]
    }
    v(2pt)
    align(center)[#contact-display(contacts)]
    v(2pt)
    //Main Body
    grid(
      columns: (1fr, 2fr),
      column-gutter: 2em,
      left, right,
    )
  }
}
