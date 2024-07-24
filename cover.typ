#let cover(title, authors, date, short-title: none) = {
  // Set document metadata
  set document(title: title, author: authors, date: date)

  upper(title)

  smallcaps(authors)

  date.display()
}

#cover("Test", "Jane Doe", datetime.today())