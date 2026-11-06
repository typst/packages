/// folio resolve utilities
/// _walk, resolve, nonempty, get-title
#import "fallback.typ": missing

/// Private: walk a dot-separated path through a nested dict.
/// Returns (found: bool, value: any)
#let _walk(data, path) = {
  let current = data
  for p in path.split(".") {
    if type(current) == dictionary and p in current {
      current = current.at(p)
    } else {
      return (found: false, value: none)
    }
  }
  (found: true, value: current)
}

/// Resolve a dot-path from data, returning missing() placeholder on failure.
#let resolve(data, path, fallback-name: none) = {
  let r = _walk(data, path)
  if not r.found or r.value == none or r.value == "" {
    return missing(if fallback-name != none { fallback-name } else { path })
  }
  r.value
}

/// Return true if data has a non-empty value at the given dot-path.
#let nonempty(data, path) = {
  let r = _walk(data, path)
  if not r.found or r.value == none or r.value == "" { return false }
  if type(r.value) == array and r.value.len() == 0 { return false }
  if type(r.value) == dictionary and r.value.pairs().len() == 0 { return false }
  true
}

/// Get a title string from data at path, falling back to default-title.
#let get-title(data, path, default-title) = {
  let r = _walk(data, path)
  if not r.found { return default-title }
  if type(r.value) == str { return r.value }
  if type(r.value) == dictionary and "title" in r.value { return r.value.title }
  default-title
}
