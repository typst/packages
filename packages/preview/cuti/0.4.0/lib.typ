#let fakebold(stroke: auto, base-weight: auto, weight: auto, s, ..params) = {
  let t-weight = if base-weight == auto { weight } else { base-weight }
  assert(
    t-weight in (auto, none) or type(t-weight) in (str, int),
    message: "`base-weight`/`weight` should be `auto`, `none`, `int` or `str` type.",
  )
  assert(
    stroke == auto or type(stroke) in (std.stroke, length),
    message: "`stroke` shoule be `auto`, `length` or `stroke` type.",
  )
  set text(weight: t-weight) if type(t-weight) in (str, int)
  set text(weight: "regular") if t-weight == none
  set text(..params) if params != ()
  context {
    let t-stroke = if stroke == auto { 0.02857em + text.fill } else if type(stroke) == length {
      stroke + text.fill
    } else { stroke }
    set text(stroke: t-stroke)
    s
  }
}

#let regex-fakebold(reg-exp: ".+", s, ..params) = {
  show regex(reg-exp): it => {
    fakebold(it, ..params)
  }
  s
}

#let show-fakebold(reg-exp: ".+", s, weight: none, ..params) = {
  show text.where(weight: "bold").or(strong): it => {
    regex-fakebold(reg-exp: reg-exp, it, weight: weight, ..params)
  }
  s
}

#let cn-fakebold(s, ..params) = {
  regex-fakebold(reg-exp: "[\p{script=Han}！-･〇-〰—]+", weight: "regular", s, ..params)
}

#let show-cn-fakebold(s, ..params) = {
  show-fakebold(reg-exp: "[\p{script=Han}！-･〇-〰—]+", weight: "regular", s, ..params)
}

#let regex-fakeitalic(reg-exp: ".+?", ang: -18.4deg, s) = {
  show regex(reg-exp): it => {
    box(skew(ax: ang, reflow: false, it))
  }
  s
}

#let fakeitalic(
  ang: -18.4deg,
  s,
) = regex-fakeitalic(
  reg-exp: "(?:\b[^\p{Script=Han}\p{Script=Hiragana}\p{Script=Katakana}\p{Script=Hangul}！-･〇-〰—]+?\b|[\p{Script=Han}\p{Script=Hiragana}\p{Script=Katakana}\p{Script=Hangul}])",
  ang: ang,
  s,
)

#let show-fakeitalic(
  ang: -18.4deg,
  s,
) = {
  show text.where(style: "italic").or(emph): it => {
    fakeitalic(ang: ang, it)
  }
  s
}

#let cn-fakeitalic(s) = {
  regex-fakeitalic(
    reg-exp: "(?:\b[^\p{Script=Han}\p{Script=Hiragana}\p{Script=Katakana}\p{Script=Hangul}！-･〇-〰—]+?\b|[\p{Script=Han}\p{Script=Hiragana}\p{Script=Katakana}\p{Script=Hangul}])",
    s,
  )
}

#let show-cn-fakeitalic(s) = {
  show-fakeitalic(ang: -18.4deg, s)
}

#let fakesc(s, scaling: 0.75) = {
  show regex("\p{Ll}+"): it => {
    context text(scaling * 1em, stroke: 0.01em + text.fill, upper(it))
  }
  text(s)
}
