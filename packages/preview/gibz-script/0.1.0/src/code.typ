#import "@preview/codly:1.3.0": *

#let _code_overrides = state("gibz-code-overrides", (:))

#let set_code_style(opts: (:)) = {
  if type(opts) == dictionary {
    _code_overrides.update(_code_overrides.get() + opts)
  }
}

// Lokaler Wrapper für Blöcke
#let code(block, opts: (:)) = {
  context {
    let ov = _code_overrides.get()
    let local_opts = if type(opts) == dictionary { ov + opts } else { ov }
    codly(..local_opts)
    block
  }
}

// Alternative Syntax: #GIBZ.codly(...)[ body ]
#let code_wrap(opts: (:), body) = {
  context {
    let ov = _code_overrides.get()
    let local_opts = if type(opts) == dictionary { ov + opts } else { ov }
    codly(..local_opts)
    body
  }
}
