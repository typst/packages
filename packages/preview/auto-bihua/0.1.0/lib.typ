// auto-bihua: stroke count, stroke order, and stroke-based sort for Chinese
// characters. Wraps a Rust WASM plugin.

#let _plugin = plugin("auto-bihua.wasm")

/// Version information about auto-bihua and its data sources.
#let version() = str(_plugin.version())

#let _extract-text(input) = {
  if type(input) == str {
    input
  } else if type(input) == content and "text" in input.fields() {
    input.text
  } else {
    none
  }
}

/// Stroke count.
///
/// - chars (str, content): text to count
/// - split (bool): if true, return an array of per-character counts
///   (none for unknown characters); if false (default), return the total.
///
/// Returns:
/// - int when split is false
/// - array of (int | none) when split is true
#let bihua-count(chars, split: false) = {
  let s = _extract-text(chars)
  if s == none {
    panic("bihua-count: input must be a string or content with text field")
  }
  if split {
    s.clusters().map(c => {
      let r = str(_plugin.char_count(bytes(c)))
      if r == "" { none } else { int(r) }
    })
  } else {
    int(str(_plugin.total_count(bytes(s))))
  }
}

/// Stroke order of a single character.
///
/// - char (str, content): a single Chinese character
/// - style (str): output style
///   - "digit"  (default): single string of GB13000 digits, e.g. "汉" → "44115254"
///                        (1=横 2=竖 3=撇 4=点 5=折)
///   - "name"   : array of Chinese stroke names, e.g. ("点","点","提","横","撇","横撇","捺")
///   - "shape"  : array of stroke shape characters, e.g. ("丶","丶","㇀",...)
///   - "letter" : raw cnchar letter encoding, e.g. "kkijser"
///
/// Returns the empty string / empty array if the character is not in the
/// stroke-order dictionary (currently ~6939 simplified characters).
#let bihua-order(char, style: "digit") = {
  let s = _extract-text(char)
  if s == none {
    panic("bihua-order: input must be a string or content with text field")
  }
  let clusters = s.clusters()
  if clusters.len() != 1 {
    panic("bihua-order: expected a single character, got " + str(clusters.len()))
  }
  let c = clusters.at(0)
  if style == "digit" {
    str(_plugin.char_order_digit(bytes(c)))
  } else if style == "letter" {
    str(_plugin.char_order_letter(bytes(c)))
  } else if style == "name" {
    let r = str(_plugin.char_order_name(bytes(c)))
    if r == "" { () } else { r.split("|") }
  } else if style == "shape" {
    let r = str(_plugin.char_order_shape(bytes(c)))
    if r == "" { () } else { r.split("|") }
  } else {
    panic("bihua-order: invalid style '" + style + "'. Valid: digit, name, shape, letter")
  }
}

/// Sort an array of strings (or contents) by stroke count, then by stroke
/// order as tiebreaker. Strings are compared character-by-character.
/// Items containing characters not in the data set sort to the end.
///
/// - items (array): strings or contents to sort
///
/// Returns: a new array in stroke-sorted order.
#let bihua-sort(items) = {
  let strs = items.map(it => {
    let s = _extract-text(it)
    if s == none {
      panic("bihua-sort: items must be strings or content")
    }
    s
  })
  if strs.len() == 0 { return () }
  let joined = strs.join("\n")
  let sorted = str(_plugin.sort_items(bytes(joined)))
  if sorted == "" { () } else { sorted.split("\n") }
}
