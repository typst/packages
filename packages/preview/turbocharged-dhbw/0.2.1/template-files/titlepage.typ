#import "i18n.typ": strings

#let titlepage(
  title: [title],
  document-type: [document-type],
  program: [program],
  module: none,
  university: none,
  author: [author],
  submission-date: none,
  duration: none,
  student-id: none,
  course: none,
  company-name: none,
  city: none,
  company-supervisor: none,
  university-supervisor: none,
  company-logo: none,
  university-logo: none,
  cover-page: none,
  lang: "de",
) = {
  let translations = strings(lang)
  let authors = if type(author) == array { author } else { (author,) }
  if cover-page == none {
    // Title page
    let logo-box = box(
      height: 2cm,
      grid(
        columns: (1fr, 1fr),
        [
          #align(left)[
            #if company-logo != none {
              company-logo
            }
          ]
        ],
        [
          #align(right)[
            #if university-logo == none {
              image("dhbw-logo.png")
            } else {
              university-logo
            }
          ]
        ],
      ),
    )

    set par(justify: false)

    let company-entry = if company-name != none and city != none {
      [#company-name \ #city]
    } else if company-name != none {
      company-name
    } else {
      none
    }

    // A string is one row. An array is one row per entry. The label is only
    // on the first row, so it is not repeated.
    let field-rows(label, value) = {
      if value == none {
        ()
      } else if type(value) == array {
        value.enumerate().map(((i, it)) => (if i == 0 { label } else { none }, it))
      } else {
        ((label, value),)
      }
    }

    let rows = (
      (translations.processing-period, duration),
      ..field-rows(translations.student-id, student-id),
      ..field-rows(translations.course, course),
      (translations.company-name, company-entry),
      (translations.company-supervisor, company-supervisor),
      (translations.university-supervisor, university-supervisor),
    ).filter(it => it.at(1) != none)

    let info-table = table(
      columns: (auto, 1fr),
      column-gutter: 1.2cm,
      align: (left, left),
      stroke: none,
      inset: (y: 3.5pt, x: 0pt),
      ..rows.map(it => {
        let label = it.at(0)
        (
          if label == none { [] } else { [#label:] },
          [#it.at(1)],
        )
      }).flatten(),
    )

    // Vertical spacing scales down for long titles so the info table
    // still fits on the same page.
    let title-block(scale: 1.0) = align(center, [
      #text(22pt, weight: "bold", title)
      #v(0.8cm * scale)
      #smallcaps(text(20pt, document-type))
      #v(0.8cm * scale)

      #text(15pt)[
        #if module != none {
          translations.for-the-module
          v(0.4cm * scale)
          module
          v(0.4cm * scale)
        }
        #translations.in-degree-program #program
        #v(0.4cm * scale)
        #translations.at-university
        #v(0.4cm * scale)
        #if university == none {
          translations.default-university
        } else {
          university
        }
      ]
      #v(0.4cm * scale)
      #text(15pt)[#translations.by]
      #v(0.4cm * scale)
      #text(15pt, weight: "bold")[#authors.join(", ")]
      #v(0.8cm * scale)
      #if submission-date != none {
        text(13pt)[#translations.submission-date #submission-date]
        v(0.6cm * scale)
      }
    ])

    let content-width = 21cm - 2 * 1.8cm
    let content-height = 29.7cm - 2.5cm - 2cm
    let logo-gap = 0.8cm
    let logo-height = 2cm
    let table-gap = 1cm

    context {
      let min-scale = 0.4
      let table-height = measure(info-table, width: content-width).height
      let natural = measure(title-block(scale: 1.0), width: content-width).height
      let available = calc.max(
        0pt,
        content-height - logo-height - logo-gap - table-height - table-gap,
      )
      let scale = if natural > 0pt {
        calc.max(min-scale, calc.min(1.0, available / natural))
      } else {
        1.0
      }

      box(
        height: content-height,
        width: 100%,
        stack(
          dir: ttb,
          spacing: 0pt,
          logo-box,
          v(logo-gap),
          title-block(scale: scale),
          v(1fr),
          info-table,
        ),
      )
    }
  } else {
    cover-page
  }
}