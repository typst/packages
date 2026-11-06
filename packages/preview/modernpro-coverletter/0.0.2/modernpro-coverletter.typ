///////////////////////////////
// modernpro-coverletter.typ
// A cover letter template with modern Sans font for job applications and other formal letters.
// Copyright (c) 2024
// Author:  Jiaxin Peng
// License: MIT
// Version: 0.0.2
// Date:    2024-07-28
// Email:   jiaxin.peng@outlook.com
///////////////////////////////

#let main(
  font-type: "",
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

  // set the recipient
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
            font: font-type,
            fill: subheadings-colour,
            weight: "bold",
          )[#department]
        }
        h(1fr)
        if date != "" {
          text(10pt, font: font-type, fill: primary-colour, weight: "light")[#date\ ]
        } else {
          text(
            10pt,
            font: font-type,
            fill: primary-colour,
            weight: "light",
          )[ #datetime.today(offset: auto).display("[day] [month repr:long] [year]")\ ]
        }

        if institution != [] {
          text(
            10pt,
            font: font-type,
            fill: subheadings-colour,
            weight: "bold",
          )[#institution\ ]
        }

        if address != [] {
          text(
            10pt,
            font: font-type,
            fill: headings-colour,
            weight: "light",
          )[#address\ ]
        }
        if postcode != [] {
          text(
            10pt,
            font: font-type,
            fill: headings-colour,
            weight: "light",
          )[#postcode ]
        }
      },
    )

    align(
      left,
      text(
        12pt,
        font: font-type,
        fill: primary-colour,
        weight: "bold",
      )[#upper(cl-title)],
    )
    v(0.1em)
    set text(11pt, font: font-type, fill: primary-colour, weight: "regular")

    [#start-title,]
  }

  // show contact details
  let display(contacts) = {
    set text(
      11pt,
      font: font-type,
      fill: headings-colour,
      weight: "medium",
      top-edge: "baseline",
      bottom-edge: "baseline",
      baseline: 2pt,
    )
    contacts
      .map(contact => {
          if contact.link == none [
            contact.text
          ] else {
            link(contact.link)[#{
                contact.text
              }]
          }
        })
      .join(" | ")
  }

  set page(
    margin: (left: 2cm, right: 2cm, top: 3.2cm, bottom: 1.5cm),
    header: {
      // Head Name Section
      text(
        25pt,
        font: font-type,
        fill: primary-colour,
        weight: "light",
        top-edge: "baseline",
        bottom-edge: "baseline",
        baseline: 12pt,
      )[#align(center, [#name])]
      text(
        11pt,
        font: font-type,
        fill: headings-colour,
        weight: "medium",
        top-edge: "baseline",
        bottom-edge: "baseline",
      )[#align(center, [#address])]
      align(center)[#display(contacts)]
      line(length: 100%, stroke: 0.5pt + primary-colour)
    },
    header-ascent: 1em,
  )

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

  set text(11pt, font: font-type, fill: primary-colour, weight: "regular")

  mainbody

  set text(11pt, font: font-type, fill: primary-colour, weight: "regular")

  v(1pt)
  [Sincerely,]
  v(1pt)
  [*#name*]
}