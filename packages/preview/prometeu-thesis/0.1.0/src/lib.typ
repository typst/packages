#import "colors.typ"
#import "cover.typ": render-cover
#import "formatting.typ"

#let author-state = state("author", [])
#let date-state = state("date", [])

#let thesis(
  author: "",
  title: [],
  date: [],
  supervisors: (),
  cover-images: (),
  cover-gray-images: (),
  school: [],
  degree: [],
) = doc => {
  set text(font: "NewsGotT", size: 12pt)
  set par(leading: 0.95em, spacing: 1.9em)
  show footnote.entry: set text(size: 8pt)
  show link: set text(fill: colors.blueuminho)

  set document(title: title, author: author)

  author-state.update(author)
  date-state.update(date)

  render-cover(
    author: author,
    title: title,
    date: date,
    supervisors: supervisors,
    images: cover-images,
    gray-images: cover-gray-images,
    school: school,
    degree: degree,
  )

  // Fake italic as NewsGotT doesn't have an italic style
  // Change regex if italic is broken when changing lines
  show emph: it => {
    show regex("\S+"): it => box(skew(ax: -18.4deg, reflow: false, it))
    it
  }

  set page(margin: 25mm, numbering: "1")

  doc
}
