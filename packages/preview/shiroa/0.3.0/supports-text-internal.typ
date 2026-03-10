

/// Collects text content of element recursively into a single string
#let converter(it, limit) = {
  if limit <= 0 or it == none or it == [] { return "" }
  if it == [ ] { return converter(" ", limit) }

  if type(it) == str {
    let s-len = it.clusters().len()
    if s-len > limit {
      return it.clusters().slice(0, limit).join()
    } else {
      return it
    }
  }

  if it.has("text") {
    return converter(it.text, limit)
  } else if it.has("child") {
    return converter(it.child, limit)
  } else if it.has("body") {
    return converter(it.body, limit)
  } else if it.has("children") {
    let parts = ()
    let current-limit = limit
    for child in it.children {
      let fragment = converter(child, current-limit)
      let fragment-len = fragment.clusters().len()

      if fragment-len > 0 {
        parts.push(fragment)
        current-limit -= fragment-len
      }
      if current-limit <= 0 { break }
    }
    // The loop logic ensures the length, so just join and return.
    return parts.join()
  }

  let f = it.func()
  let candidate = if f == smartquote {
    if it.double {
      "\""
    } else {
      "'"
    }
  } else if f == parbreak {
    "\n\n"
  } else if f == linebreak {
    "\n"
  } else if f == image and it.has("alt") and it.alt != none {
    it.alt
  } else {
    ""
  }

  return converter(candidate, limit)
}

/// Converts the content to plain text
///
/// - it (content): The content to convert
/// - limit (integer): The maximum length of the text
/// -> string
#let plain-text(it, limit: none) = {
  let effective-limit = if limit == none {
    9223372036854775807 /* integer max (2^63 - 1) */
  } else { limit }

  let res = converter(it, effective-limit)
  if limit != none {
    assert(res.clusters().len() <= limit, message: "plain-text length limit exceeded")
  }
  return res
}
