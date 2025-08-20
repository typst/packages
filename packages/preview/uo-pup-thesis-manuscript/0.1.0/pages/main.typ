#import "../helpers.typ": *

/** Setup for main content (starting from chapter 1 until before refences) */
#let main-content(body) = {
  // Option to hyphenate text is not really defined in the university thesis
  // manual. You can turn this on if you want.
  set text(hyphenate: false)

  set par(first-line-indent: 0.5in, spacing: 3em)
  // spacing: 3em  // adds additional kinda one line space between paragraphs

  // Revert back to arabic numeral for main content
  set page(numbering: "1", footer: context [#none])

  set heading(numbering: (first, ..other) => if other.pos().len() == 0 {
    return str(first) + "  "
  })

  // Rule: starting from chapter 1, main content page count
  // should restart from 1
  counter(page).update(1)
  counter(heading).update(0)

  // This sets up another rule: each chapter's starting page should not indicate
  // the page number at the header
  show heading.where(level: 1): it => {
    state("content.switch").update(false)
    state("content.switch").update(true)
    it
  }
  set page(header: context get-current-page-num())

  show heading: it => [
    #it
    #v(-1em)
  ]

  show figure: set figure.caption(position: top)
  show figure.caption: it => block(width: 100%)[
    #if it.kind == table {
      align(center)[
        #let table-num = context {
          it.counter.display(it.numbering)
        }
        Table #table-num \
        #v(-1.5em)
        #text(weight: "bold", it.body)
      ]
    } else if it.kind == image {
      align(left)[
        #let figure-num = context {
          it.counter.display(it.numbering)
        }
        Figure #figure-num. #it.body
      ]
    }
    #v(1em)
  ]

  body
}
