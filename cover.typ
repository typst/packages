/***********************/
/* TEMPLATE DEFINITION */
/***********************/

#let cover(title, authors, date-start, date-end, sub-title: none) = {
  // Set document metadata
  set document(title: title, author: authors, date: datetime.today())

  set align(center)

  v(3fr)

  set text(size: 24pt)
  upper(title)

  v(1fr)

  if sub-title != none {
    set text(size: 20pt)
    sub-title
  }

  v(1fr)
  
  set text(size: 18pt)
  date-start.display(); [ \- ]; date-end.display()

  v(0.5fr)

  set text(size: 16pt)
  smallcaps(authors)

  v(2fr)

}


/********************/
/* TESTING TEMPLATE */
/********************/

#cover(
  [A very long title over multiple lines automatically],
  "Jane Doe",
  datetime.today(),
  datetime.today(),
  sub-title: "Explain this title"
)
