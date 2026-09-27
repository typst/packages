// Fallback shim for Calepin computational notebooks.
//
// This package mirrors the public API of the Calepin runtime so a notebook
// compiles under plain `typst` without the Calepin CLI. Code chunks render as
// static, highlighted listings and a one-time banner explains that nothing was
// executed. When the document is compiled with `calepin compile` or
// `calepin watch`, the CLI rewrites this import to its locally generated
// runtime, so this shim is never loaded there.

#let _chunk-engines = (
  "r", "python", "julia", "sh", "bash",
  "mermaid", "tikz", "dot", "d2",
)

#let _warning-shown = state("calepin-shim-warning-shown", false)
#let _warning-enabled = state("calepin-shim-warning-enabled", true)
#let _echo = state("calepin-shim-echo", true)

#let _warning() = context {
  if _warning-enabled.get() and not _warning-shown.get() {
    _warning-shown.update(true)
    block(
      width: 100%,
      fill: rgb("#fff8d9"),
      stroke: 0.5pt + rgb("#d8b94e"),
      radius: 2pt,
      inset: (x: 0.65em, y: 0.45em),
    )[
      #strong[Calepin warning:] This document was compiled directly with Typst.
      Code chunks are shown unevaluated. Use `calepin compile <file.typ>` to
      execute chunks and render results. See
      #link("https://vincentarelbundock.github.io/calepin")[vincentarelbundock.github.io/calepin].
    ]
  }
}

#let setup(..args) = {
  let opts = args.named()
  if "fallback-warning" in opts {
    _warning-enabled.update(_ => opts.at("fallback-warning"))
  }
  if "echo" in opts {
    _echo.update(_ => opts.at("echo"))
  }
}

#let _body-from-args(args, name) = {
  let positional = args.pos()
  if positional.len() >= 2 and type(positional.at(0)) == str {
    positional.at(1)
  } else if positional.len() >= 1 {
    positional.at(0)
  } else {
    panic("calepin." + name + ": missing code block")
  }
}

// A chunk with a caption option would carry a cross-referenceable label when
// executed. Emit an empty labeled figure so `@fig-...` references degrade to
// "Figure ?" instead of failing the compile.
#let _placeholder-label(opts) = {
  let name = opts.at("label", default: none)
  if name == none { return none }
  let has-caption = ("fig-caption", "tbl-caption", "lst-caption")
    .any(key => opts.at(key, default: none) != none)
  if not has-caption { return none }
  [#figure(none, caption: opts.at("fig-caption", default: none)) #label(name)]
}

#let chunk(..args) = {
  _warning()
  context {
    let opts = args.named()
    if opts.at("echo", default: _echo.get()) != false {
      _body-from-args(args, "chunk")
    }
    _placeholder-label(opts)
  }
}

// The real `inline` substitutes a computed value into prose; without results
// there is nothing to show, so render a small visible placeholder.
#let inline(engine, body, ..args) = {
  _warning()
  box(raw("⟨" + engine + "⟩"))
}

// Relocated chunk output: nothing exists to relocate.
#let results(..args) = {
  _warning()
  context _placeholder-label(args.named())
}

#let store = (
  get: (key, ..args) => {
    let named = args.named()
    if "default" in named {
      named.at("default")
    } else {
      panic(
        "calepin.store.get(\"" + key + "\"): stored values require "
          + "`calepin compile`; this document was compiled with plain Typst",
      )
    }
  },
  set_: (key, value) => none,
)

#let pages() = ()

// A Typst package cannot read files from the user's project, so media
// referenced by path renders as a labeled placeholder frame.
#let _media-placeholder(src, note) = block(
  width: 100%,
  stroke: 0.5pt + gray,
  radius: 2pt,
  inset: 0.5em,
)[#raw(src) #h(1fr) #text(size: 0.8em, fill: gray, note)]

#let elements = (
  gallery: (items, ..args) => {
    let opts = args.named()
    let cols = opts.at("columns", default: 3)
    let show-captions = opts.at("show-captions", default: true)
    grid(
      columns: (1fr,) * cols,
      gutter: opts.at("gap", default: 0.75em),
      ..items.map(item => {
        let src = item.at(0)
        let caption = if item.len() > 1 { item.at(1) } else { none }
        let cell = _media-placeholder(src, "image")
        if show-captions and caption != none {
          figure(cell, caption: caption, numbering: none)
        } else {
          cell
        }
      }),
    )
  },
  lightbox-image: (id, src, alt, ..args) => _media-placeholder(src, alt),
  lightbox-video: (id, src, ..args) => _media-placeholder(src, "video"),
)

#let document(body) = {
  show raw.where(block: true): it => {
    let lang = if it.has("lang") { it.lang } else { none }
    if lang in _chunk-engines {
      _warning()
    }
    it
  }
  body
}
