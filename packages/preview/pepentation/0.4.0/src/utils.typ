/// Merges `user-dict` into `default-dict`.
///
/// Every key of `user-dict` must exist in `default-dict`; an unknown key is a
/// mistake (usually a typo) and fails the build with a message listing the valid
/// keys, rather than being dropped silently. The result is a new dictionary, so
/// neither input is modified.
///
/// = Parameters
/// - `default-dict` (dictionary): The dictionary with all possible keys.
/// - `user-dict` (dictionary or none): The user values to merge.
/// - `owner` (string or none): The configuration the keys come from, used in the
///   error message.
///
/// = Returns
/// A new dictionary with user values merged into the defaults.
#let merge-dictionary(default-dict, user-dict, owner: none) = {
  if user-dict == none {
    return default-dict
  }
  let unknown = user-dict.keys().filter(key => key not in default-dict.keys())
  if unknown.len() > 0 {
    panic(
      "pepentation: unknown key"
        + (if unknown.len() == 1 { " " } else { "s " })
        + unknown.map(repr).join(", ")
        + (if owner == none { "" } else { " in " + owner })
        + "; valid keys: " + default-dict.keys().join(", "),
    )
  }
  let merged = (:)
  for (key, value) in default-dict {
    merged.insert(key, value)
  }
  for (key, value) in user-dict {
    if key in default-dict.keys() {
      merged.insert(key, value)
    }
  }
  merged
}

/// Joins `items` with `separator`, returning `""` for an empty array.
///
/// `array.join` gained its `default` parameter only in Typst 0.14, and joining
/// an empty array without it yields `none`, which leaks into callers that
/// expect text. This stays within the compiler version the package declares.
///
/// = Parameters
/// - `items` (array): The items to join.
/// - `separator` (str): The text placed between the items.
///
/// = Returns
/// The joined string, or `""` if `items` is empty.
#let join-or-empty(items, separator) = {
  if items.len() == 0 { "" } else { items.join(separator) }
}

/// Returns the plain text of `value`.
///
/// Strings are returned as-is and numbers are stringified. Containers
/// (`sequence`, `strong`, `emph`, …) are traversed in order, while `metadata`,
/// labels and any other element contribute nothing.
///
/// = Parameters
/// - `value` (any): The value to convert.
///
/// = Returns
/// A string with the plain text of `value`.
#let plain-text(value) = {
  if value == none { return "" }
  let value-type = type(value)
  if value-type == str { return value }
  if value-type == int or value-type == float { return str(value) }
  if value-type == array {
    let parts = ()
    for item in value {
      // Typst stores the space between two inline elements as an empty
      // sequence, so it has to be mapped explicitly.
      parts.push(if item == none or item == [ ] { " " } else { plain-text(item) })
    }
    // An empty array joins to `none` instead of an empty string, which would
    // leak a `none` into every caller that expects text.
    return join-or-empty(parts, "")
  }
  if value-type != content { return "" }
  if value.has("text") { return value.at("text") }
  if value.has("children") { return plain-text(value.at("children")) }
  if value.has("body") { return plain-text(value.at("body")) }
  if value.has("value") { return "" }
  ""
}

/// Splits a heading body into its title, subtitle, header label and
/// `section-slide` flag.
///
/// A section slide stores its subtitle as `metadata` inside the heading body,
/// and a section can carry a shorter header label or opt out of its own slide
/// the same way. That metadata is not part of the visible title, so it is
/// stripped here to keep title measurements accurate. A metadata element
/// holding a dictionary is read as options, one holding anything else as the
/// subtitle, and a `none` value counts as unset.
///
/// = Parameters
/// - `body` (content): The body of a heading.
///
/// = Returns
/// A dictionary with the keys:
/// - `title` (content): The heading body without its metadata.
/// - `subtitle` (any): The subtitle, or `none`.
/// - `header` (str or content): The label for the header, or `none`.
/// - `section-slide` (bool or none): `false` to omit the section slide.
#let heading-parts(body) = {
  let title = []
  let subtitle = none
  let header = none
  let section-slide = none
  if body == none {
    return (
      title: [],
      subtitle: subtitle,
      header: header,
      section-slide: section-slide,
    )
  }
  // A content block holding nothing but one element collapses into that
  // element, so a heading that carries only metadata arrives as the metadata
  // element itself and has no children to walk. Treating it as a one-element
  // sequence keeps metadata from being silently dropped.
  let children = if type(body) == content and body.has("children") {
    body.at("children")
  } else if type(body) == content and body.has("value") {
    (body,)
  } else {
    title += body
    ()
  }
  for child in children {
    if child != none and child != [ ] and child.has("value") {
      let value = child.at("value")
      if type(value) == dictionary {
        if header == none and "header" in value and value.at("header") != none {
          let label = value.at("header")
          assert(
            type(label) == str or type(label) == content,
            message: "section metadata \"header\" must be a string or content, got "
              + repr(type(label)),
          )
          assert(
            plain-text(label).trim() != "",
            message: "section metadata \"header\" must not be empty",
          )
          header = label
        }
        if subtitle == none and "subtitle" in value {
          let value-subtitle = value.at("subtitle")
          if value-subtitle != none { subtitle = value-subtitle }
        }
        if section-slide == none and "section-slide" in value {
          let value-slide = value.at("section-slide")
          if value-slide != none {
            assert(
              type(value-slide) == bool,
              message: "section metadata \"section-slide\" must be a boolean, got "
                + repr(type(value-slide)),
            )
            section-slide = value-slide
          }
        }
      } else if subtitle == none {
        subtitle = value
      }
    } else {
      title += child
    }
  }
  (title: title, subtitle: subtitle, header: header, section-slide: section-slide)
}

/// Returns the text a section contributes to the header.
///
/// A section can override that text with `metadata((header: …))`; otherwise its
/// full title is used. The section slide and the table of contents always show
/// the full title.
///
/// = Parameters
/// - `body` (content): The body of a heading.
///
/// = Returns
/// The header label.
#let heading-title(body) = {
  let parts = heading-parts(body)
  if parts.header != none {
    plain-text(parts.header).trim()
  } else {
    // The metadata of a labelled section is cut out of the title, which leaves
    // the surrounding spaces behind, so the result is trimmed as well.
    plain-text(parts.title).trim()
  }
}

/// Returns the current month and year, formatted for `locale`.
///
/// = Parameters
/// - `locale` (string): The locale code, `"EN"` or `"RU"`.
///
/// = Returns
/// A formatted month and year.
///
/// = Panics
/// Panics if `locale` is neither `"EN"` nor `"RU"`.
#let today(locale) = {
  assert(locale in ("RU", "EN"), message: "Locale must be 'RU' or 'EN'")

  let now = datetime.today()
  let month-idx = now.month() - 1

  let months = if locale == "RU" {
    ("Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь")
  } else {
    ("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")
  }

  [#months.at(month-idx) #now.year()]
}

/// Merges `user-dict` into `default-dict`, recursing into nested dictionaries.
///
/// Every key of `user-dict`, at every level, must exist in `default-dict`; an
/// unknown key fails the build with a message naming the dotted path it came
/// from. The result is a new dictionary, so `default-dict` and its nested
/// dictionaries are never modified.
///
/// = Parameters
/// - `default-dict` (dictionary): The dictionary with all possible keys.
/// - `user-dict` (dictionary or none): The user values to merge.
/// - `owner` (string or none): The configuration the keys come from, used in the
///   error message.
/// - `prefix` (string, default: `""`): The dotted path built up while recursing.
///
/// = Returns
/// A new dictionary with user values merged into the defaults, including nested
/// dictionaries.
#let merge-nested-dictionary(default-dict, user-dict, owner: none, prefix: "") = {
  if user-dict == none {
    return default-dict
  }
  let unknown = user-dict.keys().filter(key => key not in default-dict.keys())
  if unknown.len() > 0 {
    let location = if owner == none { prefix } else if prefix == "" { owner } else { owner + "." + prefix }
    panic(
      "pepentation: unknown key"
        + (if unknown.len() == 1 { " " } else { "s " })
        + unknown.map(repr).join(", ")
        + (if location == "" { "" } else { " in " + location })
        + "; valid keys: " + default-dict.keys().join(", "),
    )
  }
  let merged = (:)
  for (key, value) in default-dict {
    if key in user-dict {
      let user-value = user-dict.at(key)
      if type(value) == dictionary and type(user-value) == dictionary {
        merged.insert(
          key,
          merge-nested-dictionary(
            value,
            user-value,
            owner: owner,
            prefix: if prefix == "" { key } else { prefix + "." + key },
          ),
        )
      } else {
        merged.insert(key, user-value)
      }
    } else {
      merged.insert(key, value)
    }
  }
  merged
}
