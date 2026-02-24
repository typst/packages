#import "@preview/touying:0.6.1": utils

#let last-positional-param-is-variadic(it) = {
  if it.has("children") {
    true
  } else if it.func() in (math.binom, math.mat) {
    true
  } else {
    false
  }
}

#let get-positional-param-names(it) = {
  let func = it.func()
  if it.has("body") {
    if func == math.class {
      ("class", "body")
    } else if (
      func
        in (
          math.underbrace,
          math.overbrace,
          math.underbracket,
          math.overbracket,
          math.underparen,
          math.overparen,
          math.undershell,
          math.overshell,
        )
    ) {
      ("body", "annotation")
    } else if func == link {
      ("dest", "body")
    } else if func in (place, align) {
      ("alignment", "body")
    } else {
      ("body",)
    }
  } else if it.has("children") {
    ("children",)
  } else {
    if func == math.accent {
      ("base", "accent")
    } else if func == math.attach {
      ("base",)
    } else if func == math.binom {
      ("upper", "lower")
    } else if func == math.frac {
      ("num", "denom")
    } else if func == math.mat {
      ("rows",)
    } else if func == math.primes {
      ("count",)
    } else if func == math.root {
      ("index", "radicand")
    } else if func == math.sqrt {
      ("radicand",)
    } else if func == math.op {
      ("text",)
    } else {
      // has no fields?
      none
    }
  }
}

#let reconstruct(it, named-params, positional-params) = {
  let label = named-params.remove("label", default: none)
  if label != none {
    return utils.label-it((it.func())(..named-params, ..positional-params), label)
  } else {
    return (it.func())(..named-params, ..positional-params)
  }
}

#let transform-childs(it, transform-func) = {
  if type(it) == content {
    if utils.is-sequence(it) {
      for item in it.children {
        transform-func(item)
      }
    } else if utils.is-styled(it) {
      let child = transform-func(it.child)
      utils.reconstruct-styled(it, child)
    } else {
      let positional-param-names = get-positional-param-names(it)
      if positional-param-names != none {
        let fields = it.fields()
        let positional-params = if positional-param-names.len() == 0 {
          ()
        } else {
          let names = positional-param-names
          let variadic-name = none
          if last-positional-param-is-variadic(it) {
            names = positional-param-names.slice(0, -1)
            variadic-name = positional-param-names.last()
          }
          for name in names {
            let x = fields.remove(name, default: none)
            (transform-func(x),)
          }
          if variadic-name != none {
            let x = fields.remove(variadic-name, default: none)
            x.map(i => transform-func(i))
          }
        }
        for (key, value) in fields {
          fields.insert(key, transform-func(value))
        }
        reconstruct(it, fields, positional-params)
      } else {
        // has no fields
        it
      }
    }
  } else if type(it) == array {
    it.map(i => transform-func(i))
  } else {
    it
  }
}
