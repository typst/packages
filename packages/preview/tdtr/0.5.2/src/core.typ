#import "@preview/fletcher:0.5.8"
#import "draws.typ" as tidy-tree-draws : *
#import "attrs.typ": *

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
            World:
                - How
                - are
                - you
            "!":
            Like you:
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

    // exclude std.table, std.grid, etc.
    // although they have children, we do not want to unfold them
    if body.func() in dictionary(std).values() {
      return (title: body, children: ())
    }

    let is-list-item(child) = child.func() == std.list.item
    let is-enum-item(child) = child.func() == std.enum.item
    body.children
      .fold(([], ()), ((title, children), child) => {
        if is-list-item(child) {
          (title, children + (collect-tree(child.body), ))
        } else if is-enum-item(child) {
          // leave out enum titles since they are for edge labels
          (title, children)
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
  construct an empty tree of edges with the same structure as a normalized tree
  - input:
    - `tree`: a normalized tree represented by a three-dimensional array
      - see `tidy-tree-normalize` for the format
  - output:
    - `ret`: a normalized tree of edges represented by a three-dimensional array
      - see `tidy-tree-edges-from-list` for the format
*/
#let tidy-tree-edges-empty(tree) = {
  tree.map((level) => level.map((children) => children.map(_ => none)))
}

/*
  collect edge labels from a list or enum
  - input:
    - `body`: a content with a list or enum
      - e.g.
        ```typ
          - Hello
            + a
            - World
              - How
              - are
              + d
              - you
            + b
            - !
            + c
            - Like you
              + e
              - doing
              - today
        ```
  - output:
    - `ret`: a simplified tree of edges represented by a three-dimensional array, if no edge label, use `none`
      - e.g.
        ```txt
                      Hello
                    /   |   \
                    a   b    c
                  /     |     \
                World   !    Like you
              /  |  \         /    \
             /   |   d       e      \
            /    |    \     /        \
           How  are   you doing    today
          let tree = (
            ((none, ), ),
            (("a", "b", "c"), ),
            ((none, none, "d"), (), ("e", )),
          )
        ```
*/
#let tidy-tree-edges-from-list(body) = {
  // cast a list or enum to a tree structure
  let collect-tree-edges(body, title: none) = {
    if not body.has("children") {
      return (title: title, children: ())
    }

    // exclude std.table, std.grid, etc.
    // although they have children, we do not want to unfold them
    if body.func() in dictionary(std).values() {
      return (title: title, children: ())
    }

    let is-list-item(child) = child.func() == std.list.item
    let is-enum-item(child) = child.func() == std.enum.item
    body.children
      .fold(((), none), ((children, title), child) => {
        if is-list-item(child) {
          // apply edge label from the nearest enum item
          (children + (collect-tree-edges(child.body, title: title), ), none)
        } else if is-enum-item(child) {
          // save enum title as edge label
          (children, child.body)
        } else {
          // leave out other texts since they are for node titles
          (children, title)
        }
      })
      .reduce((children, _, ) => (title: title, children: children))
  }

  let tree-edges = collect-tree-edges(body)

  // flatten the tree structure to an array with indices
  let flatten-tree-edges(tree, indices: ()) = {
    if (indices.len() != 0) {
      ((title: tree.title, indices: indices, ),)
    }
    tree.children.enumerate()
      .map(((i, child)) => 
        flatten-tree-edges(child, indices: indices + (i, )))
      .flatten()
  }
  let tree-edges = flatten-tree-edges(tree-edges)

  // cast the flattened tree to three-dimensional array
  let tree-edges = tidy-tree-from-array-with-indices(tree-edges)
  
  tree-edges
}

/*
  collect node attributes from a normalized tree
  - input:
    - `tree`: a normalized tree represented by a three-dimensional array
      - see `tidy-tree-normalize` for the format
    - `default-node-attr`: default attributes for nodes, default to `node-attr().value`
      - see `node-attr` for more details
  - output:
    - `ret`: a three-dimensional array with the same structure as `tree`, but each node is replaced by its attributes dictionary
*/
#let tidy-tree-attrs(tree, default-node-attr: node-attr()) = {
  tree.map(level => level.map(nodes => nodes.map(node => {
    let values = collect-metadata(node)
    let attr = values
      .filter(meta => type(meta) == dictionary)
      .find(meta => meta.at("class", default: "") == "node-attr")
    if attr == none {
      // if not specified, use default node attributes
      default-node-attr.value
    } else {
      attr
    }
  })))
}

/*
  calculate the coordinates for a normalized tree when drawing as a tidy tree
  - input:
    - `tree`: a normalized tree represented by a three-dimensional array
      - see `tidy-tree-normalize` for the format
    - `root`: root node to start calculating positions
      - `(i, j, k)`, see `tidy-tree-elements` for more details
    - `min-gap`: minimum gap between two nodes, default to 1
    - `default-node-attr`: default attributes for nodes, default to `node-attr().value`
      - see `node-attr` for more details
    - `body`: only for debug, never use it
  - output:
    - `ret`: `(xs, ys, body)`
      - `xs`: the same structure as `tree`, but each node is replaced by its horizontal axis position
      - `ys`: the same structure as `tree`, but each node is replaced by its vertical axis position
      - `body`: only for debug, never use it
      
*/
#let tidy-tree-coords(tree, root: (0, 0, 0), min-gap: 1, default-node-attr: node-attr(), body: []) = {
  let (ri, rj, rk) = root
  // calculate the horizontal axis position of every node
  let xs = tree.map(level => level.map(nodes => nodes.map(_ => 0)))
  // calculate the vertical axis position of every node
  let ys = tree.map(level => level.map(nodes => nodes.map(_ => 0)))

  // collect all node attributes
  let attrs = tree

  // expand the tree horizontally and vertically
  let x = 0 // horizontal axis position of current leaf node
  let expand(i, j, k, xs, ys, x, body) = {
    let n = tree.at(i).slice(0, j).flatten().len() + k // number of nodes before current node in current level
    
    // check if this node is leaf
    if i + 1 < tree.len() and tree.at(i + 1).at(n).len() > 0 {
      // not leaf
      let children = tree.at(i + 1).at(n)
      for (m, child) in children.enumerate() {
        (xs, ys, x, body) = expand(i + 1, n, m, xs, ys, x, body)
      }
      let children-xs = xs.at(i + 1).at(n)
      // xs.at(i).at(j).at(k) = children-xs.sum() / children-xs.len
      xs.at(i).at(j).at(k) = calc.max(..children-xs) - (calc.max(..children-xs) - calc.min(..children-xs)) / 2
    } else {
      // leaf
      xs.at(i).at(j).at(k) = x
      x += min-gap
    }

    // set vertical position
    ys.at(i).at(j).at(k) = i * min-gap

    (xs, ys, x, body)
  }
  (xs, ys, x, body) = expand(ri, rj, rk, xs, ys, x, body)
  // here, x is the width of the tree

  // try to compress the tree horizontally
  // also tackle rotation of subtrees
  let height = tree.len()
  let dxs = tree.map(level => level.map(nodes => nodes.map(_ => 0)))
  let dys = tree.map(level => level.map(nodes => nodes.map(_ => 0)))
  let lefts = tree.map(level => level.map(nodes => nodes.map(_ => range(0, height).map(_ => 3 * x))))
  let rights = tree.map(level => level.map(nodes => nodes.map(_ => range(0, height).map(_ => -3 * x))))
  let try-compress(i, j, k, xs, ys, dxs, dys, lefts, rights, body) = {
    let n = tree.at(i).slice(0, j).flatten().len() + k // number of nodes before current node in current level
    // initialize lefts and rights for current node
    let leafx = xs.at(i).at(j).at(k)
    lefts.at(i).at(j).at(k).at(i) = leafx
    rights.at(i).at(j).at(k).at(i) = leafx

    let rotate = attrs.at(i).at(j).at(k).rotate
    // if rotate, treat the subtree as an independent subtree
    // namely, treat the node as if it is leaf
    if rotate != 0deg {
      let tree = tree
      tree.at(i).at(j).at(k).rotate = 0deg // mark as visited
      let (xs-sub, ys-sub, body-sub) = tidy-tree-coords(tree, root: (i, j, k), min-gap: min-gap, default-node-attr: default-node-attr, body: body)
      body = body-sub

      // first move the subtree to root at (0, 0)
      let rootx-sub = xs-sub.at(i).at(j).at(k)
      let rooty-sub = ys-sub.at(i).at(j).at(k)
      xs-sub = xs-sub.map(level => level.map(nodes => nodes.map(x => x - rootx-sub)))
      ys-sub = ys-sub.map(level => level.map(nodes => nodes.map(y => y - rooty-sub)))

      // then override the positions of the current subtree nodes
      let cx = xs.at(i).at(j).at(k)
      let cy = ys.at(i).at(j).at(k)
      let override(i, j, k, xs, ys, body) = {
        let n = tree.at(i).slice(0, j).flatten().len() + k // number of nodes before current node in current level
        
        // if not leaf, override children
        if i + 1 < tree.len() and tree.at(i + 1).at(n).len() > 0 {
          for (m, child) in tree.at(i + 1).at(n).enumerate() {
            (xs, ys, body) = override(i + 1, n, m, xs, ys, body)
          }
        }

        // override current node
        let x-sub = xs-sub.at(i).at(j).at(k)
        let y-sub = ys-sub.at(i).at(j).at(k)
        xs.at(i).at(j).at(k) = x-sub + cx
        ys.at(i).at(j).at(k) = y-sub + cy

        (xs, ys, body)
      }
      (xs, ys, body) = override(i, j, k, xs, ys, body)

      // calculate the rotated positions
      let angle = - rotate / 180deg * calc.pi
      let cx-sub = xs-sub.at(i).at(j).at(k)
      let cy-sub = ys-sub.at(i).at(j).at(k)
      let rotate(i, j, k, xs, ys, body) = {
        let n = tree.at(i).slice(0, j).flatten().len() + k // number of nodes before current node in current level
        
        // if not leaf, rotate children
        if i + 1 < tree.len() and tree.at(i + 1).at(n).len() > 0 {
          for (m, child) in tree.at(i + 1).at(n).enumerate() {
            (xs, ys, body) = rotate(i + 1, n, m, xs, ys, body)
          }
        }

        // rotate current node
        let x-sub = xs-sub.at(i).at(j).at(k)
        let y-sub = ys-sub.at(i).at(j).at(k)
        let x-rot = (x-sub - cx-sub) * calc.cos(angle) - (y-sub - cy-sub) * calc.sin(angle)
        let y-rot = (x-sub - cx-sub) * calc.sin(angle) + (y-sub - cy-sub) * calc.cos(angle)
        xs.at(i).at(j).at(k) += x-rot - x-sub
        ys.at(i).at(j).at(k) += y-rot - y-sub

        (xs, ys, body)
      }
      (xs, ys, body) = rotate(i, j, k, xs, ys, body)
    }
    // check if this node is leaf
    else if i + 1 < tree.len() and tree.at(i + 1).at(n).len() != 0 {
      // not leaf
      for (m, child) in tree.at(i + 1).at(n).enumerate() {
        (xs, ys,dxs, dys, lefts, rights, body) = try-compress(i + 1, n, m, xs, ys, dxs, dys, lefts, rights, body)
      }

      // from the first left subtree, continue to compact the right subtrees
      let left-right = rights.at(i + 1).at(n).at(0)
      for m in range(1, tree.at(i + 1).at(n).len()) {
        let right-left = lefts.at(i + 1).at(n).at(m)
        let need-dx = calc.max(..left-right.zip(right-left).map(((a, b)) => a + min-gap - b))
        dxs.at(i + 1).at(n).at(m) += need-dx
        lefts.at(i + 1).at(n).at(m) = lefts.at(i + 1).at(n).at(m).map(x => x + need-dx)
        rights.at(i + 1).at(n).at(m) = rights.at(i + 1).at(n).at(m).map(x => x + need-dx)
        left-right = rights.at(i + 1).at(n).at(m).zip(left-right).map(((a, b)) => calc.max(a, b))
      }

      // average the spacing of children
      for m in range(1, tree.at(i + 1).at(n).len() - 1) {
        let left-spacing = calc.max(..rights.at(i + 1).at(n).at(m - 1).zip(lefts.at(i + 1).at(n).at(m)).map(((a, b)) => a - b))
        let right-spacing = calc.max(..rights.at(i + 1).at(n).at(m).zip(lefts.at(i + 1).at(n).at(m + 1)).map(((a, b)) => a - b))
        let average-spacing = (left-spacing + right-spacing) / 2

        let need-dx = left-spacing - average-spacing
        if need-dx <= 0 {
          continue
        }
        // calculate the left most positions of right subtrees after moving
        let right-left-mosts = lefts.at(i + 1).at(n).slice(m + 1, tree.at(i + 1).at(n).len()).reduce((a, b) => a.zip(b).map(((x, y)) => calc.min(x, y)))

        // check whether can move
        if rights.at(i + 1).at(n).at(m).zip(right-left-mosts).map(((a, b)) => a + need-dx <= b).reduce((a, b) => a and b) {
          dxs.at(i + 1).at(n).at(m) += need-dx
          lefts.at(i + 1).at(n).at(m) = lefts.at(i + 1).at(n).at(m).map(x => x + need-dx)
          rights.at(i + 1).at(n).at(m) = rights.at(i + 1).at(n).at(m).map(x => x + need-dx)
        }
      }

      // move subtrees align to the center
      let children-xs = xs.at(i + 1).at(n).zip(dxs.at(i + 1).at(n)).map(((x, dx)) => x + dx)
      let align-to = attrs.at(i).at(j).at(k).align-to
      let children-dx-center = leafx - if align-to == "midpoint" {
        (calc.max(..children-xs) + calc.min(..children-xs)) / 2
      } else if align-to == "first" {
        children-xs.at(0)
      } else if align-to == "last" {
        children-xs.at(children-xs.len() - 1)
      } else if align-to == "middle" {
        let mid = calc.floor(children-xs.len() / 2)
        if calc.rem(children-xs.len(), 2) == 1 {
          children-xs.at(mid)
        } else {
          (children-xs.at(mid - 1) + children-xs.at(mid)) / 2
        }
      } else if type(align-to) == int {
        children-xs.at(align-to)
      } else if type(align-to) == ratio {
        children-xs.at(0) + float(align-to) * (children-xs.at(children-xs.len() - 1) - children-xs.at(0))
      }
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
    }

    // treat the subtree as a whole to avoid further compression
    let forest = i > 0 and attrs.at(i - 1).flatten().at(j).forest
    let fit = attrs.at(i).at(j).at(k).fit
    
    // if forest, treat its children as if they have band fit
    if forest or fit == "band" {
      let left-most = calc.min(..lefts.at(i).at(j).at(k))
      let right-most = calc.max(..rights.at(i).at(j).at(k))

      lefts.at(i).at(j).at(k) = lefts.at(i).at(j).at(k).map(_ => left-most)
      rights.at(i).at(j).at(k) = rights.at(i).at(j).at(k).map(_ => right-most)
    } else if fit == "rectangle" {
      let left-most = calc.min(..lefts.at(i).at(j).at(k))
      let right-most = calc.max(..rights.at(i).at(j).at(k))

      // unlike band, rectangle only reaches to the bottom of the subtree
      // and the height is not infinite
      let left-bottom = lefts.at(i).at(j).at(k).enumerate().find(((h, left-cur)) => left-cur == left-most).at(0)
      let right-bottom = rights.at(i).at(j).at(k).enumerate().find(((h, right-cur)) => right-cur == right-most).at(0)

      lefts.at(i).at(j).at(k) = lefts.at(i).at(j).at(k).enumerate().map(((h, left-cur)) => {
        if h >= i and h < left-bottom {
          left-most
        } else {
          left-cur
        }
      })

      rights.at(i).at(j).at(k) = rights.at(i).at(j).at(k).enumerate().map(((h, right-cur)) => {
        if h >= i and h < right-bottom {
          right-most
        } else {
          right-cur
        }
      })
    } else if fit == "tight" {
      // do nothing, default behavior
    }

    (xs, ys, dxs, dys, lefts, rights, body)
  }
  (xs, ys, dxs, dys, lefts, rights, body) = try-compress(ri, rj, rk, xs, ys, dxs, dys, lefts, rights, body)

  // apply compress for recursive dxs and dys
  let apply-compress(i, j, k, dxs, dys, xs, ys, dx, dy, body) = {
    let n = tree.at(i).slice(0, j).flatten().len() + k // number of nodes before current node in current level
    
    // check if this node is leaf
    if i + 1 < tree.len() and tree.at(i + 1).at(n).len() > 0 {
      // not leaf
      let children = tree.at(i + 1).at(n)
      for (m, child) in children.enumerate() {
        (xs, ys, body) = apply-compress(i + 1, n, m, dxs, dys, xs, ys, dx + dxs.at(i).at(j).at(k), dy + dys.at(i).at(j).at(k), body)
      }
    }

    // apply dxs to xs
    xs.at(i).at(j).at(k) += dx + dxs.at(i).at(j).at(k)
    // apply dys to ys
    ys.at(i).at(j).at(k) += dy + dys.at(i).at(j).at(k)

    (xs, ys, body)
  }
  (xs, ys, body) = apply-compress(ri, rj, rk, dxs, dys, xs, ys, 0, 0, body)

  // make sure the minimum x is 0
  let x-min = calc.min(..xs.flatten())
  xs = xs.map(level => level.map(nodes => nodes.map(x => x - x-min)))
  // make sure the minimum y is 0
  let y-min = calc.min(..ys.flatten())
  ys = ys.map(level => level.map(nodes => nodes.map(y => y - y-min)))

  (xs, ys, body)
}

/*
  generate elements for drawing a tidy tree
  - input:
    - `tree`: a normalized tree represented by a three-dimensional array
      - see `tidy-tree-normalize` for the format
    - `tree-edges`: a normalized tree of edges represented by a three-dimensional array
      - see `tidy-tree-edges-from-list` for the format
    - `xs`: the same structure as `tree`, but each node is replaced by its horizontal axis position
      - see `tidy-tree-coords` for the format
    - `ys`: the same structure as `tree`, but each node is replaced by its vertical axis position
      - see `tidy-tree-coords` for the format
    - `draw-node`: function for drawing a node, default to a rectangle node
      - input:
        - `node`: the information of the node, represented by a dictionary with the following keys:
          - `name`: name of the node, can be used to connect edges
          - `label`: label of the node, can be used to display content
          - `pos`: position of the node in the tree structure, represented by a dictionary with the following keys:
            - `i`: level of the node
            - `j`: index of the parent node in the flattened `i - 1`-th level
            - `k`: index of the child node in the children of the parent node
            - `x`: horizontal axis position of the node
            - `y`: vertical axis position of the node
      - output:
        - `ret`: the arguments passed to `fletcher.node`, can be a dictionary, an array or an argument object
    - `draw-edge`: function for drawing an edge, default to a straight arrow
      - input:
        - `from-node`: the information of the parent node, same format as `node` in `draw-node`
        - `to-node`: the information of the child node, same format as `node` in `draw-node`
        - `edge-label`: label of the edge, can be used to display content
      - output:
        - `ret`: the arguments passed to `fletcher.edge`, can be a dictionary, an array or an argument object
    - `compact`: whether to compact the tree horizontally, default to false
      - if true, may cause overlapping nodes when some very long nodes are siblings in fractional positions
  - output:
    - `ret`: an array of elements for drawing a tidy tree
*/
#let tidy-tree-elements(tree, xs, ys, tree-edges, draw-node, draw-edge, compact: false) = {
  let elements = ()
  let nodes = ()
  let parents = (none, ) * tree.at(0).len() // labels of parent nodes for current level
  let label-count = 0
  let new-label(label-count) = {
    label("tree-label-" + str(label-count))
  }
  // for every (i, j, k), means the i-th level, the j-th parent, the k-th child
  for (i, level) in tree.enumerate() {
    for (j, children) in level.enumerate() {
      let parent-node = parents.at(j)
      for (k, child) in children.enumerate() {
        let x = xs.at(i).at(j).at(k)
        let y = ys.at(i).at(j).at(k)

        let child-edge = tree-edges.at(i).at(j).at(k)
        let child-label = new-label(label-count); label-count += 1
        let child-pos = (i: i, j: j, k: k, x: x, y: y)
        let child-node = (
          name: child-label, 
          label: child, 
          pos: child-pos
        )

        // prevent overlapping nodes by drawing hidden nodes at left and right positions
        if not compact {
          let child-pos-left = (i: i, j: j, k: k, x: calc.floor(x), y: calc.floor(y))
          let child-pos-right = (i: i, j: j, k: k, x: calc.ceil(x), y: calc.ceil(y))

          let child-node-left = (
            name: none, 
            label: child, 
            pos: child-pos-left
          )
          let child-node-right = (
            name: none, 
            label: child, 
            pos: child-pos-right
          )

          elements.push(fletcher.hide(fletcher.node(..draw-node(child-node-left))))
          elements.push(fletcher.hide(fletcher.node(..draw-node(child-node-right))))
        }

        // add node and edge
        elements.push(fletcher.node(..draw-node(child-node)))
        nodes.push(child-node)
        if parent-node != none {
          elements.push(
            fletcher.edge(..draw-edge(parent-node, child-node, child-edge))
          )
        }

        // update parents for next level
        parents.push(child-node)
      }
    }
    parents = parents.slice(level.len())
  }

  (elements, nodes)
}
 
/*
  draw a tidy tree
  - input:
    - `body`: a content with a list or enum, or a dictionary with arrays
      - see `tidy-tree-from-list` and `tidy-tree-from-dict-with-arrays` for the format
    - `draw-node`: a single or an array of functions for drawing a node, default to a rectangle node
      - see `tidy-tree-elements` for the format of every function
    - `draw-edge`: a single or an array of functions for drawing an edge, default to a straight arrow
      - see `tidy-tree-elements` for the format of every function
    - `additional-draw`: a single or an array of functions for drawing additional elements after drawing the tree, default to no additional drawing
      - input:
        - `args`: some configuration relative arguments for `fletcher.diagram`
        - `elements`: the generated elements (nodes and edges) from the `body`
        - `node`: the `fletcher.node` function, used to draw nodes if you need to add extra nodes
        - `edge`: the `fletcher.edge` function, used to draw edges if you need to add extra edges
      - output:
        - `ret`: the arguments passed to `fletcher.diagram`, can be a dictionary, an array or an argument object
    - `compact`: whether to compact the tree horizontally, default to false
      - if true, may cause overlapping nodes when some very long nodes are siblings in fractional positions
    - `min-gap`: minimum gap between two nodes, default to 1
    - `default-node-attr`: default attributes for nodes, default to `node-attr().value`
      - see `node-attr` for more details
    - `text-size`: size of the text, default to 6pt
    - `node-stroke`: stroke of the node, default to 0.25pt
    - `node-inset`: inset of the node, default to 2pt
    - `node-width`: width of the node, default to auto
      - Note: this is not the argument of `fletcher.diagram`, only supported in this function
    - `node-height`: height of the node, default to auto
      - Note: this is not the argument of `fletcher.diagram`, only supported in this function
    - `spacing`: horizontal and vertical spacing between nodes, default to (5pt, 10pt)
    - `edge-corner-radius`: corner radius of the edge, default to none
    - `wrapper`: only for wrapper use, never set it manually
      - if true, will return the drawing functions directly instead of drawing the tree
    - `..args`: other arguments for `fletcher.diagram`
  - output:
    - `ret`: a tidy tree drawing
*/
#let tidy-tree-graph(
  body,
  draw-node: tidy-tree-draws.default-draw-node,
  draw-edge: tidy-tree-draws.default-draw-edge,
  additional-draw: tidy-tree-draws.default-additional-draw,
  compact: false,
  min-gap: 1,
  default-node-attr: node-attr(),
  text-size: 8pt,
  node-stroke: 0.25pt,
  node-inset: 3pt,
  node-width: auto,
  node-height: auto,
  spacing: (6pt, 15pt),
  edge-corner-radius: none,
  wrapper: false,
  ..args,
) = {
  // if for wrapper use, return the drawing functions directly
  if wrapper {
    return (draw-node, draw-edge, additional-draw)
  }

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

  // collect labels of edges if specified
  let tree-edges = if type(body) == content {
    tidy-tree-edges-from-list(body)
  } else {
    // not supported yet for other types
    tidy-tree-edges-empty(tree)
  }
  // cast a simplified tree of edges into a normalized tree of edges
  let tree-edges = tidy-tree-normalize(tree-edges)

  // collect node attributes for coordinate calculation
  let attrs = tidy-tree-attrs(tree, default-node-attr: default-node-attr)

  // calculate the coordinates of every node
  let (xs, ys, _) = tidy-tree-coords(attrs, min-gap: min-gap, default-node-attr: default-node-attr)

  // support node width and node height settings, which are not supported in `fletcher.diagram` directly
  let size-draw-node = tidy-tree-draws.size-draw-node.with(
    width: node-width,
    height: node-height
  )

  // compose multiple draw-node functions if needed
  let draw-node = tidy-tree-draws.sequential-draw-function(
    size-draw-node, // place size draw-node at the front to make it able to be overridden
    default-draw-node,
    ..(draw-node, ).flatten()
  )
  // compose multiple draw-edge functions if needed
  let draw-edge = tidy-tree-draws.sequential-draw-function(
    default-draw-edge,
    ..(draw-edge, ).flatten()
  )

  // generate elements
  let (elements, nodes) = tidy-tree-elements(tree, xs, ys, tree-edges, draw-node, draw-edge, compact: compact)

  // construct arguments
  let args = arguments(
    node-stroke: node-stroke,
    spacing: spacing,
    node-inset: node-inset,
    edge-corner-radius: edge-corner-radius,
    ..args,
  )

  // compose multiple additional-draw functions if needed
  let additional-draw = tidy-tree-draws.sequential-draw-function(
    default-additional-draw,
    ..(additional-draw, ).flatten()
  )

  // wrap element functions and pass it to addition draw
  let element-func = (
    node: fletcher.node,
    edge: fletcher.edge
  )

  set text(size: text-size)
  fletcher.diagram(..args, ..elements, ..additional-draw(nodes, element-func))
}

/*
  wrap a tree graph function to append additional drawing functions
  - input:
    - `tree-graph-fn`: a base tree graph function to be wrapped, default to `tidy-tree-graph`
    - `draw-node`: a single or an array of functions for drawing a node, default to no additional drawing
      - see `tidy-tree-elements` for the format of every function
    - `draw-edge`: a single or an array of functions for drawing an edge, default to no additional drawing
      - see `tidy-tree-elements` for the format of every function
    - `additional-draw`: a single or an array of functions for drawing additional elements after drawing the tree, default to no additional drawing
      - see `tidy-tree-graph` for the format of every function
  - output:
    - `ret`: a wrapped tree graph function with additional drawing functions
*/
#let tree-graph-wrapper(
  tree-graph-fn: tidy-tree-graph,
  draw-node: none,
  draw-edge: none,
  additional-draw: none,
  
  ..args
) = {
  // get the original drawing functions from tree-graph-fn
  let (draw-node-orig, draw-edge-orig, additional-draw-orig) = tree-graph-fn(
    wrapper: true
  )[]

  tree-graph-fn.with(
    draw-node: tidy-tree-draws.sequential-draw-function(
      ..(
        draw-node-orig,
        if draw-node != none { draw-node } else { () }
      ).flatten(),
    ),
    draw-edge: tidy-tree-draws.sequential-draw-function(
      ..(
        draw-edge-orig, 
        if draw-edge != none { draw-edge } else { () }
      ).flatten(),
    ),
    additional-draw: tidy-tree-draws.sequential-draw-function(
      ..(
        additional-draw-orig, 
        if additional-draw != none { additional-draw } else { () }
      ).flatten(),
    ),

    ..args
  )
}
