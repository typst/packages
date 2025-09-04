//
// brakets.typ
//
// This library allows you to typeset expressions with Paul Dirac's
// bra--ket notation.
//


#let expectedValue(..args) = $lr(angle.l #args.pos().join(", ") angle.r)$

#let bra(..args) = $lr(angle.l #args.pos().join(", ") bar.v)$

#let ket(..args) = $lr(bar.v #args.pos().join(", ") angle.r)$

// A bra-ket function. Separate bra and ket arguments with a semicolon

#let braket(..args) = {
  let argTypes = args.pos().map(type)
  let braArgs = if argTypes.len() < 1 {
    none
  } else if argTypes.first() == array {
    args.pos().first().join(",")
  } else {
    args.pos().first()
  }
  let ketArgs = if argTypes.len() < 1 {
    none
  } else if argTypes.last() == array {
    args.pos().last().join(", ")
  } else {
    args.pos().last()
  }
  $lr(
    angle.l
    braArgs
    mid(bar.v)
    ketArgs
    angle.r
  )$
}

// A ket-bra function. Separate ket and bra arguments with a semicolon.

#let ketbra(..args) = {
  let argTypes = args.pos().map(type)
  let ketArgs = if argTypes.len() < 1 {
    none
  } else if argTypes.first() == array {
    args.pos().first().join(",")
  } else {
    args.pos().first()
  }
  let braArgs = if argTypes.len() < 1 {
    none
  } else if argTypes.last() == array {
    args.pos().last().join(", ")
  } else {
    args.pos().last()
  }
  $lr(
    bar.v
    thin
    ketArgs
    mid(angle.r)
    mid(angle.l)
    braArgs
    thin
    bar.v
  )$
}

// A bra-op-ket function. Separate bra and ket arguments with a semicolon

#let braopket(..args) = {
  let argTypes = args.pos().map(type)
  let braArgs = if argTypes.len() < 1 {
    none
  } else if array in argTypes {
    args.pos().first().join(", ")
  } else {
    args.pos().first()
  }
  let ketArgs =  if argTypes.len() < 1 {
    none
  } else if array in argTypes {
    if argTypes.len() > 2 {
      args.pos().last().join(", ")
    } else {
      args.pos().first().join(", ")
    }
  } else {
    if argTypes.len() > 2 {
      args.pos().last()
    } else {
      args.pos().first()
    }
  }
  let opArgs = if argTypes.len() < 1 {
    none
  } else if array in argTypes {
    if argTypes.len() > 2 {
      args.pos().at(1, default: none).join(",")
    } else {
      args.pos().last().join(", ")
    }
  } else {
    if argTypes.len() > 2 {
      args.pos().at(1, default: none)
    } else {
      args.pos().last()
    }
  }
  $lr(
    angle.l
    braArgs
    mid(bar.v)
    opArgs
    mid(bar.v)
    ketArgs
    angle.r
  )$
}
