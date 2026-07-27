
#let is-blank(v) = v == none or v == "" or v == []

#let format-dates(start-date, end-date) = {
  (start-date, end-date).filter(d => d != "").join(" – ")
}

#let entry-heading(
  main: "",
  dates: "",
  description: "",
  bottom-right: "",
  accent-color: "#26428b",
) = {
  let heading-blank = is-blank(main) and is-blank(dates)
  let detail-blank = is-blank(description) and is-blank(bottom-right)

  if not heading-blank {
    grid(
      columns: (1fr, auto),
      column-gutter: 8pt,
      align: (left, right),
      [=== #underline[#main]],
      [#text(fill: rgb(accent-color))[#dates]],
    )
  }

  if not detail-blank {
    if not heading-blank { v(-0.5em) }
    grid(
      columns: (1fr, auto),
      column-gutter: 8pt,
      align: (left, right),
      [#description],
      [#bottom-right],
    )
  }
}

#let cv-section(title, accent-color: "#26428b") = {
  [== #smallcaps(title)]
  v(-0.5em)
  line(length: 100%, stroke: stroke(thickness: 0.4pt))
  v(-0.5em)
}

#let cv-publication(
  title: "",
  authors: "",
  url: "",
  url_name: "",
  date: "",
  accent-color: "#26428b",
) = {
  grid(
    columns: (1fr, auto),
    column-gutter: 8pt,
    align: (left, right),
    [
      #text(weight: "bold")[#title]       #if authors != "" {
        v(-0.3em)
        authors
        linebreak()
      }
      #if url != "" or url_name != "" {
        v(-0.3em)
        let link-text = if url_name != "" { url_name } else { url }
        let link-dest = if url != "" { "https://" + url } else { "" }
        if link-dest != "" {
          link(link-dest)[#link-text]
        } else {
          link-text
        }
      }
    ],
    [#text(fill: rgb(accent-color))[#date]],
  )
}

#let cv-certification(
  title: "",
  organization: "",
  url: "",
  date: "",
  description: "",
  accent-color: "#26428b",
) = {
  grid(
    columns: (1fr, auto),
    column-gutter: 8pt,
    align: (left, right),
    [
      #text(weight: "bold")[#title]
      #if organization != "" or url != "" {
        [ ]
        if organization != "" {
          text(weight: "medium", smallcaps(organization))
        }
        if url != "" {
          let link-display = url.replace("https://", "").replace("http://", "")
          [ (]
          link(url)[#text(size: 9pt, link-display)]
          [)]
        }
      }
      #if not is-blank(description) {
        linebreak()
        v(-0.3em)
        description
      }
    ],
    [#text(fill: rgb(accent-color))[#date]],
  )
}

#let cv-award(
  title: "",
  organization: "",
  url: "",
  date: "",
  description: "",
  accent-color: "#26428b",
) = {
  grid(
    columns: (1fr, auto),
    column-gutter: 8pt,
    align: (left, right),
    [
      #text(weight: "bold")[#title]
      #if organization != "" or url != "" {
        [ ]
        if organization != "" {
          text(weight: "medium", smallcaps(organization))
        }
        if url != "" {
          let link-display = url.replace("https://", "").replace("http://", "")
          [ (]
          link(url)[#text(size: 9pt, link-display)]
          [)]
        }
      }
      #if not is-blank(description) {
        linebreak()
        v(-0.3em)
        description
      }
    ],
    [#text(fill: rgb(accent-color))[#date]],
  )
}

#let fantastic-cv(
  author: "",
  location: "",
  phone: "",
  email: "",
  social-links: (), // Array of (url, display-text) tuples
  accent-color: "#26428b",
  font: "New Computer Modern",
  font-fallback: (), // Script fallback families (e.g. CJK) appended after the Latin stack
  font-size: 10pt,
  paper: "a4",
  margin: 0.5in,
  leading: 0.65em,
  justify: true,
  lang: "en",
  body,
) = {
  let font-size-title = font-size * 1.5
  let font-size-section = font-size * 1.3
  let font-size-entry = font-size * 1.1

  // Handle both string and content for author (content is used for diff preview)
  let author-str = if type(author) == str { author } else { "CV" }
  set document(
    author: author-str,
    title: author-str + " - CV",
  )

  set text(
    font: (font, "Source Sans 3", "Roboto", "HK Grotesk", ..font-fallback),
    size: font-size,
    lang: lang,
    ligatures: false,
    hyphenate: true,
  )

  set page(
    margin: margin,
    paper: paper,
  )

  set par(justify: justify, leading: leading)

  show link: underline
  show heading: set text(fill: rgb(accent-color))
  show link: set text(fill: rgb(accent-color))

  show heading.where(level: 1): it => [#text(font-size-title, weight: "extrabold")[#it]]
  show heading.where(level: 2): it => [#text(font-size-section, weight: "bold")[#it]]
  show heading.where(level: 3): it => [#text(size: font-size-entry, weight: "semibold")[#it]]

  align(
    left,
    [= #author #h(1fr) #location],
  )

  // Build contact items: phone, email first, then social links in order
  let contact-items = ()
  if phone != "" and phone != none { contact-items.push(phone) }
  // A diffed field arrives as content, which link() rejects as a destination.
  // Show the highlighted text unlinked for as long as the diff is on screen.
  if email != "" and email != none {
    contact-items.push(if type(email) == str { link("mailto:" + email)[#email] } else { email })
  }
  
  // Add social links in the order they were provided
  for social-link in social-links {
    let (url, display-text) = social-link
    if url != "" and url != none {
      let full-url = if url.starts-with("http") { url } else { "https://" + url }
      contact-items.push(link(full-url)[#display-text])
    }
  }

  pad(
    top: 0.25em,
    [#{contact-items.join("  |  ")}],
  )

  body
}
