#let asian-power(
  han: true,
  kana: true,
  hangul: true,
  angle: -12deg,
  letterspace: 0.9em,
  body
  ) = {
let p = (if han {"\p{Han}"} else {""}) + (if kana {"ぁ-んァ-ン"} else {""}) + (if hangul {"ㄱ-ㅎㅏ-ㅣ가-힣"} else {""})
  show emph: it => {
    show regex("[" + p + "]"): it => {
      box(
        width: letterspace,
        skew(ax: angle, reflow: true)[#it]
        )
    }
    set text(style: "italic")
    it.body
  }

  body
}
}