// The project function defines how your document looks.
// It takes your content and some metadata and formats it.
// Go ahead and customize it to your liking!

// #let current-chapter-title() = context {
//   let headings = query(heading.where(level: 1).before(here()))
//   if headings == () { "" } else { headings.last().body }
// }
#let current-chapter-title() = context {
  let headings = query(heading.where(level: 1))
  let current-heading = headings.filter(h => h.location().page() <= here().page())
  if current-heading == () { "" } else { current-heading.last().body }
}

#let project(
  logo: "",
  paper_type: "project",
  title: "Title",
  subtitle: "Subtitle",
  studiengang: "Studiengang",
  schule: "Fachhochschule Salzburg GmbH",
  abstract: [],
  authors: ("Author"),
  bigboss: "Big Boss",
  betreuer: "Betreuer",
  ort: "Puch bei Hallein",
  date: datetime.today().display("[day] [month repr:long] [year repr:full]"),
  body,
  show-subtitle: true,
  show-abstract: true,
  show-bigboss: true,
  show-betreuer: true,
) = {
  // Set the document's basic properties.
  set document(author: authors, title: title)
  set text(font: "New Computer Modern", lang: "en", size: 12pt)
  show math.equation: set text(weight: 400)
  show heading: it => {
    if it.level == 1{
      v(1em)
      it
      v(0.5em)
    } else if it.level == 2 {
      v(0.5em)
      it
      v(0.5em)
    }
  }

  // Title page.
  // The page can contain a logo if you pass one with `logo: "logo.png"`.
  if logo != none {
    align(center, logo)
  }

  // Paper type (e.g., "Bachelorarbeit", "Masterarbeit", "Protokoll") and title.
  v(1cm)
  align(
    center,
    text(0.8cm, weight: 700, paper_type)
  )

  // Title and subtitle of the paper
  v(1cm)
  align(
    center,
    text(0.9cm, weight: 700, title)
  )
  if show-subtitle{
    align(
      center,
      text(0.6cm, weight: 400, subtitle) 
    )
  }

  // Information about the study program, school, and authors.
  v(7.2em, weak: true)
  align(
    center,
    text("durchgeführt am Studiengang")
  )
  align(
    center,
    text(studiengang)
  )
  align(
    center,
    text(schule)
  )

  // Author information 
  v(2cm, weak: true)
  align(
    center,
    text("vorgelegt von")
  )
  // Author array
  pad(
    grid(
      columns: (1fr,),//* calc.min(3, authors.len()), 
      gutter: 1em,
      ..authors.map(author => align(center, strong(author))),
    ),
  )

  place(
    bottom + center,
    float: false,
    dy: -1cm,
    {
      // Department head and supervisor
      if show-bigboss {
        align(
          center,
          text(
            0.5cm,
            weight: 400,
            "Studiengangsleiter: " + bigboss
          )
        )
      }

      if show-betreuer {
        align(
          center,
          text(
            0.5cm,
            weight: 400,
            "Betreuer: " + betreuer 
          )
        )
      }
      v(1cm, weak: true)

      align(
        center,
        text(
          1.1em,
          ort + ", " + str(date)
        )
      )
      v(1cm, weak: true)
    }
  )
  
  // Abstract page.
  if show-abstract {
    set page(
      header: {
        grid(
          columns: (1fr),
          inset: (y: 0.5em),
          align: (left),
          [#current-chapter-title()],
          grid.hline(),
        )
      }
    )
    align(left)[
      #heading(
        outlined: false,
        numbering: none,
        text(1em, [Abstract]),
      )
      #abstract
    ]
  }

  set page(
    header: {
    }
  )

  // Main body.
  set page(
    numbering: "1",
    number-align: center,
    header: {
      grid(
        columns: (1fr),
        inset: (y: 0.5em),
        align: (left),
        [#current-chapter-title()],
        grid.hline(),
      )
    }
  )
  counter(page).update(1)
  set par(justify: true)
  body
}