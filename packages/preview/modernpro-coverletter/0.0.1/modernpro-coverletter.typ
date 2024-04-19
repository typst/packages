///////////////////////////////
// modernpro-coverletter.typ
// A cover letter template with modern Sans font for job applications and other formal letters.
// Copyright (c) 2024
// Author:  Jiaxin Peng
// License: MIT
// Version: 0.0.1
// Date:    2024-04-19
// Email:   jiaxin.peng@outlook.com
///////////////////////////////

#let main(
  font-type: "openfont",
  name: "",
  address: "",
  contacts: (),
  recipient: (
    start-title: "",
    cl-title: "",
    date: "",
    department: "",
    institution: "",
    address: "",
    postcode: "",
  ),
  mainbody,
) = {
  let date_colour = rgb("#666666")
  let primary-colour = rgb("#2b2b2b")
  let headings-colour = rgb("#6A6A6A")
  let subheadings-colour = rgb("#333333")

  let sectionsep = {
    [#v(5pt)]
  }
  let subsectionsep = {
    [#v(2pt)]
  }

  // Set font type for all text
  // #let font-type = "macfont"
  let font-head = {
    if font-type == "macfont" {
      "Helvetica Neue"
    } else if font-type == "openfont" {
      "PT Sans"
    } else {
      "Times New Roman"
    }
  }

  let font-term = {
    if font-type == "macfont" {
      "Heiti TC"
    } else if font-type == "openfont" {
      "PT Sans"
    } else {
      "Times New Roman"
    }
  }

  let font-descript = {
    if font-type == "macfont" {
      "Heiti SC"
    } else if font-type == "openfont" {
      "PT Sans"
    } else {
      "Times New Roman"
    }
  }

  let font-info = {
    if font-type == "macfont" {
      "Helvetica"
    } else if font-type == "openfont" {
      "PT Sans"
    } else {
      "Times New Roman"
    }
  }

  let recipient-generate(
    start-title,
    cl-title,
    date,
    department,
    institution,
    address,
    postcode,
  ) = {
    align(
      left,
      {
        if department != [] {
          text(
            10pt,
            font: font-info,
            fill: subheadings-colour,
            weight: "bold",
          )[#department]
        }
        h(1fr)
        if date != "" {
          text(10pt, font: font-info, fill: primary-colour, weight: "light")[#date\ ]
        } else {
          text(
            10pt,
            font: font-info,
            fill: primary-colour,
            weight: "light",
          )[ #datetime.today(offset: auto).display("[day] [month repr:long] [year]")\ ]
        }

        if institution != [] {
          text(
            10pt,
            font: font-info,
            fill: subheadings-colour,
            weight: "bold",
          )[#institution\ ]
        }

        if address != [] {
          text(
            10pt,
            font: font-info,
            fill: headings-colour,
            weight: "light",
          )[#address\ ]
        }
        if postcode != [] {
          text(
            10pt,
            font: font-info,
            fill: headings-colour,
            weight: "light",
          )[#postcode ]
        }
      },
    )

    align(left, text(
      12pt,
      font: font-head,
      fill: primary-colour,
      weight: "medium",
    )[#upper(cl-title)])
    v(0.1em)
    set text(11pt, font: font-head, fill: primary-colour, weight: "regular")

    [#start-title]
  }

  // show contact details
  let display(contacts) = {
    set text(
      11pt,
      font: font-term,
      fill: headings-colour,
      weight: "medium",
      top-edge: "baseline",
      bottom-edge: "baseline",
      baseline: 2pt,
    )
    contacts.map(contact =>{
      if contact.link == none [
        contact.text
      ] else {
        link(contact.link)[#{ contact.text }]
      }
    }).join(" | ")
  }

  set page(margin: (left: 2cm, right: 2cm, top: 3.2cm, bottom: 1.5cm), header: {
    // Head Name Section
    text(
      25pt,
      font: font-head,
      fill: primary-colour,
      weight: "light",
      top-edge: "baseline",
      bottom-edge: "baseline",
      baseline: 12pt,
    )[#align(center, [#name])]
    text(
      11pt,
      font: font-descript,
      fill: headings-colour,
      weight: "medium",
      top-edge: "baseline",
      bottom-edge: "baseline",
    )[#align(center, [#address])]
    align(center)[#display(contacts)]
    line(length: 100%, stroke: 0.5pt + primary-colour)
  }, header-ascent: 1em)

  // Add recipient details
  recipient-generate(
    recipient.start-title,
    recipient.cl-title,
    recipient.date,
    recipient.department,
    recipient.institution,
    recipient.address,
    recipient.postcode,
  )

  set par(justify: true, first-line-indent: 2em)

  set text(11pt, font: font-info, fill: primary-colour, weight: "regular")

  mainbody

  set text(11pt, font: font-info, fill: primary-colour, weight: "regular")
  [Sincerely,\ ]
  v(1pt)
  [*#name*]
}