#import "@preview/tieflang:0.1.0": tr
#import "state.typ": meta-value

#let header-font = "Cormorant SC"
#let header-text = (weight, body) => text(font: header-font, weight: weight)[#body]
#let header-divider = place(dy: -.2em, line(angle: 90deg, length: 1em, stroke: (thickness: .4pt, paint: luma(30%))))
#let is-even-page = page => calc.rem(page, 2) == 0
#let page-left-right-choose = (page, left, right) => if is-even-page(page) { left } else { right }

#let chapter-context = () => {
  let headings = query(heading.where(level: 1))
  let current-page = here().page()
  let previous-headings = headings.filter(h => h.location().page() <= current-page)
  if previous-headings.len() == 0 {
    return none
  }
  let nearest-previous-heading = previous-headings.last()
  let heading-on-current-page = nearest-previous-heading.location().page() == current-page
  let heading-number = counter(heading).at(nearest-previous-heading.location())
  let heading-display = numbering(heading.numbering, ..heading-number)
  (
    nearest: nearest-previous-heading,
    on-current: heading-on-current-page,
    display: heading-display,
  )
}

#let chapter-title = heading-display => (tr().chapter)(heading-display)
#let chapter-title-with-body = info => if info.on-current {
  header-text("bold")[ #(chapter-title(info.display))]
} else {
  header-text("bold")[ #(chapter-title(info.display)) -- #info.nearest.body]
}

#let chapter-number-center-header = align(center, context {
  let info = chapter-context()
  if info == none {
    return
  }
  chapter-title-with-body(info)
})

#let chapter-number-outside-header = context {
  let info = chapter-context()
  if info == none {
    return
  }
  let current-page = here().page()
  let heading-alignment = page-left-right-choose(current-page, left, right)
  align(heading-alignment, chapter-title-with-body(info))
}

#let chapter-number-outside-pagenum-header = context {
  let info = chapter-context()
  if info == none {
    return
  }
  let pagenum = counter(page).display()
  let current-page = here().page()
  let heading-alignment = page-left-right-choose(current-page, left, right)
  align(heading-alignment, page-left-right-choose(
    current-page,
    header-text("bold", grid(
      align: (center, center, center),
      columns: 3,
      column-gutter: .4em,
      pagenum, header-divider, chapter-title-with-body(info),
    )),
    header-text("bold", grid(
      align: (center, center, center),
      columns: 3,
      column-gutter: .4em,
      chapter-title-with-body(info), header-divider, pagenum,
    )),
  ))
}

#let book-author-title-header = context {
  let current-page = here().page()
  let title-value = meta-value("title")
  let author-value = meta-value("author")
  align(
    page-left-right-choose(current-page, left, right),
    page-left-right-choose(
      current-page,
      header-text("bold")[ #title-value ],
      header-text("bold")[ #author-value ],
    ),
  )
}

#let book-title-subtitle-header = context {
  let current-page = here().page()
  let title-value = meta-value("title")
  let subtitle-value = meta-value("subtitle")
  align(
    page-left-right-choose(current-page, left, right),
    page-left-right-choose(
      current-page,
      header-text("bold")[ #title-value ],
      header-text("regular")[ #subtitle-value ],
    ),
  )
}

#let book-author-title-pagenum-header = context {
  let current-page = here().page()
  let pagenum = counter(page).display()
  let title-value = meta-value("title")
  let author-value = meta-value("author")
  align(
    page-left-right-choose(current-page, left, right),
    page-left-right-choose(
      current-page,
      header-text("bold", grid(
        align: (center, center, center),
        columns: 3,
        column-gutter: .4em,
        pagenum, header-divider, title-value,
      )),
      header-text("bold", grid(
        align: (center, center, center),
        columns: 3,
        column-gutter: .4em,
        author-value, header-divider, pagenum,
      )),
    ),
  )
}

#let book-title-subtitle-pagenum-header = context {
  let current-page = here().page()
  let title-value = meta-value("title")
  let subtitle-value = meta-value("subtitle")
  let pagenum = counter(page).display()
  align(
    page-left-right-choose(current-page, left, right),
    page-left-right-choose(
      current-page,
      header-text("bold", grid(
        align: (center, center, center),
        columns: 3,
        column-gutter: .4em,
        pagenum, header-divider, title-value,
      )),
      header-text("regular", grid(
        align: (center, center, center),
        columns: 3,
        column-gutter: .4em,
        subtitle-value, header-divider, pagenum,
      )),
    ),
  )
}

#let no-header = none
