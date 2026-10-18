#let setup(
  doc,
  work-title: [],
  custom-work-half-title: [],
  work-author: [],
  copyright-page: [],
  preface: [],
  recto-toc: true,
  blank-pages-after-toc: 0,
  blank-pages-before-start: 0,
  recto-chapter-start: true,
  title-text-settings: none,
  text-settings: none,
  par-settings: none,
  page-settings: none,
) = {
  import "@preview/hydra:0.6.2": hydra

  set document(
    title: work-title,
    author: work-author.text,
  )

  set text(
    font: "EB Garamond",
    number-type: "old-style",
    number-width: "proportional",
    size: 10pt,
    ..text-settings,
  )

  set par(
    first-line-indent: (amount: 1em, all: true),
    spacing: 0.65em,
    justify: true,
    ..par-settings,
    // justification-limits: (
    //   spacing: (min: 100% * 2 / 3, max: 150%), // default
    //   tracking: (min: -0.01em, max: 0.01em), // recommended
    // ),
  )

  set page(
    width: 5.5in,
    height: 8.5in,
    margin: (x: 0.6in, top: 0.9in, bottom: 0.5in),


    header: context smallcaps({
      let heading-content = hydra(1)
      if heading-content == none {
        return
      }

      let pagenum = [#counter(page).at(here()).at(0)]
      let spacer = [#sym.space.nobreak#sym.space.nobreak|#sym.space.nobreak#sym.space.nobreak]

      let order = if calc.odd(here().page()) {
        let page-num-and-spacer = [#spacer#pagenum]
        let size = measure(page-num-and-spacer)
        (
          align: right,
          columns: (1fr, size.width),
          left: heading-content,
          right: page-num-and-spacer,
        )
      } else {
        let page-num-and-spacer = [#pagenum#spacer]
        let size = measure(page-num-and-spacer)
        (
          align: left,
          columns: (size.width, 1fr),
          left: page-num-and-spacer,
          right: work-title,
        )
      }

      place(top, dy: 100% - page.header-ascent, grid(
        align: order.align,
        columns: order.columns,
        order.left, order.right,
      ))

      v(0.1in)
    }),
    ..page-settings,
  )

  show heading: it => {
    pagebreak(weak: true)

    block(
      align(
        {
          // note: outline doesn't supply numbering
          set text(weight: "regular", size: 2em)
          set par(justify: false, first-line-indent: 0em)
          v(0.3in)
          smallcaps(text(it, size: 1em))

          v(0.6in)
        },
        center,
      ),
      width: 100%,
      inset: (left: 0.3in, right: 0.3in),
    )
  }

  {
    // front matter
    set page(numbering: none, header: none)

    if custom-work-half-title != none {
      set par(justify: false)
      // half-title page
      let work-half-title = if custom-work-half-title == [] {
        box(width: 25%)[#work-title]
      } else {
        custom-work-half-title
      }
      v(0.5in)
      align(smallcaps(work-half-title), center)
      pagebreak()

      // blank
      pagebreak()
    }


    // title page
    {
      v(-0.7in)
      align(
        box({
          {
            show title: set text(weight: "regular", style: "italic", size: 1.5em, font: "Perpetua", ..title-text-settings)
            align(title(), center)
          }

          v(0.1in)
          align(center)[#work-author]
        }),
        center + horizon,
      )
      pagebreak(weak: true)
    }

    // copyright page
    {
      set text(size: 0.75em)
      set par(
        first-line-indent: 0em,
        spacing: 2em,
      )

      [
        #emph(work-title)\
        #work-author

        #copyright-page

        #pagebreak()
      ]
    }

    // blank
    pagebreak()

    // start toc on either recto or verso at choice
    if recto-toc {
      pagebreak()
    }

    // dedication page + blank
    // table of contents
    {
      set text(number-width: "tabular")
      set page(margin: (x: 20%))
      set outline.entry(fill: box(
        repeat([.], gap: 0.3em),
        inset: (left: 0.2em, right: 0.2em),
      ))
      show outline.entry: it => {
        // preface in toc should be the only thing on its line---no page num nor dots
        let inner = if it.element.body == [Preface] {
          [Preface]
        } else if it.element.body == [preface] {
          [preface]
        } else {
          it.inner()
        }

        link(
          it.element.location(),
          par(hanging-indent: 2em, first-line-indent: 0pt)[#inner],
        )
      }

      // less space between toc heading and toc
      show heading: it => {
        it
        v(-0.3in)
      }

      outline()
      pagebreak()
    }
    // foreword
    // preface
    // acknowledgements
    // introduction
    // abbreviations

    // blank
    // pagebreak()
  }

  for _ in range(blank-pages-after-toc) {
    pagebreak()
  }

  // preface
  if preface != [] {
    set page(header: none)
    counter(page).update(1)
    [
      = preface
      #preface
    ]
  }

  for _ in range(blank-pages-before-start) {
    set page(header: none)
    pagebreak()
  }

  pagebreak()

  show heading: it => if recto-chapter-start {
    {
      set page(header: none)
      pagebreak(weak: true, to: "odd")
    }
    it
  } else {
    it
  }

  counter(page).update(1)
  doc
}

#let titled-box(title, body) = {
  set par(spacing: 0.5in) // is a one-off value
  block(stroke: black, {
    place(dx: 0.3in, dy: -0.05in, box(fill: white, inset: (x: 0.05in))[#title]) // dy and x hardcoded to EB Garamond and font size
    set par(first-line-indent: 0em, spacing: 1.2em)
    block(width: 100%, inset: 1em, body)
  })
}

#let author-notes(body) = titled-box([Author's Notes], body)
#let summary(body) = titled-box([Summary], body)


#let major-break = align(center, {
  v(0.1in)
  "* * *"
  v(0.1in)
})
