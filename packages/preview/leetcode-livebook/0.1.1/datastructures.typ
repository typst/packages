// datastructures.typ - Pure data structure definitions
// No external dependencies - this is a leaf module in the DAG

// Linked list with closure-based accessors
// Closures capture the internal nodes dict, avoiding O(n) parameter copying
//
// Usage:
//   let list = linkedlist((1, 2, 3))
//   let curr = list.head
//   while curr != none {
//     let val = (list.get-val)(curr)
//     curr = (list.get-next)(curr)
//   }
//   let all-vals = (list.values)()
//
#let linkedlist(arr) = {
  if arr.len() == 0 {
    return (
      type: "linkedlist",
      head: none,
      get-val: id => none,
      get-next: id => none,
      get-node: id => none,
      values: () => (),
      len: () => 0,
      nodes: (:),
    )
  }

  let nodes = (:)
  for (i, val) in arr.enumerate() {
    let id = str(i)
    let next = if i + 1 < arr.len() { str(i + 1) } else { none }
    nodes.insert(id, (val: val, next: next))
  }

  (
    type: "linkedlist",
    head: "0",
    // Closure accessors - O(1) without copying the whole structure
    get-val: id => if id == none { none } else { nodes.at(id).val },
    get-next: id => if id == none { none } else { nodes.at(id).next },
    get-node: id => if id == none { none } else { nodes.at(id) },
    values: () => nodes.values().map(n => n.val),
    len: () => nodes.len(),
    // Keep nodes for visualization (read-only)
    nodes: nodes,
  )
}

// Binary tree with closure-based accessors
// Flat structure with string ID pointers, similar to linkedlist
//
// Usage:
//   let tree = binarytree((1, 2, 3, 4, 5))
//   let root = tree.root
//   let val = (tree.get-val)(root)
//   let left-id = (tree.get-left)(root)
//   // Modify: tree.nodes.insert(id, (..tree.nodes.at(id), val: new-val))
//
#let binarytree(arr) = {
  let n = arr.len()
  if n == 0 or arr.at(0) == none {
    return (
      type: "binarytree",
      root: none,
      nodes: (:),
      get-val: id => none,
      get-left: id => none,
      get-right: id => none,
      get-next: id => none,
      get-node: id => none,
    )
  }

  let nodes = (:)

  // BFS to build node relationships
  let q = (0,)
  let qh = 0
  let pos = 1

  // Initialize root node (next: none for 116/117 compatibility)
  nodes.insert("0", (val: arr.at(0), left: none, right: none, next: none))

  while qh < q.len() and pos < n {
    let parent = q.at(qh)
    let parent-id = str(parent)
    qh += 1

    let left-id = none
    let right-id = none

    // Left child
    if pos < n {
      if arr.at(pos) != none {
        left-id = str(pos)
        nodes.insert(left-id, (
          val: arr.at(pos),
          left: none,
          right: none,
          next: none,
        ))
        q.push(pos)
      }
      pos += 1
    }

    // Right child
    if pos < n {
      if arr.at(pos) != none {
        right-id = str(pos)
        nodes.insert(right-id, (
          val: arr.at(pos),
          left: none,
          right: none,
          next: none,
        ))
        q.push(pos)
      }
      pos += 1
    }

    // Update parent's left/right pointers (preserve next)
    let parent-node = nodes.at(parent-id)
    nodes.insert(
      parent-id,
      (
        val: parent-node.val,
        left: left-id,
        right: right-id,
        next: parent-node.next,
      ),
    )
  }

  (
    type: "binarytree",
    root: "0",
    nodes: nodes,
    // Closure accessors - O(1) without copying the whole structure
    get-val: id => if id == none { none } else { nodes.at(id).val },
    get-left: id => if id == none { none } else { nodes.at(id).left },
    get-right: id => if id == none { none } else { nodes.at(id).right },
    get-next: id => if id == none { none } else { nodes.at(id).next },
    get-node: id => if id == none { none } else { nodes.at(id) },
  )
}

// Graph with closure-based accessors
// Supports directed/undirected and weighted/unweighted graphs
//
// Usage:
//   let g = graph(4, ((0, 1), (1, 2), (2, 3)))  // undirected
//   let g = graph(4, ((0, 1), (1, 2)), directed: true)  // directed
//   let g = graph(3, ((0, 1, 5), (1, 2, 3)), weighted: true)  // weighted
//   let neighbors = (g.get-neighbors)("0")  // => ("1",)
//   let edges = (g.get-edges)("0")  // => ((to: "1", weight: 1),)
//
#let graph(n, edges, directed: false, weighted: false) = {
  if n == 0 {
    return (
      type: "graph",
      directed: directed,
      weighted: weighted,
      n: 0,
      nodes: (:),
      adj: (:),
      get-neighbors: id => (),
      get-edges: id => (),
      get-node: id => none,
    )
  }

  // Initialize nodes and adjacency lists
  let nodes = (:)
  let adj = (:)
  for i in range(n) {
    let id = str(i)
    nodes.insert(id, (val: i))
    adj.insert(id, ())
  }

  // Add edges
  for edge in edges {
    let u = str(edge.at(0))
    let v = str(edge.at(1))
    let weight = if weighted { edge.at(2) } else { 1 }

    adj.at(u).push((to: v, weight: weight))
    if not directed {
      adj.at(v).push((to: u, weight: weight))
    }
  }

  (
    type: "graph",
    directed: directed,
    weighted: weighted,
    n: n,
    nodes: nodes,
    adj: adj,
    // Closure accessors
    get-neighbors: id => if id == none { () } else {
      adj.at(id).map(e => e.to)
    },
    get-edges: id => if id == none { () } else { adj.at(id) },
    get-node: id => if id == none { none } else { nodes.at(id) },
  )
}

// Create graph from adjacency list (for problems like 785)
// Input: adj-list where adj-list[i] is array of neighbors of node i
//
// Usage:
//   let g = graph-from-adj(((1, 2, 3), (0, 2), (0, 1, 3), (0, 2)))
//   // Creates undirected graph with 4 nodes
//
#let graph-from-adj(adj-list) = {
  let n = adj-list.len()
  if n == 0 {
    return graph(0, ())
  }

  // Convert adjacency list to edge list (avoid duplicates for undirected)
  let edges = ()
  let seen = (:)

  for (u, neighbors) in adj-list.enumerate() {
    for v in neighbors {
      // Only add edge once (u < v) to avoid duplicates
      let key = if u < v { str(u) + "-" + str(v) } else {
        str(v) + "-" + str(u)
      }
      if key not in seen {
        seen.insert(key, true)
        edges.push((u, v))
      }
    }
  }

  graph(n, edges, directed: false)
}
