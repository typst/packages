#let to-latin(str) = {
  let new = str
  let chars = (
    ("á", "a"),
    ("à", "a"),
    ("ó", "o"),
    ("ò", "o"),
    ("ú", "u"),
    ("ù", "u"),
    ("ü", "u"),
    ("é", "e"),
    ("è", "e"),
    ("ë", "e"),
    ("í", "i"),
    ("ì", "i"),
    ("ý", "y"),
    ("ỳ", "y"),
    ("ð", "d"),
    ("þ", "th"),
    ("æ", "ae"),
    ("ø", "ö"),
    ("ç", "c"),
    ("ć", "c"),
    ("ñ", "n"),
    ("ß", "ss"),
  )
  for (t, f) in chars {
    new = new.replace(t, f)
  }
  // TODO: Remove other non-ascii characters?
  return new
}

// TODO: Should the main separator be `-` to match our style?
/// Converts a name string into a valid Typst label identifier.
///
/// Lowercases, removes accents via `to-latin`, and joins on whitespace, dashes,
/// and quote characters. Used to auto-generate `@labels` for attendees and authors.
///
/// - str (str): Input string, typically a person's name.
/// - sep (str): Separator inserted between words. Defaults to `""` (no separator).
///
/// -> str
#let to-label(str, sep: "") = to-latin(lower(str.split(regex("[-`'´\s]")).join(sep)))

#let to-text(c) = {
  if type(c) == str {
    return c
  } else if type(c) == content {
    let f = c.func()
    if f == text {
      return c.text
    } else if f == [ ].func() {
      // TODO: `[ ].func()` is `space`, so all whitespace will convert to `" "`.
      return " "
    } else if f == [\n].func() {
      // TODO: `[\n].func()` is `symbol`, so all symbols will convert to newlines.
      return "\n"
    } else if f == ['].func() {
      return if c.double { "\"" } else { "'" }
    } else if c.has("children") {
      return c.children.map(to-text).join()
    } else if c.has("body") {
      return to-text(c.body)
    } else {
      return ""
    }
  } else {
    // TODO: Use `repr`?
    return ""
  }
}
