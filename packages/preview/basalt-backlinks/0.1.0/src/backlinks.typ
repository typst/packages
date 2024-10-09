#let package-name = "basalt-backlinks"
#let package-uuid = "8cfa7814-461b-4cd7-8779-8e8b334e3b95"
#let prefix = package-uuid + ":" + package-name + ":"

/// Show rule for generating backlinks.
///
/// #show link: backlinks.generate
#let generate(it) = {
  if type(it.dest) != label {
    return it
  }

  let target = str(it.dest)
  return [
    #it
    #metadata(it.body)
    #label(prefix + target)
  ]
}

/// Get an array of the locations of links
/// that point to a given label.
///
/// Requires context.
#let get(target) = {
  query(label(prefix + str(target)))
}
