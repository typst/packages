#let left-to-right = ltr
#let right-to-left = rtl

#let ltr(body) = {
  set text(dir: left-to-right)
  body
}

#let rtl(body) = {
  set text(dir: right-to-left)
  body
}
