/*
Core formatting for the cover letter template document type. Establishes general document-wide formatting, and creates the header for the cover letter.

Inspired by the template from the following guide:
https://career.engin.umich.edu/sample-cover-letter/
*/

#let cover-letter(
  author: "",
  location: "",
  contacts: (),
  date: datetime.today().display(),
  addressee-name: "",
  addressee-institution: "",
  addressee-address: "",
  addressee-city: "",
  addressee-state: "",
  addressee-country: "",
  addressee-zip: "",
  font: "New Computer Modern",
  font-size: 11pt,
  lang: "en",
  margin: (
    top: 1cm,
    bottom: 1cm,
    left: 1cm,
    right: 1cm,
  ),
  body,
) = {

  // Sets document metadata
  set document(author: author, title: author)

  // Document-wide formatting, including font and margins
  set text(
    font: font,
    size: font-size,
    lang: lang,
    ligatures: false,  // Disable ligatures for better compatibility and readability
  )

  set page(
    margin: margin,
  )

  show link: set text(
    fill: rgb("#0645AD")
  )
  
  // Author
  align(center)[
    #block(text(weight: 700, 2.5em, [#smallcaps(author)]))
  ]

  // Contact Information
  align(center)[
    #[#contacts.join("  |  ")]
  ]

  // Location
  if location != "" {
    align(center)[
      #smallcaps[#location]
    ]
  }

  // Date
  pad(
    top: 1em,
    bottom: 0.5em,
    align(left)[
      #strong()[#date]
    ]
  )

  // Addressee Information
  pad(
    bottom: 1em,
    align(left)[
      #strong[#addressee-name] \
      #addressee-institution \
      #addressee-address \
      #{addressee-city + ", " + addressee-state + " " + addressee-zip} \
      #addressee-country
    ]
  )

  // Main body.
  set par(
    justify: true,
  )

  body

  // Signature
  text(
    font: font,
    size: font-size,
    lang: lang,
  )[
    #"" \ \
    #"Sincerely," \
    #strong[#author]
  ]
}
