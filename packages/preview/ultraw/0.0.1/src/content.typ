/// An element with a new body, keeping its other fields (the ones given positionally before the body, as the `alignment` of `align`, being given positionally).
///
/// - elem (content): An element with a `body`.
/// - body (content): The new body.
/// -> content
#let with-body(elem, body) = {
  let fields = elem.fields()
  let _ = fields.remove("body")
  let positional = ("dest", "alignment", "angle", "factor")
    .filter(k => k in fields)
    .map(k => fields.remove(k))
  (elem.func())(..positional, ..fields, body)
}

// The positions in a text are counted in characters (grapheme clusters), not in bytes as `str.len` and `str.slice` do.

/// The number of characters of some text.
///
/// - text (str):
/// -> int
#let text-len(text) = text.clusters().len()

/// The part of some text between two character positions.
///
/// - text (str):
/// - start (int):
/// - end (none, int):
/// -> str
#let text-slice(text, start, end: none) = (
  text.clusters().slice(start, end).sum(default: "")
)

/// Check whether a line is only composed of white spaces.
///
/// - line (content):
/// -> bool
#let is-whitespace-line(line) = line.trim().len() == 0

/// The size of an indentation level: the most frequent increase of the leading spaces between consecutive lines (the smallest one among the most frequent), a block being opened one level deeper (while several can be closed at once).
///
/// - texts (array): The texts of the lines.
/// - default (int): The size when the indentation never increases.
/// -> int
#let infer-indent-size(texts, default) = {
  let spaces = texts
    .filter(t => not is-whitespace-line(t))
    .map(t => t.len() - t.trim(" ", at: start).len())
  if spaces.len() == 0 { return default }
  let counts = (:)
  for (a, b) in spaces.zip(spaces.slice(1, spaces.len())) {
    let d = str(b - a)
    if b > a { counts.insert(d, counts.at(d, default: 0) + 1) }
  }
  if counts.len() == 0 { return default }
  let (size, _) = counts
    .pairs()
    .map(((k, n)) => (int(k), n))
    .sorted(key: ((k, n)) => (-n, k))
    .first()
  size
}

/// Return the number of indentations of the text of a line.
///
/// - text (str):
/// - tab-size (int): The size of an indentation.
/// -> int
#let get-text-indent(text, tab-size) = {
  let tab-spaces = " " * tab-size
  let num-indent = 0

  let i = 0
  while (
    i < text.len()
      and (
        text.slice(i).starts-with(tab-spaces) or text.slice(i).first() == "\t"
      )
  ) {
    num-indent += 1
    if text.slice(i).starts-with(tab-spaces) { i += tab-size } else { i += 1 }
  }

  num-indent
}

/// Return the number of indentations of a line.
///
/// - line (content):
/// - tab-size (int): The size of an indentation.
/// -> int
#let get-line-indent(line, tab-size) = if line.has("text") {
  get-text-indent(line.text, tab-size)
} else { 0 }

/// The length in character of some content.
///
/// - elem (content):
/// -> int
#let content-len(elem) = if elem.has("child") and elem.has("styles") {
  content-len(elem.child)
} else if elem.has("text") {
  text-len(elem.text)
} else if elem.has("children") {
  elem.children.map(content-len).sum(default: 0)
} else if elem.has("body") {
  content-len(elem.body)
} else {
  0
}

/// Check whether some content is empty.
///
/// - elem (content):
/// -> bool
#let is-empty-content(elem) = if elem.has("child") and elem.has("styles") {
  is-empty-content(elem.child)
} else if elem.has("text") {
  elem.text.len() == 0
} else if elem.has("children") {
  for child in elem.children {
    if not is-empty-content(child) { return false }
  }
  true
} else if elem.has("body") {
  is-empty-content(elem.body)
} else {
  true
}

/// Map some splited content.
///
/// - split (array): An array containing the content, the number of removed character, and whether the content has been emptied.
/// - fun (function): The function applied to the content.
/// -> array
#let map-split(split, fun) = {
  let (f, removed, emptied) = split
  return (fun(f), removed, emptied)
}

/// Return the number of white spaces at the end of some text.
///
/// - text (str):
/// -> int
#let find-nbr-whitespace-end(text) = {
  let i = 0
  let clusters = text.clusters().rev()
  for c in clusters {
    if c.trim().len() == 0 {
      i += 1
    } else {
      break
    }
  }
  return i
}

/// Remove the white spaces at the end of some content.
///
/// - elem (content):
/// -> content
#let content-trim-end(elem) = if elem.has("child") and elem.has("styles") {
  map-split(content-trim-end(elem.child), e => (elem.func())(e, elem.styles))
} else if elem.has("text") {
  let i = find-nbr-whitespace-end(elem.text)
  let n = text-len(elem.text)
  ([#text-slice(elem.text, 0, end: n - i)], i, i == n)
} else if elem.has("children") {
  let nc = elem.children
  let inc = nc.len() - 1
  let t = []
  let i = 0
  let ni = 0
  let e = true
  while 0 <= inc and e {
    (t, ni, e) = content-trim-end(nc.at(inc))
    i += ni
    inc -= 1
  }
  (if inc < 0 { [] } else { nc.slice(0, inc + 1).sum(default: []) } + t, i, e)
} else if elem.has("body") {
  map-split(content-trim-end(elem.body), e => with-body(elem, e))
} else {
  ([], 0, true)
}

/// Return the number of white spaces at the start of some text.
///
/// - text (str):
/// -> int
#let find-nbr-whitespace-start(text) = {
  let i = 0
  for c in text.clusters() {
    if c.trim().len() == 0 { i += 1 } else { break }
  }
  return i
}

/// Remove the white spaces at the start of some content.
///
/// - elem (content):
/// -> content
#let content-trim-start(elem) = if elem.has("child") and elem.has("styles") {
  map-split(content-trim-start(elem.child), e => (elem.func())(e, elem.styles))
} else if elem.has("text") {
  let i = find-nbr-whitespace-start(elem.text)
  ([#text-slice(elem.text, i)], i, i == text-len(elem.text))
} else if elem.has("children") {
  let nc = elem.children
  let inc = 0
  let t = []
  let i = 0
  let ni = 0
  let e = true
  while inc < nc.len() and e {
    (t, ni, e) = content-trim-start(nc.at(inc))
    i += ni
    inc += 1
  }
  (t + if inc == nc.len() { [] } else { nc.slice(inc).sum(default: []) }, i, e)
} else if elem.has("body") {
  map-split(content-trim-start(elem.body), e => with-body(elem, e))
} else {
  ([], 0, true)
}

/// Split some content containing some text at some position. If some word is present at this position, it splits the content on the space before that word.
///
/// - elem (content):
/// - pos (int):
/// -> array
#let text-split-word-pos(elem, pos) = {
  // The position in characters, and in bytes (to slice the text)
  let i = 0
  let b = 0
  while b < elem.text.len() {
    let t = elem.text.slice(b)

    if t.starts-with(regex("\S+")) {
      let word = t.find(regex("\S+"))
      let n = text-len(word)
      if n < pos - i + 1 {
        i += n
        b += word.len()
      } else {
        return (elem.text.slice(0, b), i, i, t)
      }
    } else if t.starts-with(regex("\s+")) {
      let space = t.find(regex("\s+"))
      let n = text-len(space)
      if n < pos - i + 1 {
        i += n
        b += space.len()
      } else {
        return (
          elem.text.slice(0, b),
          i,
          i + n,
          elem.text.slice(b + space.len()),
        )
      }
    }
  }

  let n = text-len(elem.text)
  return (elem, n, n, "")
}

/// Map some splited content.
///
/// - split (array): An array containing the first content, its end, the start of the second content, and the second content.
/// - fun (function): The function applied to the content.
/// -> array
#let map-split(split, fun) = {
  let (f, f-end, s-start, s) = split
  return (fun(f), f-end, s-start, fun(s))
}

/// Split some content containing at some position. If some word is present at this position, it splits the content on the space before that word.
///
/// - elem (content):
/// - pos (int):
/// -> array
#let content-split-word-pos(elem, pos) = {
  if elem.has("child") and elem.has("styles") {
    map-split(
      content-split-word-pos(elem.child, pos),
      e => elem.func()(e, elem.styles),
    )
  } else if elem.has("text") {
    map-split(
      text-split-word-pos(elem, pos),
      e => [#e],
    )
  } else if elem.has("children") {
    let before = []
    let before-len = 0

    for (i, child) in elem.children.enumerate() {
      let l = content-len(child)
      if before-len + l <= pos {
        before += child
        before-len += l
      } else {
        let (f, f-end, s-start, s) = (
          content-split-word-pos(child, pos - before-len)
        )
        return (
          before + f,
          before-len + f-end,
          before-len + s-start,
          s
            + if i < elem.children.len() - 1 {
              elem.children.slice(i + 1).sum()
            },
        )
      }
    }

    return (before, before-len, before-len, [])
  } else if elem.has("body") {
    map-split(
      content-split-word-pos(elem.body, pos),
      e => with-body(elem, e) + [],
    )
  }
}

/// Split some content at a position.
///
/// - elem (content):
/// - pos (int):
/// -> array
#let content-split-pos(elem, pos) = {
  if elem.has("child") and elem.has("styles") {
    content-split-pos(elem.child, pos).map(e => (
      elem.func()(e, elem.styles) + []
    ))
  } else if elem.has("text") and pos <= text-len(elem.text) {
    (
      [#text-slice(elem.text, 0, end: pos)],
      [#text-slice(elem.text, pos)],
    )
  } else if elem.has("text") {
    ([#elem.text], [])
  } else if elem.has("children") {
    let before = []
    let after = []

    for child in elem.children {
      if pos <= 0 {
        after += child
      } else if content-len(child) <= pos {
        before += child
        pos -= content-len(child)
      } else {
        let (f, l) = content-split-pos(child, pos)
        before += f
        after += l
        pos = 0
      }
    }

    (before, after)
  } else if elem.has("body") {
    content-split-pos(elem.body, pos).map(e => with-body(elem, e) + [])
  } else {
    ([], [])
  }
}

/// Compute the maximum possible position for a line.
///
/// - max-width (length):
/// - char-width (length):
/// -> int
#let get-max-pos(max-width, char-width) = {
  let wr = max-width / char-width
  // (an infinite width, as when the code is measured without width, breaks no line)
  if wr > 1e9 { return int(1e9) }
  if calc.ceil(wr) - wr < 0.01 { calc.ceil(wr) } else { int(wr) }
}

/// Try splitting some line at a position while respecting the words if possible. If not possible, split on the exact position.
///
/// - line (content):
/// - pos (int):
/// -> array
#let clean-content-split-word-pos(line, pos) = {
  let (l1, l1-end, l2-start, l2) = content-split-word-pos(line, pos)
  if is-empty-content(l1) {
    (l1, l2) = content-split-pos(line, pos)
    return (l1, pos, pos, l2)
  } else {
    return (l1, l1-end, l2-start, l2)
  }
}

/// Return the array of sublines containing the content of a line split to fit within a maximum width.
///
/// - line (content):
/// - max-width (length):
/// - char-width (length):
/// - line-end (int): The last position of the line.
/// - end-offset (none, length): The length of some object at the end of the line, none if there is none.]
/// - indent (int): The position (in characters) where the sub-lines after the first one start.
/// - xs (array, none): The positions of the columns of the line, when its characters are not all `char-width` wide.
/// -> array
#let sub-lines(
  line,
  max-width,
  char-width,
  line-end,
  end-offset,
  indent: 0,
  xs: none,
) = {
  let sub-lines = ()
  let prev-start = 0

  // The number of characters fitting in a sub-line starting at `start`: the first sub-line leaves room for the object at its end, the next ones start at the indentation
  let max-pos(start, first) = {
    let width = (
      max-width
        - if not first { indent * char-width } else if end-offset != none {
          end-offset
        } else { 0pt }
    )
    if xs == none { return get-max-pos(width, char-width) }
    // (all the rest of the line fitting, no position is reached)
    if xs.last() - xs.at(start) <= width + .01pt { return int(1e9) }
    let n = 0
    while xs.at(start + n + 1) - xs.at(start) <= width + .01pt { n += 1 }
    n
  }
  // Each sub-line must contain at least one character
  assert(
    max-pos(0, false) >= 1,
    message: "The code is too narrow: no character fits in its width.",
  )

  while line-end - prev-start >= max-pos(prev-start, sub-lines.len() == 0) {
    let (l1, l1-end, l2-start, l2) = clean-content-split-word-pos(
      line,
      max-pos(prev-start, sub-lines.len() == 0),
    )
    sub-lines.push((start: prev-start, body: l1, end: prev-start + l1-end))
    prev-start += l2-start
    line = l2
  }

  sub-lines.push((start: prev-start, body: line, end: line-end))

  return sub-lines
}

/// Split some line to fit within the max width and format the sublines obtained.
///
/// - line (content):
/// - max-width (length):
/// - char-width (length):
/// - line-end (int): The last position of the line.
/// - end-offset (none, length): The length of some object at the end of the line, none if there is none.]
/// - indent (int): The position (in characters) where the sub-lines after the first one start.
/// - xs (array, none): The positions of the columns of the line, when its characters are not all `char-width` wide.
/// -> array: the sub-lines, with their `start` and `end` in the line, their `body`, and the position where they are shown (`offset`)
#let format-line(
  line,
  max-width,
  char-width,
  line-end,
  end-offset,
  indent: 0,
  xs: none,
) = {
  let slines = sub-lines(
    line,
    max-width,
    char-width,
    line-end,
    end-offset,
    indent: indent,
    xs: xs,
  )
  slines = slines
    .enumerate()
    .map(((i, sl)) => {
      let (c, i_s, e_s) = if i > 0 {
        content-trim-start(sl.body)
      } else {
        (sl.body, 0, false)
      }

      let (c, i_e, e_e) = content-trim-end(c)
      (
        start: sl.start + i_s,
        body: c,
        end: sl.end - i_e,
        offset: if i > 0 { indent } else { 0 },
        emptied: e_e,
      )
    })
    .filter(l => not l.emptied)

  if slines.len() == 0 { ((start: 0, body: [], end: 1, offset: 0),) } else {
    slines
  }
}

/// Insert some content in another content at a specified position.
///
/// - elem (content):
/// - c (content): The inserted content.
/// - pos (int):
/// -> content
#let insert-at-pos(elem, c, pos) = {
  let (pre-pos, post-pos) = content-split-pos(elem, pos)
  pre-pos + c + post-pos
}

/// Return the string contained in some content.
///
/// - elem (content):
/// -> str
#let content-text(elem) = if elem.has("child") and elem.has("styles") {
  content-text(elem.child)
} else if elem.has("text") {
  elem.text
} else if elem.has("children") {
  elem.children.map(content-text).sum(default: "")
} else if elem.has("body") {
  content-text(elem.body)
} else {
  ""
}

/// Apply some function to all the text contained in some content.
///
/// - elem (content):
/// - fun (function):
/// -> content
#let content-map-text(elem, fun) = if elem.has("child") and elem.has("styles") {
  (elem.func())(content-map-text(elem.child, fun), elem.styles)
} else if elem.has("text") {
  fun(elem.text)
} else if elem.has("children") {
  elem.children.map(e => content-map-text(e, fun)).sum(default: [])
} else if elem.has("body") {
  with-body(elem, content-map-text(elem.body, fun))
}
