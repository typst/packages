// Example adapted from: @Matt https://discord.com/channels/1054443721975922748/1088371919725793360/1166508915572351067

#import "../lib.typ": *
#set page(width: 700pt, height: auto, margin: 30pt)
#set text(size: 20pt)
#set math.equation(numbering: "(1)")

#let pinit-highlight-equation-from(height: 2em, pos: bottom, fill: rgb(0, 180, 255), highlight-pins, point-pin, body) = {
  pinit-highlight(..highlight-pins, dy: -0.6em, fill: rgb(..fill.components().slice(0, -1), 40))
  pinit-point-from(
    fill: fill, pin-dx: -0.6em, pin-dy: if pos == bottom { 0.8em } else { -0.6em }, body-dx: 0pt, body-dy: if pos == bottom { -1.7em } else { -1.6em }, offset-dx: -0.6em, offset-dy: if pos == bottom { 0.8em + height } else { -0.6em - height },
    point-pin,
    rect(
      inset: 0.5em,
      stroke: (bottom: 0.12em + fill),
      {
        set text(fill: fill)
        body
      }
    )
  )
}

Equation written out directly (for comparison):

$ (q_T^* p_T)/p_E p_E^* >= (c + q_T^* p_T^*)(1+r^*)^(2N) $

Laid out with pinit:

#v(3.5em)

$ (#pin(1)q_T^* p_T#pin(2))/(p_E#pin(3))#pin(4)p_E^*#pin(5) >= (c + q_T^* p_T^*)(1+r^*)^(2N) $

#pinit-highlight-equation-from((1, 2, 3), 3, height: 3.5em, pos: bottom, fill: rgb(0, 180, 255))[
  quantity of Terran goods
]

#pinit-highlight-equation-from((4, 5), 5, height: 2.5em, pos: top, fill: rgb(150, 90, 170))[
  price of Terran goods, on Trantor
]

#v(5em)

Paragraph after the equation.
