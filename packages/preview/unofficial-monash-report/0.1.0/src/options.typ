#import "design.typ": *
#import "labels.typ": resolve-labels
#let common = (
  title: none, author: none, student-id: none, unit: none, semester: none,
  date: none, short-title: auto, info: (), logo: none,
  font: auto, heading-font: auto, math-font: auto, code-font: auto,
  labels: (:), show-marks: true, question-box: true,
  font-size: body-size, accent: monash-blue, paper: "a4", lang: "en",
)
#let defaults(mode) = common + if mode == "assignment" {
  (tutor: none)
} else {
  (
    subtitle: none, doc-type: none, authors: (), supervisor: none, word-count: none,
    faculty: none, abstract: none, keywords: (), outline: false,
  )
}
#let valid-text(value) = value == none or type(value) in (str, content)
#let require(name, condition, expected) = if not condition {
  panic("`" + name + "` must be " + expected)
}
#let plain(value) = if value == none {
  ""
} else if type(value) == str {
  value
} else if value.has("text") {
  value.text
} else if value.has("children") {
  value.children.map(plain).join()
} else if value.has("body") {
  plain(value.body)
} else {
  ""
}
#let validate(mode, args) = {
  let base = defaults(mode)
  for (key, value) in args {
    if key not in base { panic("unknown argument `" + key + "`") }
  }
  let o = base + args
  o.labels = resolve-labels(o.labels)
  for key in ("show-marks", "question-box") {
    require(key, type(o.at(key)) == bool, "bool")
  }
  require("title", o.title != none and valid-text(o.title), "str or content (required)")
  for key in (
    "author", "student-id", "unit", "semester", "tutor", "subtitle", "doc-type",
    "supervisor", "faculty", "abstract",
  ) {
    if key in o { require(key, valid-text(o.at(key)), "none, str, or content") }
  }
  require(
    "date", o.date in (auto, none) or type(o.date) in (datetime, content),
    "datetime, content, or none",
  )
  require(
    "short-title", o.short-title == auto or valid-text(o.short-title),
    "auto, none, str, or content",
  )
  require("logo", o.logo == none or type(o.logo) == content, "none or content")
  require("accent", type(o.accent) == color, "a colour")
  require(
    "font-size",
    type(o.font-size) == length and o.font-size.em == 0 and o.font-size > zero,
    "a positive absolute length",
  )
  for key in ("font", "heading-font", "math-font", "code-font") {
    let value = o.at(key)
    require(
      key,
      value == auto or type(value) == str or (
        type(value) == array and value.len() > 0 and value.all(v => type(v) == str)
      ),
      "auto, a family name, or a non-empty array of family names",
    )
  }
  require(
    "paper",
    type(o.paper) == str and o.paper in (
      "a0", "a1", "a2", "a3", "a4", "a5", "a6", "us-letter", "us-legal", "us-tabloid",
    ),
    "a supported paper name (a0–a6, us-letter, us-legal, us-tabloid)",
  )
  require("lang", type(o.lang) == str and o.lang.len() > 0, "a non-empty language string")
  require("info", type(o.info) == array, "an array")
  if mode == "assignment" {
    require("info", o.info.all(v => type(v) == content), "an array of content")
  } else {
    require("outline", type(o.outline) == bool, "bool")
    require(
      "word-count",
      o.word-count == none or valid-text(o.word-count) or (
        type(o.word-count) == int and o.word-count >= 0
      ),
      "none, a non-negative integer, str, or content",
    )
    require(
      "info", o.info.all(v => type(v) == array and v.len() == 2 and v.all(valid-text)),
      "an array of (label, value) pairs",
    )
    require(
      "keywords", type(o.keywords) == array and o.keywords.all(v => type(v) in (str, content)),
      "an array of str or content",
    )
    require("authors", type(o.authors) == array, "an array of dictionaries")
    for person in o.authors {
      require("authors", type(person) == dictionary, "an array of dictionaries")
      for (key, value) in person {
        require(
          "authors." + key, key in ("name", "student-id", "contribution"),
          "name, student-id, or contribution",
        )
        require("authors." + key, valid-text(value), "none, str, or content")
      }
      require("authors.name", person.at("name", default: none) != none, "str or content")
    }
  }
  if type(o.date) == datetime {
    require("date", o.date.year() != none, "a datetime with a calendar date")
  }
  if o.date == auto { o.date = datetime.today() }
  if o.short-title == auto {
    let unit = plain(o.unit).split(" ").first()
    let title = plain(o.title).split(":").first()
    o.short-title = (unit, title).filter(v => v != "").join(" · ")
  }
  o.font = resolve-font(o.font, body-fonts)
  o.heading-font = resolve-font(o.heading-font, heading-fonts)
  o.math-font = resolve-font(o.math-font, math-fonts)
  o.code-font = resolve-font(o.code-font, code-fonts)
  o
}
#let date-text(date) = if type(date) == datetime {
  date.display("[day] [month repr:long] [year]")
} else {
  date
}
#let present(value) = value != none and value != [] and value != ""
