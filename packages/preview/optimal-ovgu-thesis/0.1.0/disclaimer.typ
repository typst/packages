#import "components.typ": sans-font, variable-pagebreak

#let oot-disclaimer(
  title: "",
  international-title: "",
  author: none,
  city: "                    ",
  is-doublesided: none,
  lang: "en",
) = {
  let heading = "Statement of authorship of the student"
  if (lang == "de") {
    heading = "Selbstständigkeitserklärung"
  }

  text(font: sans-font, size: 2em, weight: 700, heading)

  line(start: (0pt, -1.5em), length: 100%)
  [Thesis: #title]

  if (international-title.len() > 0) {
    [\ (#international-title)]
  }

  v(5mm)

  grid(
    columns: 2,
    gutter: 1em,
    [Name: #author.name],
    [Surname: #author.surname],
    [Date of birth: #author.date-of-birth],
    [Matriculation no.: #author.matriculation-no],
  )

  v(5mm)

  par(
    first-line-indent: 0em,
  )[
    I herewith assure that I wrote the present thesis independently, that the thesis
    has not been partially or fully submitted as graded academic work and that I
    have used no other means than the ones indicated. I have indicated all parts of
    the work in which sources are used according to their wording or to their
    meaning.

    \

    I am aware of the fact that violations of copyright can lead to injunctive
    relief and claims for damages of the author as well as a penalty by the law
    enforcement agency.
  ]

  v(15mm)

  let signature-line = (length) => {
    box(line(length: length, stroke: (dash: "loosely-dotted")))
  }

  grid(
    columns: 2,
    gutter: 0.5em,
    column-gutter: 1fr,
    city + ", " + signature-line(3cm),
    " " + signature-line(5cm),
  )

  variable-pagebreak(is-doublesided)
}
