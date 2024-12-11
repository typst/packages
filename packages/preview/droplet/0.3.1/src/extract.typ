#import "util.typ": attach-label, space, splittable, to-string

// Regex for valid characters in front of the dropped capital.
#let regex-before = regex({
  "["
    "\"'"              // Dumb quotes
    "\p{C}"            // Control characters
    "\p{Pi}"           // Initial punctuation
    "\p{Ps}"           // Opening punctuation
    "\p{Z}"            // Spaces and separators
    "¹²³\u2070-\u209F" // Superscripts and subscripts
  "]+"
})

// Regex for valid characters behind the dropped capital.
#let regex-after = regex({
  "["
    "\."               // Full stop
    "\"'"              // Dumb quotes / apostrophe
    "\p{C}"            // Control characters
    "\p{Pf}"           // Final punctuation
    "\p{Pe}"           // Closing punctuation
    "\p{Z}"            // Spaces and separators
    "\p{M}"            // Combining marks
    "¹²³\u2070-\u209F" // Superscripts and subscripts
  "]+"
})

// Extracts the first letter of the given content.
//
// The first letter may be none if the content does not contain any letters.
// If the first child cannot be split further, that child is returned as the
// first letter.
//
// Returns: A tuple of the first letter and the rest.
#let extract-first-letter(body) = {
  // Handle string content.
  if type(body) == str {
    let letter = body.clusters().at(0, default: none)
    if letter == none {
      return (none, body)
    }
    let rest = body.clusters().slice(1).join()
    return (letter, rest)
  }

  // Handle text content.
  if body.has("text") {
    let (text, ..fields) = body.fields()
    if "label" in fields { fields.remove("label") }
    let label = if body.has("label") { body.label }
    let func(it) = if it != none { body.func()(..fields, it) }
    let (letter, rest) = extract-first-letter(body.text)
    return attach-label((letter, func(rest)), label)
  }

  // Handle content with "body" field.
  if body.func() in splittable {
    let (body: text, ..fields) = body.fields()
    if "label" in fields { fields.remove("label") }
    let label = if body.has("label") { body.label }
    let func(it) = if it != none { body.func()(..fields, it) }
    let (letter, rest) = extract-first-letter(text)
    return attach-label((letter, func(rest)), label)
  }

  // Handle styled content.
  if body.has("child") {
    let (child, styles, ..fields) = body.fields()
    if "label" in fields { fields.remove("label") }
    let label = if body.has("label") { body.label }
    let func(it) = if it != none { body.func()(it, styles) }
    let (letter, rest) = extract-first-letter(child)
    return attach-label((letter, func(rest)), label)
  }

  // Handle enumeration items (interpreted as text, e.g. "5. Body" or "+ Body")
  if body.func() == enum.item {
    let (body, ..fields) = body.fields()
    let number = fields.at("number", default: none)
    return if number == none {
      ("+", body)
    } else if number < 10 {
      (str(number), "." + body)
    } else {
      (str(number).first(), str(number).slice(1) + "." + body)
    }
  }

  // Handle list items (interpreted as text, e.g. "- Body")
  if body.func() == list.item {
    return ("-", body.body)
  }

  // Handle sequences.
  if body.has("children") {
    let child-pos = body.children.position(c => {
      c.func() not in (space, parbreak)
    })

    if child-pos == none {
      // There is no non-empty child, so no letter.
      return (none, body)
    }

    let child = body.children.at(child-pos)
    let (letter, rest) = extract-first-letter(child)
    if body.children.len() > child-pos {
      rest = (rest, ..body.children.slice(child-pos+1)).join()
    }
    return (letter, rest)
  }

  // Handle unbreakable content.
  return (body, none)
}

// Extracts the dropped capital from the given content.
//
// The dropped capital contains the first real letter (or number) of the
// content, but can be preceded by opening punctuation characters, and followed
// by a sequence of closing punctuation characters.
//
// For example, the dropped capital of "Hello, world!" is "H", and the
// dropped capital of "1. Hello, world!" is "1." including the dot.
//
// Returns: A tuple of the dropped capital and the rest.
#let extract(body) = {
  let (letter, rest) = extract-first-letter(body)
  if letter == none {
    return (none, body)
  }

  // We can only append punctuation characters if the first letter can be
  // converted to a string, but not if it's e.g. a 'box' or 'image'.
  if to-string(letter) != none {
    // Append opening punctuation characters until the first "real" letter.
    while regex-before in to-string(letter).last() {
      let (next-letter, new-rest) = extract-first-letter(rest)
      if next-letter == none { break }
      letter += next-letter
      rest = new-rest
    }

    // Append closing punctuation characters.
    let (next-letter, new-rest) = extract-first-letter(rest)
    while to-string(next-letter) != none and regex-after in to-string(next-letter) {
      letter += next-letter
      rest = new-rest
      (next-letter, new-rest) = extract-first-letter(rest)
    }
  }

  return (letter, rest)
}
