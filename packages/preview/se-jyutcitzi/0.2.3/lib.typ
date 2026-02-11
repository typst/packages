#import "utils.typ": *
#import "data.typ": *
#import "display.typ": *

#let jyutcitzi(input) = {
  show regex(jp-initials): m => simple-jyutcitzi-display(m.text, none, tone: none)
  show regex-jyutping: m => {
    let (jp-initial, jp-final, jp-tone) = split-jyutping(m.text)
    simple-jyutcitzi-display(jp-initial, jp-final, tone: jp-tone)
  }
  show regex(" "): m => ""
  input
}
