#import "typesetting.typ": typeset

#let calc-state = state("calc-state", (plugin("./matset.wasm"), bytes("")))

#let insert(x) = context {
  calc-state.update(pair => {
    let (plug, current) = pair

    let reply = plug.insert(current, bytes(json.encode(x)))

    (plug, reply)
  })

  x
}


#let debug() = context {
  let (plug, current) = calc-state.get()

  let reply = plug.debug_ctx(current)

  raw(str(reply))
}

#let evaluate(expr) = context {
  let (plug, current) = calc-state.get()

  // Need to wrap in new equation in case we don't get an
  // equation and instead get a bare value such as if we
  // had said `$ evaluate(alpha) $` -- we'd get a symbol
  // rather than an equation. The plugin supports nested
  // equation objects anyway so this shouldn't be an issue.
  let encoded = json.encode($expr$, pretty: false)

  // return raw(lang: "json", encoded)

  let reply = plug.evaluate(current, bytes(encoded))

  let reply = typeset(json(reply))

  $ expr = reply $
}

#let floateval(expr) = context {
  let (plug, current) = calc-state.get()
  
  let encoded = json.encode($expr$)

  let reply = plug.floateval(current, bytes(encoded))

  let reply = typeset(json(reply))

  $ reply $
}

#let floatexpr(callback) = context {
  let (plug, current) = calc-state.get()

  callback(expr => {
    let encoded = json.encode($expr$)

    let reply = plug.floateval(current, bytes(encoded))
  
    let reply = json(reply).Real.Float

    if reply == none {
      100000000.0
    } else {
      reply
    }
  })
}
