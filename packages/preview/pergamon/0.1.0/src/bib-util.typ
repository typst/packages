
// Concatenate an array of strings ("A", "B", "C") into "A, B, and C".
#let concatenate-list(names, options) = {
  let ret = names.at(0)

  for i in range(1, names.len()) {
    if type(names.at(i)) != dictionary { // no idea how it would be a dictionary
      if names.len() == 2 {
        ret = ret + options.list-end-delim-two + names.at(i)
      } else if i == names.len()-1 {
        ret = ret + options.list-end-delim-many + names.at(i)
      } else {
        ret = ret + options.list-middle-delim + names.at(i)
      }
    }
  }

  ret
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

