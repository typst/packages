

#let place-in-out(
  alignment,
  content,
  dx: 0pt, dy: 0pt,
) = {
  if alignment.y == top { dy *= -1 }
  if alignment.x == right { dx *= -1 }
  place(alignment, content, dx: dx, dy: dy)
}



#let if-auto(value, default) = if value == auto { default } else { value }
#let if-none(value, default) = if value == none { default } else { value }

#let match-type(value, ..args) = {
  let value-type = str(type(value))
  args = args.named()
  let get-output(output) = {
      if type(output) == function { return output() }
      else { return output }
    }
  for (key, output) in args {
    if key == "auto-type" { key = "auto" }
    if key == "none-type" { key = "none" }
    if value-type == key { 
      return get-output(output)
    }
  }
  if "default" in args { return get-output(args.default) }
  panic("The provided value matches none of the given types. Found " + str(value-type))
}

#let match(value, ..args) = {
  let pos-args = args.pos()
  let get-output(output) = {
      if type(output) == function { return output() }
      else { return output }
    }
  assert(calc.even(pos-args.len()))
  let i = 0
  while i < pos-args.len() {
    if value == pos-args.at(i) { 
      return get-output(pos-args.at(i + 1))
    }
    i += 2
  }
  if "default" in args.named() { return get-output(args.named().default) }
  panic("The provided value matches none of the given arguments")
}



#let _run-func-on-first-loc(func, label-name: "loc-tracker") = {
  let lbl = label(label-name)
  [#metadata(label-name)#lbl]
  locate(loc => {
    let use-loc = query(selector(lbl).before(loc), loc).last().location()
    func(use-loc)
  })
}

/// Place content at a specific location on the page relative to the top left corner
/// of the page, regardless of margins, current container, etc.
/// -> content
#let absolute-place(dx: 0em, dy: 0em, content) = {
  _run-func-on-first-loc(loc => {
    let pos = loc.position()
    place(dx: -pos.x + dx, dy: -pos.y + dy, content)
  })
}
