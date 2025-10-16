#import "@preview/fletcher:0.5.8"

/*
  convert a flattened tree represented by array with indices to a simplified tree
  - input:
    - `arr`: array of `(indices, title)` pairs
      - `indices`: indices of the node in the tree, e.g. (0, 1, 2) means the node is the 2nd child of the 1st child of the root
      - `title`: title of the node
      - e.g.
        ```txt
                   Hello
                 /   |   \
              World  !   Like you
             /  |  \      /    \
           How are you  doing  today
          let arr = (
            (indices: (0,), title: "Hello"),
            (indices: (0, 0), title: "World"),
            (indices: (0, 1), title: "!"),
            (indices: (0, 2), title: "Like you"),
            (indices: (0, 0, 0), title: "How"),
            (indices: (0, 0, 1), title: "are"),
            (indices: (0, 0, 2), title: "you"),
            (indices: (0, 2, 0), title: "doing"),
            (indices: (0, 2, 1), title: "today"),
          )
        ```
  - output:
    - `ret`: a simplified tree represented by a three-dimensional array
      - see `tidy-tree-normalize` for the format
*/
#let tidy-tree-from-array-with-indices(arr) = {
  let array-set(arr, indices, value) = {
    if (indices.len() == 0) {
      arr = value
    } else {
      // fill in empty arrays until in bound
      let index = indices.at(0)
      for i in range(arr.len(), index + 1) {
        arr = arr + ((), )
      }
      arr.at(index) = array-set(arr.at(index), indices.slice(1), value)
    }
    arr
  }

  let tree = ()
  for (indices, title) in arr {
    // i-th level
    let i = indices.len() - 1
    // if root, j = 0, else j
    let j = if i == 0 { 0 } else {
      // pi = parent index in flattened (i - 1)-th level
      let pi = 0
      // i = current level index
      // cpi = child index in children of parent
      for (i, cpi) in indices.enumerate().slice(1, i) {
        // accumulate the previous nodes in the same level
        pi = tree.at(i).slice(0, pi).flatten().len()
        pi += cpi
      }
      pi
    }
    // k-th child
    let k = indices.at(i)
    tree = array-set(tree, (i, j, k), title)
  }
  tree
}

/*
  convert a dictionary with arrays to a simplified tree
  - input:
    - `tree`: a dictionary with arrays, read from json/yaml/toml file
      - e.g.
        ```json
          {
            "Hello": {
              "World": ["How", "are", "you"],
              "!": [],
              "Like you": ["doing", "today"]
            }
          }
        ```
        ```yaml
          Hello:
            - World:
                - How
                - are
                - you
            - !
            - Like you:
                - doing
                - today
        ```
        ```toml
          [Hello]
          World = ["How", "are", "you"]
          "!" = []
          "Like you" = ["doing", "today"]
        ```
  - output:
    - `ret`: a simplified tree represented by a three-dimensional array
      - see `tidy-tree-normalize` for the format
*/
#let tidy-tree-from-dict-with-arrays(tree) = {
  // flatten the tree structure to an array with indices
  let flatten-tree(tree, indices: ()) = {
    if type(tree) == dictionary {
      for (i, (title, tree)) in tree.pairs().enumerate() {
        let indices = indices + (i, )
        ((title: title, indices: indices), )
        flatten-tree(tree, indices: indices)
      }
    } else if type(tree) == array {
      tree.enumerate().map(((i, child)) => {
        let indices = indices + (i, )
        ((title: child, indices: indices), )
      }).flatten()
    } else {
      ((title: tree, indices: indices + (0, )), )
    }
  }
  let tree = flatten-tree(tree)

  // cast the flattened tree to three-dimensional array
  let tree = tidy-tree-from-array-with-indices(tree)

  tree
}

/*
  convert a list or enum to a simplified tree
  - input:
    - `body`: a content with a list or enum
      - e.g.
        ```typ
          - Hello
            - World
              - How
              - are
              - you
            - !
            - Like you
              - doing
              - today
        ```
  - output:
    - `ret`: a simplified tree represented by a three-dimensional array
      - see `tidy-tree-normalize` for the format
*/
#let tidy-tree-from-list(body) = {
  // cast a list or enum to a tree structure
  let collect-tree(body) = {
    if not body.has("children") {
      return (title: body, children: ())
    }

    let is-item(child) = child.func() == std.list.item or child.func() == std.enum.item
    body.children
      .fold(([], ()), ((title, children), child) => {
        if is-item(child) {
          (title, children + (collect-tree(child.body), ))
        } else {
          (title + child, children)
        }
      })
      .reduce((title, children) => (title: title, children: children))
  }
  let tree = collect-tree(body)
  
  // flatten the tree structure to an array with indices
  let flatten-tree(tree, indices: ()) = {
    if (indices.len() != 0) {
      ((title: tree.title, indices: indices, ),)
    }
    tree.children.enumerate()
      .map(((i, child)) => 
        flatten-tree(child, indices: indices + (i, )))
      .flatten()
  }
  let tree = flatten-tree(tree)
  
  // cast the flattened tree to three-dimensional array
  let tree = tidy-tree-from-array-with-indices(tree)
  
  tree
}

/*
  normalize a simplified tree to a normalized tree
  - input:
    - `tree`: a simplified tree represented by a three-dimensional array
      - for any `i, j`, `tree.at(i).at(j)` is the `i`-th level, whose parent is `j`-th node in the flattened `i - 1`-th level, e.g.
        ```txt
                   Hello
                 /   |   \
              World  !   Like you
             /  |  \      /    \
           How are you  doing  today
          let tree = (
            "Hello",
            (("World", "!", "Like you"), ),
            (("How", "are", "you"), (), ("doing", "today"),),
          )
        ```
        where `()` means there is not any child for that parent
  - output:
    - `ret`: a normalized tree represented by a three-dimensional array
      - for any `i, j, k`, `tree.at(i).at(j).at(k)` is the `i`-th level, whose parent is `j`-th node in the flattened `i - 1`-th level, `k`-th child, e.g.
        ```txt
                   Hello
                 /   |   \
              World  !   Like you
             /  |  \      /    \
           How are you  doing  today
          let tree = (
            (("Hello", ), ),
            (("World", "!", "Like you"), ),
            (("How", "are", "you"), (), ("doing", "today")),
          )
        ```
        where `()` means there is not any child for that parent, and you can leave out the empty `()` at the end of a level
*/
#let tidy-tree-normalize(tree) = {
  // convert simplified nodes to normalized nodes
  tree = tree.map((level) => {
    level = if type(level) != array {
      (level, )
    } else {
      level
    }
    level.map(children => {
      if type(children) != array {
        (children, )
      } else {
        children
      }
    })
  })

  // assert the root has exactly one node
  if tree.at(0).at(0).len() != 1 {
    panic("The root must have exactly one node")
  }

  // fill in empty nodes to make sure the number of children is the same as the number of parents in the previous level
  for i in range(1, tree.len()) {
    for _ in range(tree.at(i).len(), tree.at(i - 1).flatten().len()) {
      tree.at(i).push(())
    }
  }

  tree
}

/*
  calculate the horizontal axis position for a normalized tree when drawing as a tidy tree
  - input:
    - `tree`: a normalized tree represented by a three-dimensional array
      - see `tidy-tree-normalize` for the format
    - `min-gap`: minimum gap between two nodes, default to 1
    - `body`: only for debug, never use it
  - output:
    - `ret`: `(xs, body)`
      - `xs`: the same structure as `tree`, but each node is replaced by its horizontal axis position
      - `body`: only for debug, never use it
      
*/
#let tidy-tree-xs(tree, min-gap: 1, body: []) = {
  // calculate the horizontal axis position of every node
  let xs = tree.map(level => level.map(nodes => nodes.map(_ => 0)))

  // expand the tree horizontally
  let x = 0 // horizontal axis position of current leaf node
  let expand(i, j, k, xs, x, body) = {
    let n = tree.at(i).slice(0, j).flatten().len() + k // number of nodes before current node in current level
    
    // check if this node is leaf
    if i + 1 < tree.len() and tree.at(i + 1).at(n).len() > 0 {
      // not leaf
      let children = tree.at(i + 1).at(n)
      for (m, child) in children.enumerate() {
        (xs, x, body) = expand(i + 1, n, m, xs, x, body)
      }
      let children-xs = xs.at(i + 1).at(n)
      // xs.at(i).at(j).at(k) = children-xs.sum() / children-xs.len
      xs.at(i).at(j).at(k) = calc.max(..children-xs) - (calc.max(..children-xs) - calc.min(..children-xs)) / 2
      ()
    } else {
      // leaf
      xs.at(i).at(j).at(k) = x
      x += min-gap
    }

    (xs, x, body)
  }
  (xs, x, body) = expand(0, 0, 0, xs, x, body)
  // here, x is the width of the tree

  // try to compress the tree horizontally
  let height = tree.len()
  let dxs = tree.map(level => level.map(nodes => nodes.map(_ => 0)))
  let lefts = tree.map(level => level.map(nodes => nodes.map(_ => range(0, height).map(_ => 3 * x))))
  let rights = tree.map(level => level.map(nodes => nodes.map(_ => range(0, height).map(_ => -3 * x))))
  let try-compress(i, j, k, dxs, lefts, rights, body) = {
    let n = tree.at(i).slice(0, j).flatten().len() + k // number of nodes before current node in current level
    // initialize lefts and rights for current node
    let leafx = xs.at(i).at(j).at(k)
    lefts.at(i).at(j).at(k).at(i) = leafx
    rights.at(i).at(j).at(k).at(i) = leafx

    // check if this node is leaf
    if i + 1 >= tree.len() or tree.at(i + 1).at(n).len() == 0 {
      // leaf
      return (dxs, lefts, rights, body)
    }

    // not leaf
    for (m, child) in tree.at(i + 1).at(n).enumerate() {
      (dxs, lefts, rights, body) = try-compress(i + 1, n, m, dxs, lefts, rights, body)
    }

    // from the first left subtree, continue to compact the right subtrees
    let left-right = rights.at(i + 1).at(n).at(0)
    for m in range(1, tree.at(i + 1).at(n).len()) {
      let right-left = lefts.at(i + 1).at(n).at(m)
      let need-dx = calc.max(..left-right.zip(right-left).map(((a, b)) => a + min-gap - b))
      if need-dx < 0 {
        // can compact
        dxs.at(i + 1).at(n).at(m) += need-dx
        lefts.at(i + 1).at(n).at(m) = lefts.at(i + 1).at(n).at(m).map(x => x + need-dx)
        rights.at(i + 1).at(n).at(m) = rights.at(i + 1).at(n).at(m).map(x => x + need-dx)
      }
      left-right = rights.at(i + 1).at(n).at(m).zip(left-right).map(((a, b)) => calc.max(a, b))
    }

    // average the spacing of children
    for m in range(1, tree.at(i + 1).at(n).len() - 1) {
      let left-spacing = calc.max(..rights.at(i + 1).at(n).at(m - 1).zip(lefts.at(i + 1).at(n).at(m)).map(((a, b)) => a - b))
      let right-spacing = calc.max(..rights.at(i + 1).at(n).at(m).zip(lefts.at(i + 1).at(n).at(m + 1)).map(((a, b)) => a - b))
      let average-spacing = (left-spacing + right-spacing) / 2

      let need-dx = left-spacing - average-spacing
      // because has been compressed to left, thus can only move right
      if need-dx > 0 {
        // calculate the left most positions of right subtrees after moving
        let right-left-mosts = lefts.at(i + 1).at(n).slice(m + 1, tree.at(i + 1).at(n).len()).reduce((a, b) => a.zip(b).map(((x, y)) => calc.min(x, y)))

        // check whether can move
        if rights.at(i + 1).at(n).at(m).zip(right-left-mosts).map(((a, b)) => a + need-dx <= b).reduce((a, b) => a and b) {
          dxs.at(i + 1).at(n).at(m) += need-dx
          lefts.at(i + 1).at(n).at(m) = lefts.at(i + 1).at(n).at(m).map(x => x + need-dx)
          rights.at(i + 1).at(n).at(m) = rights.at(i + 1).at(n).at(m).map(x => x + need-dx)
        }
      }
    }

    // move subtrees align to the center
    let children-xs = xs.at(i + 1).at(n).zip(dxs.at(i + 1).at(n)).map(((x, dx)) => x + dx)
    let children-dx-center = leafx - (calc.max(..children-xs) + calc.min(..children-xs)) / 2
    for m in range(0, tree.at(i + 1).at(n).len()) {
      dxs.at(i + 1).at(n).at(m) += children-dx-center
      lefts.at(i + 1).at(n).at(m) = lefts.at(i + 1).at(n).at(m).map(x => x + children-dx-center)
      rights.at(i + 1).at(n).at(m) = rights.at(i + 1).at(n).at(m).map(x => x + children-dx-center)
    }

    // lefts are the leftest positions of every level of the left subtree
    lefts.at(i).at(j).at(k) = lefts.at(i + 1).at(n).reduce((a, b) => a.zip(b).map(((x, y)) => calc.min(x, y)))
    // rights are the rightest positions of every level of the right subtree
    rights.at(i).at(j).at(k) = rights.at(i + 1).at(n).reduce((a, b) => a.zip(b).map(((x, y)) => calc.max(x, y)))
    lefts.at(i).at(j).at(k).at(i) = leafx
    rights.at(i).at(j).at(k).at(i) = leafx

    (dxs, lefts, rights, body)
  }
  (dxs, lefts, rights, body) = try-compress(0, 0, 0, dxs, lefts, rights, body)

  // apply compress to xs
  let apply-compress(i, j, k, dxs, xs, dx, body) = {
    let n = tree.at(i).slice(0, j).flatten().len() + k // number of nodes before current node in current level
    
    // check if this node is leaf
    if i + 1 < tree.len() and tree.at(i + 1).at(n).len() > 0 {
      // not leaf
      let children = tree.at(i + 1).at(n)
      for (m, child) in children.enumerate() {
        (xs, body) = apply-compress(i + 1, n, m, dxs, xs, dx + dxs.at(i).at(j).at(k), body)
      }
    }

    // apply dxs to xs
    xs.at(i).at(j).at(k) += dx + dxs.at(i).at(j).at(k)

    (xs, body)
  }
  (xs, body) = apply-compress(0, 0, 0, dxs, xs, 0, body)

  // make sure the minimum x is 0
  let x-min = calc.min(..xs.flatten())
  xs = xs.map(level => level.map(nodes => nodes.map(x => x - x-min)))

  (xs, body)
}

/*
  generate elements for drawing a tidy tree
  - input:
    - `tree`: a normalized tree represented by a three-dimensional array
      - see `tidy-tree-normalize` for the format
    - `xs`: the same structure as `tree`, but each node is replaced by its horizontal axis position
      - see `tidy-tree-xs` for the format
    - `draw-node`: function for drawing a node, default to a rectangle node
      - input:
        - `pos`: position of the node, `(x, y)`, where `x` is the horizontal axis position calculated by `tidy-tree-xs`, `y` is the level of the node
        - `name`: label of the node, can be used to connect edges
        - `label`: label of the node, can be used to display text
        - `(i, j, k)`: indices of the node in the tree structure
      - output:
        - `ret`: a node element
    - `draw-edge`: function for drawing an edge, default to a straight arrow
      - input:
        - `from-name`: label of the parent node
        - `to-name`: label of the child node
        - `((i1, j1, k1), (i2, j2, k2))`: indices of the parent node and child node in the tree structure
      - output:
        - `ret`: an edge element
  - output:
    - `ret`: an array of elements for drawing a tidy tree
*/
#let tidy-tree-elements(tree, xs, draw-node, draw-edge) = {
  let elements = ()
  let parents = ((none, none), ) * tree.at(0).len() // labels of parent nodes for current level
  let label-count = 0
  let new-label(label-count) = {
    label("tree-label-" + str(label-count))
  }
  // for every (i, j, k), means the i-th level, the j-th parent, the k-th child
  for (i, level) in tree.enumerate() {
    for (j, children) in level.enumerate() {
      let (parent-label, parent-position) = parents.at(j)
      for (k, child) in children.enumerate() {
        let label = new-label(label-count); label-count += 1

        let x = xs.at(i).at(j).at(k)
        elements.push(
          draw-node((x, i), label, child, (i, j, k, x))
        )
        if (parent-label != none) {
          elements.push(
            draw-edge(parent-label, label, (parent-position, (i, j, k, x)))
          )
        }
        parents.push((label, (i, j, k, x)))
      }
    }
    parents = parents.slice(level.len())
  }

  elements
}

/// pre-defined drawing functions for tidy tree
#let tidy-tree-draws = (
  /// default function for drawing a node
  default-draw-node: (pos, name, label, (i, j, k, x)) => fletcher.node(pos, [#label], name: name),
  /// default function for drawing an edge
  default-draw-edge: (from-name, to-name, ((i1, j1, k1, x1), (i2, j2, k2, x2))) => fletcher.edge(from-name, to-name, "-|>"),
  /// draw an edge with horizontal-vertical style
  horizontal-vertical-draw-edge: (from-name, to-name, ((i1, j1, k1, x1), (i2, j2, k2, x2))) => {
    let from-anchor = (name: from-name, anchor: "south")
    let to-anchor = (name: to-name, anchor: "north")
    let middle-anchor = (from-anchor, 50%, to-anchor)
    if x1 == x2 {
      fletcher.edge(from-anchor, to-anchor, "-|>")
    } else {
      fletcher.edge(
        from-anchor,
        ((), "|-", middle-anchor),
        ((), "-|", to-anchor),
        to-anchor,
        "-|>"
      )
    }
  }
)

/*
  draw a tidy tree
  - input:
    - `body`: a content with a list or enum, or a dictionary with arrays
      - see `tidy-tree-from-list` and `tidy-tree-from-dict-with-arrays` for the format
    - `draw-node`: function for drawing a node, default to a rectangle node
      - input:
        - `pos`: position of the node, `(x, y)`, where `x` is the horizontal axis position calculated by `tidy-tree-xs`, `y` is the level of the node
        - `name`: label of the node, can be used to connect edges
        - `label`: label of the node, can be used to display text
        - `(i, j, k, x)`: indices and horizontal position of the node in the tree structure
      - output:
        - `ret`: a node element
    - `draw-edge`: function for drawing an edge, default to a straight arrow
      - input:
        - `from-name`: label of the parent node
        - `to-name`: label of the child node
        - `((i1, j1, k1, x1), (i2, j2, k2, x2))`: indices and horizontal position of the parent node and child node in the tree structure
      - output:
        - `ret`: an edge element
    - `min-gap`: minimum gap between two nodes, default to 1
    - `text-size`: size of the text, default to 6pt
    - `node-stroke`: stroke of the node, default to 0.25pt
    - `node-inset`: inset of the node, default to 2pt
    - `spacing`: horizontal and vertical spacing between nodes, default to (5pt, 10pt)
    - `edge-corner-radius`: corner radius of the edge, default to none
    - `..args`: other arguments for `fletcher.diagram`
  - output:
    - `ret`: a tidy tree drawing
*/
#let tidy-tree-graph(
  body,
  draw-node: tidy-tree-draws.default-draw-node,
  draw-edge: tidy-tree-draws.default-draw-edge,
  min-gap: 1,
  text-size: 8pt,
  node-stroke: 0.25pt,
  spacing: (6pt, 15pt),
  node-inset: 3pt,
  edge-corner-radius: none,
  ..args,
) = {
  let tree = if type(body) == content {
    tidy-tree-from-list(body)
  } else if type(body) == dictionary {
    tidy-tree-from-dict-with-arrays(body)
  } else if type(body) == array {
    body
  } else {
    error("body must be a content with a list or enum, or a dictionary with arrays")
  }
  // cast a simplified tree into a normalized tree
  let tree = tidy-tree-normalize(tree)
  // calculate the horizontal axis position of every node
  let (xs, _) = tidy-tree-xs(tree, min-gap: min-gap)
  // generate elements
  let elements = tidy-tree-elements(tree, xs, draw-node, draw-edge)

  set text(size: text-size)
  fletcher.diagram(
    node-stroke: node-stroke,
    spacing: spacing,
    node-inset: node-inset,
    edge-corner-radius: none,
    ..args,

    // Nodes
    ..elements,
  )
  
}
