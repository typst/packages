#import "utils.typ": *

#let default-style = (
  rb-color:    rgb("#808080"),  // Annotation text color
  rb-size:     0.5em,   // Annotation text size
  word-sep:    0.2em,   // Chinese words separation
  char-jp-sep: 0.2em,   // vertical space between words and Jyutping above
)

#let render-word-groups(
  data,
  romanization: "jyutping",  // Romanization scheme: "Yale"/"Jyutping" (default)
  visual-tones: true,  // display 'ˉ¹' by default.  If set to false, show '1'.
  style: (:),  // caller can pass a partial or full style dict
) = {
  let s = default-style + style  // caller values override defaults

  [
    #for item in data {
      if item.word == "\n" {text[\ ]; continue}
      let ruby-txt
      if romanization == "jyutping" and item.jyutping != none {
        ruby-txt = item.jyutping.matches(regex("([a-z]+[1-6])")).map(m => m.text).join(" ")
        if visual-tones {
          ruby-txt = ruby-txt.replace(regex("[1-6]"), m => tone-map.at(m.text))
        }
      } else if romanization == "yale" and item.yale != none {
        ruby-txt = item.yale.join(" ")
      }
      if ruby-txt != none {
        box(
          stack(
            dir: ttb,
            spacing: s.char-jp-sep,
            align(center, text(s.rb-size, s.rb-color, ruby-txt)),
            align(bottom + center, box(height: 1em, text(1em, item.word))),
          )
        )
      } else {
        text(1em)[#item.word]
      }
      h(s.word-sep)
    }
    #h(-s.word-sep)  // get rid of final space
  ]
}
