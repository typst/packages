#set page(width: auto, height: auto)
#import "@local/lingotree:1.0.0": *
#import "@preview/mannot:0.3.0": mark, annot-cetz
#import "@preview/cetz:0.4.2"


// Renders a tree structure with specific marks indicating the start and end points of movement


#render(
  defaults: (align: center),
  tree(
    tag: [VP],
    tree(
      defaults: (color: blue),
      tag: [D],
      [D\ #mark(tag: <endqr>)[an]],
      [N\ egg],
    ),
    tree(
      tag: [VP], 
      [DP\ Jane],
      tree(
        tag: [VP],
        [V\ found],
        mark(tag: <begqr>, text(blue)[$t$])
      ),
    ),
  ),
)

// Integrate mannot and cetz functionalities
// Creates a canvas to track the positions of the marks in the tree and draws a Bezier arrow between them

#annot-cetz(
  (<begqr>, <endqr>),
  cetz,
  {
    cetz.draw.bezier-through(
      "begqr.south", 
      (rel: (x: -1, y: -1)), 

      // Adjusts the arrow's endpoint position to fall between "an" and "egg"
      (rel: (x: 0.3), to: "endqr.south"), 

      stroke: blue,
      mark: (end: "straight"),
    )
  },
)
