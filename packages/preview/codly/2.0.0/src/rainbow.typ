// R's backtick identifiers have no string scope; use its explicit bracket scopes.
#let code-scopes = "source - source.r, source.r punctuation.section, meta.interpolation, punctuation.typst, punctuation.math.typst"
#let ignore-scopes = "string, comment, constant.character, markup.raw"
#let delimiters = regex("[()\\[\\]{}]")
#let singletons = (
  "(": ((start: 0, text: "("),),
  ")": ((start: 0, text: ")"),),
  "[": ((start: 0, text: "["),),
  "]": ((start: 0, text: "]"),),
  "{": ((start: 0, text: "{"),),
  "}": ((start: 0, text: "}"),),
)
#let palette = (
  rgb("#b04080"),
  rgb("#996300"),
  rgb("#267a45"),
  rgb("#007f99"),
  rgb("#425cc7"),
  rgb("#8655a8"),
)

// A private theme marks code with strong, independently of the display theme.
#let theme(code, ignored) = {
  let escape(s) = s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
  bytes(
    "<?xml version=\"1.0\"?><plist version=\"1.0\"><dict><key>settings</key><array>"
      + "<dict><key>settings</key><dict><key>foreground</key><string>#000000</string></dict></dict>"
      + "<dict><key>scope</key><string>"
      + escape(code)
      + "</string><key>settings</key><dict><key>fontStyle</key><string>bold</string></dict></dict>"
      + "<dict><key>scope</key><string>"
      + escape(ignored)
      + "</string><key>settings</key><dict><key>fontStyle</key><string></string></dict></dict>"
      + "</array></dict></plist>",
  )
}

// Match while walking classified runs; only delimiter positions survive.
#let scan(lines, pairs) = {
  let openers = (:)
  let closers = ""
  for pair in pairs {
    openers.insert(pair.first(), pair.last())
    closers += pair.last()
  }
  let stack = ()
  let result = (:)
  for line in lines {
    let key = str(line.number)
    let marks = ()
    let offset = 0
    let pieces = if line.body.has("children") { line.body.children } else { (line.body,) }
    for piece in pieces {
      let eligible = false
      while not piece.has("text") {
        if piece.func() == strong {
          eligible = true
          piece = piece.body
        } else if piece.has("child") { piece = piece.child } else { break }
      }
      let value = piece.at("text", default: "")
      let size = value.len()
      if eligible {
        let found = if size == 1 { singletons.at(value, default: ()) } else if value.contains(
          delimiters,
        ) { value.matches(delimiters) } else { () }
        for found in found {
          let symbol = found.text
          let depth = none
          if symbol in openers {
            depth = stack.len()
            stack.push((openers.at(symbol), key, marks.len()))
          } else if closers.contains(symbol) {
            if stack.len() > 0 and stack.last().first() == symbol {
              let _ = stack.pop()
              depth = stack.len()
            }
          } else { continue }
          marks.push((offset + found.start, depth))
        }
      }
      offset += size
    }
    if marks.len() > 0 { result.insert(key, marks) }
  }
  for (_, line, index) in stack { result.at(line).at(index).at(1) = none }
  result
}

#let replace-leaf(piece, body) = {
  if piece.has("text") { body } else if piece.has("child") {
    (piece.func())(replace-leaf(piece.child, body), piece.styles)
  } else {
    let fields = piece.fields()
    fields.body = replace-leaf(fields.body, body)
    (piece.func())(..fields)
  }
}

#let paint(body, marks, colors, depth-offset, unmatched) = {
  let pieces = if body.has("children") { body.children } else { (body,) }
  let output = ()
  let offset = 0
  let next = 0
  for original in pieces {
    if next == marks.len() {
      output.push(original)
      continue
    }
    let piece = original
    while not piece.has("text") {
      if piece.has("child") { piece = piece.child } else { piece = piece.body }
    }
    let value = piece.text
    let end = offset + value.len()
    if marks.at(next).first() < end {
      let parts = ()
      let start = 0
      while next < marks.len() and marks.at(next).first() < end {
        let (position, depth) = marks.at(next)
        let color = if depth == none { unmatched } else {
          colors.at(calc.rem(depth + depth-offset, colors.len()))
        }
        if color != none {
          let at = position - offset
          if at > start { parts.push(text(value.slice(start, at))) }
          parts.push(text(fill: color, value.slice(at, at + 1)))
          start = at + 1
        }
        next += 1
      }
      if start == 0 { output.push(original) } else {
        if start < value.len() { parts.push(text(value.slice(start))) }
        output.push(replace-leaf(original, parts.join()))
      }
    } else { output.push(original) }
    offset = end
  }
  output.join()
}

#let capture(body, origin, key, pairs: none) = {
  show raw: it => [#metadata((
    origin: origin,
    key: key,
    value: if pairs == none { it.lines } else { scan(it.lines, pairs) },
  ))<__codly-rainbow>]
  body
}

#let resource(value, inherited, name) = {
  let safe = type(value) != str and (type(value) != array or value.all(v => type(v) != str))
  assert(
    safe or value == inherited,
    message: "codly: rainbow cannot copy an explicit string `raw."
      + name
      + "`; use `path(...)` or `read(..., encoding: none)`",
  )
  if safe { ((name): value) } else { (:) }
}

#let paint-lines(lines, marks, settings) = {
  for (key, positions) in marks {
    let i = int(key) - 1
    let line = lines.at(i)
    lines.at(i) = raw.line(line.number, line.count, line.text, paint(
      line.body,
      positions,
      settings.palette,
      settings.depth-offset,
      settings.unmatched,
    ))
  }
  lines
}

// Single-language blocks render directly; sublanguages share one metadata query.
#let prepare(source, settings, sublangs, render) = context {
  let origin = here()
  let syntax = resource(source.syntaxes, raw.syntaxes, "syntaxes")
  let classifier = theme(settings.code-scopes, settings.ignore-scopes)
  let parent-text = source.text
  let segments = if sublangs == none { () } else { sublangs }
  if segments.len() == 0 {
    let size = text.size
    let font = text.font
    return {
      show raw: it => {
        set text(size: size, font: font)
        render(paint-lines(source.lines, scan(it.lines, settings.pairs), settings))
      }
      raw(
        parent-text,
        block: true,
        lang: source.lang,
        tab-size: source.tab-size,
        theme: classifier,
        ..syntax,
      )
    }
  }
  if segments.len() > 0 {
    let rows = source.text.split(regex("\r\n|\r|\n"))
    let parent = rows
    let display-theme = resource(source.theme, raw.theme, "theme")
    for (index, segment) in segments.enumerate() {
      let code = rows.slice(segment.start - 1, segment.end).join("\n")
      for i in range(segment.start - 1, segment.end) { parent.at(i) = "" }
      capture(
        raw(
          code,
          block: true,
          lang: segment.lang,
          tab-size: source.tab-size,
          theme: classifier,
          ..syntax,
        ),
        origin,
        "marks-" + str(index),
        pairs: settings.pairs,
      )
      capture(
        raw(
          code,
          block: true,
          lang: segment.lang,
          tab-size: source.tab-size,
          ..display-theme,
          ..syntax,
        ),
        origin,
        "lines-" + str(index),
      )
    }
    parent-text = parent.join("\n")
  }
  capture(
    raw(
      parent-text,
      block: true,
      lang: source.lang,
      tab-size: source.tab-size,
      theme: classifier,
      ..syntax,
    ),
    origin,
    "parent",
    pairs: settings.pairs,
  )
  context {
    let records = (:)
    for record in query(selector(<__codly-rainbow>).after(origin).before(here())) {
      if record.value.origin == origin { records.insert(record.value.key, record.value.value) }
    }
    // Speculative measurement cannot see its own metadata; color changes no metrics.
    if records.len() != 1 + 2 * segments.len() { return render(source.lines) }
    let lines = source.lines
    let marks = records.at("parent")
    for (index, segment) in segments.enumerate() {
      let local-marks = records.at("marks-" + str(index))
      for (i, line) in records.at("lines-" + str(index)).enumerate() {
        let number = segment.start + i
        lines.at(number - 1) = raw.line(number, lines.len(), line.text, line.body)
        let key = str(number)
        if key in marks { let _ = marks.remove(key) }
        let found = local-marks.at(str(i + 1), default: ())
        if found.len() > 0 { marks.insert(key, found) }
      }
    }
    render(paint-lines(lines, marks, settings))
  }
}
