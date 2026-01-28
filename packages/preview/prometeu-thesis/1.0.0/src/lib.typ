#import "colors.typ"
#import "cover.typ": render-cover
#import "state.typ"

#let thesis(
  author: "",
  title: [],
  date: [],
  supervisors: (),
  cover-images: (),
  cover-gray-images: (),
  school: [],
  degree: [],
  language: "en",
) = doc => {
  if language != "en" and language != "pt" {
    panic("Language must be either 'en' or 'pt'")
  }

  set text(
    font: "NewsGotT",
    size: 12pt,
    lang: language,
    region: if language == "pt" { "PT" } else { "US" },
  )

  set par(leading: 0.95em, spacing: 1.9em, justify: true)
  show footnote.entry: set text(size: 8pt)

  show footnote: set text(fill: colors.blueuminho)
  show cite: set text(fill: colors.blueuminho)
  show link: set text(fill: colors.blueuminho)

  set document(title: title, author: author)

  state.author.update(author)
  state.date.update(date)
  state.language.update(language)

  render-cover(
    author: author,
    title: title,
    date: date,
    supervisors: supervisors,
    images: cover-images,
    gray-images: cover-gray-images,
    school: school,
    degree: degree,
    language: language,
  )

  // Fake italic as NewsGotT doesn't have an italic style
  // Change regex if italic is broken when changing lines
  show emph: it => {
    show regex("\S+"): it => box(skew(ax: -18.4deg, reflow: false, it))
    it
  }

  set page(margin: 25mm, numbering: "1")

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    block(inset: (top: 30mm, bottom: 15mm), {
      if it.supplement != [] and it.numbering != none {
        block(
          text(15pt, {
            it.supplement + [ ] + counter(heading).display(it.numbering)
          }),
          below: 7mm,
        )
      }
      block(text(18pt, it.body))
    })
  }

  show heading.where(level: 2): it => {
    set text(16pt)
    set block(above: 2.5em, below: 1.5em)
    it
  }

  doc
}
