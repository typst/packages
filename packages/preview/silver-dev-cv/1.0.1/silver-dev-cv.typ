///////////////////////////////
// silver-dev-cv.typ
// A CV template for software engineer by Gabriel Benmergui
// Copyright (c) 2024
// Author:  Gabriel Benmergui
// License: MIT
// Version: 1.0.1
// Date:    2024-10-29
// Email:   gabriel@silver.dev
///////////////////////////////

#set document(author: "silver")

// Define the colour scheme
#let date-colour = rgb("#666666")
#let primary-colour = rgb("#000000")
#let headings-colour  = rgb("#2b2b2b")
#let subheadings-colour  = rgb("#333333")

#let sectionsep = {
  [#v(0.5pt)]
}

#let subsectionsep = {
  [#v(0.5pt)]
}

// Section Headings (Education, Experience, etc)
#let section(title) = {
  text(12pt, fill: headings-colour , weight: "bold")[
    #upper[#title]
    #v(-8pt)
    #line(length: 100%)
    #v(-5pt)
  ]
}

// Subsection Headings (institution, Company, etc)
#let subsection(content) = {
  text(11pt, fill: subheadings-colour , weight: "bold")[#content]
}

// Education part
#let education(institution: "", major: "", date: "", location: "", description: "") = {
  text(11pt, fill: subheadings-colour , weight: "bold")[#institution, #location]
  h(1fr)
  text(11pt, style: "italic", fill: headings-colour , weight: "regular")[#date \ ]
  text(11pt, style: "italic", fill: subheadings-colour , weight: "medium")[#major \ ]
  if description != [] or description != "" {
    text(11pt, fill: primary-colour, weight: "regular")[#description]
  }
}

// Projects
#let project(title: "", description: "", date: "") = {
  text(11pt, fill: subheadings-colour , weight: "semibold")[#title ]
  if date != [] or date != "" {
    h(1fr)
    text(11pt, fill: headings-colour , weight: "medium")[#date \ ]
  } else {
    [\ ]
  }
  if description != [] or description != "" {
    text(11pt, fill: primary-colour, weight: "light")[#description ]
  }
}

// Description of a job, degree, etc
#let descript(content) = {
  text(11pt, fill: subheadings-colour , weight: "regular")[#content ]
}

// Job title
#let job(position: "", institution: "", location: "", date: "", description: "") = {
  text(11pt, fill: subheadings-colour , weight: "semibold")[#position]
  h(1fr)
  text(11pt, style: "italic", fill: headings-colour , weight: "regular")[#location \ ]
  text(11pt, style: "italic", fill: subheadings-colour , weight: "medium")[#institution]
  h(1fr)
  text(11pt, style: "italic", fill: headings-colour , weight: "regular")[#date]
  if description != [] or description != "" {
    text(11pt, fill: primary-colour, weight: "regular")[#description]
  }
}

// Details
#let info(content) = {
  text(11pt, fill: primary-colour, weight: "light")[#content\ ]
}

#let oneline-title-item(title: "", content: "") = {
  text(11pt, fill: subheadings-colour , weight: "bold")[#title: ]
  text(11pt, fill: primary-colour, weight: "light")[#content \ ]
}

#let oneline-two(entry1: "", entry2: "") = {
  text(11pt, fill: subheadings-colour , weight: "regular")[#entry1]
  h(1fr)
  text(11pt, fill: primary-colour, weight: "regular")[#entry2 \ ]
}

#let twoline-item(entry1: none, entry2: none, entry3: none, entry4: none, description: none) = {
  text(11pt, fill: subheadings-colour , weight: "semibold")[#entry1]
  if entry2 != none {
    h(1fr)
    text(11pt, style: "italic", fill: headings-colour , weight: "regular")[#entry2 \ ]
  }
  if entry3 != [] or entry3 != "" != none {
    text(11pt, style: "italic", fill: subheadings-colour , weight: "medium")[#entry3]
  }
  if entry4 != none {
    h(1fr)
    text(11pt, style: "italic", fill: headings-colour , weight: "regular")[#entry4 \ ]
  }
  if description != [] or description != "" {
    text(11pt, fill: primary-colour, weight: "regular")[#description]
  }
}

#let award(award: "", institution: "", date: "") = {
  [#text(11pt, fill: primary-colour, weight: "medium")[#award,] #text(
      11pt,
      fill: primary-colour,
      weight: "regular",
    )[#emph(institution)] #h(1fr) #text(11pt, fill: primary-colour, weight: "regular")[#emph(date)\ ]]
}

// show contact details
#let display(contacts) = {
  set text(10pt, fill: headings-colour , weight: "regular", top-edge: "baseline", bottom-edge: "baseline", baseline: 2pt)
  contacts
    .map(contact => {
        if ("link" in contact) {
          link(contact.link)[#{
              contact.text
            }]
        } else [
          #{contact.text}
        ]
      })
    .join(" | ")
}

#let cv(
  font-type: "Times New Roman",
  continue-header: "false",
  name: "",
  address: "",
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
  ])

  if continue-header == "true" {
    set page(
      margin: (left: 1.25cm, right: 1.25cm, top: 2.5cm, bottom: 1.5cm),
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
          v(2pt)
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
        align(center)[#display(contacts)]
      },
      header-ascent: 1em,
    )
    mainbody
  } else {
    set page(margin: (left: 1.25cm, right: 1.25cm, top: 1cm, bottom: 1cm))
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
      v(2pt)
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
    align(center)[#display(contacts)]
    // line(length: 100%, stroke: 0.5pt + primary-colour)
    mainbody
  }
  //Main Body
}
