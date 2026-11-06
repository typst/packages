#import "@preview/sanor:0.2.1": *

// Set up presentation format.
#set page(paper: "presentation-16-9", fill: luma(20))
#set text(size: 25pt, fill: white)

#slide(s => (
  [
    #let tag = tag.with(s)
    = Math Example
    Simplify
    $
      (x(x + 1)tag("m", (x + 2)))/(2 tag("m", (x + 2)))
    $
    #s.push(apply("m")) // Show the `m`.
    #s.push(apply("m", text.with(fill: red))) // Make it red.
    #s.push(apply("m", math.cancel)) // Cancel it.
    #s.push(apply("m", it => none)) // Remove it.
    #s.push(-1) // to move the `pause` up
    #pause(s)[End.]
    #s.push(1) // to update the last `pause`.
  ],
  s,
))