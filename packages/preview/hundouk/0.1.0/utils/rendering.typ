#let group-nodes(nodes) = {
  if nodes == none { return () }
  let grouped = ()
  let i = 0
  while i < nodes.len() {
    let node = nodes.at(i)
    if (
      node.type == "character" and i + 1 < nodes.len() and nodes.at(i + 1).type == "connector"
    ) {
      let group-children = (node,)
      i += 1
      while i < nodes.len() {
        let curr = nodes.at(i)
        if curr.type == "connector" {
          group-children.push(curr)
          i += 1
        } else if curr.type == "character" {
          group-children.push(curr)
          if i + 1 < nodes.len() and nodes.at(i + 1).type == "connector" {
            i += 1
          } else {
            i += 1
            break
          }
        } else {
          break
        }
      }
      grouped.push((
        type: "connected-group",
        children: group-children,
        surface: group-children.map(n => n.at("surface", default: "")).join(""),
      ))
    } else {
      grouped.push(node)
      i += 1
    }
  }
  grouped
}
