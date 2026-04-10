#import "data.typ"
#import "display.typ": *
#import "utils.typ": *

#let jyutcitzi(input, merge-nasals: false) = {
  show regex(" "): m => ""
  // Render Jyutcitzi from Jyutci alphabets
  show regex-jyutcitzi: m => {
    let (split-mode, split-tuple) = split-jyutcit(m.text)
    if split-tuple.len() < 4 {
      let (jc-initial, jc-final, jc-tone) = split-tuple
      display-from-simple-jc-tuple(jc-initial, jc-final, tone: jc-tone, merge-nasals: merge-nasals)
    } else {
      display-from-long-jc-tuple(..split-tuple.slice(0, -1), tone: split-tuple.at(-1), mode: split-mode, merge-nasals: merge-nasals)
    }
  }
  // Convert standalone Jyutping alphabet to Jyutcit alphabet
  show regex("\b" + jp-initials + "\b"): m => get-jc-from-jp-init(m.text)
  // Convert "Extended Jyut6ping3" to Jyutcit alphabets
  show regex-jp-ccv: m => {
    let (jp-init1, jp-init2, jp-final, jp-tone) = split-jyutping(m.text, split-mode: "CCV")
    let jc-inits = (jp-init1, jp-init2).map(get-jc-from-jp-init)
    let jc-final = get-jc-from-jp-final(jp-final)
    jc-inits.join() + jc-final + jp-tone
  }
  show regex-jp-cvc: m => {
    let (jp-init1, jp-final, jp-init2, jp-tone) = split-jyutping(m.text, split-mode: "CVC")
    let jc-inits = (jp-init1, jp-init2).map(get-jc-from-jp-init)
    let jc-final = get-jc-from-jp-final(jp-final)
    jc-inits.join(jc-final) + jp-tone
  }
  // Convert Jyut6ping3 to Jyutcit alphabets
  show regex-jyutping: m => {
    let (jp-initial, jp-final, jp-tone) = split-jyutping(m.text)
    let jc-initial = get-jc-from-jp-init(jp-initial)
    let jc-final = get-jc-from-jp-final(jp-final)
    jc-initial + jc-final + jp-tone
  }
  input
}
