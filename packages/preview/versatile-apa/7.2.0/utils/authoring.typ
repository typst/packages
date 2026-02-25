#import "languages.typ": get-terms

// Normalize authors to a standard format
#let normalize-authors(authors) = {
  // Handle none -> return none as is
  if authors == none {
    return none
  }

  // Handle content/string -> single author
  if type(authors) == content or type(authors) == str {
    return (authors,)
  }

  // Handle array
  if type(authors) == array {
    // Empty array -> empty result
    if authors.len() == 0 {
      return ()
    }

    // Single element -> normalize to single author
    if authors.len() == 1 {
      let author = authors.at(0)
      if type(author) == content or type(author) == str {
        return (author,)
      }
      // Keep complex author structure
      return (author,)
    }

    // Multiple elements -> return as is
    return authors
  }

  // Handle dictionary
  if type(authors) == dictionary {
    // Single key -> normalize to single author
    if authors.keys().len() == 1 {
      let key = authors.keys().at(0)
      return (authors.at(key),)
    }
    // Multiple keys -> return as is
    return authors
  }

  return authors
}

// Normalize affiliations to a standard format
#let normalize-affiliations(affiliations) = {
  // Handle none -> return none as is
  if affiliations == none {
    return none
  }

  // Handle content/string -> single affiliation (no ID)
  if type(affiliations) == content or type(affiliations) == str {
    return (affiliations,)
  }

  // Handle dictionary -> convert to internal format with IDs
  if type(affiliations) == dictionary {
    if affiliations.keys().len() == 0 {
      return ()
    }

    // Single key -> normalize to single affiliation
    if affiliations.keys().len() == 1 {
      let key = affiliations.keys().at(0)
      return ((id: key, name: affiliations.at(key)),)
    }

    // Multiple keys -> convert all to internal format
    return affiliations.keys().map(key => (id: key, name: affiliations.at(key)))
  }

  // Arrays are NO LONGER supported for affiliations
  // Only dictionary format ("ID": [name]) or simple content/string
  panic("Affiliations must be a dictionary with format (\"ID\": [name], ...) or a single content/string value")
}

// Check if all items are simple (content or string)
#let all-simple(items) = {
  if type(items) != array {
    return type(items) == content or type(items) == str
  }

  for item in items {
    if type(item) != content and type(item) != str {
      return false
    }
  }
  return true
}

// Assign affiliations by index when both are lists of same length
#let assign-affiliations-by-index(authors, affiliations) = {
  let result = ()

  for i in range(authors.len()) {
    let author = authors.at(i)
    let aff = affiliations.at(i)

    // If affiliation is a sublist, assign all of them
    let author-affs = if type(aff) == array {
      aff
    } else {
      (aff,)
    }

    result.push((
      name: author,
      affiliations: author-affs,
    ))
  }

  return result
}

// Convert content/value to string key for comparison
#let to-key(value) = {
  if type(value) == dictionary and "id" in value {
    return value.id
  } else if type(value) == content {
    return repr(value)
  } else if type(value) == str {
    return value
  } else {
    return repr(value)
  }
}

// Check if authors have different affiliations
#let has-different-affiliations(authors) = {
  if type(authors) != array or authors.len() <= 1 {
    return false
  }

  // Check if it's complex structure with affiliations
  let first = authors.at(0)
  if type(first) != dictionary {
    return false
  }

  let unique-affiliations = ()
  for author in authors {
    // Skip authors without affiliations
    if "affiliations" not in author {
      continue
    }

    // Normalize to array if single value
    let author-affs = if type(author.affiliations) == array {
      author.affiliations
    } else {
      (author.affiliations,)
    }

    for aff in author-affs {
      let aff-id = to-key(aff)

      if aff-id not in unique-affiliations {
        unique-affiliations.push(aff-id)
      }
    }
  }

  return unique-affiliations.len() > 1
}

// Enumerate affiliations for display
#let enumerate-affiliations(affiliations) = {
  let result = ()
  let count = 1

  for affiliation in affiliations {
    if type(affiliation) == dictionary and "id" in affiliation {
      // Already has an ID, just add enumeration
      let aff-copy = affiliation
      aff-copy.insert("n", count)
      result.push(aff-copy)
    } else if type(affiliation) == dictionary and "name" in affiliation {
      // Has name but no ID (shouldn't happen with new schema, but handle it)
      let aff-copy = affiliation
      aff-copy.insert("n", count)
      result.push(aff-copy)
    } else {
      // Simple content/string affiliation without ID
      result.push((name: affiliation, n: count))
    }
    count += 1
  }

  return result
}

// Print authors with affiliation superscripts
#let print-authors-with-superscripts(authors, affiliations, language, script) = {
  let enumerated-affs = enumerate-affiliations(affiliations)

  let aff-positions = (:)
  for aff in enumerated-affs {
    let key = to-key(aff)
    aff-positions.insert(key, str(aff.n))
  }

  let author-strings = authors.map(author => {
    let name = if type(author) == dictionary { author.name } else { author }

    // Handle authors without affiliations
    if type(author) != dictionary or "affiliations" not in author {
      return name
    }

    // Normalize affiliations to array if it's a single value
    let affs = if type(author.affiliations) == array {
      author.affiliations
    } else {
      (author.affiliations,)
    }

    let aff-numbers = affs.map(aff => {
      let key = to-key(aff)
      super[#aff-positions.at(key)]
    })

    if aff-numbers.len() > 0 {
      [#name#aff-numbers.join(super[, ])]
    } else {
      name
    }
  })

  if author-strings.len() == 2 {
    author-strings.join([ #context get-terms(language, script).and ])
  } else {
    author-strings.join([, ], last: [, #context get-terms(language, script).and ])
  }
}

// Main function to print authors
#let print-authors(authors, affiliations, language, script) = {
  // Handle none early - just return it as content
  if authors == none {
    return none
  }

  let norm-authors = normalize-authors(authors)
  let norm-affiliations = normalize-affiliations(affiliations)

  // Single author case (content/string)
  if norm-authors.len() == 1 and all-simple(norm-authors) {
    return norm-authors.at(0)
  }

  // Multiple simple authors (all content/string)
  if all-simple(norm-authors) {
    // Both are arrays of same length - this means shared affiliations
    // The case of index-based assignment is removed as requested

    // All authors share same affiliation(s)
    let author-names = norm-authors
    if author-names.len() == 2 {
      author-names.join([ #context get-terms(language, script).and ])
    } else {
      author-names.join([, ], last: [, #context get-terms(language, script).and ])
    }
  } else {
    // Complex structure - check if different affiliations
    if has-different-affiliations(norm-authors) {
      print-authors-with-superscripts(norm-authors, norm-affiliations, language, script)
    } else {
      // Same affiliation(s) for all
      let author-names = norm-authors.map(it => {
        if type(it) == dictionary { it.name } else { it }
      })
      if author-names.len() == 2 {
        author-names.join([ #context get-terms(language, script).and ])
      } else {
        author-names.join([, ], last: [, #context get-terms(language, script).and ])
      }
    }
  }
}

// Main function to print affiliations
#let print-affiliations(authors, affiliations) = {
  // Handle none early - just return it as content
  if affiliations == none {
    return none
  }

  let norm-affiliations = normalize-affiliations(affiliations)

  // Single affiliation (content/string)
  if norm-affiliations.len() == 1 and all-simple(norm-affiliations) {
    return norm-affiliations.at(0)
  }

  let norm-authors = normalize-authors(authors)

  // Check if we need enumeration
  if has-different-affiliations(norm-authors) {
    enumerate-affiliations(norm-affiliations)
      .map(aff => {
        let name = if type(aff) == dictionary { aff.name } else { aff }
        [#super[#aff.n] #name#parbreak()]
      })
      .join()
  } else {
    // No enumeration needed
    norm-affiliations
      .map(aff => {
        let name = if type(aff) == dictionary { aff.name } else { aff }
        [#name#parbreak()]
      })
      .join()
  }
}
