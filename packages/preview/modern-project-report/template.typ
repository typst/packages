// Modern Typst Project Report Template

#let build-main-header(main-heading-content) = [
  #align(center, smallcaps(main-heading-content))
  #v(-4pt)
  #line(length: 100%, stroke: 0.5pt + luma(120))
]

#let build-secondary-header(main-heading-content, secondary-heading-content) = [
  #smallcaps(main-heading-content) #h(1fr) #emph(secondary-heading-content)
  #v(-4pt)
  #line(length: 100%, stroke: 0.5pt + luma(120))
]

#let is-after(sec-heading, main-heading) = {
  let sec-pos = sec-heading.location().position()
  let main-pos = main-heading.location().position()
  if sec-pos.page > main-pos.page {
    return true
  }
  if sec-pos.page == main-pos.page {
    return sec-pos.y > main-pos.y
  }
  return false
}

#let get-header() = context {
  let current-page = here().page()

  // Find if there is a level 1 heading on the current page
  let next-main-heading = query(selector(heading.where(level: 1)).after(here())).find(head-it => {
    head-it.location().page() == current-page
  })
  if next-main-heading != none {
    return build-main-header(next-main-heading.body)
  }

  // Find the last previous level 1 heading
  let previous-main-headings = query(selector(heading.where(level: 1)).before(here()))
  let last-main-heading = previous-main-headings.at(-1, default: none)

  if last-main-heading == none {
    return none
  }

  // Find the last level > 1 heading before the current location
  let previous-secondary-headings = query(
    selector(heading).before(here())
  ).filter(head-it => head-it.level > 1)
  let last-secondary-heading = previous-secondary-headings.at(-1, default: none)

  // Find if the last secondary heading exists and if it's after the last main heading
  if last-secondary-heading != none and is-after(last-secondary-heading, last-main-heading) {
    return build-secondary-header(last-main-heading.body, last-secondary-heading.body)
  }

  return build-main-header(last-main-heading.body)
}

// Backward compatibility aliases
#let buildMainHeader = build-main-header
#let buildSecondaryHeader = build-secondary-header
#let isAfter = is-after
#let getHeader = get-header

// Main Project Template Function
#let project(
  title: "", 
  authors: (), 
  subtitle: "",
  department: "", 
  institute: "", 
  address: "", 
  logo: none, 
  abstract: none,
  subject: "",
  degree: "Bachelor of Technology",
  stream: "Information Technology",
  guide: (),
  body
) = {
  // Set document metadata
  set document(
    title: title,
    author: authors.map(a => if type(a) == dictionary { a.at("name", default: "") } else { str(a) })
  )

  // Initial Page Setup for Cover Page
  set page(
    paper: "a4",
    margin: (top: 1in, bottom: 1in, left: 1in, right: 1in)
  )
  set text(font: ("New Computer Modern", "Libertinus Serif", "Times New Roman"), lang: "en", size: 11pt)
  set par(justify: true, leading: 0.65em)

  // Title Block
  v(0.1fr)
  align(center)[
    #if subject != "" [
      #text(12pt, weight: "bold", smallcaps(subject)) \
    ]
    #text(12pt, weight: "bold", smallcaps("Project Report")) \ \
    #text(28pt, weight: 900, smallcaps(title)) \
    #if subtitle != "" [
      #text(14pt, weight: 200, subtitle) \
    ]
    \
    #emph(text(11pt, weight: 200, "Submitted in fulfillment of")) \
    #emph(text(11pt, weight: 200, "the requirements for the paper")) \
    #if subject != "" [
      #emph(text(11pt, weight: 200, subject))
    ]
  ]

  // Degree Information
  align(center)[
    #text(12pt, weight: "bold", degree) \
    #text(12pt, weight: "bold", "in") \
    #text(12pt, weight: "bold", stream)
    #v(1cm)
    #text(12pt, weight: "bold", "Submitted By,")
  ]

  // Authors Grid
  pad(
    top: 1em,
    {
      let chunk-size = 3
      let author-chunks = range(int(calc.ceil(authors.len() / chunk-size))).map(i => {
        authors.slice(i * chunk-size, calc.min((i + 1) * chunk-size, authors.len()))
      })
      for (idx, chunk) in author-chunks.enumerate() {
        grid(
          columns: (1fr,) * chunk.len(),
          gutter: 12pt,
          ..chunk.map(author => align(center, {
            if type(author) == dictionary {
              text(11pt, weight: "bold", author.at("name", default: ""))
              if "rollno" in author [ \ #author.rollno ]
              if "regno" in author [ \ #author.regno ]
              if "department" in author [ \ #author.department ]
              if "email" in author [ \ #link("mailto:" + author.email) ]
            } else {
              text(11pt, weight: "bold", str(author))
            }
          }))
        )
        if idx < author-chunks.len() - 1 {
          v(16pt, weak: true)
        }
      }
    }
  )

  // Guide Section
  if guide != () and guide != none {
    v(1cm)
    align(center)[
      #text(11pt, "Under the guidance of,") \
      #if type(guide) == dictionary {
        text(13pt, weight: "bold", smallcaps(guide.at("name", default: "")))
        if "designation" in guide [ \ #text(11pt, smallcaps(guide.designation + ",")) ]
        if "department" in guide [ \ #text(11pt, smallcaps(guide.department)) ]
      } else {
        text(13pt, weight: "bold", smallcaps(str(guide)))
      }
    ]
  }

  // Institutional Details & Logo
  v(0.75fr)
  align(center)[
    #if logo != none [
      #image(logo, width: 26%) \
    ]
    #if department != "" [
      #text(11pt, weight: "bold", smallcaps(department)) \
    ]
    #if institute != "" [
      #text(13pt, institute) \
    ]
    #if address != "" [
      #text(10pt, address)
    ]
  ]

  // Body Margins (with binding offset on left margin)
  set page(margin: (top: 1in, bottom: 1in, left: 1.5in, right: 1in))

  // Abstract Page
  if abstract != none {
    pagebreak()
    align(right)[
      #text(28pt, weight: "bold", smallcaps("Abstract"))
    ]
    v(1em)
    set par(justify: true)
    abstract
  }

  // Outline / Table of Contents
  pagebreak()
  outline(depth: 3, indent: auto)

  // Heading Styles
  show heading: set block(above: 1.2em, below: 0.6em)

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(1cm)
    align(right)[
      #block[
        #text(28pt, weight: "bold", smallcaps(it.body))
        #v(0.4em)
        #line(length: 100%, stroke: 1.5pt)
      ]
    ]
    v(1.5em)
  }

  show heading.where(level: 2): it => block(
    above: 1.4em,
    below: 0.7em,
    text(18pt, weight: "bold")[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #smallcaps(it.body)
    ]
  )

  show heading.where(level: 3): it => block(
    above: 1.2em,
    below: 0.6em,
    text(15pt, weight: "bold")[
      #if it.numbering != none {
        counter(heading).display()
        h(0.5em)
      }
      #smallcaps(it.body)
    ]
  )

  show heading.where(level: 4): it => block(
    above: 1em,
    below: 0.5em,
    text(13pt, weight: "bold", smallcaps(it.body))
  )

  show heading.where(level: 5): it => block(
    above: 1em,
    below: 0.5em,
    text(11pt, weight: "bold", smallcaps(it.body))
  )

  // Main Body Setup
  set par(justify: true)
  set heading(numbering: "1.1")
  counter(page).update(1)
  set page(
    header: get-header(),
    numbering: "1",
    number-align: center
  )

  body
}
