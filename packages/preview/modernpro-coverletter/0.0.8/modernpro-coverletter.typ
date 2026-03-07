///////////////////////////////
// modernpro-coverletter.typ
// A cover letter template with modern Sans font for job applications and other formal letters.
// Copyright (c) 2025
// Author:  Jiaxin Peng
// License: MIT
// Version: 0.0.8
// Date:    2025-12-11
// Email:   jiaxin.peng@outlook.com
///////////////////////////////


#let coverletter(
  font-type: none,
  margin: none,
  name: none,
  address: none,
  contacts: (),
  recipient: (start-title: none, cl-title: none, date: none, department: none, institution: none, address: none, postcode: none),
  supplements: none,
  salutation: "Sincerely,",
  // Colour options
  primary-colour: rgb("#000000"),
  headings-colour: rgb("#2b2b2b"),
  subheadings-colour: rgb("#333333"),
  date-colour: rgb("#666666"),
  link-colour: none,  // none = inherit from text colour
  // Font size options
  name-size: 20pt,
  body-size: 11pt,
  address-size: 11pt,
  contact-size: 10pt,
  recipient-size: 10pt,
  cl-title-size: 12pt,
  supplement-size: 10pt,
  // Layout options
  line-stroke: 0.2pt,
  header-ascent: 1em,
  first-line-indent: 2em,
  line-spacing: 0.65em,
  paragraph-spacing: 0.8em,
  contact-separator: " | ",
  // Header alignment
  name-align: center,
  address-align: center,
  contact-align: center,
  // Font weight options
  name-weight: "bold",
  body-weight: "regular",
  salutation-weight: "regular",
  signature-weight: "bold",
  // Signature block spacing (defaults for electronic version)
  closing-spacing: 0.8em,
  signature-spacing: 0.3em,
  supplement-spacing: 0.8em,
  // Date format
  date-format: "[day] [month repr:long] [year]",
  mainbody,
) = {
  set text(font: font-type, weight: "regular")

  let sectionsep = {
    [#v(5pt)]
  }
  let subsectionsep = {
    [#v(2pt)]
  }

  let resolved-margin = if margin != none {
    margin
  } else {
    (left: 1.25cm, right: 1.25cm, top: 3cm, bottom: 1.5cm)
  }

  // set the recipient
  let recipient-generate(start-title, cl-title, date, department, institution, address, postcode) = {
    align(
      left,
      {
        if department != none and department != [] and department != "" {
          text(recipient-size, font: font-type, fill: subheadings-colour, weight: "bold")[#department]
        }
        h(1fr)
        if date != none and date != [] and date != "" {
          text(recipient-size, font: font-type, fill: date-colour, weight: "light")[#date\ ]
        } else {
          text(
            recipient-size,
            font: font-type,
            fill: date-colour,
            weight: "light",
          )[ #datetime.today(offset: auto).display(date-format)\ ]
        }

        if institution != none and institution != [] and institution != "" {
          text(recipient-size, font: font-type, fill: subheadings-colour, weight: "bold")[#institution\ ]
        }

        if address != none and address != [] and address != "" {
          text(recipient-size, font: font-type, fill: headings-colour, weight: "light")[#address\ ]
        }
        if postcode != none and postcode != [] and postcode != "" {
          text(recipient-size, font: font-type, fill: headings-colour, weight: "light")[#postcode ]
        }
      },
    )
    if cl-title != none and cl-title != [] and cl-title != "" {
      align(left, text(cl-title-size, font: font-type, fill: primary-colour, weight: "bold")[#upper(cl-title)])
      v(0.1em)
    }
    if start-title != none and start-title != [] and start-title != "" {
      set text(body-size, font: font-type, fill: primary-colour, weight: body-weight)
      [#start-title]
    }
  }

  // show contact details
  let contact-display(contacts) = {
    v(-5pt)
    set text(contact-size, fill: headings-colour, weight: "regular")
    let resolved-link-colour = if link-colour != none { link-colour } else { headings-colour }
    show link: set text(fill: resolved-link-colour)
    contacts
      .map(contact => {
          if ("link" in contact) {
            link(contact.link)[#{
                contact.text
              }]
          } else [
            #{
              contact.text
            }
          ]
        })
      .join(contact-separator)
  }

  set page(
    margin: resolved-margin,
    header: {
      // Head Name Section
      if name != none and name != [] and name != "" {
        text(
          name-size,
          fill: primary-colour,
          weight: name-weight,
          top-edge: "baseline",
          bottom-edge: "baseline",
          baseline: 12pt,
        )[#align(name-align, [#name])]
      }
      // address
      if address != none and address != [] and address != "" {
        v(5pt)
        text(
          address-size,
          fill: primary-colour,
          weight: "regular",
          top-edge: "baseline",
          bottom-edge: "baseline",
          baseline: 2pt,
        )[#align(address-align, [#address])]
      }
      v(2pt)
      if contacts != none and contacts.len() > 0 {
        align(contact-align)[#contact-display(contacts)]
      }
      line(length: 100%, stroke: line-stroke + primary-colour)
    },
    header-ascent: header-ascent,
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

  set par(justify: true, first-line-indent: first-line-indent, leading: line-spacing, spacing: paragraph-spacing)

  set text(body-size, font: font-type, fill: primary-colour, weight: body-weight)

  // Apply link colour if specified
  if link-colour != none {
    show link: set text(fill: link-colour)
  }

  mainbody

  set text(body-size, font: font-type, fill: primary-colour, weight: body-weight)

  // Signature block with improved layout
  v(closing-spacing)
  
  // Salutation
  if salutation != none {
    set par(first-line-indent: 0em)
    text(body-size, font: font-type, fill: primary-colour, weight: salutation-weight)[#salutation]
    v(signature-spacing) // Space for signature
  }
  
  // Name (signature line)
  if name != none and name != [] and name != "" {
    set par(first-line-indent: 0em)
    text(body-size, font: font-type, fill: primary-colour, weight: signature-weight)[#name]
  }
  
  // Supplements (enclosures, attachments, etc.)
  if supplements != none {
    v(supplement-spacing)
    let additions = if type(supplements) == array {
      supplements
    } else {
      (supplements,)
    }
    set par(first-line-indent: 0em)
    for addition in additions {
      text(supplement-size, font: font-type, fill: headings-colour, weight: "regular")[#addition]
      linebreak()
    }
  }
}



#let statement(
  font-type: none,
  margin: none,
  name: none,
  address: none,
  contacts: (),
  supplement: none,
  // Colour options
  primary-colour: rgb("#000000"),
  headings-colour: rgb("#2b2b2b"),
  subheadings-colour: rgb("#333333"),
  date-colour: rgb("#666666"),
  link-colour: none,  // none = inherit from text colour
  // Font size options
  name-size: 20pt,
  body-size: 11pt,
  address-size: 11pt,
  contact-size: 10pt,
  // Layout options
  line-stroke: 0.2pt,
  header-ascent: 1em,
  first-line-indent: 2em,
  line-spacing: 0.65em,
  paragraph-spacing: 0.8em,
  contact-separator: " | ",
  // Header alignment
  name-align: center,
  address-align: center,
  contact-align: center,
  // Font weight options
  name-weight: "bold",
  body-weight: "regular",
  mainbody,
) = {
  set text(font: font-type, weight: "regular")

  let sectionsep = {
    [#v(5pt)]
  }
  let subsectionsep = {
    [#v(2pt)]
  }

  let resolved-margin = if margin != none {
    margin
  } else {
    (left: 1.25cm, right: 1.25cm, top: 3cm, bottom: 1.5cm)
  }

  // show contact details
  let contact-display(contacts) = {
    v(-5pt)
    set text(contact-size, fill: headings-colour, weight: "regular")
    let resolved-link-colour = if link-colour != none { link-colour } else { headings-colour }
    show link: set text(fill: resolved-link-colour)
    contacts
      .map(contact => {
          if ("link" in contact) {
            link(contact.link)[#{
                contact.text
              }]
          } else [
            #{
              contact.text
            }
          ]
        })
      .join(contact-separator)
  }

  set page(
    margin: resolved-margin,
    header: {
      // Head Name Section
      if name != none and name != [] and name != "" {
        text(
          name-size,
          fill: primary-colour,
          weight: name-weight,
          top-edge: "baseline",
          bottom-edge: "baseline",
          baseline: 12pt,
        )[#align(name-align, [#name])]
      }
      // address
      if address != none and address != [] and address != "" {
        v(5pt)
        text(
          address-size,
          fill: primary-colour,
          weight: "regular",
          top-edge: "baseline",
          bottom-edge: "baseline",
          baseline: 2pt,
        )[#align(address-align, [#address])]
      }
      if contacts != none and contacts.len() > 0 {
        align(contact-align)[#contact-display(contacts)]
      }
      line(length: 100%, stroke: line-stroke + primary-colour)
    },
    header-ascent: header-ascent,
  )

  set par(justify: true, first-line-indent: first-line-indent, leading: line-spacing, spacing: paragraph-spacing)

  set text(body-size, font: font-type, fill: primary-colour, weight: body-weight)

  // Apply link colour if specified
  if link-colour != none {
    show link: set text(fill: link-colour)
  }

  mainbody

  set text(body-size, font: font-type, fill: primary-colour, weight: body-weight)

  if supplement != none {
    v(1pt)
    supplement
  }
}
