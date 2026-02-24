#import "../../helpers.typ": *

#let solution(digits) = {
  let digits = digits.clusters()
  let d = (
    "2": ("a", "b", "c"),
    "3": ("d", "e", "f"),
    "4": ("g", "h", "i"),
    "5": ("j", "k", "l"),
    "6": ("m", "n", "o"),
    "7": ("p", "q", "r", "s"),
    "8": ("t", "u", "v"),
    "9": ("w", "x", "y", "z"),
  )
  let ans = ("",)
  for c in digits {
    let nxt = ()
    for nc in d.at(c) {
      for s in ans {
        nxt.push(s + nc)
      }
    }
    ans = nxt
  }

  if ans == ("",) { () } else { ans }
}
