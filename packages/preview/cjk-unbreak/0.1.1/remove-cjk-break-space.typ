#import "transform-childs.typ": transform-childs
#import "@preview/touying:0.6.1": utils

#let cn-char = "\p{Han}，。；：！？‘’“”（）「」【】…—"
#let jp-char = "\p{Hiragana}\p{Katakana}"
#let cjk-char-regex = regex("[" + cn-char + jp-char + "]")

#let ends-with-cjk(it) = (
  it != none
    and (
      (it.has("text") and it.text.ends-with(cjk-char-regex)) or (it.has("body") and ends-with-cjk(it.body))
    )
)

#let start-with-cjk(it) = (
  it != none
    and (
      (it.has("text") and it.text.starts-with(cjk-char-regex)) or (it.has("body") and start-with-cjk(it.body))
    )
)

#let is-text(it) = (
  it != none and it.func() == text
)

#let remove-cjk-break-space(rest) = {
  rest = transform-childs(rest, remove-cjk-break-space)
  if utils.is-sequence(rest) {
    let first = none
    let mid = none
    for third in rest.children {
      // first, mid, third
      if mid == [ ] and is-text(first) and is-text(third) and (ends-with-cjk(first) or start-with-cjk(third)) {
        mid = none
      }
      first
      first = mid
      mid = third
    }
    first
    mid
  } else {
    rest
  }
}
