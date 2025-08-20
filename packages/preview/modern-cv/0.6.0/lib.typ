#import "@preview/fontawesome:0.2.1": *
#import "@preview/linguify:0.4.0": *

// const color
#let color-darknight = rgb("#131A28")
#let color-darkgray = rgb("#333333")
#let color-gray = rgb("#5d5d5d")
#let default-accent-color = rgb("#262F99")
#let default-location-color = rgb("#333333")

// const icons
#let linkedin-icon = box(
  fa-icon("linkedin", fill: color-darknight),
)
#let github-icon = box(
  fa-icon("github", fill: color-darknight),
)
#let twitter-icon = box(
  fa-icon("twitter", fill: color-darknight),
)
#let google-scholar-icon = box(
  fa-icon("google-scholar", fill: color-darknight),
)
#let orcid-icon = box(
  fa-icon("orcid", fill: color-darknight),
)
#let phone-icon = box(fa-icon("square-phone", fill: color-darknight))
#let email-icon = box(fa-icon("envelope", fill: color-darknight))
#let birth-icon = box(fa-icon("cake", fill: color-darknight))
#let homepage-icon = box(fa-icon("home", fill: color-darknight))

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

#let __coverletter_footer(author, language, date, lang_data) = {
  set text(
    fill: gray,
    size: 8pt,
  )
  __justify_align_3[
    #smallcaps[#date]
  ][
    #smallcaps[
      #if language == "zh" or language == "ja" [
        #author.firstname#author.lastname
      ] else [
        #author.firstname#sym.space#author.lastname
      ]
      #sym.dot.c
      #linguify("cover-letter", from: lang_data)
    ]
  ][
    #counter(page).display()
  ]
}

#let __resume_footer(author, language, lang_data, date) = {
  set text(
    fill: gray,
    size: 8pt,
  )
  __justify_align_3[
    #smallcaps[#date]
  ][
    #smallcaps[
      #if language == "zh" or language == "ja" [
        #author.firstname#author.lastname
      ] else [
        #author.firstname#sym.space#author.lastname
      ]
      #sym.dot.c
      #linguify("resume", from: lang_data)
    ]
  ][
    #counter(page).display()
  ]
}

/// Show a link with an icon, specifically for Github projects
/// *Example*
/// #example(`resume.github-link("DeveloperPaul123/awesome-resume")`)
/// - github-path (string): The path to the Github project (e.g. "DeveloperPaul123/awesome-resume")
/// -> none
#let github-link(github-path) = {
  set box(height: 11pt)
  
  align(right + horizon)[
    #fa-icon("github", fill: color-darkgray) #link(
      "https://github.com/" + github-path,
      github-path,
    )
  ]
}

/// Right section for the justified headers
/// - body (content): The body of the right header
#let secondary-right-header(body) = {
  set text(
    size: 11pt,
    weight: "medium",
  )
  body
}

/// Right section of a tertiaty headers. 
/// - body (content): The body of the right header
#let tertiary-right-header(body) = {
  set text(
    weight: "light",
    size: 9pt,
  )
  body
}

/// Justified header that takes a primary section and a secondary section. The primary section is on the left and the secondary section is on the right.
/// - primary (content): The primary section of the header
/// - secondary (content): The secondary section of the header
#let justified-header(primary, secondary) = {
  set block(
    above: 0.7em,
    below: 0.7em,
  )
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
/// - accent-color (color): The accent color of the resume
/// - colored-headers (boolean): Whether the headers should be colored or not
/// - language (string): The language of the resume, defaults to "en". See lang.toml for available languages
/// - body (content): The body of the resume
/// -> none
#let resume(
  author: (:),
  date: datetime.today().display("[month repr:long] [day], [year]"),
  accent-color: default-accent-color,
  colored-headers: true,
  show-footer: true,
  language: "en",
  font: ("Source Sans Pro", "Source Sans 3"),
  body,
) = {
  if type(accent-color) == "string" {
    accent-color = rgb(accent-color)
  }
  
  let lang_data = toml("lang.toml")
  
  set document(
    author: author.firstname + " " + author.lastname,
    title: "resume",
  )
  
  set text(
    font: font,
    lang: language,
    size: 11pt,
    fill: color-darkgray,
    fallback: true,
  )
  
  set page(
    paper: "a4",
    margin: (left: 15mm, right: 15mm, top: 10mm, bottom: 10mm),
    footer: if show-footer [#__resume_footer(author, language, lang_data, date)] else [],
    footer-descent: 0pt,
  )
  
  // set paragraph spacing
  show par: set block(
    above: 0.75em,
    below: 0.75em,
  )
  set par(justify: true)
  
  set heading(
    numbering: none,
    outlined: false,
  )
  
  show heading.where(level: 1): it => [
    
    #set block(
      above: 1em,
      below: 1em,
    )
    #set text(
      size: 16pt,
      weight: "regular",
    )
    
    #align(left)[
      #let color = if colored-headers {
        accent-color
      } else {
        color-darkgray
      }
      #text[#strong[#text(color)[#it.body.text]]]
      #box(width: 1fr, line(length: 100%))
    ]
    
  ]
  
  show heading.where(level: 2): it => {
    set text(
      color-darkgray,
      size: 12pt,
      style: "normal",
      weight: "bold",
    )
    it.body
  }
  
  show heading.where(level: 3): it => {
    set text(
      size: 10pt,
      weight: "regular",
    )
    smallcaps[#it.body]
  }
  
  let name = {
    align(center)[
      #pad(bottom: 5pt)[
        #block[
          #set text(
            size: 32pt,
            style: "normal",
            font: ("Roboto"),
          )
          #if language == "zh" or language == "ja" [
            #text(
              accent-color,
              weight: "thin",
            )[#author.firstname]#text(weight: "bold")[#author.lastname]
          ] else [
            #text(accent-color, weight: "thin")[#author.firstname]
            #text(weight: "bold")[#author.lastname]
          ]
        ]
      ]
    ]
  }
  
  let positions = {
    set text(
      accent-color,
      size: 9pt,
      weight: "regular",
    )
    align(center)[
      #smallcaps[
        #author.positions.join(
          text[#"  "#sym.dot.c#"  "],
        )
      ]
    ]
  }
  
  let address = {
    set text(
      size: 9pt,
      weight: "regular",
    )
    align(center)[
      #if ("address" in author) [
        #author.address
      ]
    ]
  }
  
  let contacts = {
    set box(height: 9pt)
    
    let separator = box(width: 5pt)
    
    align(center)[
      #set text(
        size: 9pt,
        weight: "regular",
        style: "normal",
      )
      #block[
        #align(horizon)[
          #if ("birth" in author) [
            #birth-icon
            #box[#text(author.birth)]
            #separator
          ]
          #if ("phone" in author) [
            #phone-icon
            #box[#text(author.phone)]
            #separator
          ]
          #if ("email" in author) [
            #email-icon
            #box[#link("mailto:" + author.email)[#author.email]]
          ]
          #if ("homepage" in author) [
            #separator
            #homepage-icon
            #box[#link(author.homepage)[#author.homepage]]
          ]
          #if ("github" in author) [
            #separator
            #github-icon
            #box[#link("https://github.com/" + author.github)[#author.github]]
          ]
          #if ("linkedin" in author) [
            #separator
            #linkedin-icon
            #box[
              #link("https://www.linkedin.com/in/" + author.linkedin)[#author.linkedin]
            ]
          ]
          #if ("twitter" in author) [
            #separator
            #twitter-icon
            #box[#link("https://twitter.com/" + author.twitter)[\@#author.twitter]]
          ]
          #if ("scholar" in author) [
            #let fullname = str(author.firstname + " " + author.lastname)
            #separator
            #google-scholar-icon
            #box[#link("https://scholar.google.com/citations?user=" + author.scholar)[#fullname]]
          ]
          #if ("orcid" in author) [
            #separator
            #orcid-icon
            #box[#link("https://orcid.org/" + author.orcid)[#author.orcid]]
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
  set text(
    size: 10pt,
    style: "normal",
    weight: "light",
    fill: color-darknight,
  )
  set par(leading: 0.65em)
  body
}

/// The base item for resume entries. This formats the item for the resume entries. Typically your body would be a bullet list of items. Could be your responsibilities at a company or your academic achievements in an educational background section.
/// - title (string): The title of the resume entry
/// - location (string): The location of the resume entry
/// - date (string): The date of the resume entry, this can be a range (e.g. "Jan 2020 - Dec 2020")
/// - description (content): The body of the resume entry
/// - title-link (string): The link to use for the title (can be none)
/// - accent-color (color): Override the accent color of the resume-entry
/// - location-color (color): Override the default color of the "location" for a resume entry.
#let resume-entry(
  title: none,
  location: "",
  date: "",
  description: "",
  title-link: none,
  accent-color: default-accent-color,
  location-color: default-location-color,
) = {
  let title-content
  if type(title-link) == "string" {
    title-content = link(title-link)[#title]
  } else {
    title-content = title
  }
  
  pad[
    #justified-header(title-content, location)
    #if description != "" or date != "" [
      #secondary-justified-header(description, date)
    ]
  ]
}

/// Show cumulative GPA.
/// *Example:*
/// #example(`resume.resume-gpa("3.5", "4.0")`)
#let resume-gpa(numerator, denominator) = {
  set text(
    size: 12pt,
    style: "italic",
    weight: "light",
  )
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
        #set text(
          size: 11pt,
          style: "normal",
          weight: "light",
        )
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
/// - profile-picture (image): The profile picture of the author. This will be cropped to a circle and should be square in nature.
/// - date (date): The date the cover letter was created
/// - accent-color (color): The accent color of the cover letter
/// - body (content): The body of the cover letter
#let coverletter(
  author: (:),
  profile-picture: image,
  date: datetime.today().display("[month repr:long] [day], [year]"),
  accent-color: default-accent-color,
  language: "en",
  font: ("Source Sans Pro", "Source Sans 3"),
  show-footer: true,
  body,
) = {
  if type(accent-color) == "string" {
    accent-color = rgb(accent-color)
  }
  
  // language data
  let lang_data = toml("lang.toml")
  
  set document(
    author: author.firstname + " " + author.lastname,
    title: "cover-letter",
  )
  
  set text(
    font: font,
    lang: language,
    size: 11pt,
    fill: color-darkgray,
    fallback: true,
  )
  
  set page(
    paper: "a4",
    margin: (left: 15mm, right: 15mm, top: 10mm, bottom: 10mm),
    footer: if show-footer [#__coverletter_footer(author, language, date, lang_data)] else [],
    footer-descent: 0pt,
  )
  
  // set paragraph spacing
  show par: set block(
    above: 0.75em,
    below: 0.75em,
  )
  set par(justify: true)
  
  set heading(
    numbering: none,
    outlined: false,
  )
  
  show heading: it => [
    #set block(
      above: 1em,
      below: 1em,
    )
    #set text(
      size: 16pt,
      weight: "regular",
    )
    
    #align(left)[
      #text[#strong[#text(accent-color)[#it.body.text]]]
      #box(width: 1fr, line(length: 100%))
    ]
  ]
  
  let name = {
    align(right)[
      #pad(bottom: 5pt)[
        #block[
          #set text(
            size: 32pt,
            style: "normal",
            font: ("Roboto"),
          )
          #if language == "zh" or language == "ja" [
            #text(
              accent-color,
              weight: "thin",
            )[#author.firstname]#text(weight: "bold")[#author.lastname]
          ] else [
            #text(accent-color, weight: "thin")[#author.firstname]
            #text(weight: "bold")[#author.lastname]
          ]
          
        ]
      ]
    ]
  }
  
  let positions = {
    set text(
      accent-color,
      size: 9pt,
      weight: "regular",
    )
    align(right)[
      #smallcaps[
        #author.positions.join(
          text[#"  "#sym.dot.c#"  "],
        )
      ]
    ]
  }
  
  let address = {
    set text(
      size: 9pt,
      weight: "bold",
      fill: color-gray,
    )
    align(right)[
      #if ("address" in author) [
        #author.address
      ]
    ]
  }
  
  let contacts = {
    set box(height: 9pt)
    
    let separator = [#box(sym.bar.v)]
    
    align(right)[
      #set text(
        size: 8pt,
        weight: "light",
        style: "normal",
      )
      #block[
        #align(horizon)[
          #stack(
            dir: ltr,
            spacing: 0.5em,
            if ("phone" in author) [
              #phone-icon
              #box[#text(author.phone)]
              #separator
            ],
            if ("email" in author) [
              #email-icon
              #box[#link("mailto:" + author.email)[#author.email]]
            ],
            if ("github" in author) [
              #separator
              #github-icon
              #box[#link("https://github.com/" + author.github)[#author.github]]
            ],
            if ("linkedin" in author) [
              #separator
              #linkedin-icon
              #box[
                #link("https://www.linkedin.com/in/" + author.linkedin)[#author.firstname #author.lastname]
              ]
            ],
          )
        ]
      ]
    ]
  }
  
  let letter-heading = {
    grid(
      columns: (1fr, 2fr),
      rows: (100pt),
      align(left + horizon)[
        #block(
          clip: true,
          stroke: 0pt,
          radius: 2cm,
          width: 4cm,
          height: 4cm,
          profile-picture,
        )
      ],
      [
        #name
        #positions
        #address
        #contacts
      ],
    )
  }
  
  let letter-conclusion = {
    align(bottom)[
      #pad(bottom: 2em)[
        #text(weight: "light")[#linguify(
            "sincerely",
            from: lang_data,
          )#sym.comma] \
        #text(weight: "bold")[#author.firstname #author.lastname] \ \
        #text(weight: "light", style: "italic")[ #linguify(
            "attached",
            from: lang_data,
          )#sym.colon #linguify("curriculum-vitae", from: lang_data)]
      ]
    ]
  }
  
  // actual content
  letter-heading
  body
  linebreak()
  letter-conclusion
}

/// Cover letter heading that takes in the information for the hiring company and formats it properly.
/// - entity-info (content): The information of the hiring entity including the company name, the target (who's attention to), street address, and city
/// - date (date): The date the letter was written (defaults to the current date)
#let hiring-entity-info(
  entity-info: (:),
  date: datetime.today().display("[month repr:long] [day], [year]"),
) = {
  set par(leading: 1em)
  pad(top: 1.5em, bottom: 1.5em)[
    #__justify_align[
      #text(weight: "bold", size: 12pt)[#entity-info.target]
    ][
      #text(weight: "light", style: "italic", size: 9pt)[#date]
    ]
    
    #pad(top: 0.65em, bottom: 0.65em)[
      #text(weight: "regular", fill: color-gray, size: 9pt)[
        #smallcaps[#entity-info.name] \
        #entity-info.street-address \
        #entity-info.city \
      ]
    ]
  ]
}

/// Letter heading for a given job position and addressee.
/// - job-position (string): The job position you are applying for
/// - addressee (string): The person you are addressing the letter to
/// - dear (string): optional field for redefining the "dear" variable
#let letter-heading(job-position: "", addressee: "", dear: "") = {
  let lang_data = toml("lang.toml")
  
  // TODO: Make this adaptable to content
  underline(evade: false, stroke: 0.5pt, offset: 0.3em)[
    #text(weight: "bold", size: 12pt)[Job Application for #job-position]
  ]
  pad(top: 1em, bottom: 1em)[
    #text(weight: "light", fill: color-gray)[
      #if dear == "" [
        #linguify("dear", from: lang_data)
      ] else [
        #dear
      ]
      #addressee,
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
