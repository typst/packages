// Models

/// Ordinals
/// --------
/// type: "ord"
/// func: `(<positional>n: int, <named>depth: int) => str`
#let ord(f) = {
  if type(f) == str {
    import "ordinals.typ": ordinal_funcs
    // assert(
    //   f in ordinal_funcs,
    //   message: "Unknown ordinal: " + f,
    // )
    if f not in ordinal_funcs {
      return (type: "ord", func: (n, ..args) => numbering(f, n))
    }
    return (type: "ord", func: ordinal_funcs.at(f))
  }
  return (type: "ord", func: f)
}

#let ord_mod(o, prefix: "", suffix: "") = {
  return ord((..args) => prefix + (o.func)(..args) + suffix)
}

/// Constants
/// ---------
/// type: "const"
/// func: `(<named>depth: int) => str`
#let const(f) = {
  if type(f) == str {
    return (type: "const", func: (..args) => f)
  }
  return (type: "const", func: f)
}

#let const_from_str(s) = {
  return const((..args) => s)
}

// Conditions
// ----------
// `(<positional>n: int, <named>depth: int) => bool`

/// Construct a new ord
///
/// - `cases`: A list of cases. Each case is a tuple of a condition and an ordinal.
#let match_ord(..cases) = {
  cases = cases.pos()
  return ord((..args) => {
    for (cond, ord) in cases {
      if cond(..args) {
        if ord == none {
          return ""
        }
        return (ord.func)(..args)
      }
    }
    return ""
  })
}

/// Construct a new const
///
/// - `cases`: A list of cases. Each case is a tuple of a condition and a constant.
#let match_const(..cases) = {
  cases = cases.pos()
  return const((..args) => {
    for (cond, const) in cases {
      if cond(..args) {
        if const == none {
          return ""
        }
        return (const.func)(..args)
      }
    }
    return ""
  })
}

/// Constructs a numbering function from parsed numbering structure
///
/// - elements: A list of Ordinal | Const
#let to_numbering(..elements, repeat: none) = {
  elements = elements.pos()
  return (..nums) => {
    nums = nums.pos()
    let cur_ind = 0
    let depth = nums.len()
    let res = ""
    for e in elements {
      if e.type == "ord" {
        // Ignore the ordinal if the depth is not enough
        if cur_ind >= depth {
          continue
        }
        res += (e.func)(nums.at(cur_ind), depth: depth)
        cur_ind += 1
      } else if e.type == "const" {
        res += (e.func)(depth: depth)
      }
    }
    if repeat != none {
      assert(false, message: "Not implemented yet")
    }
    return res
  }
}
