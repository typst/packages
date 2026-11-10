// For now a static value. In the future we might be smarter to automatically
// support languages with other syntax (OCaml, C++, ...)
#let _default-pattern = "# | %key: %value"

// A regex that matches every character that is special in a regex
#let _metachar-regex = regex(`[.*+?|(){}^$\[\]\\]`.text)
// A function that replaces a special regex character by its escaped version
#let _escape-metachar(match) = "\\" + match.text

// Parse a header pattern string and return a regex for finding a cell header
// line and extracting key and value.
#let _header-regex-from-string(pat) = {
  // Escape every special character from the pattern string
  let escaped = pat.replace(_metachar-regex, _escape-metachar)

  // Translate the pattern to a regular expression with capture groups
  let translated = escaped
      .replace(regex("\\s+"), "\\s*") // space means any number of spaces
      .replace("%key", "(.*?)", count: 1) // key capture group
      .replace("%value", "(.*?)", count: 1) // value capture group

  // Require the header to start the line, but allow trailing spaces
  return regex("^" + translated + "\\s*$")
}

// Get header regex from cell-header-pattern setting (a regex that matches a
// header line).
#let _regex(pat) = {
  if type(pat) == dictionary {
    let regx = pat.at("regex", default: none)
    if regx == none {
      // Regex that matches nothing
      return regex("[^\s\S]")
    }
    if type(regx) != regex {
      panic("cell header pattern regex must be a regex value or none")
    }
    return regx
  }
  // pat is a string
  return _header-regex-from-string(pat) 
}

// Get a header writer function from cell-header-pattern setting
// (a function that takes key and value strings and returns a header line
// without trailing newline).
#let _writer(pat) = {
  if type(pat) == dictionary {
    let writer = pat.at("writer", default: none)
    if type(writer) not in (function, type(none)) {
      panic("cell header pattern writer must be a function or none")
    }
    // Can be none
    return writer
  }
  // pat is a string
  return (key, value) => pat
    .replace("%key", key, count: 1)
    .replace("%value", value, count: 1)
}

#let resolve(pat) = {
  // Validate pattern
  let type-ok = type(pat) in (type(auto), type(none), str, dictionary)
  let keys-ok = type(pat) != dictionary or pat.keys().all(
    k => k in ("regex", "writer"))
  if not (type-ok and keys-ok) {
    panic("cell header pattern must be a string, a dict with fields 'regex' " +
      "and/or 'writer', or auto or none")
  }

  if pat == auto {
    pat = _default-pattern
  }

  if pat == none {
    pat = (regex: none, writer: none)
  }

  return (
    regex: _regex(pat),
    writer: _writer(pat),
  )
}

// Build a cell header string for the given dict, based on the given pattern
#let make-text(header-dict, pattern: none) = {
  if header-dict == none {
    return none
  }
  if type(header-dict) != dictionary {
    panic("cell header must be a dict or none")
  }
  // Build header
  let header = none
  let header-writer = resolve(pattern).writer
  if header-writer == none {
    panic("cell header pattern writer not specified")
  }
  for (k, v) in header-dict {
    if type(v) != str {
      panic("cell header has key " + k + " of type " + type(v) +
        " but only strings are supported")
    }
    header += header-writer(k, v) + "\n"
  }
  return header
}

// Parse the given cell source text to find the header and convert it to a
// dictionary. The returned value is a dict with `header` field holding header
// dict and `code` field holding the rest of the cell source as a string.
#let parse-text(cell-source, pattern: none) = {
  let header-regex = resolve(pattern).regex
  if header-regex == none {
    return (header: (:), code: cell-source)
  }
  let header = (:)
  let lines = cell-source.split("\n")
  for line in lines {
    let m = line.match(header-regex)
    if m == none {
      break
    }
    let (key, value) = m.captures
    header.insert(key, value)
  }
  let code-lines = lines.slice(header.len())
  return (header: header, code: code-lines.join("\n"))
}
