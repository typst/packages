/// This module normalizes the document metadata given to the template.

/// Normalizes a single author.
///
/// -> dictionary
#let _author(
  /// A name, or a dictionary with a `name` and optionally an `affiliation` and an `email`.
  /// -> str | content | dictionary
  author,
) = if type(author) in (str, content) {
  (name: author, affiliation: none, email: none)
} else if type(author) == dictionary {
  assert("name" in author, message: "quire: author dictionaries must contain a 'name' key")
  (affiliation: none, email: none) + author
} else {
  panic("quire: invalid author: " + repr(author))
}

/// Normalizes the authors to an array of dictionaries with `name`, `affiliation` and `email` keys.
///
/// -> array
#let _authors(
  /// An author or an array of authors (see `_author`).
  /// -> str | content | dictionary | array
  authors,
) = if type(authors) == array { authors.map(_author) } else { (_author(authors),) }

/// Converts content to a plain string, as needed by the PDF metadata.
///
/// -> str
#let _plain(
  /// The content to convert.
  /// -> str | content
  it,
) = if type(it) == str {
  it
} else if it.has("text") {
  it.text
} else if it.has("children") {
  it.children.map(_plain).join()
} else if it.has("body") {
  _plain(it.body)
} else if it == [ ] {
  " "
} else {
  ""
}

/// Displays a date as "month year".
///
/// Month names are always in English: `datetime.display` is not localized yet (see
/// https://github.com/typst/typst/issues/2840). Pass the date as content to localize it in the meantime.
///
/// -> none | content
#let _date(
  /// The date to display.
  /// -> none | datetime | content
  date,
) = if type(date) == datetime { date.display("[month repr:long] [year]") } else { date }

/// Normalizes the abstracts to an array of dictionaries with `lang`, `body` and `keywords` keys.
///
/// -> array
#let _abstracts(
  /// A single abstract body, a dictionary with a `body` and optionally a `lang` and `keywords`, or an array of
  /// such dictionaries (e.g. one per language).
  /// -> none | content | dictionary | array
  abstract,
  /// The keywords of the document, used when an abstract has none of its own.
  /// -> array
  keywords,
) = {
  let normalize(it) = if type(it) == dictionary {
    assert("body" in it, message: "quire: abstract dictionaries must contain a 'body' key")
    (lang: none, keywords: keywords) + it
  } else {
    (lang: none, body: it, keywords: keywords)
  }

  if abstract == none { () } else if type(abstract) == array { abstract.map(normalize) } else { (normalize(abstract),) }
}
