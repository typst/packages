// display.typ - Display and visualization logic
// Depends on: datastructures, utils, visualize

#import "visualize.typ": (
  visualize-binarytree, visualize-graph, visualize-linkedlist,
)

// Display thresholds - avoid magic numbers
#let MAX-ARRAY-DISPLAY = 210
#let MAX-ARRAY-PREVIEW = 100
#let MAX-STRING-DISPLAY = 1050
#let MAX-STRING-PREVIEW = 500
#let MAX-LINKEDLIST-VISUALIZE = 8

// Main display function with integrated type dispatch
// Note: chessboard display is now handled via custom-output-display per problem
#let display(value) = {
  if type(value) == array {
    if value.len() == 0 {
      return [[]]
    }
    if value.len() > MAX-ARRAY-DISPLAY {
      let start = value.slice(0, MAX-ARRAY-PREVIEW)
      let end = value.slice(-MAX-ARRAY-PREVIEW)
      let omitted = value.len() - 2 * MAX-ARRAY-PREVIEW
      return [[#start.map(x => display(x)).join(", "), $...$ #omitted items omitted $...$, #end.map(x => display(x)).join(", ")]]
    }
    [[#value.map(x => display(x)).join(", ")]]
  } else if type(value) == dictionary {
    let t = value.at("type", default: none)
    if t == "linkedlist" {
      // Linked list display - use closure method
      let vals = (value.values)()
      if vals.len() <= MAX-LINKEDLIST-VISUALIZE {
        visualize-linkedlist(value)
      } else {
        vals.map(v => display(v)).join($->$)
      }
    } else if t == "binarytree" {
      // Binary tree display
      // Auto-detect if tree has populated next pointers
      let has-next = value
        .nodes
        .values()
        .any(n => n.at("next", default: none) != none)
      visualize-binarytree(value, show-nulls: false, show-next: has-next)
    } else if t == "graph" {
      // Graph display
      visualize-graph(value)
    } else {
      repr(value)
    }
  } else if type(value) == str {
    // String display logic
    if value.len() > MAX-STRING-DISPLAY {
      let start = value.slice(0, MAX-STRING-PREVIEW)
      let end = value.slice(-MAX-STRING-PREVIEW)
      let omitted = value.len() - 2 * MAX-STRING-PREVIEW
      return display(
        start + " [..." + str(omitted) + " characters omitted ...] " + end,
      )
    }
    "\"" + value.codepoints().join(sym.zws) + "\""
  } else {
    repr(value)
  }
}
