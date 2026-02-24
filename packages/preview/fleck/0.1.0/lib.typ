#let coffee(
  which,
  where: center + horizon,
  opacity: 100%,
  dx: 0% + 0pt,
  dy: 0% + 0pt,
  angle: 0deg,
  scale: auto,
) = {
  assert(
    ("a", "b", "c", "d").contains(which),
    message: "unknown stain, should be one of 'a', 'b', 'c', and 'd'",
  )
  opacity = calc.clamp(float(opacity), 0, 1)
  let svg = read("./assets/stains_x.svg".replace("x", which)).replace(
    "$OPACITY",
    str(opacity),
  )

  place(where, rotate(angle, image(bytes(svg), width: auto, height: scale)), dx: dx, dy: dy)
}

#let coffee-a = coffee.with("a")
#let coffee-b = coffee.with("b")
#let coffee-c = coffee.with("c")
#let coffee-d = coffee.with("d")



