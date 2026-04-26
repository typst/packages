 #import "../lib.typ": *

#pipe(
  5,
  (
    x => x + 1,
    x => x + 2,
    x => assert(x == 8),
  ),
)

#compose(
  (
    c => assert(c == "xyz"),
    c => c + "z",
    c => "x" + c,
  ),
  "y",
)

#let pipeline = pipe_((
  c => c + "c",
  c => "a" + c,
))
#assert(pipeline("b") == "abc")

#let composed = compose_((
  c => "a" + c,
  c => c + "c",
))
#assert(composed("b") == "abc")
