/// attributes used to guide the layout of the tree

/*
  create attributes for tree nodes
  - input:
    - `forest`: whether this node is the root of a forest
      - if false (default), the children are fitted into `tight`
      - if true, the children are fitted into `band`
    - `fit`: how to calculate the bounding box of this subtree
      - `"tight"` (default): fit subtree tightly with its sibling subtrees
      - `"rectangle"`: fit children in a rectangle with width equal to the widest span of the subtree and height equal to the height of the subtree
      - `"band"`: fit children in a band, i.e., the width is the same as the rectangle fit, but the height is infinite
    - `align-to`: specify the node that this node needs to align to
      - if an index specified, e,g, `0` as the first child, align this node above that child
      - if a string specified
        - `"midpoint"`: align to the midpoint of all children (default)
        - `"first"`: align to the first child
        - `"last"`: align to the last child
        - `"middle"`: align to the middle child (midpoint of the middle two if even number of children)
      - if a ratio specified, e.g. `25%`, align to that percentage point between the first and last child
    - `rotate`: rotate the subtree rooted at this node by the specified angle (counter-clockwise)
    - `sink`: sink the subtree rooted at this node by the specified number of layers
      - note: this argument must be a non-negative integer, and if the subtree sinks down too much as to exceed the original height of the tree, then nodes deeper than the original height will just be ignored which may cause overlapping but we have no better choice
  - output: metadata with node attributes
*/
#let node-attr(
  forest: false,
  fit: "tight",
  align-to: "midpoint",
  rotate: 0deg,
  sink: 0,
) = {
  metadata((
    class: "node-attr",
    forest: forest,
    fit: fit,
    align-to: align-to,
    rotate: rotate,
    sink: sink,
  ))
}
