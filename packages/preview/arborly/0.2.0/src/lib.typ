/// A function which takes a hierarchy of syntax elements and displays a tree of them.
///
/// -> content
#let tree(
  /// The root node of the syntax tree.
  /// See the examples for its structure.
  /// -> array
  node, 
  /// Draws all words at the bottom in a line, with stems extending down from their parent. It does not function correctly with a non-default min-slope.
  ///
  /// -> bool
  hug-bottom: false, 
  /// The vertical separation of levels of the tree. It may be higher than this if min-slope is set.
  ///
  /// -> float
  min-space-y: 1.0,
  /// The minimum horizontal gap between terminal nodes, which applies even if they are not vertically aligned.
  ///
  /// -> float
  min-gap-x: 0.3,
  /// Sets an approximate lower bound for the slope of the connecting lines. \
  /// Setting it to a non-zero value will change the vertical spacing of the graph. \
  /// 0.2 - 0.5 has worked well for me, but this can be any number.
  ///
  /// -> float
  min-slope: 0.0,
  /// To space tree layers by increments of min-space-y when using a min-slope.
  /// This prevents layers from getting "out of sync" and having words that are slightly out of alignment with each other.
  ///
  /// -> bool
  full-step-y: false,
  /// This accepts one of three strings: "middle", "average", or "smart".
  ///
  /// Middle places a parent label exactly between its outer children's labels (the ones furthest to the left and right)
  ///
  /// Average places it at the average of its children's horizontal positions, which can look better when there are many clumped close together and only one off to the side.
  ///
  /// Smart acts like average, but if there are three children and the second label is sufficiently close to the middle, the parent will "snap" to it.
  ///
  /// -> str
  label-alignment: "middle",
) = context {
  /*
  Utility functions
  */

  // Combined width a node and its children should take up
  let width(node) = {
    if type(node) == array {
      let (label, children) = node
      let child-widths = if type(children) == array {
        children.map(width).sum(default: 0)
      } else {
        measure(children).width.cm() + min-gap-x
      }
      calc.max(child-widths, measure(label).width.cm() + min-gap-x)
    } else {
      measure(node).width.cm() + min-gap-x
    }
  }

  // What offset a label should have from the left extremity of its width in order to be in the halfway position from its children's extremities' labels
  let offset-mid(node) = {
    if type(node) == array {
      let (_, children) = node
      if type(children) == array and children.len() > 0 {
        if children.len() == 1 {
          width(children.at(0)) / 2
        } else {
          let first-offset = offset-mid(children.first())
          let last-offset = width(node) - (width(children.last()) - offset-mid(children.last()))
          (first-offset + last-offset) / 2
        }
      } else {
        width(node) / 2
      }
    } else {
      width(node) / 2
    }
  }

  let offset-avg(node) = {
    if type(node) == array {
      let (_, children) = node
      if type(children) == array and children.len() > 0 {
        let n = children.len()
        children.enumerate().map(((i, child)) => {
          offset-avg(child) + width(child) * (n - i - 1)
        }).sum() / n
      } else {
        width(node) / 2
      }
    } else {
      width(node) / 2
    }
  }

  // Average offset of children, but with one exception:
  // if there are three elements, and the middle one is placed close enough to the midpoint, the label will snap to align with it
  let offset-smart(node) = {
    if type(node) == array {
      let (_, children) = node
      if type(children) == array and children.len() > 0 {
          let n = children.len()
          let average = children.enumerate().map(((i, child)) => {
            offset-smart(child) + width(child) * (n - i - 1)
          }).sum() / n
          if children.len() == 3 {
            let (first, middle, last) = children
            let first-offset = offset-smart(first)
            let last-offset = width(node) - width(last) + offset-smart(last)
            let middle-offset = (first-offset + last-offset) / 2
            let middle-child-offset = width(children.first()) + offset-smart(children.at(1))
            let gap = calc.abs(middle-offset - middle-child-offset)
            if gap < 1 {
              middle-child-offset
            } else {
              average
            } 
          } else {
            average
          }
      } else {
        width(node) / 2
      }
    } else {
      width(node) / 2
    }
  }

  let offset = if label-alignment == "middle" {
    offset-mid
  } else if label-alignment == "average" {
    offset-avg
  } else if label-alignment == "smart" {
    offset-smart
  } else {
    panic("invalid label-alignment value: " + label-alignment)
  }

  // Largest horizontal distance from parent label to child label, used to ensure a minimum line slope when dynamic-row-space is true
  let max-dist-to-child(node) = {
    if type(node) == array {
      let (_, children) = node
      if type(children) == array and children.len() > 0 {
        let left-dist = offset(node) - offset(children.first())
        let right-dist = width(node) - offset(node) - width(children.last()) + offset(children.last())
        calc.max(left-dist, right-dist)
      } else {
        0
      }
    } else {
      0
    }
  }

  // Basic depth of tree checker
  let depth(node) = {
    if type(node) == array {
      let (_, children) = node
      if type(children) == array {
        if children.len() == 0 {
          0
        } else {
          calc.max(..children.map(depth)) + 1
        }
      } else {
        1
      }
    } else {
      0
    }
  }

  let max-depth = if hug-bottom { 
    depth(node) 
  } else {
    none
  }

  // Drawing of the tree
  import "@preview/cetz:0.3.2"
  import cetz.draw: *
  import cetz.vector: add
  let tree-recursive(node, id: (0,), x: 0, y: 0) = {
    let mid = offset(node)
    if type(node) == array {
      // set up for and display parent element
      let parent-width = width(node)
      let (label, children) = node
      let parent = id.map(str).join(",")
      content((x + mid, y), name: parent, {
        set text(bottom-edge: "descender")
        pad(y: 0.5em, label)
      })

      // vertical spacing calculations
      let y-diff = min-space-y
      if min-slope > 0 {
        y-diff = calc.max(y-diff, max-dist-to-child(node) * min-slope + 0.8)
      }
      if full-step-y {
        y-diff = calc.round(y-diff / min-space-y) * min-space-y
      }
      y -= y-diff
    
      if type(children) == array {
        let offset = 0
        for (i, node) in children.enumerate() {
          let wid = width(node)
          let child-id = id
          child-id.push(i)
          let child = child-id.map(str).join(",")
          tree-recursive(node, id: child-id, x: x, y: y)
          line(parent + ".south", child + ".north")
          x += wid
        }
      } else {
        let child = parent + "-c"
        let child-y = if hug-bottom { -max-depth * min-space-y } else { y }
        content((x + mid, child-y), name: child, {
          set text(bottom-edge: "descender")
          pad(y: 0.5em, children)
        })
        line(child, parent)
      }
    } else {
      let parent = id.map(str).join(",")
      content((x + mid, y), name: parent, {
        set text(bottom-edge: "descender")
        pad(y: 0.5em, node)
      })
    }
  }
  cetz.canvas(tree-recursive(node))
}
