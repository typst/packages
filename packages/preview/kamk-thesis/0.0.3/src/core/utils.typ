// Joins author names for display, e.g. "Surname Firstname ja Secondname Another"
#let format-authors(authors, language: "fi") = {
  let glue = if language == "fi" { "ja" } else { "and" }
  // A single-element tuple without a trailing comma, e.g. ("Name"), is just a string
  let authors = if type(authors) == str { (authors,) } else { authors }
  if authors.len() == 0 {
    ""
  } else if authors.len() == 1 {
    authors.at(0)
  } else {
    authors.slice(0, -1).join(", ") + " " + glue + " " + authors.last()
  }
}
