/***********************/
/* TEMPLATE DEFINITION */
/***********************/

/* HANDLING DATE DISPLAY */

#let translate_month(month) = {
  // Construction mapping for months
  let t = (:)
  let fr-month-s = ("Janv.", "Févr.", "Mars", "Avr.", "Mai", "Juin",
    "Juill.", "Août", "Sept.", "Oct.", "Nov.", "Déc.")
  let fr-months-l = ("Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
    "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre")
  for i in range(12) {
    let idate = datetime(year: 0, month: i + 1, day: 1)
    let ml = idate.display("[month repr:long]")
    let ms = idate.display("[month repr:short]")
    t.insert(ml, fr-months-l.at(i))
    t.insert(ms, fr-month-s.at(i))
  }

  // Translating month
  let fr_month = t.at(month)
  fr_month
}

#let display-date(date, short-month) = {
  context {
    // Getting adapted month string
    let repr = if short-month { "short" } else { "long" }
    let month = date.display("[month repr:" + repr + "]")

    // Translate if necessary
    if text.lang == "fr" {
      month = translate_month(month)
    }

  // Returns month and year
  [#month #str(date.year())]
  }
}


/* MAIN COVER DEFINITION */

#let cover(title, author, date-start, date-end, subtitle: none, logo: none, short-month: false, logo-horizontal: true) = {
  set page(background: move(dx: 0pt, dy: -13%, image("assets/armes.svg")))
  set text(font: "New Computer Modern Sans", hyphenate: false, fill: rgb(1, 66, 106))
  set align(center)

  v(1.8fr)

  set text(size: 24pt, weight: "bold")
  upper(title)

  v(1.5fr)

  if subtitle != none {
    set text(size: 20pt)
    subtitle
  }

  v(1.5fr)
  
  set text(size: 18pt, weight: "regular")
  display-date(date-start, short-month); [ \- ]; display-date(date-end, short-month)

  image("assets/filet-court.svg")

  set text(size: 16pt)
  smallcaps(author)

  v(1fr)

  let logo-height = if (logo-horizontal) { 20mm } else { 30mm }
  let path-logo-x = if (logo-horizontal) { "assets/logo-x-ip-paris.svg" } else { "assets/logo-x.svg" }

  set image(height: logo-height)

  if (logo != none) {
    grid(
      columns: (1fr, 1fr), align: center + horizon,
      logo, image(path-logo-x)
    )
  } else {
    grid(
      columns: (1fr), align: center + horizon,
      image(path-logo-x)
    )
  }

}


/********************/
/* TESTING TEMPLATE */
/********************/

#set text(lang: "fr")

#cover(
  [A very long title over multiple lines automatically],
  "Jane Doe",
  datetime.today(),
  datetime.today(),
  subtitle: "Je n'ai pas de stage mais je suis détendu",
  logo-horizontal: true,
)
