/// attributes used to guide the layout of the tree

/*
  create attributes for tree nodes
  - input:
    - `forest`: whether this node is the root of a forest
      - if false (default), the subtrees from its children will be compressed horizontally together with this node
      - if true, the subtrees from its children will be treated as a separate tree and are not compressed horizontally
    - `align-to`: specify the node that this node needs to align to
      - if an index specified, e,g, `0` as the first child, align this node above that child
      - if a string specified
        - `"midpoint"`: align to the midpoint of all children (default)
        - `"first"`: align to the first child
        - `"last"`: align to the last child
        - `"middle"`: align to the middle child (midpoint of the middle two if even number of children)
  - output: metadata with node attributes
*/
#let node-attr(
  forest: false,
  align-to: "midpoint"
) = {
  metadata((
    class: "node-attr",
    forest: forest,
    align-to: align-to,
  ))
}
