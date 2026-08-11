/// Merges two dictionaries recursively.
#let merge-dicts(dict-a, base: (:)) = {
  let res = base
  for (key, val) in dict-a {
    if type(val) == dictionary and type(res.at(key, default: none)) == dictionary {
      res.insert(key, merge-dicts(val, base: res.at(key)))
    }
    else {
      res.insert(key, val)
    }
  }
  return res
}

/// Extracts plain text from Typst content.
#let extract-text(body) = {
  if body == none { return "" }
  let t = type(body)
  if t == str {
    return body
  } else if t != content {
    return str(body)
  }

  if body.has("text") {
    return body.text
  }

  let f = body.func()
  let name = repr(f)
  if name == "space" {
    return " "
  } else if name == "linebreak" {
    return "\n"
  } else if name == "smartquote" {
    return if body.double { "\"" } else { "'" }
  } else if body.has("body") {
    return extract-text(body.body)
  } else if body.has("children") {
    return body.children.map(extract-text).join("")
  } else if body.has("value") {
    return str(body.value)
  } else {
    return ""
  }
}

/// Truncates text to a maximum length and adds an ellipsis if needed.
#let truncate-text(text-str, max-length) = {
  if max-length == none or text-str.clusters().len() <= max-length {
    return text-str
  }
  return text-str.clusters().slice(0, max-length).join("") + "…"
}

/// Resolves the final body content for a heading based on priority:
/// 1. Short title (if enabled and present)
/// 2. Original title
/// 3. Truncation (if max-length is set)
#let resolve-body(original-body, short-title: none, use-short-title: true, max-length: none) = {
  let body = original-body
  if use-short-title and short-title != none {
    body = short-title
  }
  
  if max-length != none {
    body = truncate-text(extract-text(body), max-length)
  }
  
  return body
}


/// Standardized slide title component (visual only, no heading)
#let slide-title(content, size: 1.2em, weight: "bold", color: black, inset: (bottom: 0.8em)) = {
  if content == none { return none }
  block(
    width: 100%, 
    inset: inset, 
    text(size: size, weight: weight, fill: color, content)
  )
}
