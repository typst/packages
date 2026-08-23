// Internal public API implementation for blockst.
// This module may define private helpers (e.g. _normalize-source)
// that are not re-exported by the package entrypoint.

#import "options.typ": get-options, scratch-block-options

// Generic parser/renderer — supports all 26 WASM locales
#import "text/parser.typ": parse-scratch-text as _generic-parse, render-scratch-text as _generic-render

#import "text/execute.typ": execute-scratch-text

#let _blockst-label-store = state("blockst-label-store", (:))

#let _with-local-options(
  theme: auto,
  scale: auto,
  line-numbering: auto,
  line-numbers: auto,
  line-number-start: auto,
  line-number-first-block: auto,
  line-number-gutter: auto,
  inset-scale: auto,
  language: auto,
  body,
) = context {
  if theme == auto and scale == auto and line-numbering == auto and line-numbers == auto and line-number-start == auto and line-number-first-block == auto and line-number-gutter == auto and inset-scale == auto and language == auto {
    return body
  }

  let previous-opts = get-options()
  let resolved-opts = previous-opts
  resolved-opts.theme = if theme == auto { previous-opts.at("theme", default: "normal") } else { theme }
  resolved-opts.scale = if scale == auto { previous-opts.at("scale", default: 100%) } else { scale }
  resolved-opts.insert("line-numbering", if line-numbering == auto { previous-opts.at("line-numbering", default: none) } else { line-numbering })
  resolved-opts.insert("line-numbers", if line-numbers == auto { previous-opts.at("line-numbers", default: false) } else { line-numbers })
  resolved-opts.insert("line-number-start", if line-number-start == auto { previous-opts.at("line-number-start", default: 1) } else { line-number-start })
  resolved-opts.insert("line-number-first-block", if line-number-first-block == auto { previous-opts.at("line-number-first-block", default: 1) } else { line-number-first-block })
  resolved-opts.insert("line-number-gutter", if line-number-gutter == auto { previous-opts.at("line-number-gutter", default: 24) } else { line-number-gutter })
  resolved-opts.insert("inset-scale", if inset-scale == auto { previous-opts.at("inset-scale", default: 1.0) } else { inset-scale })
  resolved-opts.insert("language", if language == auto { previous-opts.at("language", default: "en") } else { language })
  [
    #hide(scratch-block-options.update(_ => resolved-opts))
    #body
    #hide(scratch-block-options.update(_ => previous-opts))
  ]
}

/// Optional container for grouped blocks with theme/scale override.
/// Only needed when a specific group should differ from global settings.
#let blockst(
  theme: auto,
  scale: auto,
  line-numbering: auto,
  line-numbers: auto,
  line-number-start: auto,
  line-number-first-block: auto,
  line-number-gutter: auto,
  inset-scale: auto,
  language: auto,
  spacing: 1.5em,
  body,
) = context {
  _with-local-options(
    theme: theme,
    scale: scale,
    line-numbering: line-numbering,
    line-numbers: line-numbers,
    line-number-start: line-number-start,
    line-number-first-block: line-number-first-block,
    line-number-gutter: line-number-gutter,
    inset-scale: inset-scale,
    language: language,
    stack(spacing: spacing, body),
  )
}

/// Global settings applied to all scratch() and sb3 calls.
#let set-blockst(
  theme: none,
  scale: none,
  stroke-width: none,
  font: none,
  line-numbering: none,
  line-numbers: none,
  line-number-start: none,
  line-number-first-block: none,
  line-number-gutter: none,
  inset-scale: none,
  language: none,
) = {
  scratch-block-options.update(old => {
    let new-opts = old
    if theme != none { new-opts.insert("theme", theme) }
    if scale != none { new-opts.insert("scale", scale) }
    if stroke-width != none { new-opts.insert("stroke-width", stroke-width) }
    if font != none { new-opts.insert("font", font) }
    if line-numbering != none { new-opts.insert("line-numbering", line-numbering) }
    if line-numbers != none { new-opts.insert("line-numbers", line-numbers) }
    if line-number-start != none { new-opts.insert("line-number-start", line-number-start) }
    if line-number-first-block != none { new-opts.insert("line-number-first-block", line-number-first-block) }
    if line-number-gutter != none { new-opts.insert("line-number-gutter", line-number-gutter) }
    if inset-scale != none { new-opts.insert("inset-scale", inset-scale) }
    if language != none { new-opts.insert("language", language) }
    new-opts
  })
}

#let _normalize-source(elements) = {
  if type(elements) == content and elements.func() == raw {
    elements = elements.text
  }
  if type(elements) == str { elements } else { str(elements) }
}

#let _collect-labels-from-nodes(nodes) = {
  let out = (:)
  let queue = nodes
  let index = 0

  while index < queue.len() {
    let node = queue.at(index)
    index += 1

    if type(node) != dictionary {
      continue
    }

    let label = node.at("label", default: none)
    let line = node.at("line", default: none)
    if label != none and line != none {
      out.insert(str(label), line)
    }

    for child in node.at("body", default: ()) {
      queue.push(child)
    }
    for child in node.at("else-body", default: ()) {
      queue.push(child)
    }
  }

  out
}

#let _merge-labels(labels) = {
  if labels.len() == 0 {
    return none
  }
  _blockst-label-store.update(old => {
    let merged = old
    for (k, v) in labels.pairs() {
      merged.insert(k, v)
    }
    merged
  })
}

/// Render scratch blocks from text. Works standalone or inside #blockst[].
/// Supports 26 languages: en, de, fr, es, it, pt, nl, pl, ru, ja, ...
#let scratch(
  text,
  language: auto,
  theme: auto,
  scale: auto,
  line-numbering: auto,
  line-numbers: auto,
  line-number-start: auto,
  line-number-first-block: auto,
  line-number-gutter: auto,
  inset-scale: auto,
) = context {
  let opts = get-options()
  let lang = if language != auto { language } else { opts.at("language", default: "en") }
  let source = _normalize-source(text)
  let labels = _collect-labels-from-nodes(_generic-parse(source, language: lang))
  _with-local-options(
    theme: theme,
    scale: scale,
    line-numbering: line-numbering,
    line-numbers: line-numbers,
    line-number-start: line-number-start,
    line-number-first-block: line-number-first-block,
    line-number-gutter: line-number-gutter,
    inset-scale: inset-scale,
    language: lang,
    [
      #hide(_merge-labels(labels))
      #_generic-render(source, language: lang)
    ],
  )
}

/// Parse scratch text to AST (for programmatic use).
#let scratch-parse(text, language: "en") = {
  let text = _normalize-source(text)
  _generic-parse(text, language: language)
}

/// Parse scratch text and return a dictionary mapping #labels to rendered line numbers.
#let scratch-labels(text, language: "en") = {
  _collect-labels-from-nodes(scratch-parse(text, language: language))
}

/// Register labels globally without rendering blocks.
/// Useful when labels are needed before the first #scratch() output appears.
#let blockst-register-labels(text, language: "en") = {
  let parsed = scratch-parse(text, language: language)
  let labels = _collect-labels-from-nodes(parsed)
  hide(_merge-labels(labels))
}

/// Read globally collected line labels from all previously rendered scratch() blocks.
/// With a name: #blockst-labels("start", default: "?")
/// Without a name: returns the full label->line dictionary.
#let blockst-labels(name) = context {
  let labels = _blockst-label-store.final()
  if name == none {
    labels
  } else {
    labels.at(str(name), default: "NaN")
  }
}

/// Execute scratch text, producing scratch-run commands.
#let scratch-execute(text, language: "en") = execute-scratch-text(_normalize-source(text), language: language)

/// Enable scratch code blocks in raw text:
///   #show: raw-scratch()
///   ```scratch
///   move (10) steps
///   ```
/// With language:
///   #show: raw-scratch(language: "de")
#let raw-scratch(..args) = (
  body => {
    show raw.where(block: true, lang: "scratch"): scratch.with(..args)
    body
  }
)
