// relaxng: create typechecked XML-authoring functions from a RELAX NG grammar.
//
// `create-from-relaxng` compiles a grammar in RELAX NG *compact syntax*
// (`.rnc`) via a WASM plugin and returns a dictionary with two entries:
//
//   - `elements`: a dictionary mapping each element name defined in the
//                 grammar to its tag function.
//   - `utils`:    grammar-level helpers:
//     - `render`: a template that serializes its body and renders the XML
//       source, without validating. Usable as `#show: utils.render`.
//     - `validate-and-render`: a template that serializes its body,
//       validates it against the grammar (panicking with readable errors if
//       invalid), and renders the XML source. Usable as
//       `#show: utils.validate-and-render`.
//     - `render-and-show-validation-errors`: like `validate-and-render`, but
//       instead of panicking it renders the XML source and highlights the
//       offending element(s) in place with each error message. Usable as
//       `#show: utils.render-and-show-validation-errors`.
//     - `validate`: validate content or an XML string; returns the raw
//       result `(valid: bool, errors: (..))` instead of panicking.
//     - `roots`: the element names allowed as the document root.
//
// Example:
//   #import "@preview/xmlit:0.1.0": create-from-relaxng
//   #let (utils, elements) = create-from-relaxng(
//     "start = element foo { element bar { attribute baz { text } }* }",
//   )
//   #let (foo, bar) = elements
//   #show: utils.validate-and-render
//   #foo[#bar(baz: "xx")]

#import "../elem/elem.typ": make-tag
#import "../xml-to-string/xml-to-string.typ": xml-to-string, xml-to-string-with-ranges

/// The bundled RELAX NG plugin (see plugin/typst-relaxng in the repository).
#let relaxng-plugin = plugin("relaxng.wasm")

/// Given `ranges` from `xml-to-string-with-ranges` and a byte `offset` (a
/// validator error position), return the `path` of the deepest element whose
/// `[start, end)` contains the offset, or `none` if none does. "Deepest" = the
/// tightest containing range, i.e. the most specific element.
#let locate-path(ranges, offset) = {
  let best = none
  for r in ranges {
    if r.start <= offset and offset < r.end {
      if best == none or (r.end - r.start) < (best.end - best.start) { best = r }
    }
  }
  if best == none { none } else { best.path }
}

/// 1-based line number of byte `offset` within `text`.
#let line-of(text, offset) = text.slice(0, offset).split("\n").len()

// A wavy ("squiggle") underline of the given width, for marking an error span
// the way an editor does.
#let _squiggle(width, color: rgb("#cc0000")) = {
  let period = 2.4pt
  let amp = 1.1pt
  let n = calc.max(2, int(width / period))
  let step = width / n
  let verts = range(n + 1).map(i => (i * step, if calc.even(i) { 0pt } else { amp }))
  box(width: width, height: amp, curve(
    stroke: 0.6pt + color,
    curve.move(verts.first()),
    ..verts.slice(1).map(v => curve.line(v)),
  ))
}

// Draw `body` with a squiggle underline beneath it. The squiggle is anchored
// to `body`'s own box, so it stays under the right glyphs even as the
// surrounding line wraps.
#let _squiggle-under(body) = box({
  body
  context place(bottom + left, dy: 2pt, _squiggle(measure(body).width))
})

// Rebuild a source line, wrapping each error span (a byte `(col, span)` within
// the line, clipped to the line's end) in a squiggle underline while leaving
// the rest as ordinary syntax-highlighted XML. `spans` may be empty.
#let _underline-spans(line-text, spans) = {
  let sorted = spans.sorted(key: s => s.col)
  let pos = 0
  let out = ()
  for s in sorted {
    let a = calc.max(pos, s.col)
    let b = calc.min(line-text.len(), s.col + s.span)
    if a > pos { out.push(raw(line-text.slice(pos, a), lang: "xml")) }
    if b > a {
      out.push(_squiggle-under(raw(line-text.slice(a, b), lang: "xml")))
      pos = b
    }
  }
  if pos < line-text.len() { out.push(raw(line-text.slice(pos), lang: "xml")) }
  out.join()
}

// Tunables for the snippet shown under a located error. Character counts
// (not bytes) -- see the char-index conversion inside `snippet-at`.
#let _snippet-context-lines = 2
#let _snippet-max-line-chars = 120
#let _snippet-window-chars = 60
#let _snippet-max-marked-chars = 60
#let _snippet-max-errors = 5

// `array.join` returns `none` (not "") for an empty array; normalize so the
// windowing code below always gets a string back from a cluster slice.
#let _joined(cls) = {
  let s = cls.join("")
  if s == none { "" } else { s }
}

// Convert a byte offset within `text` to a character (grapheme cluster)
// index by walking clusters and summing byte lengths -- keeps all
// subsequent windowing/padding in character units (safe for multi-byte
// content and correct for monospace alignment), even though the plugin's
// positions and the ranges machinery are byte offsets throughout.
#let _char-index-of(text, byte-offset) = {
  let pos = 0
  let idx = 0
  for c in text.clusters() {
    if pos >= byte-offset { break }
    pos += c.len()
    idx += 1
  }
  idx
}

// Cap a non-target context line to a bounded number of characters from its
// start (no error position on it to center a window around).
#let _capped-line(text) = {
  let cls = text.clusters()
  if cls.len() <= _snippet-max-line-chars {
    text
  } else {
    cls.slice(0, _snippet-max-line-chars).join("") + "…"
  }
}

// Build the target line's displayed (possibly windowed) text plus a
// caret-underline beneath it, both bounded in character count regardless of
// the line's real length. The marked span itself is windowed too (head "…"
// tail): a long invalid element -- e.g. a mixed-content <p> full of prose --
// would otherwise reproduce, carets and all, the very wall of text this
// machinery exists to avoid.
#let _target-line-snippet(text, start-idx, end-idx) = {
  let cls = text.clusters()
  let needs-window = cls.len() > _snippet-max-line-chars
  let lo = if needs-window { calc.max(0, start-idx - _snippet-window-chars) } else { 0 }
  let hi = if needs-window { calc.min(cls.len(), end-idx + _snippet-window-chars) } else { cls.len() }
  let before = (if needs-window and lo > 0 { "…" } else { "" }) + _joined(cls.slice(lo, start-idx))
  let marked = _joined(cls.slice(start-idx, end-idx))
  let mcls = marked.clusters()
  if mcls.len() > _snippet-max-marked-chars {
    let half = calc.quo(_snippet-max-marked-chars, 2)
    marked = _joined(mcls.slice(0, half)) + "…" + _joined(mcls.slice(mcls.len() - half))
  }
  let after = _joined(cls.slice(end-idx, hi)) + (if needs-window and hi < cls.len() { "…" } else { "" })
  (
    text: before + marked + after,
    pad: " " * before.clusters().len(),
    carets: "^" * calc.max(marked.clusters().len(), 1),
  )
}

/// Build a small line-numbered, character-windowed excerpt of `text` around
/// the byte range `[start, end)` (see `format-errors` for the two-level,
/// bounded-size windowing rationale), with the target line's span
/// underlined. `start`/`end` must be valid byte positions within `text`.
///
/// This is the shared core `error-snippet` builds on top of (after mapping
/// a validator offset to an authored element's position in the pretty
/// string). It needs no element-path structure itself, so it also works
/// directly on a raw XML string passed to `validate` -- there `start`/`end`
/// are already byte offsets into that exact string (it IS both what was
/// validated and what to excerpt), no path-mapping step required.
#let snippet-at(text, start, end) = {
  let lines = text.split("\n")
  let target = line-of(text, start)
  let col = text.slice(0, start).split("\n").last().len()
  let target-text = lines.at(target - 1)
  let span = calc.min(end - start, target-text.len() - col)

  let tl = _target-line-snippet(target-text, _char-index-of(target-text, col), _char-index-of(target-text, col + span))

  let lo = calc.max(1, target - _snippet-context-lines)
  let hi = calc.min(lines.len(), target + _snippet-context-lines)
  let width = str(hi).len()
  let pad-num(n) = " " * (width - str(n).len()) + str(n)

  range(lo, hi + 1).map(n => {
    let gutter = if n == target { "> " } else { "  " }
    let prefix = gutter + pad-num(n) + " | "
    if n == target {
      let caret-line = " " * (width + 5) + tl.pad + tl.carets
      prefix + tl.text + "\n" + caret-line
    } else {
      prefix + _capped-line(lines.at(n - 1))
    }
  }).join("\n")
}

/// Locate a single error's byte offset -> deepest element -> that element's
/// line in the pretty-printed source, and render a small line-numbered
/// window around it via `snippet-at`. Returns `none` if the error has no
/// position or can't be mapped to an element (e.g. `TextBufferOverflow`, or
/// `doc` was a raw XML string rather than authored content, which carries
/// no element path structure -- use `snippet-at` on that string directly
/// instead, no mapping needed).
///
/// `compact-ranges`/`pretty` are as in `format-errors`. `e` is a single
/// entry from a `(valid: false, errors: (..))` validation result.
#let error-snippet(compact-ranges, pretty, e) = {
  if e.at("start", default: none) == none { return none }
  let path = locate-path(compact-ranges, e.start)
  if path == none { return none }
  let drange = pretty.ranges.find(r => r.path == path)
  if drange == none { return none }
  snippet-at(pretty.xml, drange.start, drange.end)
}

/// Format the errors of a `(valid: false, errors: (..))` validation result
/// into a readable multi-line string, with a small windowed snippet of the
/// pretty-printed source around each error's location instead of dumping the
/// whole document. `compact-ranges` is the `ranges` from
/// `xml-to-string-with-ranges` of the COMPACT serialization (the one
/// actually validated; used to locate each error's byte offset via
/// `locate-path`). `pretty` is `(xml: str, ranges: array)` from
/// `xml-to-string-with-ranges(..., pretty-print: true)` of the SAME tree
/// (used to build the displayed snippet).
///
/// Pretty-printing only breaks lines between all-element children (see
/// `xml-to-string`'s `pretty-print`); mixed content -- e.g. a `<p>` full of
/// prose -- stays on one line however long, and in the extreme a whole
/// document can pretty-print to a single line with no newlines at all. So
/// the target line itself is ALSO windowed to a bounded number of characters
/// around the error (not just "N lines of context") -- that inner windowing
/// is what actually guarantees a bounded snippet regardless of document
/// shape.
#let format-errors(result, compact-ranges, pretty) = {
  // No "(line, column)" suffix here: this is always called on authored
  // content (from `validate-and-render`), where those positions are offsets
  // into an invisible, internally-generated compact string the user never
  // sees or writes -- meaningless without the snippet, which already shows
  // the actual location relative to the readable pretty-printed source.
  let entries = result.errors.map(e => {
    let snippet = error-snippet(compact-ranges, pretty, e)
    "- " + e.message + (if snippet == none { "" } else { "\n" + snippet })
  })

  let shown = entries.slice(0, calc.min(entries.len(), _snippet-max-errors))
  let rest = entries.len() - shown.len()
  shown.join("\n\n") + (if rest > 0 { "\n\n...and " + str(rest) + " more error(s)" } else { "" })
}

/// Create XML-authoring functions from a RELAX NG grammar (compact syntax).
///
/// Returns `(elements: (..), utils: (..))` -- destructure it directly:
///
///   #let (utils, elements) = create-from-relaxng(rnc)
///
/// - `elements` maps each element name defined in the grammar to its tag
///   function; destructure what you need: `#let (foo, bar) = elements`
/// - `utils` holds the grammar-level helpers `render` (a `#show:` template
///   that serializes its body and renders the XML source WITHOUT validating
///   -- for fast iteration; accepts `pretty-print`), `validate-and-render`
///   (a `#show:` template that validates its body and renders the XML
///   source, panicking with readable errors if invalid; also accepts
///   `pretty-print` -- `#show: utils.validate-and-render.with(pretty-print:
///   true)`), `render-and-show-validation-errors` (a `#show:` template that,
///   instead of panicking, renders the XML source and highlights the offending
///   element(s) with their messages in place -- for authoring/preview; also
///   accepts `pretty-print`, default true), `validate` (non-panicking; returns
///   `(valid: bool, errors: (..))`), and `roots` (the element names allowed as
///   the document root).
///
/// - `rnc`: the grammar source (str or bytes), or -- for grammars split
///   across several files with `include`/`external` -- a dictionary mapping
///   file names to file contents. The FIRST entry is the entry point:
///     create-from-relaxng((
///       "pretext.rnc": read("pretext.rnc"),
///       "pf-adapter.rnc": read("pf-adapter.rnc"),
///       ...
///     ))
/// - `handlers`: forwarded to `make-tag` -- overrides for how Typst content
///   (markup, math, ...) is converted to XML.
/// - `wasm`: the validator plugin; defaults to the bundled one. Pass a
///   `plugin(...)` module or raw wasm bytes to substitute your own build.
#let create-from-relaxng(rnc, handlers: auto, wasm: auto) = {
  let p = if wasm == auto {
    relaxng-plugin
  } else if type(wasm) == bytes {
    plugin(wasm)
  } else {
    wasm
  }
  // Multi-file grammars are sent as a JSON VFS object (the plugin detects
  // the leading "{"); single grammars are sent verbatim.
  let rnc-bytes = if type(rnc) == dictionary {
    bytes(json.encode(rnc))
  } else {
    bytes(rnc)
  }
  let info = json(p.list_elements(rnc-bytes))

  // Validate content (authored with the tag functions) or a raw XML string.
  // On failure, each entry in `errors` additionally carries a `snippet`: the
  // same located, windowed source excerpt used in `validate-and-render`'s
  // panic message -- for authored content via `error-snippet`, or directly
  // via `snippet-at` for a raw string (its own text is both what was
  // validated and what to excerpt, so no element-path mapping is needed).
  // `none` only if the error itself has no position (e.g.
  // `TextBufferOverflow`). Ranges/snippets are only computed on this (rare)
  // failure path, so the common valid-input case stays as cheap as before.
  let validate = doc => {
    let is-str = type(doc) == str
    let xml-str = if is-str { doc } else { xml-to-string(doc, handlers: handlers) }
    let result = json(p.validate(rnc-bytes, bytes(xml-str)))
    if result.valid {
      return result
    }
    if is-str {
      // The exact validated string IS the source to excerpt -- window
      // snippets directly around each error's byte offset in it, no
      // element-path mapping needed (that machinery only exists to bridge
      // between separately-serialized compact/pretty representations of
      // AUTHORED content; a raw string has just the one representation).
      return (
        valid: false,
        errors: result.errors.map(e => {
          let snippet = if e.at("start", default: none) == none {
            none
          } else {
            snippet-at(xml-str, e.start, e.at("end", default: e.start))
          }
          e + (snippet: snippet)
        }),
      )
    }
    let compact = xml-to-string-with-ranges(doc, handlers: handlers)
    let pretty = xml-to-string-with-ranges(doc, handlers: handlers, pretty-print: true)
    (
      valid: false,
      errors: result.errors.map(e => {
        // line/column are positions in the invisible, internally-generated
        // compact string -- meaningless for authored content (the user
        // never wrote that string), so drop them; `snippet` already shows
        // the real location relative to the readable pretty-printed source.
        let with-snippet = e + (snippet: error-snippet(compact.ranges, pretty, e))
        let _ = with-snippet.remove("line", default: none)
        let _ = with-snippet.remove("column", default: none)
        with-snippet
      }),
    )
  }

  // Non-validating template: serialize the body and render the XML source,
  // without calling the validator at all. Use as `#show: utils.render`, or
  // with options via `#show: utils.render.with(pretty-print: true)`. Useful
  // while iterating, when paying for a validation round-trip on every render
  // isn't wanted; switch to `validate-and-render` once the document is ready
  // to be checked.
  let render = (body, pretty-print: false) => {
    raw(xml-to-string(body, handlers: handlers, pretty-print: pretty-print), lang: "xml", block: true)
  }

  // Validating template: serialize the body, panic on validation errors,
  // render the XML source on success. Use as
  // `#show: utils.validate-and-render`, or with options via
  // `#show: utils.validate-and-render.with(pretty-print: true)`.
  //
  // Validation always uses the compact serialization (so cosmetic
  // pretty-print whitespace can never affect the result); only the rendered
  // output is indented when `pretty-print` is true. The panic message uses a
  // windowed snippet of the source around each error's location, not the
  // whole document (see `format-errors`) -- ranges are only computed on this
  // (rare) failure path, so the common valid-input case stays cheap.
  let validate-and-render = (body, pretty-print: false) => {
    let xml-str = xml-to-string(body, handlers: handlers)
    let result = json(p.validate(rnc-bytes, bytes(xml-str)))
    if not result.valid {
      let compact = xml-to-string-with-ranges(body, handlers: handlers)
      let pretty = xml-to-string-with-ranges(body, handlers: handlers, pretty-print: true)
      panic(
        "XML failed RELAX NG validation:\n" + format-errors(result, compact.ranges, pretty),
      )
    }
    let display = if pretty-print {
      xml-to-string(body, handlers: handlers, pretty-print: true)
    } else {
      xml-str
    }
    raw(display, lang: "xml", block: true)
  }

  // Non-panicking, error-locating template: serialize and render the body's
  // XML source, but when validation fails, highlight the offending element(s)
  // in place and show each message next to the element it belongs to (instead
  // of aborting the compile like `validate-and-render`). Use as
  // `#show: utils.render-and-show-validation-errors`, or with options via
  // `.with(pretty-print: false)`.
  //
  // Validation still runs on the compact serialization (so cosmetic
  // pretty-print whitespace can never affect the result); the plugin's
  // byte-offset error positions are mapped to the specific element via
  // `xml-to-string-with-ranges`, then to that element's line in the rendered
  // (pretty by default) output. Ranges are only computed on the failure
  // path -- the cheap, ranges-free `xml-to-string` handles the common
  // valid-input case (mirrors `validate-and-render` and the plugin's own
  // fast-validate/slow-diagnostic split).
  let render-and-show-validation-errors = (body, pretty-print: true) => {
    let xml-str = xml-to-string(body, handlers: handlers)
    let result = json(p.validate(rnc-bytes, bytes(xml-str)))

    if result.valid {
      let display-str = if pretty-print {
        xml-to-string(body, handlers: handlers, pretty-print: true)
      } else {
        xml-str
      }
      return raw(display-str, lang: "xml", block: true)
    }

    let compact = xml-to-string-with-ranges(body, handlers: handlers, pretty-print: false)
    let display = xml-to-string-with-ranges(body, handlers: handlers, pretty-print: pretty-print)

    // Map each error -> deepest offending element -> that element's line in the
    // displayed source. Errors that can't be tied to an element are listed
    // separately below the block.
    let messages-by-line = (:)
    let spans-by-line = (:)
    let unlocated = ()
    for e in result.errors {
      // `start` is none (JSON null) for positionless errors (e.g. the
      // plugin's internal buffer/pattern limits) -- those can't be tied to
      // an element, so they fall through to the `unlocated` list.
      let start = e.at("start", default: none)
      let path = if start == none { none } else { locate-path(compact.ranges, start) }
      let drange = if path == none { none } else { display.ranges.find(r => r.path == path) }
      if drange == none {
        unlocated.push(e.message)
      } else {
        let key = str(line-of(display.xml, drange.start))
        messages-by-line.insert(key, messages-by-line.at(key, default: ()) + (e.message,))
        // Byte column of the element's start within its line, plus the
        // element's full byte length (clipped to the line by `_underline-spans`).
        let col = display.xml.slice(0, drange.start).split("\n").last().len()
        spans-by-line.insert(key, spans-by-line.at(key, default: ()) + ((col: col, span: drange.end - drange.start),))
      }
    }

    // Render the source as a single-column grid, one row per line. A grid
    // (rather than a `raw` block + `show raw.line`) is used because the
    // squiggle underlines are themselves `raw`, which would recurse through a
    // `raw.line` show rule. `row-gutter: 0` + a per-row `inset` make the red
    // fill of consecutive error lines touch (contiguous) while still giving
    // every line vertical breathing room.
    let arrow = place(top + left, dx: -1em, text(fill: rgb("#cc0000"), size: 0.85em)[←])
    {
      grid(
        columns: (1fr,),
        row-gutter: 0pt,
        inset: (x: 4pt, y: 3pt),
        fill: (_, row) => if str(row + 1) in messages-by-line { rgb("#ffe3e3") } else { none },
        ..display.xml.split("\n").enumerate().map(((i, line-text)) => {
          let key = str(i + 1)
          let msgs = messages-by-line.at(key, default: ())
          if msgs.len() > 0 {
            // The message lives in a reserved right column so a wrapping
            // message stays within its own block (never wrapping back under
            // the source); the `←` is `place`d into the gutter so it hangs to
            // the left of the message text instead of being part of the flow.
            grid(
              columns: (1fr, 40%),
              column-gutter: 1.4em,
              // Source line with the offending span(s) squiggle-underlined.
              _underline-spans(line-text, spans-by-line.at(key, default: ())),
              {
                arrow
                text(fill: rgb("#cc0000"), size: 0.85em, style: "italic")[#msgs.join("; ")]
              },
            )
          } else {
            raw(line-text, lang: "xml")
          }
        }),
      )
      for m in unlocated {
        text(fill: rgb("#cc0000"), size: 0.85em)[⚠ #m]
        linebreak()
      }
    }
  }

  let tags = (:)
  for name in info.elements {
    tags.insert(name, make-tag(name, handlers: handlers))
  }

  (
    elements: tags,
    utils: (
      render: render,
      validate-and-render: validate-and-render,
      render-and-show-validation-errors: render-and-show-validation-errors,
      validate: validate,
      roots: info.roots,
    ),
  )
}
