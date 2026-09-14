#import "title.typ": title-page
#import "frontmatter.typ": frontmatter-page
#import "bibliography.typ": bibliography-page
#import "utils.typ": latest-heading, page-has-heading
#import calc: even

#let thesis(
  title: none,
  author: none,
  college: none,
  degree: "Doctor of Philosophy",
  submission-term: none,
  acknowledgements: none,
  abstract: none,
  logo: none,
  show-toc: true,
  bib: none,
  body,
) = {
  // Validate inputs
  assert(title != none, message: "Thesis title must be provided")
  assert(author != none, message: "Thesis author must be provided")

  // =========== Document settings ===========
  set document(
    title: title,
    author: author,
  )

  set page(
    paper: "a4",
    margin: (
      inside: 3.6cm,
      outside: 2.6cm,
      top: 4cm,
      bottom: 2.5cm,
    ),
    header: context {
      let page-num = here().page()
      let page-display-num = counter(page).display()
      let has-h1 = page-has-heading(here())
      if has-h1 {
        return none
      }
      let latest-h1 = latest-heading(level: 1)
      set text(style: "italic")
      if even(page-num) {
        set align(left)
        page-display-num
        if latest-h1 != none {
          h(1fr)
          latest-h1
        }
      } else {
        set align(right)
        if latest-h1 != none {
          latest-h1
        }
        h(1fr)
        page-display-num
      }
    },
    footer: context {
      let has-h1 = page-has-heading(here())
      if not has-h1 { none } else {
        set align(center)
        set text(style: "italic")
        counter(page).display()
      }
    },
  )

  set par(
    justify: true,
    leading: 1.5em,
  )

  set text(
    font: "New Computer Modern",
    size: 12pt,
  )

  // Suppress header, footers and numbering on
  // empty pages
  show selector.or(
    pagebreak.where(to: "odd"),
    pagebreak.where(to: "even"),
  ): set page(
    header: none,
    footer: none,
    numbering: none,
  )

  // Heading styling
  set heading(numbering: "1.1.1")
  show heading: it => {
    v(1em)
    it
    v(1em)
  }
  show heading.where(level: 1): it => {
    // Place level 1 headings on an odd page
    pagebreak(weak: true, to: "odd")
    align(
      right,
      block[
        #v(4cm)
        #let num = counter(heading).get().at(0)
        #if num > 0 {
          set text(
            size: 90pt,
            weight: 900,
            fill: gray,
          )
          num
        } \
        #set text(
          size: 24pt,
          weight: 100,
        )
        #it.body
        #v(1em)
      ],
    )
  }

  // ============== Title page ==============
  title-page(
    title: title,
    author: author,
    college: college,
    degree: degree,
    submission-term: submission-term,
    logo: logo,
  )
  // Skip a page after title
  pagebreak(to: "odd")

  // ============== Frontmatter =============
  // Set latin page numbering
  set page(numbering: "i")
  counter(page).update(1)

  // Acknowledgements
  if acknowledgements != none {
    frontmatter-page(title: "Acknowledgements")[
      #acknowledgements
    ]
  }

  // Abstract
  if abstract != none {
    frontmatter-page(title: "Abstract")[
      #abstract
    ]
  }

  // Table of contents
  if show-toc {
    outline(
      title: "Contents",
      indent: 2em,
      depth: 3,
    )
    pagebreak(weak: true, to: "odd")
  }

  // ============== Main body ==============
  // Page numbering
  set page(numbering: "1")
  counter(page).update(1)

  body

  // ============ Bibliography =============
  if bib != none {
    bibliography-page(bib)
  }
}
