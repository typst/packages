


// Functions for parsing and formatting names.
// The central data structure of this file is a "name-parts dictionary",
// whose keys are the parts of a name (family, given, ...).


// Parses the name lists for the given name-fields. Returns a reference dictionary
// that has been enriched with "parsed-X" fields, for all X in name-fields.
#let parse-reference-names(reference, name-fields) = {
  for field in name-fields {
    if field in reference.parsed_names {
      let parsed-names = reference.parsed_names.at(field)
      let lastname-first = parsed-names.map(it => it.family + "," + it.given).join(" ")
      reference.fields.insert("parsed-" + field, parsed-names)
      reference.fields.insert("sortstr-" + field, lastname-first)
      // sortstr fields are needed to perform efficient sorting on the "n" key
    } else {
      reference.fields.insert("parsed-" + field, none)
    }
  }

  return reference
}

/// Extracts the list of family names from the list of name-part dictionaries.
/// For instance, the `parsed-author` entry of the example in @fig:reference-dict
/// will be mapped to the array `("Bender", "Koller")`.
/// 
/// If `parsed-names` is `none`, the function returns `none`.
/// 
/// -> array | none
#let family-names(parsed-names) = {
  if parsed-names == none {
    none
  } else {
    parsed-names.map( it => it.at("family", default: none) )
  }
}

// Spells out a name-parts dictionary 
#let format-name(name-parts-dict, format-str: "{family}, {given}") = {
  let ret = format-str
  for (key, value) in name-parts-dict.pairs() {
    ret = ret.replace("{" + key + "}", value)

    // Citegeist inserts keys with empty strings as values into the 
    // name-parts dictionary; skip those.
    if value.len() > 0 {
      ret = ret.replace("{" + key.at(0) + "}", value.at(0))
    }
  }
  return ret
}

