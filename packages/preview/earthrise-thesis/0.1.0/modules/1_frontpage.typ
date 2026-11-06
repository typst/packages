
#let fill-size(body, target, start: 24pt, cap: 60pt) = {
  let chosen = start
  let natural = measure(text(chosen, body)).width
  let pass = 0
  while natural > 0pt and pass < 5 {
    let next = calc.min(cap, chosen * (target / natural))
    if calc.abs(next - chosen) < 0.01pt { break }
    chosen = next
    natural = measure(text(chosen, body)).width
    pass += 1
  }
  chosen
}

#let column = 96%

#let front-page(
  doc-id: "",
  faculty: "",
  defense-date: none,
  date-format: "[day padding:none] [month repr:long] [year]",
  defense-location: "",
  degree-title: [],
  degree-subject: [],
  author: "",
  title: [],
  subtitle: [],
  front-img: none,
) = page(
  paper: "a4",
  header: none,
  footer: none,
  numbering: none,
  background: front-img,
  [
    #let has-location = defense-location not in (none, "", [])
    #let defense-line = if defense-date == none and not has-location {
      []
    } else {
      [defense held#if defense-date != none [ on #defense-date.display(date-format)]#if has-location [ in #defense-location] to obtain the degree of]
    }
    #let degree-line = if degree-subject in (none, [], "") {
      degree-title
    } else {
      [#degree-title #degree-subject]
    }
    #set align(center)
    #set par(justify: false, spacing: 0pt)
    #set text(top-edge: "ascender", bottom-edge: "descender")

    #layout(measure-of => context {
      let w = column * measure-of.width

      let faculty-line-size = fill-size(
        faculty,
        0.5 * w,
        start: 10pt,
        cap: 100pt,
      )
      if doc-id not in (none, "", []) {
        faculty-line-size = calc.min(
          faculty-line-size,
          fill-size(doc-id, w, start: 10pt, cap: 100pt),
        )
      }

      v(2.5em)

      text(faculty-line-size, doc-id)
      v(0.1em)
      text(faculty-line-size, faculty)

      v(0.5fr)

      let head = text(weight: "bold")[#title]
      let deck = text(weight: "regular")[#subtitle]

      let head-size = fill-size(head, w, start: 10pt, cap: 100pt)

      text(head-size, head)
      v(0.1em)
      text(
        calc.min(head-size, fill-size(deck, w, start: 10pt, cap: 100pt)),
        deck,
      )

      v(1fr)
      v(-2em)

      let dissertation-line = text(tracking: 0.5pt, "DISSERTATION")
      let degree-line = text(tracking: 0.5pt)[#degree-line]
      let defense-line-size = fill-size(
        defense-line,
        0.75 * w,
        start: 10pt,
        cap: 100pt,
      )

      text(
        fill-size(dissertation-line, 0.4 * w, start: 10pt, cap: 100pt),
        dissertation-line,
      )
      v(2em)
      text(defense-line-size, defense-line)
      v(1em)
      text(fill-size(degree-line, w, start: 10pt, cap: 100pt), degree-line)

      v(0.5fr)
      text(defense-line-size, "by")
      v(0.5fr)
      text(fill-size(author, 1.0 / 3.0 * w, start: 10pt, cap: 100pt), author)

      v(2.5em)
    })
  ],
)
