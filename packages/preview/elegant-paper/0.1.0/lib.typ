#import "@preview/zh-kit:0.1.0": *

#let make-title(
  title: (),
  authors: (
    (
      name: (),
      institution: (),
      note: (),
      email: ()
    ),
  ),
  abstract: (),
  keywords: ()
) = {
  set par(first-line-indent: 0em, spacing: 1em)
  set align(center)

  // Helper function to display string or content
  let display-field(field) = {
    if type(field) == content { field }
    else if type(field) == str { text(field) } // Use 'str' for string type
    else { () } // Handle other types or empty if necessary
  }

  if title != () {
    v(4em)
    set text(size: 16pt)
    strong(display-field(title))
  }

  if authors != () {
    let author-content = ()

    for author in authors {
      author-content.push(
        [
          #set text(size: 10pt)

          // Display name based on type
          #display-field(author.name)

          // Display institution based on type
          #display-field(author.institution)

          // Display email based on type (handle string as link, content directly)
          #if "email" in author {
            if type(author.email) == content {
              author.email
            } else if type(author.email) == str { // Use 'str' for string type
              link("mailto:" + author.email)[#author.email]
            }
          }

          // Display note based on type
          #if "note" in author {
            display-field(author.note)
          }
        ]
      )
    }

    table(
      columns: authors.len(),
      align: center,
      stroke: 0em,
      inset: (
        x: 20pt
      ),
      ..author-content
    )
  }

  if abstract != () {
    set par(first-line-indent: 0em)

    text(strong("摘     要"))
    parbreak()

    set align(left)
    set text(size: 9pt)
    // Box likely handles string/content correctly, pass directly
    box(abstract, inset: (x: 3em))
  }

  if keywords != () and keywords.len() > 0 {
    v(0.75em)
    set align(left)
    set text(size: 10pt)

    text(strong("关键词："))
    // Iterate and display keywords based on type, joining with "；"
    for (i, keyword) in keywords.enumerate() {
      display-field(keyword)
      if i < keywords.len() - 1 {
        "；"
      }
    }
  }
}

#let elegant-paper(
  body,
  title: (
    title: "",
    authors: (),
    abstract: (),
    keywords: ()
  ),
  font: (
    font-size: 10pt
  ),
  paper: "a4",
  enable-outline: false
) = {
  set page(paper: paper)

  setup-base-fonts(
    {
      set heading(numbering: "1.1")
      set text(size: font.font-size)
      set par(spacing: 12pt, leading: 9pt)
      set list(spacing: 9pt)
      set enum(spacing: 9pt)

      show heading: it => {
        v(5pt)
        it
        v(2pt + (3 - it.level) * 1pt)
      }

      show ref: it => {
        set text(fill: color.rgb(128, 0, 0))
        it
      }

      make-title(
        title: title.title,
        authors: title.authors,
        abstract: title.abstract,
        keywords: title.keywords
      )

      if enable-outline {
        show outline.entry: it => {
          set text(fill: color.rgb(128, 0, 0))

          it
        }

        show outline.entry.where(level: 1): it => {
          v(0.75em)
          strong(it)
        }

        outline(title: [目录], indent: 1em)
      }

      body
    }
  )
}