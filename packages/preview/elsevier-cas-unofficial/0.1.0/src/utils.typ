#import "globals.typ": sizes

/// Set text size and baselineskip like LaTeX's `\fontsize{size}{skip}`.
/// - size (array): a `(size, baselineskip)` pair, e.g. `sizes.small`.
#let with-size(size, body) = {
  let (sz, skip) = size
  set text(size: sz)
  set par(leading: skip - sz, spacing: skip - sz)
  body
}

/// Switch font family. Every font change goes through here so that Typst
/// reports a missing font only once.
#let with-font(font, body) = {
  set text(font: font)
  body
}

/// Switch to the monospace font at 0.8em, the size Typst gives `raw` text,
/// so that URLs and email addresses match inline code.
#let with-mono(font, body) = with-font(font, {
  set text(size: 0.8em)
  body
})

/// Vertical gap between two text lines so that their baselines end up
/// `distance` apart (line boxes span 0.7em above to 0.3em below the baseline).
#let baseline-gap(distance, above-size, below-size) = (
  distance - 0.3 * above-size - 0.7 * below-size
)

/// Wrap a single value into an array; `none` becomes the empty array.
#let as-array(x) = {
  if x == none { () } else if type(x) == array { x } else { (x,) }
}

/// Best-effort conversion of content to a plain string (for PDF metadata).
#let to-str(it) = {
  if it == none { return "" }
  if type(it) == str { return it }
  if type(it) != content { return str(it) }
  if it.func() == smartquote {
    return if it.at("double", default: true) { "\"" } else { "'" }
  }
  if it.func() == linebreak { return " " }
  if it.has("text") { return to-str(it.text) }
  if it.has("children") { return it.children.map(to-str).join("") }
  if it.has("body") { return to-str(it.body) }
  if it == [ ] { return " " }
  ""
}

#let is-chinese(author) = author.at("style", default: none) == "chinese"

/// Split an author name into given names and surname, like the class's
/// `\parsename` (surname = last word) or, for `style: "chinese"`,
/// `\invparsename` (surname = first word). A dictionary with `given` and
/// `family` keys sets both parts explicitly; other content is kept whole.
#let split-name(author) = {
  let name = author.name
  if type(name) == dictionary {
    return (
      given: name.at("given", default: none),
      family: name.at("family", default: none),
    )
  }
  if type(name) != str { return (given: none, family: name) }
  let parts = name.split(" ").filter(p => p != "")
  if parts.len() < 2 { return (given: none, family: name.trim()) }
  if is-chinese(author) {
    (given: parts.slice(1).join(" "), family: parts.first())
  } else {
    (given: parts.slice(0, -1).join(" "), family: parts.last())
  }
}

/// The name in reading order, without prefix or suffix.
#let full-name(author) = {
  let n = split-name(author)
  let parts = (n.given, n.family)
  if is-chinese(author) { parts = parts.rev() }
  parts.filter(p => p != none).join(" ")
}

/// Initials of the given names followed by the surname ("W. J. Hansen"),
/// as used for email/URL/ORCID notes and the default running footer.
#let short-name(author) = {
  let n = split-name(author)
  let given = n.given
  if given == none { return n.family }
  if type(given) == str {
    given = given
      .split(" ")
      .filter(p => p != "")
      .map(p => if p.contains(".") { p } else { p.clusters().first() + "." })
      .join(" ")
  }
  [#given #n.family]
}
