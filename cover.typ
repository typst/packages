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

#let cover(title, authors, date-start, date-end, subtitle: none, short-month: false) = {
  // Set document metadata
  set document(title: title, author: authors, date: datetime.today())

  set align(center)

  v(3fr)

  set text(size: 24pt)
  upper(title)

  v(1fr)

  if subtitle != none {
    set text(size: 20pt)
    subtitle
  }

  v(1fr)
  
  set text(size: 18pt)
  display-date(date-start, short-month); [ \- ]; display-date(date-end, short-month)

  v(0.5fr)

  set text(size: 16pt)
  smallcaps(authors)

  v(2fr)

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
  subtitle: "Explain this title"
)
