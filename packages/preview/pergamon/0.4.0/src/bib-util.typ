
#import "bibstrings.typ": default-bibstring

#let matches-completely(s, re) = {
  let result = s.match(re)

  if result == none {
    return false
  } else {
    // [#result]
    result.start == 0 and result.end == s.len()
  }
}


// Checks whether a string can be converted into an int
#let is-integer(s) = {
  // s = s.trim()

  // TODO: allow negative numbers at some point
  matches-completely(s.trim(), regex("\d+"))
}


/// Concatenates an array of names. If there is only one name, it is returned
/// unmodified. If there are two names, they are concatenated with the
/// value `options.list-end-delim-two` ("and"). If there are three names, they
/// are concatenated with the value `options.list-end-delim-two` (", "), except
/// the last name is joined with `options.list-end-delim-many` (", and").
/// 
/// -> str | content
#let concatenate-names(
  /// An array of names. Each name can a string or content. If the names are strings,
  /// the function will return a string; if at least one name is content, the
  /// function will return content.
  /// 
  /// -> array
  names, 

  /// Options that control the concatenation. `concatenate-names` defines reasonable
  /// default options for `list-end-delim-two`,
  /// `list-end-delim-two`, `list-end-delim-many`, and `bibstring`.
  /// You can override these options by passing them in a dictionary here.
  /// 
  /// -> dictionary
  options: (:), 

  /// Maximum number of names that is displayed before the name list is truncated
  /// with "et al." See the `maxnames` parameter in @format-reference for details.
  maxnames: 2, 

  /// Minimum number of names that is guaranteed to be displayed. See the `minnames`
  /// parameter in @format-reference for details.
  minnames: 1
  ) = {
  let etal = names.len() > maxnames and names.len() > minnames // print "et al.", at least one name dropped
  let num-names = if etal { calc.min(minnames, names.len()) } else { names.len() } // #names that will be printed
  let options = (list-end-delim-two: " and ", list-middle-delim: ", ", list-end-delim-many: ", and ", bibstring: default-bibstring) + options

  if etal {
    let nn = names.slice(0, num-names).join(options.list-middle-delim)
    nn + " " + options.bibstring.andothers
  } else {
    if names.len() == 1 {
      names.at(0)
    } else if names.len() == 2 {
      names.at(0) + options.list-end-delim-two + names.at(1)
    } else {
      names.join(options.list-middle-delim, last: options.list-end-delim-many)
    }
  }
}


// Map "modern" Biblatex field names to legacy field names as they
// might appear in the bib file. Should be complete, as per biblatex.def
#let field-aliases = (
  "journaltitle": "journal",
  "langid": "hyphenation",
  "location": "address",
  "institution": "school",
  "annotation": "annote",
  "eprinttype": "archiveprefix",
  "eprintclass": "primaryclass",
  "sortkey": "key",
  "file": "pdf"
)


// Map legacy Bibtex entry types to their "modern" Biblatex names.
#let type-aliases = (
  "conference": reference => { reference.insert("entry_type", "inproceedings"); return reference },
  "electronic": reference => { reference.insert("entry_type", "online"); return reference },
  "www": reference => { reference.insert("entry_type", "online"); return reference },
  "mastersthesis": reference => { 
    reference.insert("entry_type", "thesis")
    if not "type" in reference.fields {
      reference.fields.insert("type", "mathesis")
    }
    return reference
  },
  "phdthesis": reference => { 
    reference.insert("entry_type", "thesis")
    if not "type" in reference.fields {
      reference.fields.insert("type", "phdthesis")
    }
    return reference
  },
  "techreport": reference => { 
    reference.insert("entry_type", "report")
    reference.fields.insert("type", "techreport")
    return reference
  },
)



#let fd(reference, field, options, format: x => x) = {
  let legacy-field = field-aliases.at(field, default: "dummy-field-name")
  
  if field in options.at("suppressed-fields", default: ()) {
    return none
  } else if field in reference.fields {
    return format(reference.fields.at(field))
  } else if legacy-field in reference.fields {
    return format(reference.fields.at(legacy-field))
  } else {
    return none
  }
}


#let ifdef(reference, field, options, fn) = {
  let value = fd(reference, field, options)

  if value == none { none } else { fn(value) }
}

// Convert an array of (key, value) pairs into a "multimap":
// a dictionary in which each key is assigned to an array of all
// the values with which it appeared.
// 
// Example: (("a", 1), ("a", 2), ("b", 3)) -> (a: (1, 2), b: (3,))
#let collect-deduplicate(pairs) = {
  let ret = (:)

  for (key, value) in pairs {
    if key in ret {
      ret.at(key).push(value)
    } else {
      ret.insert(key, (value,))
    }
  }

  return ret
}


/// Wraps a function in `none`-handling code. 
/// `nn(func)` is a function that
/// behaves like `func` on arguments that are not `none`,
/// but if the argument is `none`, it simply returns `none`.
/// Only works for functions `func` that have a single argument.
/// -> function
#let nn(func) = {
  it => if it == none { none } else { func(it) }
}



