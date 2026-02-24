// The show-authors function is heavily based on the one from pubmatter, licensed under MIT.

#let show-authors(
  size: 10pt,
  weight: "regular",
  show-affiliations: true,
  authors,
) = {
  // Allow to pass frontmatter as well
  let authors = if (type(authors) == dictionary and "authors" in authors) {authors.authors} else { authors }
  if authors.len() == 0 { return none }

    set text(size, weight: weight)
    authors.map(author => {
      text(size, weight: weight, author.name)
      if (show-affiliations and "affiliations" in author) {
        // text(size: 2.5pt, [~]) // Ensure this is not a linebreak
        if (type(author.affiliations) == str) {
          super(author.affiliations, size: .7*size)
        } else if (type(author.affiliations) == array) {
          super(author.affiliations.map((affiliation) => str(affiliation.index)).join(","), size: .7*size)
        }
      }
    }).join(", ")
}


#let show-affiliations(
  size: 10pt,
  style: "italic",
  super-style: "normal",
  separator: ", ",
  affiliations
  ) = {
  // Allow to pass frontmatter as well
  let fm = affiliations
  let affiliations = if (type(affiliations) == dictionary and "affiliations" in affiliations) {affiliations.affiliations} else { affiliations }
  if affiliations.len() == 0 { return none }

  set par(leading: 5pt)
  affiliations.map(affiliation => {
    set text(size, style: super-style)
    super(str(affiliation.index), size: .7*size)
    // text(size: 2.5pt, [~]) // Ensure this is not a linebreak
    set text(size, style: style)
    if ("name" in affiliation) {
      affiliation.name
    } else if ("institution" in affiliation) {
      affiliation.institution
    }
  }).join(separator)
}

#let show-copyright(body) = {
  footnote(numbering: _ => [])[#body]
  counter(footnote).update(n => n - 1)
}