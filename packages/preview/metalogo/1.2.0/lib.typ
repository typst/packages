// TODO: workaround until Typst gets a real ex unit.
// See <https://github.com/typst/typst/issues/2405>
#let ex = 0.47
#let defaults = (
  drop-tex: 0.5em*ex,
  drop-xe: 0.5em*ex,
  drop-a: -.2em,

  kern-te: -.1667em,
  kern-ex: -.125em,
  kern-la: -.36em,
  kern-at: -.15em,
  kern-xe: -.125em,
  kern-et: -.1667em,
  kern-el: -.125em,
  kern-x2: 0.15em,
)

#let config = state("metalogo", defaults)
#let metalogo(
  ..opts,
  body,
) = context{
  // save configuration before applying `opts`
  let before = config.get()

  if opts.named().len() == 0 {
    // reset default options if no options are passed
    config.update(defaults)
  } else {
    config.update(c => {
      for (key, value) in opts.named() {
        assert(
          c.at(key, default: none) != none,
          message: "metalogo: Unknown option \"" + key + "\""
        )
        let expected_type = type(c.at(key))
        let actual_type = type(value)
        assert(
          expected_type == actual_type,
          message: "metalogo: Option \"" + key + "\" has type `" +
          str(expected_type) + "` but was assigned a `" + str(actual_type) + "`"
        )
        c.insert(key, value)
      }
      return c
    })
  }

  body

  // restore config from before invocation of #metalogo
  config.update(before)
}

// utility commands
#let drop(distance, body) = box(move(dy: distance, body))
#let mirror(body) = scale(x: -100%)[#body]
#let kern(distance) = h(distance)

#let TeX = context[#box[#{
  let cfg = config.get()

  [T]
  kern(cfg.kern-te)
  drop(cfg.drop-tex)[E]
  kern(cfg.kern-ex)
  [X]
}]]

#let Xe = context[#box[#{
  let cfg = config.get()

  [X]
  kern(cfg.kern-xe)
  drop(cfg.drop-xe)[#mirror[E]]
}]]

#let a = context[#box[#{
  let cfg = config.get()

  drop(cfg.drop-a)[#text(size: 0.7em)[A]]
}]]

#let LaTeX = context[#box[#{
  let cfg = config.get()

  [L]
  // TODO: `A` is too far to the left compared to real LaTeX due to optical
  // size support, see <https://github.com/typst/typst/issues/5626>
  kern(cfg.kern-la)
  a
  kern(cfg.kern-at)
  TeX
}]]

#let XeTeX = context[#box[#{
  let cfg = config.get()

  Xe
  kern(cfg.kern-et)
  TeX
}]]

#let XeLaTeX = context[#box[#{
  let cfg = config.get()

  Xe
  kern(cfg.kern-el)
  LaTeX
}]]

#let LuaLaTeX = box[Lua#LaTeX]
#let LuaTeX = box[Lua#TeX]

#let LaTeXe = context[#box[#{
  let cfg = config.get()

  LaTeX
  kern(cfg.kern-x2)
  [2]
  [$attach(, b: #sym.epsilon)$]
}]]

