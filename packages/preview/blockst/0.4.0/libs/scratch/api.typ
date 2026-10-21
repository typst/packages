// Internal public API implementation for blockst.
// This module may define private helpers (e.g. _normalize-source)
// that are not re-exported by the package entrypoint.

#import "options.typ": get-options, scratch-block-options

// Generic parser/renderer — supports all 26 WASM locales
#import "text/parser.typ": parse-scratch-text as _generic-parse, render-scratch-text as _generic-render

#import "text/execute.typ": execute-scratch-text

#let _blockst-label-store = state("blockst-label-store", (:))

/// Apply per-call overrides for the duration of `body`.
///
/// Both state updates are pure functions of the previous value: the entry
/// merges the overrides into whatever is current and pushes the old options
/// onto a stack kept inside the state, the exit pops that stack. Nothing read
/// through introspection is written back, so a document with any number of
/// calls converges in two passes. (Restoring a captured copy of the options
/// instead made each call depend on the previous pass, and two `blockly()`
/// calls after `set-blockst(profile: …)` never settled.)
#let _with-local-options(
  theme: auto,
  scale: auto,
  font: auto,
  line-numbering: auto,
  line-numbers: auto,
  line-number-start: auto,
  line-number-first-block: auto,
  line-number-gutter: auto,
  inset-scale: auto,
  language: auto,
  colors: auto,
  body,
) = {
  let local = (:)
  if theme != auto { local.insert("theme", theme) }
  if scale != auto { local.insert("scale", scale) }
  if font != auto { local.insert("font", font) }
  if line-numbering != auto { local.insert("line-numbering", line-numbering) }
  if line-numbers != auto { local.insert("line-numbers", line-numbers) }
  if line-number-start != auto { local.insert("line-number-start", line-number-start) }
  if line-number-first-block != auto { local.insert("line-number-first-block", line-number-first-block) }
  if line-number-gutter != auto { local.insert("line-number-gutter", line-number-gutter) }
  if inset-scale != auto { local.insert("inset-scale", inset-scale) }
  if language != auto { local.insert("language", language) }
  if colors != auto { local.insert("colors", colors) }
  if local.len() == 0 {
    return body
  }
  [
    #hide(scratch-block-options.update(old => {
      let saved = old
      let _ = saved.remove("_saved", default: none)
      let new = old + local
      // Local colours are laid over the global ones, category by category.
      if "colors" in local {
        new.insert("colors", old.at("colors", default: (:)) + local.colors)
      }
      new.insert("_saved", old.at("_saved", default: ()) + (saved,))
      new
    }))
    #body
    #hide(scratch-block-options.update(old => {
      let stack = old.at("_saved", default: ())
      if stack.len() == 0 { return old }
      let restored = stack.last()
      if stack.len() > 1 { restored.insert("_saved", stack.slice(0, -1)) }
      restored
    }))
  ]
}

/// Optional container for grouped blocks with theme/scale override.
/// Only needed when a specific group should differ from global settings.
#let blockst(
  theme: auto,
  scale: auto,
  font: auto,
  line-numbering: auto,
  line-numbers: auto,
  line-number-start: auto,
  line-number-first-block: auto,
  line-number-gutter: auto,
  inset-scale: auto,
  language: auto,
  colors: auto,
  spacing: 1.5em,
  body,
) = context {
  _with-local-options(
    theme: theme,
    scale: scale,
    font: font,
    line-numbering: line-numbering,
    line-numbers: line-numbers,
    line-number-start: line-number-start,
    line-number-first-block: line-number-first-block,
    line-number-gutter: line-number-gutter,
    inset-scale: inset-scale,
    language: language,
    colors: colors,
    stack(spacing: spacing, body),
  )
}

/// Global settings applied to all scratch() and sb3 calls.
///
/// `colors` lays the document's own category colours over the profile's
/// palette: `set-blockst(colors: (logik: "#73cc47"))` — a hex string or a
/// Typst colour per category. The shades a theme derives (bevel, stroke,
/// high-contrast, grayscale) follow the new fill.
#let set-blockst(
  theme: none,
  profile: none,
  colors: none,
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
    if profile != none { new-opts.insert("profile", profile) }
    if colors != none { new-opts.insert("colors", new-opts.at("colors", default: (:)) + colors) }
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

/// Render scratch blocks from text. Works standalone or inside `#blockst[...]`.
/// Supports 26 languages: en, de, fr, es, it, pt, nl, pl, ru, ja, ...
#let scratch(
  text,
  language: auto,
  theme: auto,
  scale: auto,
  font: auto,
  line-numbering: auto,
  line-numbers: auto,
  line-number-start: auto,
  line-number-first-block: auto,
  line-number-gutter: auto,
  inset-scale: auto,
  colors: auto,
) = context {
  let opts = get-options()
  let lang = if language != auto { language } else { opts.at("language", default: "en") }
  let source = _normalize-source(text)
  let labels = _collect-labels-from-nodes(_generic-parse(source, language: lang, profile: "scratch"))
  _with-local-options(
    theme: theme,
    scale: scale,
    font: font,
    line-numbering: line-numbering,
    line-numbers: line-numbers,
    line-number-start: line-number-start,
    line-number-first-block: line-number-first-block,
    line-number-gutter: line-number-gutter,
    inset-scale: inset-scale,
    language: lang,
    colors: colors,
    [
      #hide(_merge-labels(labels))
      #_generic-render(source, language: lang, profile: "scratch")
    ],
  )
}

/// Render Blockly blocks from text. Same notation as `scratch()`, drawn with
/// Blockly's shapes — notch, puzzle tab, boxed fields — and the vocabulary,
/// categories and colours of a profile:
///
/// - `"blockly"` (the default): today's flat look, Blockly's German wording
/// - `"blockly-klassisch"`: the pre-2019 look
/// - `"jwinf"`: jwinf.de — classic geometry, the robot and turtle world
///   blocks, and the palette of the robot training tasks
/// - `"jwinf-turtle"`: the same with the colours of the Freie Turtle-Umgebung
///
/// `colors: (logik: "#73cc47")` overrides single categories of any profile.
///
/// Labels that no profile knows are drawn as written, with the category
/// taken from a `::kategorie` suffix — on jwinf the normal case, because the
/// same block reads differently from task to task.
///
/// ```typ
/// #blockly("wiederhole (4) mal:\n  gehe nach rechts\nende", profile: "jwinf")
/// ```
#let blockly(
  text,
  profile: auto,
  language: auto,
  theme: auto,
  scale: auto,
  font: auto,
  line-numbering: auto,
  line-numbers: auto,
  line-number-start: auto,
  line-number-first-block: auto,
  line-number-gutter: auto,
  inset-scale: auto,
  colors: auto,
) = context {
  let opts = get-options()
  let prof = if profile != auto { profile } else { opts.at("profile", default: "blockly") }
  // The standard blocks read Blockly's own message files, 24 languages;
  // the jwinf world blocks exist in German only.
  let lang = if language != auto { language } else { opts.at("language", default: "de") }
  let source = _normalize-source(text)
  let labels = _collect-labels-from-nodes(_generic-parse(source, language: lang, profile: prof))
  _with-local-options(
    theme: theme,
    scale: scale,
    font: font,
    line-numbering: line-numbering,
    line-numbers: line-numbers,
    line-number-start: line-number-start,
    line-number-first-block: line-number-first-block,
    line-number-gutter: line-number-gutter,
    inset-scale: inset-scale,
    language: lang,
    colors: colors,
    [
      #hide(_merge-labels(labels))
      #_generic-render(source, language: lang, profile: prof)
    ],
  )
}

/// Parse Blockly text to AST (for programmatic use).
#let blockly-parse(text, language: "de", profile: "blockly") = {
  _generic-parse(_normalize-source(text), language: language, profile: profile)
}

/// Enable Blockly code blocks in raw text:
///
/// ````typ
/// #show: raw-blockly()
/// ```blockly
/// wiederhole (4) mal:
/// ende
/// ```
/// ````
///
/// A `jwinf` fence uses the jwinf profile whatever the arguments say, a
/// `jwinf-turtle` fence the turtle sandbox's colours.
#let raw-blockly(..args) = (
  body => {
    let jwinf-args = args.named()
    jwinf-args.insert("profile", "jwinf")
    let turtle-args = args.named()
    turtle-args.insert("profile", "jwinf-turtle")
    show raw.where(block: true, lang: "blockly"): blockly.with(..args)
    show raw.where(block: true, lang: "jwinf"): blockly.with(..jwinf-args)
    show raw.where(block: true, lang: "jwinf-turtle"): blockly.with(..turtle-args)
    body
  }
)

/// Render MakeCode blocks from text — the micro:bit and Calliope mini
/// editors' look: Blockly's zelos renderer with MakeCode's monospace labels.
/// Same notation as `scratch()`; `(…)` is a value, `[… v]` a dropdown,
/// `<…>` a boolean, `ende`/`end` closes a C-block and `sonst`/`else` opens
/// the else branch. The profile picks the target: `"makecode"` (micro:bit,
/// the default) or `"makecode-calliope"`; the language is any of the
/// editors' 36 (`"de"` by default, `"en"`, `"fr"`, `"es"`, `"zh-cn"`, …),
/// with the block texts the editors show in that language. The end marker
/// follows the language (`ende`, `end`, `fin`, …); `end` and `ende` work in
/// every language.
///
/// ```typ
/// #makecode("beim Start\n  zeige Zahl (0)\nende")
/// ```
#let makecode(
  text,
  profile: auto,
  language: auto,
  theme: auto,
  scale: auto,
  font: auto,
  line-numbering: auto,
  line-numbers: auto,
  line-number-start: auto,
  line-number-first-block: auto,
  line-number-gutter: auto,
  inset-scale: auto,
  colors: auto,
) = context {
  let opts = get-options()
  let prof = if profile != auto { profile } else {
    let p = opts.at("profile", default: "makecode")
    if p.starts-with("makecode") { p } else { "makecode" }
  }
  let lang = if language != auto { language } else { opts.at("language", default: "de") }
  let source = _normalize-source(text)
  let labels = _collect-labels-from-nodes(_generic-parse(source, language: lang, profile: prof))
  _with-local-options(
    theme: theme,
    scale: scale,
    font: font,
    line-numbering: line-numbering,
    line-numbers: line-numbers,
    line-number-start: line-number-start,
    line-number-first-block: line-number-first-block,
    line-number-gutter: line-number-gutter,
    inset-scale: inset-scale,
    language: lang,
    colors: colors,
    [
      #hide(_merge-labels(labels))
      #_generic-render(source, language: lang, profile: prof)
    ],
  )
}

/// Parse MakeCode text to AST (for programmatic use).
#let makecode-parse(text, language: "de", profile: "makecode") = {
  _generic-parse(_normalize-source(text), language: language, profile: profile)
}

/// Enable MakeCode code blocks in raw text:
///
/// ````typ
/// #show: raw-makecode()
/// ```makecode
/// beim Start
///   zeige Zahl (0)
/// ende
/// ```
/// ````
///
/// A `microbit` fence is the same; a `calliope` fence uses the Calliope mini
/// profile whatever the arguments say.
#let raw-makecode(..args) = (
  body => {
    let calliope-args = args.named()
    calliope-args.insert("profile", "makecode-calliope")
    show raw.where(block: true, lang: "makecode"): makecode.with(..args)
    show raw.where(block: true, lang: "microbit"): makecode.with(..args)
    show raw.where(block: true, lang: "calliope"): makecode.with(..calliope-args)
    body
  }
)

/// Parse scratch text to AST (for programmatic use).
#let scratch-parse(text, language: "en") = {
  let text = _normalize-source(text)
  _generic-parse(text, language: language)
}

/// Parse scratch text and return a dictionary mapping `#labels` to rendered line numbers.
#let scratch-labels(text, language: "en") = {
  _collect-labels-from-nodes(scratch-parse(text, language: language))
}

/// Register labels globally without rendering blocks.
/// Useful when labels are needed before the first `#scratch()` output appears.
#let blockst-register-labels(text, language: "en") = {
  let parsed = scratch-parse(text, language: language)
  let labels = _collect-labels-from-nodes(parsed)
  hide(_merge-labels(labels))
}

/// Read globally collected line labels from all previously rendered `scratch()` blocks.
/// With a name: `#blockst-labels("start", default: "?")`.
/// Without a name: returns the full label-to-line dictionary.
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
///
/// ```typ
/// #show: raw-scratch()
/// ```
///
/// With language: `#show: raw-scratch(language: "de")`.
#let raw-scratch(..args) = (
  body => {
    show raw.where(block: true, lang: "scratch"): scratch.with(..args)
    body
  }
)
