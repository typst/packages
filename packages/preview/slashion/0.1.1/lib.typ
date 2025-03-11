/// Convert a `frac` to a `lr` with slash
/// - frac: The frac to convert
/// - parens: Whether to wrap the num and denom in parens, default: true
/// -> The resulting lr
#let convert(
  frac,
  parens: true,
) = {
  let edge = math.class("fence", [])
  assert(frac.func() == math.frac, message: "Expected a frac")
  let num = if frac.num.func() == [].func() {
    if parens {
      math.lr([\(] + frac.num + [\)])
    } else {
      math.lr(frac.num)
    }
  } else {
    frac.num
  }
  let denom = if frac.denom.func() == [].func() {
    if parens {
      math.lr([\(] + frac.denom + [\)])
    } else {
      math.lr(frac.denom)
    }
  } else {
    frac.denom
  }
  return math.lr([#edge #num #math.mid(math.class("fence", "/")) #denom #edge])
}

/// Convert a `sequence` to a new `sequence` with all `frac` converted to `lr` with slash
/// - seq: The sequence to convert
/// - parens: Whether to wrap the num and denom in parens, default: true
/// -> The new sequence
#let convert-sequence(
  seq,
  parens: true,
) = {
  assert(seq.func() == [].func(), message: "Expected a sequence")
  if seq.children.filter(c => c.func() == math.frac).len() == 0 {
    return seq
  }
  let children = seq.children.map(c => if c.func() == math.frac {
    convert(c, parens: parens)
  } else {
    c
  })
  return children.join()
}

/// Convert a `equation` to a new `equation` with all `frac` converted to `lr` with slash
/// - eq: The equation to convert
/// - parens: Whether to wrap the num and denom in parens, default: true
/// -> The new equation
#let convert-equation(
  eq,
  parens: true,
) = {
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
      convert(eq.body, parens: parens),
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
      convert-sequence(eq.body, parens: parens),
    )
  }

  // assert(false, message: "Unexpected body")
  return eq
}

/// Smart function
#let slash-frac(
  ..args,
  parens: true,
) = {
  let pos = args.pos()
  let named = args.named()

  if named.len() == 2 {
    assert(pos.len() == 0, message: "Positional arguments are not allowed")
    assert("num" in named, message: "Missing 'num' argument")
    assert("denom" in named, message: "Missing 'denom' argument")
    return convert(math.frac(named.num, named.denom), parens: parens)
  }
  assert(named.len() == 0, message: "Named arguments are not allowed")
  if pos.len() == 2 {
    return convert(math.frac(..pos), parens: parens)
  }
  assert(pos.len() == 1, message: "Expected 1 or 2 arguments")
  let target = pos.first()
  if target.func() == math.frac {
    return convert(target, parens: parens)
  }
  if target.func() == [].func() {
    return convert-sequence(target, parens: parens)
  }
  if target.func() == math.equation {
    return convert-equation(target, parens: parens)
  }
  assert(false, message: "Unexpected argument type, expected frac, sequence or equation, got " + repr(type(target)))
  return target
}
