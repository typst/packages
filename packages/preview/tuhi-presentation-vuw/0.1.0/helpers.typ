
#let bf(body) = text(weight:"semibold", body)

#let tw(body) = text(font: "Fira Mono", body)

#let scr(it) = text(
  features: ("ss01",),
  box($cal(it)$),
)

#let hair = $#h(0.1em)$

#let smcps(body) = {
  show smallcaps: set text(tracking: 1.4pt);lower(smallcaps[#body])
}
