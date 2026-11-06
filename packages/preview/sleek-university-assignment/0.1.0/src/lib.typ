#let assignment(
  title: none,
  authors: (),
  university-logo: none,
  course: none,
  body,
) = {
  set page(
    paper: "a4",
    margin: (top: 1in, right: 1in, bottom: 2cm, left: 1in),
    header: context {
      if counter(page).get().first() > 1 [
        #title
        #h(1fr)
        #counter(page).display()
      ]
    },
    footer: context {
      if counter(page).get().first() > 1 {
        align(right, course)
      }
    },
  )
  set text(11pt, font: "Libertinus Serif")
  set list(indent: 8pt)
  set raw(syntaxes: "./syntax/console.sublime-syntax")
  show heading: set block(below: 8pt)
  show raw: set text(font: "Inconsolata")

  grid(
    columns: (auto, 1fr),
    {
      emph(course)
      v(-0.4em)
      strong(text(2em, title))
      linebreak()
      v(0.5em)

      for author in authors [
        #text(1.1em, upper(author.name), font: "Libertinus Sans"), #link("mailto:" + author.email), #author.student-no \
      ]
      if authors != () {
        v(0.5em)
      }
    },
    align(
      right,
      if university-logo != none {
        box(height: 3em, university-logo)
      },
    ),
  )

  set par(justify: true)
  show figure: align.with(center)
  show figure: set text(8pt)
  show figure.caption: pad.with(x: 10%)

  body
}
