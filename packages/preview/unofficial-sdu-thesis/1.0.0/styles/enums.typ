#import "@preview/numbly:0.1.0": numbly
#let enums(
  body,
) = {
  set enum(
    // numbering: numbly("({1})"),
    numbering: "①.①",
    indent: 1.65em,
    full: true,
    body-indent: 0.35em,
  )
  set list(
    indent: 2em,
    body-indent: 0.35em,
    marker: [#v(1pt)●]
  )
  
  body
}
