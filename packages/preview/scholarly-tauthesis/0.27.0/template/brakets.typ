//
// brakets.typ
//
// This library allows you to typeset expressions with Paul Dirac's
// bra--ket notation.
//


#let expected-value(..args) = $lr(chevron.l #args.pos().join(", ") chevron.r)$

#let bra(..args) = $lr(chevron.l #args.pos().join(", ") bar.v)$

#let ket(..args) = $lr(bar.v #args.pos().join(", ") chevron.r)$

// A bra-ket function. Separate bra and ket arguments with a semicolon

#let braket(..args) = {
  let arg-types = args.pos().map(type)
  let bra-args = if arg-types.len() < 1 {
    none
  } else if arg-types.first() == array {
    args.pos().first().join(",")
  } else {
    args.pos().first()
  }
  let ket-args = if arg-types.len() < 1 {
    none
  } else if arg-types.last() == array {
    args.pos().last().join(", ")
  } else {
    args.pos().last()
  }
  $lr(
    chevron.l
    #bra-args
    mid(bar.v)
    #ket-args
    chevron.r
  )$
}

// A ket-bra function. Separate ket and bra arguments with a semicolon.

#let ketbra(..args) = {
  let arg-types = args.pos().map(type)
  let ket-args = if arg-types.len() < 1 {
    none
  } else if arg-types.first() == array {
    args.pos().first().join(",")
  } else {
    args.pos().first()
  }
  let bra-args = if arg-types.len() < 1 {
    none
  } else if arg-types.last() == array {
    args.pos().last().join(", ")
  } else {
    args.pos().last()
  }
  $lr(
    bar.v
    thin
    #ket-args
    mid(chevron.r)
    mid(chevron.l)
    #bra-args
    thin
    bar.v
  )$
}

// A bra-op-ket function. Separate bra and ket arguments with a semicolon

#let braopket(..args) = {
  let arg-types = args.pos().map(type)
  let bra-args = if arg-types.len() < 1 {
    none
  } else if array in arg-types {
    args.pos().first().join(", ")
  } else {
    args.pos().first()
  }
  let ket-args =  if arg-types.len() < 1 {
    none
  } else if array in arg-types {
    if arg-types.len() > 2 {
      args.pos().last().join(", ")
    } else {
      args.pos().first().join(", ")
    }
  } else {
    if arg-types.len() > 2 {
      args.pos().last()
    } else {
      args.pos().first()
    }
  }
  let op-args = if arg-types.len() < 1 {
    none
  } else if array in arg-types {
    if arg-types.len() > 2 {
      args.pos().at(1, default: none).join(",")
    } else {
      args.pos().last().join(", ")
    }
  } else {
    if arg-types.len() > 2 {
      args.pos().at(1, default: none)
    } else {
      args.pos().last()
    }
  }
  $lr(
    chevron.l
    #bra-args
    mid(bar.v)
    #op-args
    mid(bar.v)
    #ket-args
    chevron.r
  )$
}
