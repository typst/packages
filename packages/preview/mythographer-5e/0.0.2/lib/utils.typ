#let in-outline = state("in-outline", false)
#let flex-heading(long, short) = context if in-outline.get() { short } else { long }

#let to-string(it) = {
  if type(it) == str {
    it
  } else if type(it) != content {
    str(it)
  } else if it.has("text") {
    it.text
  } else if it.has("children") {
    it.children.map(to-string).join()
  } else if it.has("body") {
    to-string(it.body)
  } else if it == [ ] {
    " "
  }
}

/// Add a dictionary to another dictionary recursively
///
/// Example: `add-dicts((a: (b: 1), (a: (c: 2))` returns `(a: (b: 1, c: 2)`
///
/// -> dictionary
#let add-dicts(dict-a, dict-b) = {
  let res = dict-a
  for key in dict-b.keys() {
    if (
      key in res and type(res.at(key)) == dictionary and type(dict-b.at(key)) == dictionary
    ) {
      res.insert(key, add-dicts(res.at(key), dict-b.at(key)))
    } else {
      res.insert(key, dict-b.at(key))
    }
  }
  return res
}

/// Merge some dictionaries recursively
///
/// Example: `merge-dicts((a: (b: 1)), (a: (c: 2)))` returns `(a: (b: 1, c: 2))`
///
/// -> dictionary
#let merge-dicts(init-dict, ..dicts) = {
  assert(
    dicts.named().len() == 0,
    message: "You must provide dictionaries as positional arguments",
  )
  let res = init-dict
  for dict in dicts.pos() {
    res = add-dicts(res, dict)
  }
  return res
}

#let typst-builtin-sequence = ([A] + [ ] + [B]).func()

/// Determine if a content is a sequence.
///
/// Example: `is-sequence([a])` returns `true`
///
/// -> bool
#let is-sequence(it) = {
  type(it) == content and it.func() == typst-builtin-sequence
}

/// Determine if a content is a metadata.
///
/// Example: `is-metadata(metadata((a: 1)))` returns `true`
///
/// -> bool
#let is-metadata(it) = {
  type(it) == content and it.func() == metadata
}

/// Determine if a content is a metadata with a specific kind.
///
/// -> bool
#let is-kind(it, kind) = {
  (
    is-metadata(it) and type(it.value) == dictionary and it.value.at("kind", default: none) == kind
  )
}

/// Remove leading and trailing empty elements from an array of content
///
/// Example: `trim(([], [ ], parbreak(), linebreak(), [a], [ ], [b], [c], linebreak(), parbreak(), [ ], [ ]))` returns `([a], [ ], [b], [c])`
///
/// #let arr = `array(content)`
///
/// - arr (arr): The array of content to trim
///
/// - empty-contents (array): An array of content that is considered empty
///
/// -> content
#let trim(arr, empty-contents: ([], [ ], parbreak(), linebreak())) = {
  let i = 0
  let j = arr.len() - 1
  while i != arr.len() and arr.at(i) in empty-contents {
    i += 1
  }
  while j != i - 1 and arr.at(j) in empty-contents {
    j -= 1
  }
  arr.slice(i, j + 1)
}

#let typst-builtin-styled = [#set text(fill: red)].func()

/// Determine if a content is styled.
///
/// Example: `is-styled(text(fill: red)[Red])` returns `true`
///
/// -> bool
#let is-styled(it) = {
  type(it) == content and it.func() == typst-builtin-styled
}

#let call-if-fn(fn, args) = {
  if type(fn) == function {
    (fn)[#args]
  } else {
    args
  }
}

/// Apply styles if they are not none
///
/// This method is a decent way to avoid rewriting styling methods to include/exclude macros like `smallcaps`, `emph`, etc.
#let maybe-apply-style(style, body) = {
  if style != none {
    (style)[#body]
  } else {
    [#body]
  }
}



/// Top-balanced columns
///   many thanks to this angel: https://forum.typst.app/t/how-to-display-the-table-of-contents-in-two-columns-with-an-even-distribution/4514/3
///
/// Example:
/// #balance(columns(2)[
//    #lorem(500)
//  ])
// #let columns-balance(fill: none, n-cols: 2, height-correction: 10pt, content) = layout(size => {
//   let textheight = measure(content, width: size.width).height / n-cols
//   let height = measure(content, height: textheight + height-correction, width: size.width).height
//   block(height: height, fill: fill, width: 100%, content)
// })

#let columns-balance(fill: none, correction-factor: 1, n-cols: 2, content) = layout(size => {
  let textheight = measure(content, width: size.width).height / n-cols

  // 2em is the horizontal space taken by the column dividers in the block inset, so we need to add it to the height of the block to make sure the content fits.
  let corrected-height = (textheight + ((n-cols) * 1em))*correction-factor


  let height = measure(content, height: corrected-height, width: size.width).height
  if n-cols == 1 {
    height = corrected-height
  }

  block(
    height: height + 1em,
    fill: fill,
    width: 100%,
    inset: 1em,
    above: 1em,
    below: 1em,
    breakable: false,
    sticky: false,
  )[
    #content]
})

#let dnd-dice-average(amount, die) = {
  let average = int(amount * (die / 2 + 0.5))
  return average
}

/// Calculates the average of the given dice expression and returns a text with the average and the original expression, e.g. "13 (3d8 + 3)".
///
/// - body: Dice formatted as either:
///       - [3d8]
///       - [3d8+3]
///       - [3d8 + 3]
///       - the same as strings, e.g. "3d8", "3d8+3", "3d8 + 3"
///
/// -> e.g. [16 (3d8 + 3)] or [13 (3d8)] or none if the expression is invalid or somehow the assertion fails.
#let dnd-dice(body) = {
  assert(type(body) == str or body.has("children") or body.has("text"))

  // Case "3d8" and "3d8+3"
  if type(body) == str {
    // panic()

    let d-form = ""
    let modifier = 0
    if body.contains("+") {
      let parts = body.split(regex("[+]"))
      d-form = parts.at(0).trim()
      modifier = int(parts.at(1).trim())
    } else {
      d-form = body.trim()
    }
    let amount-dice = d-form.split(regex("[d]")).map(int)
    let average = dnd-dice-average(amount-dice.at(0), amount-dice.at(1))
    let hp-no-sum = average + modifier

    return [#hp-no-sum (#body)]
  }

  // Case [3d8]
  if body.has("text") {
    if body.text.contains("+") {
      let parts = body.text.split(regex("[+]")).map(str.trim)
      let amount-dice = parts.at(0).split(regex("[d]")).map(int)
      let average = dnd-dice-average(amount-dice.at(0), amount-dice.at(1))
      let modifier = int(parts.at(1))
      let hp-no-sum = average + modifier
      return [#hp-no-sum (#body)]
    } else {
      let amount-dice = body.text.split(regex("[d]")).map(int)
      let average = dnd-dice-average(amount-dice.at(0), amount-dice.at(1))
      return [#average (#body)]
    }
  }

  // Case [3d8 + 3]
  if body.has("children") {
    let amount-dice = (body.children.at(0).text).split(regex("[d]")).map(int)
    let average = dnd-dice-average(amount-dice.at(0), amount-dice.at(1))
    let modifier = int(body.children.last().text)  
    let hp-no-sum = average + modifier
    return [#hp-no-sum (#body)]
  }

  return none
}