// Local, dependency-free refinement of @preview/basic-resume:0.2.9.
// It preserves the original component API while using a warm paper palette.
#let paper-color = rgb("f4f3ee")
#let ink = rgb("2f2f2d")
#let accent = rgb("de5d3e")
#let rule = rgb("deddda")

#let resume(
  author: "",
  author-position: left,
  personal-info-position: left,
  pronouns: "",
  location: "",
  email: "",
  github: "",
  linkedin: "",
  phone: "",
  personal-site: "",
  orcid: "",
  contact-lines: (),
  accent-color: accent,
  font: "New Computer Modern",
  paper: "a4",
  author-font-size: 20pt,
  font-size: 10pt,
  lang: "en",
  body,
) = {
  set document(author: author, title: author)
  set text(font: font, size: font-size, fill: ink, lang: lang, ligatures: false)
  set page(margin: 0.5in, paper: paper, fill: paper-color)
  set par(justify: true)
  set list(indent: 1.2em, body-indent: 0.35em)

  show link: underline
  show link: set text(fill: accent-color)
  show heading: set text(fill: accent-color)
  show heading.where(level: 2): it => [
    #pad(top: 0pt, bottom: -10pt)[#smallcaps(it.body)]
    #line(length: 100%, stroke: 0.75pt + rule)
  ]
  show heading.where(level: 1): it => [
    #set align(author-position)
    #set text(weight: "bold", size: author-font-size)
    #pad(it.body)
  ]

  [= #author]
  pad(top: 0.25em)[
    #align(personal-info-position)[
      #if contact-lines.len() > 0 {
        contact-lines.join(linebreak())
      } else {
        let contact-item(value, prefix: "", link-type: "") = {
          if value == "" { none
          } else if link-type == "" { prefix + value
          } else { link(link-type + value)[#(prefix + value)] }
        }
        let items = (
          contact-item(pronouns), contact-item(phone), contact-item(location),
          contact-item(email, link-type: "mailto:"),
          contact-item(github, link-type: "https://"),
          contact-item(linkedin, link-type: "https://"),
          contact-item(personal-site, link-type: "https://"),
          contact-item(orcid, prefix: "orcid.org/", link-type: "https://orcid.org/"),
        )
        items.filter(item => item != none).join("  |  ")
      }
    ]
  ]
  body
}

#let generic-two-by-two(top-left: "", top-right: "", bottom-left: "", bottom-right: "") = [
  #top-left #h(1fr) #top-right \
  #bottom-left #h(1fr) #bottom-right
]

#let generic-one-by-two(left: "", right: "") = [#left #h(1fr) #right]

#let dates-helper(start-date: "", end-date: "") = start-date + " " + $dash.em$ + " " + end-date
#let date-range(start: "", end: "") = dates-helper(start-date: start, end-date: end)

// The education row intentionally uses New Computer Modern Italic for the
// qualification and place, giving academic credentials a traditional tone.
#let edu(institution: "", dates: "", degree: "", gpa: "", location: "", consistent: false) = {
  if consistent {
    generic-two-by-two(
      top-left: strong(institution), top-right: dates,
      bottom-left: emph(degree), bottom-right: emph(location),
    )
  } else {
    generic-two-by-two(
      top-left: strong(institution), top-right: emph(location),
      bottom-left: emph(degree), bottom-right: emph(dates),
    )
  }
}

#let work(title: "", dates: "", company: "", location: "") = generic-two-by-two(
  top-left: strong(title), top-right: dates,
  bottom-left: company, bottom-right: emph(location),
)

#let project(role: "", name: "", url: "", dates: "") = generic-one-by-two(
  left: {
    if role == "" { [*#name* #if url != "" [ (#link("https://" + url)[#url])]]
    } else { [*#role*, #name #if url != "" [ (#link("https://" + url)[#url])]] }
  },
  right: if dates == "" and url != "" { link("https://" + url)[#url] } else { dates },
)

#let certificates(name: "", issuer: "", url: "", date: "") = [
  *#name*, #issuer#if url != "" [ (#link("https://" + url)[#url])]#h(1fr)#date
]
#let extracurriculars(activity: "", dates: "") = generic-one-by-two(left: strong(activity), right: dates)

// A Fireside-inspired cover letter with the same palette and typography.
#let _cover-title-size = 44pt

#let cover-letter(
  author: "",
  title: none,
  location: "",
  email: "",
  phone: "",
  website: "",
  date: "",
  recipient: none,
  subject: "",
  greeting: "Dear Hiring Manager,",
  closing: "Sincerely,",
  font: "Libertinus Serif",
  paper: "a4",
  font-size: 11pt,
  lang: "en",
  vertical-center-level: 2,
  body,
) = {
  set document(author: author, title: "Cover letter — " + author)
  set page(paper: paper, margin: 2.1cm, fill: paper-color)
  set text(font: font, size: font-size, fill: ink, lang: lang)
  set par(justify: true, leading: 0.65em, spacing: 0.85em)
  show link: underline
  show link: set text(fill: accent)

  let contact-item(value, link-type: "") = {
    if value == "" { none
    } else if link-type == "" { value
    } else { link(link-type + value)[#value] }
  }
  let contacts = (
    contact-item(phone),
    contact-item(location),
    contact-item(email, link-type: "mailto:"),
    contact-item(website, link-type: "https://"),
  ).filter(item => item != none)

  let display-title = if title == none { author } else { title }
  let header = [
    #grid(
      columns: (1fr, auto),
      column-gutter: 2em,
      [
        #set text(size: _cover-title-size, weight: "bold", fill: accent)
        #set par(leading: 0.42em)
        #display-title
      ],
      align(end, box(
        inset: (top: 0.6em),
        text(size: 10.2pt)[#contacts.join(linebreak())],
      )),
    )
    #v(_cover-title-size)
    #grid(
      columns: (1fr, auto),
      column-gutter: 1em,
      [#text(size: 9.2pt)[#if recipient != none { recipient }]],
      [#text(size: 9.2pt)[#if date != "" { emph(date) }]],
    )
    #v(_cover-title-size)
  ]

  let letter-body = [
    #set text(size: 11pt, weight: "medium")
    #set par(spacing: 2em)
    #if subject != "" [*Re: #subject* #v(1.1em)]
    #greeting
    #v(0.8em)
    #body
    #v(1.3em)
    #closing
    #linebreak()
    #v(1.1em)
    #strong(author)
  ]

  layout(size => context [
    #let header-size = measure(block(width: size.width, header))
    #let body-size = measure(block(width: size.width, letter-body))
    #let ratio = (header-size.height + body-size.height) / size.height
    #let overflowing = ratio > 1

    #if overflowing or vertical-center-level == none {
      header
      letter-body
    } else {
      grid(
        rows: (auto, 1fr),
        header,
        box([
          #v(1fr * ratio)
          #letter-body
          #v(vertical-center-level * 1fr)
        ]),
      )
    }
  ])
}
