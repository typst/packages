#import "core/draw/group.typ"

#let _grp(name, desc: none, type: "default", elmts) = {
  return ((
    type: "grp",
    draw: group.render-start,
    name: name,
    desc: desc,
    grp-type: type,
    elmts: elmts
  ),)
}

#let _alt(desc, elmts, ..args) = {
  let all-elmts = ()
  all-elmts += elmts
  let args = args.pos()
  for i in range(0, args.len(), step: 2) {
    let else-desc = args.at(i)
    let else-elmts = args.at(i + 1, default: ())
    all-elmts.push((
      type: "else",
      draw: group.render-else,
      desc: else-desc
    ))
    all-elmts += else-elmts
  }

  return _grp("alt", desc: desc, type: "alt", all-elmts)
}

#let _loop(desc, min: none, max: auto, elmts) = {
  let name = "loop"
  if min != none {
    if max == auto {
      max = "*"
    }
    name += "(" + str(min) + "," + str(max) + ")"
  }
  _grp(name, desc: desc, type: "loop", elmts)
}
#let _opt(desc, elmts) = _grp("opt", desc: desc, type: "opt", elmts)
#let _break(desc, elmts) = _grp("break", desc: desc, type: "break", elmts)
