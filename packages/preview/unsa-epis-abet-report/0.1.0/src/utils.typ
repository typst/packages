// =============================================================================
// src/utils.typ: Pure utility and normalization helper functions
// =============================================================================

/// Internal cache of the content space element function (Typst standard library
/// does not expose `space` as a top-level binding).
#let space = [ ].func()

/// Builds styled content with font size, weight, alignment, and color.
///
/// - content (content, str): The text or content to style.
/// - weight (str): Font weight (e.g., "regular", "bold").
/// - size (length): Font size.
/// - align-to (alignment, none): Optional alignment.
/// - color (color): Text fill color.
/// -> content
#let font-build(
  content,
  weight: "regular",
  size: 10pt,
  align-to: none,
  color: black,
) = {
  set text(size: size, weight: weight, fill: color)
  if align-to != none {
    align(align-to)[#content]
  } else {
    content
  }
}

/// Extracts uppercase letters from a string as an abbreviation.
///
/// - w (str): Input string.
/// -> str
#let abbreviate-by-caps(w) = {
  let chars = w.clusters()
  let caps = chars.filter(c => c == upper(c) and c != lower(c))
  caps.join("", default: "")
}

/// Abbreviates a full name in the format "FirstSurname, FirstName".
///
/// - name (str): Full name string.
/// -> str
#let abbreviate-full-name(name) = {
  let parts = name.trim().split(" ").filter(p => p != "")
  if parts.len() >= 3 {
    parts.at(0) + ", " + parts.at(2)
  } else {
    parts.join(" ", default: "")
  }
}

/// Safely extracts plain text representation from content, strings, dates, or other values.
///
/// Useful for PDF document metadata (title, author) and formatting where plain string is required.
///
/// - val (any): The value to convert to a plain string.
/// -> str
#let to-plain-string(val) = {
  if val == none {
    ""
  } else if type(val) == str {
    val
  } else if type(val) in (int, float) {
    str(val)
  } else if type(val) == datetime {
    val.display("[day]/[month]/[year]")
  } else if type(val) == content {
    if val.has("text") {
      val.text
    } else if val.has("children") {
      val.children.map(to-plain-string).join("", default: "")
    } else if val.has("body") {
      to-plain-string(val.body)
    } else if val.has("child") {
      to-plain-string(val.child)
    } else if val.func() == space {
      " "
    } else if val.func() in (parbreak, linebreak) {
      "\n"
    } else {
      ""
    }
  } else if type(val) == array {
    val.map(to-plain-string).filter(s => s != "").join(", ", default: "")
  } else if type(val) == dictionary {
    if "name" in val {
      to-plain-string(val.name)
    } else {
      ""
    }
  } else {
    repr(val)
  }
}

/// Normalizes color values from string or color type into standard Typst color.
///
/// - c (color, str): Input color representation.
/// -> color
#let normalize-color(c) = {
  if type(c) == str {
    rgb(c)
  } else {
    c
  }
}

/// Resolves presentation date according to date format or auto values.
///
/// - date (datetime, str, content, none, auto): Input date.
/// - format (str): Display format for datetime values.
/// -> str, content
#let resolve-date(date, format) = {
  if date == auto {
    datetime.today().display(format)
  } else if type(date) == datetime {
    date.display(format)
  } else if type(date) == str or type(date) == content {
    date
  } else if date == none {
    "—"
  } else {
    to-plain-string(date)
  }
}

/// Resolves presentation time from parameter, sys.inputs, or datetime.
///
/// - time (str, datetime, content, none, auto): Time parameter.
/// - date (datetime, any): Date reference to query hour if present.
/// -> str, content
#let resolve-time(time, date) = {
  if time == auto {
    let cli-time = sys.inputs.at(
      "hora",
      default: sys.inputs.at(
        "time",
        default: sys.inputs.at("compilation-time", default: none),
      ),
    )
    if cli-time != none {
      cli-time
    } else if type(date) == datetime and date.hour() != none {
      date.display("[hour]:[minute]")
    } else {
      "—"
    }
  } else if time == none {
    "—"
  } else if type(time) == datetime {
    if time.hour() != none {
      time.display("[hour]:[minute]")
    } else {
      "—"
    }
  } else if type(time) == str or type(time) == content {
    time
  } else {
    to-plain-string(time)
  }
}

/// Resolves academic year string from parameter or active date.
///
/// - year (str, int, content, none, auto): Academic year input.
/// - date (datetime, any): Fallback date to infer year.
/// -> str, content
#let resolve-academic-year(year, date) = {
  if year == auto {
    if type(date) == datetime {
      str(date.year())
    } else {
      str(datetime.today().year())
    }
  } else if year == none {
    "—"
  } else if type(year) == str or type(year) == content {
    year
  } else if type(year) == int {
    str(year)
  } else {
    to-plain-string(year)
  }
}

/// Normalizes author parameter into a uniform array.
///
/// - authors (array, dictionary, str, none): Author or list of authors.
/// -> array
#let normalize-authors(authors) = {
  if type(authors) == array {
    authors
  } else if authors != none {
    (authors,)
  } else {
    ()
  }
}

/// Internal helper to split content into sections at level-1 headings.
#let _split-heading-sections(body) = {
  if type(body) != content or not body.has("children") {
    return (body,)
  }

  let is-whitespace(c) = (
    type(c) == content and c.func() in (space, parbreak, linebreak)
  )
  let is-h1(c) = (
    type(c) == content
      and c.func() == heading
      and c.at("depth", default: c.at("level", default: 1)) == 1
  )

  let h1-count = body.children.filter(is-h1).len()
  if h1-count <= 1 {
    return (body,)
  }

  let cells = ()
  let current-cell = ()
  for child in body.children {
    if is-h1(child) {
      if current-cell.any(c => not is-whitespace(c)) {
        cells.push(current-cell.join())
      }
      current-cell = ()
    }
    current-cell.push(child)
  }
  if current-cell.any(c => not is-whitespace(c)) {
    cells.push(current-cell.join())
  }
  cells
}
