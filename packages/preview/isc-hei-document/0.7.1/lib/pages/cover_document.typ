// Simple document cover page — no course info, no cover image
#import "../includes.typ" as inc
#import "/isc_templates.typ" as isc

#let cover_page(
  font: "",
  title: "",
  subtitle: none,
  authors: "",
  date: "",
  revision: none,
  logo: none,
  language: "",
) = {

  let i18n = isc.i18n.with(extra-i18n: none, language)

  let insert-logo(logo) = {
    if logo != none {
      place(
        top + right,
        dx: 0mm,
        dy: 3mm,
        clearance: 0em,
        // Put it in a box to be resized
        box(width: 7.6cm, height: 2.0cm, logo),
      )
    }
  }

  // Title page
  insert-logo(logo)

  v(10fr, weak: true)

  // Main title
  set par(leading: 0.2em)
  text(font: font, 2em, weight: 700, smallcaps(title))
  set par(leading: 0.65em)

  // Subtitle
  v(1em, weak: true)
  text(font: font, 1.2em, subtitle)
  line(length: 100%)

  v(12em)

  // Author information on the title page
  pad(top: 1em, right: 20%, grid(
    columns: 3,
    column-gutter: 3em,
    gutter: 2em,
    ..authors.map(author => align(start, text(1.2em, strong(author)))),
  ))

  // The date and optional version
  if date != none {
    text(1.1em, inc.custom-date-format(date, pattern: i18n("date-format"), lang: language))
  }
  
  if revision != none {
    if date != none {
      text(1.1em, [ — v#revision])
    } else {
      text(1.1em, [v#revision])
    }
  }
  
  v(2.4fr)
  pagebreak()
}
