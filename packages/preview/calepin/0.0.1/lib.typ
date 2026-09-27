#let _warning-shown = state("calepin-shim-warning-shown", false)
#let _warning-enabled = state("calepin-shim-warning-enabled", true)

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
  _warning-enabled.update(_ => opts.at("fallback-warning", default: true))
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

#let chunk(..args) = [
  #_warning()
  #_body-from-args(args, "chunk")
]

#let inline(..args) = [
  #_warning()
  #_body-from-args(args, "inline")
]

#let chunk-from-raw-plain(engine, it) = it

#let require() = none
