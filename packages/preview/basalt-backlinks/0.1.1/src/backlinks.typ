#let package-name = "basalt-backlinks"
#let package-uuid = "8cfa7814-461b-4cd7-8779-8e8b334e3b95"
#let prefix = package-name + ":" + package-uuid + ":"

/// Show rule for generating backlinks.
///
/// #show: backlinks.generate
#let generate(body) = {
  show link: it => {
    if type(it.dest) != label {
      return it
    }

    it
    [
      #metadata(it.body)
      #label(prefix + str(it.dest))
    ]
  }
  body
}

/// Get an array of the locations of links
/// that point to a given label.
///
/// Requires context.
#let get(target) = {
  query(label(prefix + str(target)))
}
