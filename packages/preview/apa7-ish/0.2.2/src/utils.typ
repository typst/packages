
// utility function: go through all authors and check their affiliations
// purpose is to group authors with the same affiliations
// returns a dict with two keys:
// "authors" (modified author array)
// "affiliations": array with unique affiliations
#let parse-authors(authors) = {
  let affiliations = ()
  let parsed-authors = ()
  let corresponding = ()
  let pos = 0
  for author in authors {
    author.insert("affiliation-parsed", ())
    if "affiliation" in author {
      if type(author.affiliation) == str {
        author.at("affiliation") = (author.affiliation,)
      }
      for affiliation in author.affiliation {
        if affiliation not in affiliations {
          affiliations.push(affiliation)
        }
        pos = affiliations.position(a => a == affiliation)
        author.affiliation-parsed.push(pos)
      }
    } else {
      // if author has no affiliation, just use the same as the previous author
      author.affiliations-parsed.push(pos)
    }
    parsed-authors.push(author)
    if "corresponding" in author {
      if author.corresponding {
        corresponding = author
      }
    }
  }
  (
    authors: parsed-authors,
    affiliations: affiliations,
    corresponding: corresponding,
  )
}

// utility function to turn a number into a letter
// simulates footnotes
#let number2letter(num) = {
  "abcdefghijklmnopqrstuvwxyz".at(num)
}

#let orcid(height: 10pt, o_id) = [
  #box(height: height, baseline: 10%, image("assets/orcid.svg")) #link("https://orcid.org/" + o_id)
]
