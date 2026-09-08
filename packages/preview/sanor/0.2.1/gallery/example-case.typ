#import "@preview/sanor:0.2.1": *

// Set up presentation format.
#set page(paper: "presentation-16-9", fill: luma(20))
#set text(size: 25pt, fill: white)

#slide(
  defined-cases: (
    "highlighted": case(block.with(outset: 0.5em, stroke: yellow)),
    "alert": case(text.with(fill: yellow)),
  ),
  s => (
    [
      #let tag = tag.with(s)
      = Mixing animations and pause

      #pause(s, [Hello, there!])
      #s.push(1)

      #pause(s, [Here are some switches you can choose.])
      #s.push(1)

      #set align(center + horizon)

      #let myrect = object(rect.with(height: 2cm, width: 2cm))

      #grid(columns: (1fr,) * 2, align: top)[
        #tag("green", myrect(fill: green))
        #tag("gtext", [If you press the green one, nothing will happen.])
      ][
        #tag("red", myrect(fill: red))
        #tag("rtext", [If you press the red one, also nothing...])
      ]

      #s.push((
        apply("green"),
        apply("red"),
      ))
      #s.push((
        once("gtext", "alert"),
        once("green", "highlighted"),
      ))
      #s.push((
        once("rtext", "alert"),
        once("red", "highlighted"),
      ))

      #pause(s, move(dy: -2em)[What did you choose?])
      #s.push(1)
    ],
    s,
  ),
)