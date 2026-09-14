// Fancy pretty print with line numbers and stuff
#import "../includes.typ" as inc
#import "../overflow.typ" as overflow
#import "/isc_templates.typ" as isc

#let cover_page(
  course-supervisor: "",
  course-name: "",
  font: "",
  title: "",
  subtitle: none,
  semester: "",
  academic-year: "",
  cover-image: "",
  cover-image-height: "",
  cover-image-caption: "",
  cover-image-kind: "",
  cover-image-supplement: "",
  authors: "",
  date: "",
  logo: none,
  language: "",
) = {

  let i18n = isc.i18n.with(extra-i18n: none, language)

  let insert-logo(logo) = {
    if logo != none {
      place(
        top + right,
        dx: 0mm,
        dy: -10mm,
        clearance: 0em,
        // Put it in a box to be resized
        box(width: 7.8cm, height: 2.0cm, logo),
      )
    }
  }

  // Title page
  insert-logo(logo)

  let title-block = [
    #course-supervisor\
    #semester #academic-year
  ]

  let title-block-content = title-block

  place(top + left, dy: -2em, text(1em)[
    #text(weight: 700, course-name)\
    #text(title-block-content)
  ])

  v(10fr, weak: true)

  // Puts a default cover image
  if cover-image != none {
    show figure.caption: emph
    figure(
      box(cover-image, height: cover-image-height),
      caption: cover-image-caption,
      numbering: none,
      kind: cover-image-kind,
      supplement: cover-image-supplement,
    )
  }

  v(10fr, weak: true)

  // Main title
  set par(leading: 0.2em)
  text(font: font, 2em, weight: 700, smallcaps(title))
  set par(leading: 0.65em)

  // Subtitle
  v(1em, weak: true)
  text(font: font, 1.2em, subtitle)
  line(length: 100%)

  // Title / subtitle overflow warning. The verdict is measured against the shared
  // thesis reference (see lib/overflow.typ) so it matches every other document;
  // the box is just displayed here at this cover's content width. Plain context
  // (NOT layout, which is a real block and would shift the fr-spaced layout even
  // when empty) keeps the no-overflow case zero-footprint; on overflow the box is
  // absorbed by the flexible spacing below.
  context {
    let issues = overflow.title-overflow-issues(title, subtitle: subtitle)
    if issues.len() > 0 {
      v(0.8em)
      overflow.overflow-warning-box(issues, font: font, width: 210mm - 2.5cm - 2cm)
    }
  }

  v(4em)

  // Author information on the title page
  pad(top: 1em, right: 20%, grid(
    columns: 3,
    column-gutter: 3em,
    gutter: 2em,
    ..authors.map(author => align(start, text(1.1em, strong(author)))),
  ))

  // The date
  text(1.1em, inc.custom-date-format(date, pattern: i18n("date-format"), lang: language))

  v(2.4fr)
  pagebreak()
}