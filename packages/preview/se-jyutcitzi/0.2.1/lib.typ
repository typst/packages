#import "utils.typ": *
#import "data.typ": *
#import "display.typ": *

#let jyutcitzi(input) = {
  show re-other: m => {
    let (jp-initial, jp-final, jp-tone) = split-jyutping(m.text)
    simple-jyutcitzi-display(jp-initial, jp-final, tone: jp-tone)
  }
  show re-nasal: m => {
    let (jp-initial, jp-final, jp-tone) = split-jyutping(m.text)
    syllabic-nasal-char(jp-initial, tone: jp-tone)
  }
  show regex(" "): m => ""
  input
}
