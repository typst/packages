#import "config.typ": sp_config

#let character(..args) = {
  let args = args.pos()

  if args.len() == 1 {
    return args.at(0)
  } else if args.len() == 2 {
    return (
      args.at(0),
      args.at(0) + " " + args.at(1)
    )
  } else if args.len() == 3 {
    let first = args.at(0)
    let middle = args.at(1)
    let last = args.at(2)

    return (
      first,
      first + " " + last,
      first + " " + middle + " " + last,
    )
  }
}

// Shorthand simplification for Dialogue
#let _translate_shorthand(x) = {
  assert(type(x) == str)
  if x.len() != 1 {
    return x
  }
  
  if x == "I" {
    return "INT"
  } else if x == "E" {
    return "EXT"
  } else if x == "D" {
    return "DAY"
  } else if x == "N" {
    return "NIGHT"
  }

  return x
}

// Dialogue intermediates
#let _is_parenthetical(it) = {
  if it.func() != text {
    false
  } else {
    let value = it.text.trim()
    value.starts-with("(") and value.ends-with(")")
  }
}
#let _format_dialogue_body(body) = {
  if body.has("children") {
    for child in body.children {
      if _is_parenthetical(child) {
        h(1in)
        child
      } else { child }
    }
  }
  else if _is_parenthetical(body) { body }
  else { body }
}
