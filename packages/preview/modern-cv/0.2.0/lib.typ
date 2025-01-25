#import "@preview/fontawesome:0.1.0": *

// const color
#let color-darknight = rgb("#131A28")
#let color-darkgray = rgb("#333333")
#let color-gray = rgb("#5d5d5d")
#let default-accent-color = rgb("#262F99")

// const icons
#let linkedin-icon = box(fa-icon("linkedin", fa-set: "Brands", fill: color-darknight))
#let github-icon = box(fa-icon("github", fa-set: "Brands", fill: color-darknight))
// for some reason this icon doesn't work with fa-icon, so we use the local version
#let phone-icon = box(image("assets/icons/square-phone-solid.svg"))
#let email-icon = box(fa-icon("envelope", fill: color-darknight))

/// Helpers

// layout utility
#let __justify_align(left_body, right_body) = {
  block[
    #left_body
    #box(width: 1fr)[
      #align(right)[
        #right_body
      ]
    ]
  ]
}

#let __justify_align_3(left_body, mid_body, right_body) = {
  block[
    #box(width: 1fr)[
      #align(left)[
        #left_body
      ]
    ]
    #box(width: 1fr)[
      #align(center)[
        #mid_body
      ]
    ]
    #box(width: 1fr)[
      #align(right)[
        #right_body
      ]
    ]
  ]
}

/// Show a link with an icon, specifically for Github projects
/// *Example*
/// #example(`resume.github-link("DeveloperPaul123/awesome-resume")`)
/// - github_path (string): The path to the Github project (e.g. "DeveloperPaul123/awesome-resume")
/// -> none
#let github-link(github_path) = {
  set box(height: 11pt)
  
  align(right + horizon)[
    #fa-icon("github", fa-set: "Brands", fill: color-darkgray) #link("https://github.com/" + github_path, github_path)
  ]
}

/// Right section for the justified headers
/// - body (content): The body of the right header
/// - accent_color (color): The accent color to color the text with. This defaults to the default-accent-color
#let secondary-right-header(body, accent_color: default-accent-color) = {
  set text(size: 11pt, weight: "medium")
  body
}

/// Right section of a tertiaty headers. 
/// - body (content): The body of the right header
#let tertiary-right-header(body) = {
  set text(weight: "light", size: 9pt)
  body
}

/// Justified header that takes a primary section and a secondary section. The primary section is on the left and the secondary section is on the right.
/// - primary (content): The primary section of the header
/// - secondary (content): The secondary section of the header
#let justified-header(primary, secondary) = {
  set block(above: 0.7em, below: 0.7em)
  pad[
    #__justify_align[
      == #primary
    ][
      #secondary-right-header[#secondary]
    ]
  ]
}

/// Justified header that takes a primary section and a secondary section. The primary section is on the left and the secondary section is on the right. This is a smaller header compared to the `justified-header`.
/// - primary (content): The primary section of the header
/// - secondary (content): The secondary section of the header
#let secondary-justified-header(primary, secondary) = {
    __justify_align[
      === #primary
    ][
      #tertiary-right-header[#secondary]
    ]
}
/// --- End of Helpers

/// ---- Resume Template ----

/// Resume template that is inspired by the Awesome CV Latex template by posquit0. This template can loosely be considered a port of the original Latex template.
///
/// The original template: https://github.com/posquit0/Awesome-CV 
///
/// - author (content): Structure that takes in all the author's information
/// - date (string): The date the resume was created
/// - accent_color (color): The accent color of the resume
/// - colored_headers (boolean): Whether the headers should be colored or not
/// - body (content): The body of the resume
/// -> none
#let resume(
  author: (:), 
  date: datetime.today().display("[month repr:long] [day], [year]"), 
  accent_color: default-accent-color, 
  colored_headers : true,
  body) = {
  set document(
    author: author.firstname + " " + author.lastname, 
    title: "resume",
  )
  
  set text(
    font: ("Source Sans Pro"),
    lang: "en",
    size: 11pt,
    fill: color-darkgray,
    fallback: true
  )

  set page(
    paper: "a4",
    margin: (left: 15mm, right: 15mm, top: 10mm, bottom: 10mm),
    footer: [
      #set text(fill: gray, size: 8pt)
      #__justify_align_3[
        #smallcaps[#date]
      ][
        #smallcaps[
          #author.firstname
          #author.lastname
          #sym.dot.c
          #"Résumé"
        ]
      ][
        #counter(page).display()
      ]
    ],
    footer-descent: 0pt,
  )
  
  // set paragraph spacing
  show par: set block(above: 0.75em, below: 0.75em)
  set par(justify: true)

  set heading(
    numbering: none,
    outlined: false,
  )
  
  show heading.where(level:1): it => [
    #set block(above: 1em, below: 1em)
    #set text(
      size: 16pt,
      weight: "regular"
    )
    
    #align(left)[
      #let color = if colored_headers { accent_color } else { color-darkgray }
      #text[#strong[#text(color)[#it.body.text]]]
      #box(width: 1fr, line(length: 100%))
    ]
  ]

  show heading.where(level: 2): it => {
    set text(color-darkgray, size: 12pt, style: "normal", weight: "bold")
    it.body
  }

  show heading.where(level: 3): it => {
    set text(size: 10pt, weight: "regular")
    smallcaps[#it.body]
  }
  
  let name = {
    align(center)[
      #pad(bottom: 5pt)[
        #block[
          #set text(size: 32pt, style: "normal", font: ("Roboto"))
          #text(accent_color, weight: "thin")[#author.firstname]
          #text(weight: "bold")[#author.lastname]
        ]
      ]
    ]
  }

  let positions = {
    set text(
      accent_color,
      size: 9pt,
      weight: "regular"
    )
    align(center)[
      #smallcaps[
        #author.positions.join(
          text[#"  "#sym.dot.c#"  "]
        )
      ]
    ]
  }

  let address = {
    set text(
      size: 9pt,
      weight: "bold"
    )
    align(center)[
      #author.address
    ]
  }

  let contacts = {
    set box(height: 9pt)
    
    let separator = box(width: 5pt)

    align(center)[
      #set text(size: 9pt, weight: "regular", style: "normal")
      #block[
        #align(horizon)[
          #phone-icon
          #box[#text(author.phone)]
          #separator
          #email-icon
          #box[#link("mailto:" + author.email)[#author.email]]
          #separator
          #github-icon
          #box[#link("https://github.com/" + author.github)[#author.github]]
          #separator
          #linkedin-icon
          #box[
            #link("https://www.linkedin.com/in/" + author.linkedin)[#author.firstname #author.lastname]
          ]
        ]
      ]
    ] 
  }

  name
  positions
  address
  contacts
  body
}

/// The base item for resume entries. 
/// This formats the item for the resume entries. Typically your body would be a bullet list of items. Could be your responsibilities at a company or your academic achievements in an educational background section.
/// - body (content): The body of the resume entry
#let resume-item(body) = {
  set text(size: 10pt, style: "normal", weight: "light", fill: color-darknight)
  set par(leading: 0.65em)
  body
}

/// The base item for resume entries. This formats the item for the resume entries. Typically your body would be a bullet list of items. Could be your responsibilities at a company or your academic achievements in an educational background section.
/// - title (string): The title of the resume entry
/// - location (string): The location of the resume entry
/// - date (string): The date of the resume entry, this can be a range (e.g. "Jan 2020 - Dec 2020")
/// - description (content): The body of the resume entry
#let resume-entry(
  title: none, 
  location: "", 
  date: "",
  description: ""
) = {
  pad[
    #justified-header(title, location)
    #secondary-justified-header(description, date)
  ]
}

/// Show cumulative GPA.
/// *Example:*
/// #example(`resume.resume-gpa("3.5", "4.0")`)
#let resume-gpa(numerator, denominator) = {
  set text(size: 12pt, style: "italic", weight: "light")
  text[Cumulative GPA: #box[#strong[#numerator] / #denominator]]
}

/// Show a certification in the resume.
/// *Example:*
/// #example(`resume.resume-certification("AWS Certified Solutions Architect - Associate", "Jan 2020")`)
/// - certification (content): The certification
/// - date (content): The date the certification was achieved
#let resume-certification(certification, date) = {
  justified-header(certification, date)
}

/// Show a list of skills in the resume under a given category.
/// - category (string): The category of the skills
/// - items (list): The list of skills. This can be a list of strings but you can also emphasize certain skills by using the `strong` function.
#let resume-skill-item(category, items) = {
  set block(below: 0.65em)
  set pad(top: 2pt)
  
  pad[
    #grid(
      columns: (20fr, 80fr),
      gutter: 10pt,
      align(right)[
        #set text(hyphenate: false)
        == #category
      ],
      align(left)[
        #set text(size: 11pt, style: "normal", weight: "light")
        #items.join(", ")
      ],
    )
  ]
}

/// ---- End of Resume Template ----

/// ---- Coverletter ----

/// Cover letter template that is inspired by the Awesome CV Latex template by posquit0. This template can loosely be considered a port of the original Latex template. 
/// This coverletter template is designed to be used with the resume template.
/// - author (content): Structure that takes in all the author's information
/// - profile_picture (image): The profile picture of the author. This will be cropped to a circle and should be square in nature.
/// - date (date): The date the cover letter was created
/// - accent_color (color): The accent color of the cover letter
/// - body (content): The body of the cover letter
#let coverletter(
  author: (:), 
  profile_picture: image,
  date: datetime.today().display("[month repr:long] [day], [year]"),
  accent_color: default-accent-color,
  body
) = {
  set document(
    author: author.firstname + " " + author.lastname, 
    title: "resume",
  )
  
  set text(
    font: ("Source Sans Pro"),
    lang: "en",
    size: 11pt,
    fill: color-darkgray,
    fallback: true
  )

  set page(
    paper: "a4",
    margin: (left: 15mm, right: 15mm, top: 10mm, bottom: 10mm),
    footer: [
      #set text(fill: gray, size: 8pt)
      #__justify_align_3[
        #smallcaps[#date]
      ][
        #smallcaps[
          #author.firstname
          #author.lastname
          #sym.dot.c
          #"Cover Letter"
        ]
      ][
        #counter(page).display()
      ]
    ],
    footer-descent: 0pt,
  )
  
  // set paragraph spacing
  show par: set block(above: 0.75em, below: 0.75em)
  set par(justify: true)

  set heading(
    numbering: none,
    outlined: false,
  )
  
  show heading: it => [
    #set block(above: 1em, below: 1em)
    #set text(
      size: 16pt,
      weight: "regular"
    )
    
    #align(left)[   
      #text[#strong[#text(accent_color)[#it.body.text]]]
      #box(width: 1fr, line(length: 100%))
    ]
  ]
  
  let name = {
    align(right)[
      #pad(bottom: 5pt)[
        #block[
          #set text(size: 32pt, style: "normal", font: ("Roboto"))
          #text(accent_color, weight: "thin")[#author.firstname]
          #text(weight: "bold")[#author.lastname]
        ]
      ]
    ]
  }

  let positions = {
    set text(
      accent_color,
      size: 9pt,
      weight: "regular"
    )
    align(right)[
      #smallcaps[
        #author.positions.join(
          text[#"  "#sym.dot.c#"  "]
        )
      ]
    ]
  }

  let address = {
    set text(
      size: 9pt,
      weight: "bold",
      fill: color-gray
    )
    align(right)[
      #author.address
    ]
  }

  let contacts = {
    set box(height: 9pt)
    
    let separator = [#box(sym.bar.v)]
    
    align(right)[
      #set text(size: 8pt, weight: "light", style: "normal")
      #block[
        #align(horizon)[
          #stack(dir: ltr, spacing: 0.5em,
              phone-icon,
              box[#text(author.phone)],
              separator,
              email-icon,
              box[#link("mailto:" + author.email)[#author.email]],
              separator,
              github-icon,
              box[#link("https://github.com/" + author.github)[#author.github]],
              separator,
              linkedin-icon,
              box[
                #link("https://www.linkedin.com/in/" + author.linkedin)[#author.firstname #author.lastname]
              ]
          )
        ]
      ]
    ] 
  }

  let letter-heading = {
    grid(columns: (1fr, 2fr), 
      rows: (100pt),
      align(left+horizon)[
        #block(clip: true, stroke: 0pt, radius: 2cm, 
        width: 4cm, height: 4cm, profile_picture)
      ],
      [
        #name
        #positions
        #address
        #contacts
      ]
    )
  }

  let letter_conclusion = {
    align(bottom)[
      #pad(bottom: 2em)[
        #text(weight: "light")[Sincerely,] \
        #text(weight: "bold")[#author.firstname #author.lastname] \ \
        #text(weight: "light", style: "italic")[Attached: Curriculum Vitae]
      ]
    ]
  }

  // actual content
  letter-heading
  body
  linebreak()
  letter_conclusion
}

/// Cover letter heading that takes in the information for the hiring company and formats it properly.
/// - entity_info (content): The information of the hiring entity including the company name, the target (who's attention to), street address, and city
/// - date (date): The date the letter was written (defaults to the current date)
#let hiring-entity-info(entity_info: (:), date: datetime.today().display("[month repr:long] [day], [year]")) = {
  set par(leading: 1em)
  pad(top: 1.5em, bottom: 1.5em)[
    #__justify_align[
      #text(weight: "bold", size: 12pt)[#entity_info.target]
    ][
      #text(weight: "light", style: "italic", size: 9pt)[#date]
    ]

    #pad(top: 0.65em, bottom: 0.65em)[
      #text(weight: "regular", fill: color-gray, size: 9pt)[
        #smallcaps[#entity_info.name] \
        #entity_info.street_address \
        #entity_info.city \
      ]
    ]
  ]
}

/// Letter heading for a given job position and addressee.
/// - job_position (string): The job position you are applying for
/// - addressee (string): The person you are addressing the letter to
#let letter-heading(job_position: "", addressee: "") = {
  // TODO: Make this adaptable to content
  underline(evade: false, stroke: 0.5pt, offset: 0.3em)[
    #text(weight: "bold", size: 12pt)[Job Application for #job_position]
  ]
  pad(top: 1em, bottom: 1em)[
    #text(weight: "light", fill: color-gray)[
      Dear #addressee,
    ]
  ]
}

/// Cover letter content paragraph. This is the main content of the cover letter.
/// - content (content): The content of the cover letter
#let coverletter-content(content) = {
  pad(top: 1em, bottom: 1em)[
    #set par(first-line-indent: 3em)
    #set text(weight: "light")
    #content
  ]
}

/// ---- End of Coverletter ----
