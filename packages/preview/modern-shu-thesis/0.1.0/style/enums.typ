#import "font.typ": ziti, zihao
#import "@preview/numbly:0.1.0": numbly
#let enums(
  body,
) = {
  set enum(
    numbering: numbly("({1})"),
    indent: 2em,
    full:true
  )
  body
}
