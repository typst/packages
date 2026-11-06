#let copy-stroke(_stroke, args) = {
  let s = stroke(_stroke)
  return stroke((
    paint: args.at("paint", default: s.paint),
    thickness: args.at("thickness", default: s.thickness),
    cap: args.at("cap", default: s.cap),
    join: args.at("join", default: s.join),
    dash: args.at("dash", default: s.dash),
    miter-limit: args.at("miter-limit", default: s.miter-limit),
  ))
}
