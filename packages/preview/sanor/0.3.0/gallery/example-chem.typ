#import "@preview/sanor:0.3.0": *

// Set up presentation format.
#set page(paper: "presentation-16-9", fill: luma(20))
#set text(size: 25pt, fill: white)

#import "@preview/chemformula:0.1.3": ch

#slide(
  defined-cases: ("grayed": text.with(fill: gray.transparentize(70%))),
  s => (
    [
      #let tag = tag.with(s, hidden: none)
      = Redox Reaction

      #set align(center + horizon)
      // Use selectors to apply styles on certain elements
      #show select(ch("Fe")).or(select(ch("Fe^3+"))): set text(fill: orange)
      #show select(ch("Al")).or(select(ch("Al^3+"))): set text(fill: teal)
      #show select(ch("3e-")): tag.with("e-", hidden: "base")

      $
          && ch("Fe^3+ + Al &-> Fe + Al^3+") \
        tag("ox", "Oxidation:"&& ch("Al &-> Al^3+") + ch("3e-")) \
        tag("red", "Reduction:"&& ch("Fe^3+") + ch("3e-") ch("&-> Fe"))
      $

      #s.push(1)
      #s.push(apply("ox"))
      #s.push(apply("red"))
      #s.push(apply("e-", text.with(fill: yellow)))
      #s.push(force("e-", math.cancel, text.with(fill: luma(100))))
    ],
    s,
  ),
)
