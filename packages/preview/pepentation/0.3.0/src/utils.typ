/// Merges a user dictionary into a default dictionary.
///
/// Only keys present in the default dictionary are updated. Keys in `user-dict`
/// that are not in `default-dict` are ignored. If `user-dict` is `none`, the
/// default dictionary is returned unchanged.
///
/// # Parameters
/// - `default-dict` (dictionary): The default dictionary with all possible keys.
/// - `user-dict` (dictionary or none): The user-provided dictionary to merge.
///
/// # Returns
/// A new dictionary with user values merged into defaults.
#let merge-dictionary(default-dict, user-dict) = {
  if user-dict == none {
    return default-dict
  }
  let new-dict = default-dict
  for (key, value) in user-dict {
    if key in default-dict.keys() {
      new-dict.insert(key, value)
    }
  }
  return new-dict
}

/// Converts a value into its plain text representation.
///
/// Styles and invisible elements are dropped, so the result can be measured and
/// truncated reliably:
/// - `str` values are returned unchanged.
/// - `text` elements yield their raw text.
/// - Containers (`sequence`, `strong`, `emph`, ...) are traversed in order.
/// - `metadata` and labels yield nothing.
/// - Any other element yields nothing as well.
///
/// # Parameters
/// - `value` (any): The value to convert.
///
/// # Returns
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
    return parts.join("", default: "")
  }
  if value-type != content { return "" }
  if value.has("text") { return value.at("text") }
  if value.has("children") { return plain-text(value.at("children")) }
  if value.has("body") { return plain-text(value.at("body")) }
  if value.has("value") { return "" }
  ""
}

/// Splits a heading body into its title, its optional subtitle and its optional
/// header label.
///
/// Section slides built with `section-slide` store the subtitle as `metadata`
/// inside the heading body, together with the `<section-subtitle>` label, and a
/// section can carry a shorter label for the header in the same way:
///
/// ```typ
/// = Cargo и компилятор #metadata("17 минут")                  // subtitle
/// = Cargo и компилятор #metadata((header: "Cargo"))          // header label
/// ```
///
/// A section that should exist in the header and the table of contents without
/// taking a slide of its own says so with `section-slide: false`. Leaving the
/// title out of the heading then keeps the visible title empty:
///
/// ```typ
/// = #metadata((header: "Владение", section-slide: false))
/// ```
///
/// That metadata is not part of the visible title, so it is split off here to
/// keep title measurements accurate. A metadata element holding a dictionary is
/// read as a set of options, and one holding anything else is read as the
/// subtitle, which is the form `section-slide` uses. The read keys are
/// `header`, `subtitle` and `section-slide`; any other key is ignored, so
/// unrelated metadata keeps working. All of them are taken from the first
/// metadata element that supplies them, and a `none` value counts as "not set".
///
/// # Parameters
/// - `body` (content): The body of a heading.
///
/// # Returns
/// A dictionary with the keys:
/// - `title` (content): The heading body without any metadata.
/// - `subtitle` (any): The subtitle, or `none`.
/// - `header` (str or content): The label for the header, or `none`.
/// - `section-slide` (bool or none): `false` to leave out the section slide of
///   this heading, `true` or `none` to render it.
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
  // sequence keeps metadata from being silently dropped, which is what happened
  // to `= #metadata(..)` before.
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
/// A section can override that text with `metadata((header: ...))`, which keeps
/// long section titles out of the header without renaming the section itself:
/// the section slide and the table of contents still show the full title.
///
/// # Parameters
/// - `body` (content): The body of a heading.
///
/// # Returns
/// A string with the label for the header.
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

/// Returns the current date as a formatted string based on locale.
///
/// The date is formatted as "Month Year" (e.g., "January 2025" or "Январь 2025").
///
/// # Parameters
/// - `locale` (string): The locale code, either `"EN"` or `"RU"`.
///
/// # Returns
/// A formatted string containing the current month and year.
///
/// # Panics
/// Panics if `locale` is not `"EN"` or `"RU"`.
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

/// Merges nested dictionaries, including sub-dictionaries.
///
/// This function handles merging of nested dictionary structures, such as
/// theme dictionaries with a `blocks` sub-dictionary.
///
/// # Parameters
/// - `default-dict` (dictionary): The default dictionary with all possible keys.
/// - `user-dict` (dictionary or none): The user-provided dictionary to merge.
///
/// # Returns
/// A new dictionary with user values merged into defaults, including nested dictionaries.
#let merge-nested-dictionary(default-dict, user-dict) = {
  if user-dict == none {
    return default-dict
  }
  let new-dict = default-dict
  for (key, value) in user-dict {
    if key in default-dict.keys() {
      if type(default-dict.at(key)) == dictionary and type(value) == dictionary {
        new-dict.insert(key, merge-nested-dictionary(default-dict.at(key), value))
      } else {
        new-dict.insert(key, value)
      }
    }
  }
  return new-dict
}
