#import "languages.typ": *

#let validate-inputs(data, custom-data, data-type) = {
  if data != (:) and custom-data != [] {
    panic(data-type + " and custom-" + data-type + " cannot both be defined.")
  }

  if data == (:) and (custom-data == [] or custom-data == none) {
    panic("At least one " + data-type + " must be defined.")
  }

  if data != (:) {
    data
  } else {
    custom-data
  }
}

#let enumerate-affiliations(affiliations) = {
  let count = 1
  for affiliation in affiliations {
    affiliations.at(count - 1).insert("n", count)
    count += 1
  }

  return affiliations
}

#let is-multiple-authors-with-different-affiliations(authors, affiliations) = {
  let unique-affiliations = ()

  for author in authors {
    for author-affiliations in author.affiliations {
      if author-affiliations not in unique-affiliations {
        unique-affiliations.push(author-affiliations)
      }
    }
  }

  return unique-affiliations.len() > 1
}

#let print-authors-with-different-affiliations(authors, affiliations, language) = {
  affiliations = enumerate-affiliations(affiliations)

  let aff-positions = (:)
  for aff in affiliations {
    aff-positions.insert(aff.id, str(aff.n))
  }

  let author-strings = authors.map(author => {
    let aff-numbers = author.affiliations.map(aff => super[#aff-positions.at(aff)])
    [#author.name#aff-numbers.join(super[, ])]
  })

  if author-strings.len() == 2 {
    author-strings.join([ #context get-terms(language).and ])
  } else {
    author-strings.join([, ], last: [, #context get-terms(language).and ])
  }
}

#let print-authors(authors, affiliations, language) = {
  if type(authors) != content and type(authors) != str {
    if authors.len() == 1 {
      authors.at(0).name
    } else if is-multiple-authors-with-different-affiliations(authors, affiliations) {
      print-authors-with-different-affiliations(authors, affiliations, language)
    } else {
      let author-names = authors.map(it => it.name)
      if author-names.len() == 2 {
        author-names.join([ #context get-terms(language).and ])
      } else {
        author-names.join([, ], last: [, #context get-terms(language).and ])
      }
    }
  } else {
    authors
  }
}

#let print-affiliations(authors, affiliations) = {
  if type(affiliations) != content and type(affiliations) != str {
    if affiliations.len() == 1 {
      affiliations.at(0).name
    } else if is-multiple-authors-with-different-affiliations(authors, affiliations) {
      enumerate-affiliations(affiliations)
        .map(aff => [
            #super[#aff.n] #aff.name
            #parbreak()
          ])
        .join()
    } else {
      affiliations
        .map(aff => [
            #aff.name
            #parbreak()
          ])
        .join()
    }
  } else {
    affiliations
  }
}

