/// helper function
#let __wrap(s, dw, c: 0, insert-and: true) = {
  if calc.odd(c) {
    // left clip for e.g. &=
    if insert-and {
      h(dw)
      $&$
    }
    h(-dw)
  }
  s
  if c > 1 {
    // right clip for e.g. =&
    h(-dw)
    if insert-and {
      $&$
      h(dw)
    }
  }
}

/// clip param c ∈ {0,1,2,3} ≜ {no clip, left clip, right clip, both clip},
/// param insert-and: inserts a & at clip positions
#let overset(s, t, c: 0, insert-and: true) = if c == 0 {
  $limits(#s)^(#t)$
} else {
  context {
    let sw = measure(s).width
    let tw = measure($script(#t)$).width
    let dw = calc.max(tw - sw, 0pt) / 2
    __wrap($limits(#s)^(#t)$, dw, c: c, insert-and: insert-and)
  }
}

/// clip param c ∈ {0,1,2,3} ≜ {no clip, left clip, right clip, both clip},
/// param insert-and: inserts a & at clip positions
#let underset(s, b, c: 0, insert-and: true) = if c == 0 {
  $limits(#s)_(#b)$
} else {
  context {
    let sw = measure(s).width
    let bw = measure($script(#b)$).width
    let dw = calc.max(bw - sw, 0pt) / 2
    __wrap($limits(#s)_(#b)$, dw, c: c, insert-and: insert-and)
  }
}

/// clip param c ∈ {0,1,2,3} ≜ {no clip, left clip, right clip, both clip}
/// param insert-and: inserts a & at clip positions
#let overunderset(s, t, b, c: 0, insert-and: true) = if c == 0 {
  $limits(#s)^(#t)_(#b)$
} else {
  context {
    let sw = measure(s).width
    let tw = measure($script(#t)$).width
    let bw = measure($script(#b)$).width
    let dw = calc.max(calc.max(tw, bw) - sw, 0pt) / 2
    __wrap($limits(#s)^(#t)_(#b)$, dw, c: c, insert-and: insert-and)
  }
}

/// wrapper for the other functions. Write `ouset(&, <, toptext, bottomtext, &)`, no argument is mandatory, but first & will be search at first and last position, otherwise everything must be in this order.
#let ouset(..a-sym-over-under-a, insert-and: true) = {
  let params = a-sym-over-under-a.pos()
  let pl = params.len()
  if pl == 0 {
    return
  }

  let frontand = params.at(0) == $&$.body
  let backand = params.last() == $&$.body

  let c = if frontand {
    1
  } else {
    0
  } + if backand {
    2
  } else {
    0
  }
  let rest-params = params.slice(
    if frontand {
      1
    } else {
      0
    },
    if backand {
      pl - 1
    } else {
      pl
    },
  )

  overunderset(
    rest-params.at(0, default: []),
    rest-params.at(1, default: []),
    rest-params.at(2, default: []),
    c: c,
    insert-and: insert-and,
  )
}