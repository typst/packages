/// Convert a `frac` to a `lr` with slash
/// - frac: The frac to convert
/// -> The resulting lr
#let convert(frac) = {
  assert(frac.func() == math.frac, message: "Expected a frac")
  let num = if frac.num.func() == [].func() {
    math.lr([\(] + frac.num + [\)])
  } else {
    frac.num
  }
  let denom = if frac.denom.func() == [].func() {
    math.lr([\(] + frac.denom + [\)])
  } else {
    frac.denom
  }
  return math.lr([#num #math.mid(math.class("fence", "/")) #denom])
}

/// Convert a `sequence` to a new `sequence` with all `frac` converted to `lr` with slash
/// - seq: The sequence to convert
/// -> The new sequence
#let convert-sequence(seq) = {
  assert(seq.func() == [].func(), message: "Expected a sequence")
  if seq.children.filter(c => c.func() == math.frac).len() == 0 {
    return seq
  }
  let children = seq.children.map(c => if c.func() == math.frac {
    convert(c)
  } else {
    c
  })
  return children.join()
}

/// Convert a `equation` to a new `equation` with all `frac` converted to `lr` with slash
/// - eq: The equation to convert
/// -> The new equation
#let convert-equation(eq) = {
  assert(eq.func() == math.equation, message: "Expected an equation")

  // Empty
  if eq.body == [] {
    return eq
  }

  let eq-args = eq.fields()
  eq-args.remove("body")

  // Single Frac
  if eq.body.func() == math.frac {
    return math.equation(
      ..eq-args,
      convert(eq.body),
    )
  }

  // Sequence
  if eq.body.func() == [].func() {
    // No fraction
    if eq.body.children.filter(c => c.func() == math.frac).len() == 0 {
      return eq
    }
    return math.equation(
      ..eq-args,
      convert-sequence(eq.body),
    )
  }

  // assert(false, message: "Unexpected body")
  return eq
}

/// Smart function
#let slash-frac(..args) = {
  let pos = args.pos()
  let named = args.named()

  if named.len() == 2 {
    assert(pos.len() == 0, message: "Positional arguments are not allowed")
    assert("num" in named, message: "Missing 'num' argument")
    assert("denom" in named, message: "Missing 'denom' argument")
    return convert(math.frac(named.num, named.denom))
  }
  assert(named.len() == 0, message: "Named arguments are not allowed")
  if pos.len() == 2 {
    return convert(math.frac(..pos))
  }
  assert(pos.len() == 1, message: "Expected 1 or 2 arguments")
  let target = pos.first()
  if target.func() == math.frac {
    return convert(target)
  }
  if target.func() == [].func() {
    return convert-sequence(target)
  }
  if target.func() == math.equation {
    return convert-equation(target)
  }
  assert(false, message: "Unexpected argument type, expected frac, sequence or equation, got " + repr(type(target)))
  return target
}
