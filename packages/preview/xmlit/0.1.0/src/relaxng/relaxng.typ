// relaxng: create typechecked XML-authoring functions from a RELAX NG grammar.
//
// `create-from-relaxng` compiles a grammar in RELAX NG *compact syntax*
// (`.rnc`) via a WASM plugin and returns a dictionary containing one
// tag function per element defined in the grammar, plus:
//
//   - `root`:     a template that serializes its body, validates it against
//                 the grammar (panicking with readable errors if invalid),
//                 and renders the XML source. Usable as `#show: root`.
//   - `validate`: validate content or an XML string; returns the raw result
//                 `(valid: bool, errors: (..))` instead of panicking.
//   - `roots`:    the element names allowed as the document root.
//   - `elements`: all element names defined in the grammar.
//
// Example:
//   #import "@preview/xmlit:0.1.0": create-from-relaxng
//   #let (root, foo, bar) = create-from-relaxng(
//     "start = element foo { element bar { attribute baz { text } }* }",
//   )
//   #show: root
//   #foo[#bar(baz: "xx")]

#import "../elem/elem.typ": make-tag
#import "../xml-to-string/xml-to-string.typ": xml-to-string

/// The bundled RELAX NG plugin (see plugin/typst-relaxng in the repository).
#let relaxng-plugin = plugin("relaxng.wasm")

/// Format the errors of a `(valid: false, errors: (..))` validation result
/// into a readable multi-line string.
#let format-errors(result) = {
  result.errors.map(e => {
    let loc = if e.at("line", default: none) != none {
      " (line " + str(e.line) + ", column " + str(e.column) + ")"
    } else {
      ""
    }
    "- " + e.message + loc
  }).join("\n")
}

/// Create XML-authoring functions from a RELAX NG grammar (compact syntax).
///
/// Returns a dictionary with one tag function per element defined in the
/// grammar plus the reserved keys `root`, `validate`, `roots`, and
/// `elements` (reserved keys win if the grammar defines elements with those
/// names). Destructure what you need:
///
///   #let (root, foo, bar) = create-from-relaxng(rnc)
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
  let validate = doc => {
    let xml-str = if type(doc) == str { doc } else { xml-to-string(doc, handlers: handlers) }
    json(p.validate(rnc-bytes, bytes(xml-str)))
  }

  // Validating template: serialize the body, panic on validation errors,
  // render the XML source on success. Use as `#show: root`.
  let root = body => {
    let xml-str = xml-to-string(body, handlers: handlers)
    let result = json(p.validate(rnc-bytes, bytes(xml-str)))
    if not result.valid {
      panic(
        "XML failed RELAX NG validation:\n" + format-errors(result)
          + "\nDocument was: " + xml-str,
      )
    }
    raw(xml-str, lang: "xml", block: true)
  }

  let tags = (:)
  for name in info.elements {
    tags.insert(name, make-tag(name, handlers: handlers))
  }

  tags + (
    root: root,
    validate: validate,
    roots: info.roots,
    elements: info.elements,
  )
}
