#import "utils.typ": *

#let default-style = (
  jp-color:    gray,    // Jyutping color
  jp-size:     0.5em,   // Jyutping size
  word-sep:    0.2em,   // Chinese words separation
  char-jp-sep: 0.2em,   // vertical space between words and Jyutping above
)

#let render-word-groups(
  data,
  visual-tones: true,  // display 'ˉ¹' by default.  If set to false, show '1'.
  style: (:),  // caller can pass a partial or full style dict
) = {
  let s = default-style + style  // caller values override defaults

  [
    #for item in data {
      if item.jyutping != none {
        let item-jp = item.jyutping.matches(regex("([a-z]+[1-6])")).map(m => m.text).join(" ")
        if visual-tones {
          item-jp = item-jp.replace(regex("[1-6]"), m => tone-map.at(m.text))
        }
        box(
          stack(
            dir: ttb,
            spacing: s.char-jp-sep,
            align(center, text(s.jp-size, s.jp-color, item-jp)),
            align(bottom + center, box(height: 1em, text(1em, item.word))),
          )
        )
      } else {
        text(1em)[#item.word]
      }
      h(s.word-sep)
    }
  ]
}
