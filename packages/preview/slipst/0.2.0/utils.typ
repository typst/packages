#let sequence = [].func()
#let styled = text(red)[].func()
#let space = [ ].func()
#let symbol-func = $.$.body.func()
#let context-func = (context {}).func()

#assert($mu$.body.func() == symbol-func)
#assert(type(sym.mu) == symbol)

#let fmap(it, func) = {
  assert(type(it) == content)
  if it.func() == sequence {
    func(it)
  } else if it.func() == styled {
    styled(fmap(it.child, func), it.styles)
  } else {
    it
  }
}

#let _is(it, func) = {
  type(it) == content and it.func() == func
}
