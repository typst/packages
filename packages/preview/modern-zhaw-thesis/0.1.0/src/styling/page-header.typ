#import "tokens.typ": tokens

#let page-header-styles(doc) = {
  set page(
    header-ascent: 30%,
    header: context {
      let fill-line(left-text, right-text) = {
        set par(
          first-line-indent: (
            amount: 0em,
          ),
        )

        [#left-text #h(1fr) #right-text]
      }

      let page-number = here().page()

      // If the current page is the start of a chapter, don't show a header
      let target = heading.where(level: 1)
      if query(target).any(it => it.location().page() == page-number) {
        return []
      }

      // Find the chapter of the section we are currently in.
      let before = query(target.before(here()))
      if before.len() > 0 {
        let current = before.last()

        let chapter-title = current.body
        let chapter-number = counter(heading.where(level: 1)).display()
        let chapter-number-text = [Chapter #chapter-number]

        if current.numbering != none {
          let (left-text, right-text) = if calc.odd(page-number) {
            (chapter-number-text, chapter-title)
          } else {
            (chapter-title, chapter-number-text)
          }
          // text(weight: "regular", font: tokens.font-families.headers,
          fill-line(left-text, right-text)
          // )
          v(-tokens.spacing)
          line(length: 100%, stroke: 0.5pt)
        }
      }
    },
  )

  doc
}
