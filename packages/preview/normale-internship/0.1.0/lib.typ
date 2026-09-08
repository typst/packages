#let blue-light-ens = rgb("#8cc8d2")
#let blue-dark-ens = rgb("#00778b")

#let normale-internship(
  title: "",
  subtitle: "",
  lang: "en",
  paper-size: "a4",
  authors: (),
  mentors: (),
  place: "",
  logo: none,
  date: "",
  table-of-contents: true,
  bibliography: none, 
  doc,
) = {
  if type(authors) == str {
    authors = (authors,)
  }
  if type(mentors) == str {
    mentors = (mentors,)
  }

  set document(
    title: title,
    author: authors.join(",")
  )
  set page(
    paper: paper-size,
    numbering: "1",
  )
  set par(
    leading: 0.5em,
    spacing: 0.5em,
    first-line-indent: 2em, 
    justify: true
  )
  set text(
    font: "New Computer Modern",
    lang: lang
  )
  set heading(numbering: "1.1.a")

  page(
    numbering: none,
    {
      if(logo == none) {
        image("assets/Logo_ENS_PS.jpg", height: 50pt)
      } else {
        grid(
          columns: (1fr, 1fr),
          align: (left, right),
          image("assets/Logo_ENS_PS.jpg", height: 50pt),
          logo
        )
      }

      set align(center + horizon)
      line(length: 100%)
      pad(y: 15pt, text(30pt, fill: black)[#title])
      line(length: 100%)

      pad(top: 15pt, text(15pt, fill: black)[#subtitle])

      set align(center)
      if(authors != none and authors.len() >= 1) {
        if(authors.len() == 1 and lang == "en") {
          pad(top: 30pt, strong("Author"))
        } else if(authors.len() == 1 and lang == "fr"){
          pad(top: 30pt, strong("Auteur"))
        } else if(authors.len() != 1 and lang == "en"){
          pad(top: 30pt, strong("Authors"))
        } else if(authors.len() != 1 and lang == "fr"){
          pad(top: 30pt, strong("Auteurs"))
        }
        pad(top: 5pt,
          grid(
            columns: authors.len(),
            gutter: 10%,
            ..for author in authors { (author,) }
          )
        )
      }

      if(mentors != none and mentors.len() >= 1) {
        if(mentors.len() == 1 and lang == "en") {
          pad(top: 10pt, strong("Mentor"))
        } else if(mentors.len() == 1 and lang == "fr"){
          pad(top: 10pt, strong("Encadrant"))
        } else if(mentors.len() != 1 and lang == "en"){
          pad(top: 10pt, strong("Mentors"))
        } else if(mentors.len() != 1 and lang == "fr"){
          pad(top: 10pt, strong("Encadrants"))
        }
        pad(top: 5pt,
          grid(
            columns: mentors.len(),
            gutter: 10%,
            ..for author in mentors { (author,) }
          )
        )
      }

      set align(center + bottom)
      text()[#place \ #date]
    }
  )

  if(table-of-contents == true) {
    outline()
    pagebreak()
  }

  doc

  if(bibliography != none) {
    bibliography
  }
}
