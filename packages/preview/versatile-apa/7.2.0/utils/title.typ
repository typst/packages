#import "languages.typ": get-terms
#import "authoring.typ": print-affiliations, print-authors
#import "constants.typ": double-spacing, first-indent-length
#import "to-string.typ": to-string

#let title-page(
  title: none,
  authors: none,
  affiliations: none,
  course: none,
  instructor: none,
  due-date: none,
  author-note: none,
) = context {
  set document(
    author: if type(authors) == array and authors.len() > 0 and type(authors.at(0)) == dictionary {
      authors.map(it => to-string[#it.name]).join(", ")
    } else if type(authors) == array {
      authors.map(it => to-string[#it]).join(", ")
    } else {
      to-string[#authors].trim()
    },
  ) if authors != none
  set document(
    title: title,
  ) if title != none

  for i in range(4) {
    [~] + parbreak()
  }

  std.title()

  [~]

  parbreak()

  set align(center)
  print-authors(authors, affiliations, text.lang, text.script)
  parbreak()
  print-affiliations(authors, affiliations)
  parbreak()
  parbreak()
  course
  parbreak()
  instructor
  parbreak()
  due-date

  if author-note == none {
    pagebreak(weak: true)
    return
  }

  v(1fr)

  strong(context get-terms(text.lang, text.script).at("Author Note"))
  set align(left)
  set par(first-line-indent: first-indent-length)
  author-note

  pagebreak(weak: true)
}
