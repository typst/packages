#import "../lib.typ": *

#let appendix(chapter_numbering: str, title: str, doc) = {
  set page(
    header-ascent: 35%,
    header: context {
      set text(fill: colors.darkgray)
      let curr-page = counter(page).get().first()
      let next-chp = query(selector(heading.where(level: 1)).after(here()))

      // we are in a blank page
      if next-chp == none or next-chp.len() == 0 {
        return
      }

      next-chp = next-chp.first()
      let next-chp-page = counter(page).at(next-chp.location()).first()

      // check if there is 1st level heading on this page, if there is do not display the header
      if curr-page == 1 or next-chp-page == 1 or curr-page == next-chp-page {
        return
      }

      let alignment = none
      let body = none

      if calc.even(curr-page) {
        alignment = right
        let header-title = query(selector(heading).before(here())).last().body
        body = [#curr-page #h(1fr) #header-title]
      } else {
        alignment = left
        let header-title = query(selector(heading.where(level: 1)).before(here())).last().body
        body = [#header-title #h(1fr) #curr-page]
      }

      align(alignment, [
        #block(inset: 0pt, spacing: 0pt, body)
        #v(0.75em)
        #line(length: 100%, stroke: 0.2pt)
      ])
    },
  )

  counter(heading).update(1)
  heading(
    numbering: none,
    outlined: true,
    supplement: "Appendix",
  )[#title]
  set heading(numbering: chapter_numbering + ".1", outlined: true)

  // setup the figure numbering for the appendix
  set figure(numbering: n => [#chapter_numbering.#n])
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)

  doc
}
