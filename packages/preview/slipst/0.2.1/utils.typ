#let sequence = [].func()
#let styled = text(red)[].func()
#let space = [ ].func()
#let symbol-func = $.$.body.func()
#let context-func = (context {}).func()

#assert($mu$.body.func() == symbol-func)
#assert(type(sym.mu) == symbol)

#let _is(it, func) = {
  type(it) == content and it.func() == func
}

#let _should_strip(it) = {
  _is(it, parbreak) or _is(it, space)
}

#let _strip(slip) = {
  let _ = while _should_strip(slip.first(default: none)) {
    slip.remove(0)
  }
  let _ = while _should_strip(slip.last(default: none)) {
    slip.pop()
  }
  slip
}

#let fmap(it, func) = {
  assert(type(it) == content)
  if it.func() == sequence {
    let children = _strip(it.children)
    if (children.len() == 1) {
      fmap(children.at(0), func)
    } else {
      func(it)
    }
  } else if it.func() == styled {
    styled(fmap(it.child, func), it.styles)
  } else {
    it
  }
}

